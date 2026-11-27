package main

import (
	"context"
	"net/http/httptest"
	"strings"
	"testing"
	"time"

	"github.com/coder/websocket"
	"github.com/coder/websocket/wsjson"
)

func testPlaza(t *testing.T) plazaLayout {
	t.Helper()
	layout, err := loadPlaza("../content/plaza_v1.json")
	if err != nil {
		t.Fatal(err)
	}
	return layout
}

func TestGuestJoinUsesServerSpawnsAndRejectsMismatches(t *testing.T) {
	layout := testPlaza(t)
	server := httptest.NewServer(newGame(layout).routes())
	defer server.Close()
	ctx, cancel := context.WithTimeout(t.Context(), 5*time.Second)
	defer cancel()
	connect := func(request hello) joinReply {
		t.Helper()
		url := "ws" + strings.TrimPrefix(server.URL, "http") + "/game"
		conn, _, err := websocket.Dial(ctx, url, nil)
		if err != nil {
			t.Fatal(err)
		}
		t.Cleanup(func() { conn.CloseNow() })
		if err := wsjson.Write(ctx, conn, request); err != nil {
			t.Fatal(err)
		}
		var reply joinReply
		if err := wsjson.Read(ctx, conn, &reply); err != nil {
			t.Fatal(err)
		}
		return reply
	}

	for _, test := range []struct {
		request hello
		code    string
	}{
		{hello{"hello", protocolVersion, "old"}, "map_mismatch"},
		{hello{"hello", protocolVersion + 1, layout.ID}, "protocol_mismatch"},
	} {
		reply := connect(test.request)
		if reply.Type != "error" || reply.Code != test.code {
			t.Fatalf("unexpected error reply: %+v", reply)
		}
	}

	request := hello{"hello", protocolVersion, layout.ID}
	first, second := connect(request), connect(request)
	for i, reply := range []joinReply{first, second} {
		want := layout.center(layout.SpawnPoints[i])
		if reply.Type != "welcome" || reply.EntityID == "" || reply.Zone != zoneID ||
			reply.MapRevision != layout.ID || reply.Protocol != protocolVersion || reply.Spawn != want {
			t.Fatalf("welcome %d: %+v, expected spawn %+v", i, reply, want)
		}
	}
	if first.EntityID == second.EntityID || second.Tick < first.Tick {
		t.Fatalf("unexpected session identities or ticks: %+v, %+v", first, second)
	}
}
