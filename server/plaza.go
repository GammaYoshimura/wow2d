package main

import (
	"encoding/json"
	"fmt"
	"os"
)

type cell [2]int

type position struct {
	X float64 `json:"x"`
	Y float64 `json:"y"`
}

type plazaLayout struct {
	ID          string          `json:"id"`
	TileSize    int             `json:"tile_size"`
	Origin      cell            `json:"origin"`
	Size        cell            `json:"size"`
	Landmarks   map[string]cell `json:"landmarks"`
	SpawnPoints []cell          `json:"spawn_points"`
	SolidCells  []cell          `json:"solid_cells"`
}

func loadPlaza(path string) (plazaLayout, error) {
	data, err := os.ReadFile(path)
	if err != nil {
		return plazaLayout{}, err
	}
	var layout plazaLayout
	if err := json.Unmarshal(data, &layout); err != nil {
		return plazaLayout{}, fmt.Errorf("decode plaza %s: %w", path, err)
	}
	if err := layout.validate(); err != nil {
		return plazaLayout{}, fmt.Errorf("validate plaza %s: %w", path, err)
	}
	return layout, nil
}

func (p plazaLayout) validate() error {
	if p.ID == "" || p.TileSize < 1 || p.Size[0] < 1 || p.Size[1] < 1 || len(p.SpawnPoints) == 0 {
		return fmt.Errorf("map needs an ID, positive dimensions and at least one spawn")
	}
	solids := make(map[cell]bool, len(p.SolidCells))
	for _, point := range p.SolidCells {
		if !p.contains(point) || solids[point] {
			return fmt.Errorf("invalid or duplicate solid cell %v", point)
		}
		solids[point] = true
	}
	for _, point := range p.SpawnPoints {
		if !p.contains(point) || solids[point] {
			return fmt.Errorf("invalid spawn cell %v", point)
		}
	}
	for name, point := range p.Landmarks {
		if !p.contains(point) {
			return fmt.Errorf("invalid landmark %s at %v", name, point)
		}
	}
	return nil
}

func (p plazaLayout) contains(point cell) bool {
	return point[0] >= 0 && point[0] < p.Size[0] && point[1] >= 0 && point[1] < p.Size[1]
}

func (p plazaLayout) center(point cell) position {
	pitch := float64(p.TileSize)
	return position{
		X: float64(p.Origin[0]) + (float64(point[0])+0.5)*pitch,
		Y: float64(p.Origin[1]) + (float64(point[1])+0.5)*pitch,
	}
}
