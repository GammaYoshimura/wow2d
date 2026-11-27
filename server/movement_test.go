package main

import (
	"math"
	"testing"
	"time"
)

func TestMovementSpeedAndCollisions(t *testing.T) {
	layout := testPlaza(t)
	start := position{220, 220}
	for _, direction := range []position{{1, 0}, {1, 1}, {0, -1}} {
		got := layout.move(start, direction)
		if distance := math.Hypot(got.X-start.X, got.Y-start.Y); math.Abs(distance-7.2) > 0.001 {
			t.Fatalf("tick travelled %.3f with direction %+v", distance, direction)
		}
	}
	west := position{140, 320}
	for range 100 {
		west = layout.move(west, position{-1, 0})
	}
	if west != (position{74, 320}) {
		t.Fatalf("west fence: %+v", west)
	}

	northGate := layout.center(layout.Landmarks["north_gate"])
	for range 100 {
		northGate = layout.move(northGate, position{0, -1})
	}
	if northGate.Y != actorRadius {
		t.Fatalf("gate should allow walking to the map edge: %+v", northGate)
	}

	well := position{496, 550}
	for range 20 {
		well = layout.move(well, position{0, -1})
	}
	if well != (position{496, 522}) {
		t.Fatalf("well must block movement: %+v", well)
	}
}

func TestGuestStopsWhenInputIsReleasedOrExpires(t *testing.T) {
	g := newGame(testPlaza(t))
	start := position{220, 220}
	player := &guest{position: start, inbox: make(chan movementInput, 1), outbox: make(chan movementSnapshot, 1)}
	g.guests[player] = struct{}{}
	now := time.Now()

	sendLatest(player.inbox, movementInput{Sequence: 1, Direction: &position{1, 0}, received: now})
	g.step(now)
	moved := player.position
	if moved.X <= start.X {
		t.Fatal("pressed direction did not move")
	}
	sendLatest(player.inbox, movementInput{Sequence: 2, Direction: &position{}, received: now})
	g.step(now.Add(tickInterval))
	if snap := <-player.outbox; snap.Sequence != 2 || snap.Position != moved || snap.Tick != 2 {
		t.Fatalf("release snapshot: %+v", snap)
	}

	sendLatest(player.inbox, movementInput{Sequence: 3, Direction: &position{1, 0}, received: now})
	g.step(now.Add(inputTimeout))
	if player.position != moved {
		t.Fatalf("expired input moved the guest: %+v", player.position)
	}
}
