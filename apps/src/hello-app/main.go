package main

import (
	"fmt"
	"log"
	"net/http"
)

func helloHandler(w http.ResponseWriter, r *http.Request) {
	fmt.Fprintf(w, "Hello from the backend :D")
}

func main() {
	http.HandleFunc("GET /", helloHandler)
	log.Println("App starts")

	log.Fatal(http.ListenAndServe(":3000", nil))
}
