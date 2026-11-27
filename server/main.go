package main

import (
	"flag"
	"log"
	"net/http"
	"time"
)

func main() {
	address := flag.String("listen", "127.0.0.1:8080", "HTTP listen address")
	mapPath := flag.String("map", "../content/plaza_v1.json", "Path to the plaza layout")
	flag.Parse()

	layout, err := loadPlaza(*mapPath)
	if err != nil {
		log.Fatal(err)
	}
	server := &http.Server{
		Addr:              *address,
		Handler:           newGame(layout).routes(),
		ReadHeaderTimeout: 5 * time.Second,
	}
	log.Printf("plaza=%s listen=%s", layout.ID, server.Addr)
	log.Fatal(server.ListenAndServe())
}
