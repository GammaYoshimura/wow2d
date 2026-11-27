package main

import (
	"math"
	"time"
)

const (
	moveSpeed     = 144.0
	actorRadius   = 10.0
	inputTimeout  = 350 * time.Millisecond
	snapshotEvery = 2
)

type movementInput struct {
	Type      string    `json:"type"`
	Sequence  uint64    `json:"sequence"`
	Direction *position `json:"direction"`
	received  time.Time
}

type movementSnapshot struct {
	Type     string   `json:"type"`
	Tick     int64    `json:"tick"`
	Sequence uint64   `json:"sequence"`
	Position position `json:"position"`
}

type guest struct {
	position position
	input    movementInput
	inbox    chan movementInput
	outbox   chan movementSnapshot
}

func (g *game) step(now time.Time) {
	g.mu.Lock()
	defer g.mu.Unlock()
	g.tick++
	for player := range g.guests {
		select {
		case player.input = <-player.inbox:
		default:
		}
		if player.input.Direction != nil && now.Sub(player.input.received) < inputTimeout {
			player.position = g.layout.move(player.position, *player.input.Direction)
		}
		if g.tick%snapshotEvery == 0 {
			sendLatest(player.outbox, movementSnapshot{"position", g.tick, player.input.Sequence, player.position})
		}
	}
}

// Each mailbox has one producer. Retaining only the newest state bounds the
// backlog when input arrives in bursts or a connection reads slowly.
func sendLatest[T any](mailbox chan T, value T) {
	select {
	case <-mailbox:
	default:
	}
	mailbox <- value
}

func (p plazaLayout) move(at, direction position) position {
	x := clamp(direction.X, -1, 1)
	y := clamp(direction.Y, -1, 1)
	step := moveSpeed * tickInterval.Seconds() / math.Max(1, math.Hypot(x, y))
	at.X = p.moveAxis(at.X, at.Y, x*step, 0)
	at.Y = p.moveAxis(at.Y, at.X, y*step, 1)
	return at
}

func (p plazaLayout) moveAxis(along, across, delta float64, axis int) float64 {
	if delta == 0 {
		return along
	}
	origin := float64(p.Origin[axis])
	pitch := float64(p.TileSize)
	end := clamp(along+delta, origin+actorRadius, origin+float64(p.Size[axis])*pitch-actorRadius)
	other := 1 - axis
	for _, tile := range p.SolidCells {
		edge := float64(p.Origin[other]) + float64(tile[other])*pitch
		distance := math.Abs(across - clamp(across, edge, edge+pitch))
		if distance >= actorRadius {
			continue
		}
		extent := math.Sqrt(actorRadius*actorRadius - distance*distance)
		near := origin + float64(tile[axis])*pitch - extent
		far := near + pitch + 2*extent
		if delta > 0 && along <= near && end > near {
			end = near
		}
		if delta < 0 && along >= far && end < far {
			end = far
		}
	}
	return end
}

func clamp(value, lower, upper float64) float64 {
	return max(lower, min(value, upper))
}
