package main

import (
	"fmt"
	"net/http"
	"regexp"

	"github.com/gorilla/websocket"
)

var upgrader = websocket.Upgrader{
	ReadBufferSize:  1024,
	WriteBufferSize: 1024,
}

var clients = make(map[string]*websocket.Conn)
var server_key = "cfFL8srATWziHRCdZU82SaaXqo8YhbV2MrTLA8LyTzsSdhBt1LEd5cGVIj1PNsAxv9PDtssz0Ao8S62d1u3FCiYJXQbVf9eIpWNR"

func IsValidUUID(uuid string) bool {
	r := regexp.MustCompile("^[a-fA-F0-9]{8}-[a-fA-F0-9]{4}-4[a-fA-F0-9]{3}-[8|9|aA|bB][a-fA-F0-9]{3}-[a-fA-F0-9]{12}$")
	return r.MatchString(uuid)
}

func main() {

	http.HandleFunc("/ws", func(w http.ResponseWriter, r *http.Request) {
		// validate request
		if r.Method != "GET" {
			http.Error(w, "Method not allowed", 405)
			return
		}

		if r.Header.Get("Sec-Key") != server_key {
			http.Error(w, "Invalid key", 406)
			return
		}

		UUID := r.Header.Get("UUID")
		if !IsValidUUID(UUID){
			http.Error(w, "Invalid key", 407)
			return
		}

		credentials := r.Header.Get("credentials")
		if len(credentials) != 25 {
			http.Error(w, "Invalid credentials", 408)
			return
		}
		credential_key := r.Header.Get("credential_key")
		version := r.Header.Get("version")

		db, err := DBConn("root:@/notifi")
		if err != nil {
			panic(err.Error())
		}

		err = SetLastLogin(db, version, credentials, credential_key, UUID)
		if err != nil {
			panic(err.Error())
		}

		conn, _ := upgrader.Upgrade(w, r, nil)
		clients["test"] = conn // add conn to clients

		for {
			// Read message from browser
			msgType, msg, err := conn.ReadMessage()
			if err != nil {
				return
			}

			fmt.Printf("%s - %s sent: %s\n", string(msgType), conn.RemoteAddr(), string(msg))
		}
	})

	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		for msg := range clients {
			_ = clients[msg].WriteMessage(1, []byte(string(msg)))
		}
	})

	_ = http.ListenAndServe(":8123", nil)
}
