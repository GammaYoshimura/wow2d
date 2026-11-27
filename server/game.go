package main

import (
	"context"
	"fmt"
	"net/http"
	"sync"
	"sync/atomic"
	"time"

	"github.com/coder/websocket"
	"github.com/coder/websocket/wsjson"
)

const (
	protocolVersion = 2
	zoneID          = "zone.vado"
	tickInterval    = time.Second / 20
	handshakeLimit  = 5 * time.Second
)

type game struct {
	layout      plazaLayout
	mu          sync.Mutex
	tick        int64
	guests      map[*guest]struct{}
	nextID      atomic.Uint64
	connections chan struct{}
}

type hello struct {
	Type        string `json:"type"`
	Protocol    int    `json:"protocol"`
	MapRevision string `json:"map_revision"`
}

type joinReply struct {
	Type        string   `json:"type"`
	Code        string   `json:"code,omitempty"`
	Protocol    int      `json:"protocol,omitempty"`
	EntityID    string   `json:"entity_id,omitempty"`
	Zone        string   `json:"zone,omitempty"`
	MapRevision string   `json:"map_revision,omitempty"`
	Tick        int64    `json:"tick"`
	Spawn       position `json:"spawn"`
}

func newGame(layout plazaLayout) *game {
	return &game{
		layout:      layout,
		guests:      make(map[*guest]struct{}),
		connections: make(chan struct{}, 64),
	}
}

func (g *game) routes() http.Handler {
	mux := http.NewServeMux()
	mux.HandleFunc("GET /healthz", func(w http.ResponseWriter, _ *http.Request) {
		w.WriteHeader(http.StatusNoContent)
	})
	mux.HandleFunc("GET /game", g.join)
	return mux
}

func (g *game) join(w http.ResponseWriter, r *http.Request) {
	select {
	case g.connections <- struct{}{}:
		defer func() { <-g.connections }()
	default:
		http.Error(w, "plaza is full", http.StatusServiceUnavailable)
		return
	}
	conn, err := websocket.Accept(w, r, nil)
	if err != nil {
		return
	}
	defer conn.CloseNow()
	conn.SetReadLimit(2048)

	ctx, cancel := context.WithTimeout(r.Context(), handshakeLimit)
	defer cancel()
	var request hello
	if err := wsjson.Read(ctx, conn, &request); err != nil {
		return
	}

	reply := joinReply{Type: "error", Protocol: protocolVersion, MapRevision: g.layout.ID}
	switch {
	case request.Type != "hello":
		reply.Code = "expected_hello"
	case request.Protocol != protocolVersion:
		reply.Code = "protocol_mismatch"
	case request.MapRevision != g.layout.ID:
		reply.Code = "map_mismatch"
	default:
		id := g.nextID.Add(1)
		spawn := g.layout.SpawnPoints[(id-1)%uint64(len(g.layout.SpawnPoints))]
		reply.Type = "welcome"
		reply.EntityID = fmt.Sprintf("guest-%d", id)
		reply.Zone = zoneID
		g.mu.Lock()
		reply.Tick = g.tick
		g.mu.Unlock()
		reply.Spawn = g.layout.center(spawn)
	}

	if err := wsjson.Write(ctx, conn, reply); err != nil {
		return
	}
	cancel()
	if reply.Type == "error" {
		conn.Close(websocket.StatusPolicyViolation, reply.Code)
		return
	}

	player := &guest{
		position: reply.Spawn,
		inbox:    make(chan movementInput, 1),
		outbox:   make(chan movementSnapshot, 1),
	}
	g.mu.Lock()
	g.guests[player] = struct{}{}
	g.mu.Unlock()
	defer func() {
		g.mu.Lock()
		delete(g.guests, player)
		g.mu.Unlock()
	}()
	play(r.Context(), conn, player)
}

func (g *game) run(ctx context.Context) {
	ticker := time.NewTicker(tickInterval)
	defer ticker.Stop()
	for {
		select {
		case <-ctx.Done():
			return
		case now := <-ticker.C:
			g.step(now)
		}
	}
}

func play(parent context.Context, conn *websocket.Conn, player *guest) {
	ctx, cancel := context.WithCancel(parent)
	defer cancel()
	go func() {
		defer cancel()
		var lastSequence uint64
		for {
			var input movementInput
			if err := wsjson.Read(ctx, conn, &input); err != nil {
				return
			}
			if input.Type != "move" || input.Direction == nil || input.Sequence <= lastSequence {
				continue
			}
			lastSequence = input.Sequence
			input.received = time.Now()
			sendLatest(player.inbox, input)
		}
	}()
	for {
		select {
		case <-ctx.Done():
			return
		case snapshot := <-player.outbox:
			writeCtx, done := context.WithTimeout(ctx, 2*time.Second)
			err := wsjson.Write(writeCtx, conn, snapshot)
			done()
			if err != nil {
				return
			}
		}
	}
}
