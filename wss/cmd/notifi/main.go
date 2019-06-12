package main

import (
	"encoding/json"
	"fmt"
	"github.com/gorilla/schema"
	"github.com/gorilla/websocket"
	"models"
	"net/http"
	"os"
	"validator"
)

var upgrader = websocket.Upgrader{
	ReadBufferSize:  1024,
	WriteBufferSize: 1024,
}
var decoder = schema.NewDecoder()

var server_key = os.Getenv("server_key")

var clients = make(map[string]*websocket.Conn)

func WSHandler(w http.ResponseWriter, r *http.Request) {
	var u models.User

	if r.Method != "GET" {
		http.Error(w, "Method not allowed", 405)
		return
	}

	if r.Header.Get("Sec-Key") != server_key {
		http.Error(w, "Invalid key", 406)
		return
	}

	err := decoder.Decode(&u, r.Header)
	if err != nil {
		http.Error(w, "Invalid form data", 406)
		return
	}

	db, err := models.DBConn(os.Getenv("db"))
	if err != nil {
		panic(err.Error())
	}
	defer db.Close()

	err = models.SetLastLogin(db, u)
	if err != nil {
		panic(err.Error())
	}

	wsconn, _ := upgrader.Upgrade(w, r, nil)
	clients["test"] = wsconn // add conn to clients
}

func CodeHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method != "POST" {
		http.Error(w, "Method not allowed", 405)
		return
	}

	if r.Header.Get("Sec-Key") != server_key {
		fmt.Println("Invalid key ?", r.Header.Get("Sec-Key"))
		http.Error(w, "Invalid form data", 406)
		return
	}

	err := r.ParseForm()
	if err != nil {
		http.Error(w, "Invalid form data", 406)
		return
	}

	// store POST data in struct
	PostUser := models.User{
		Credentials: models.Credentials{
			Value: r.Form.Get("current_credentials"),
			Key:   r.Form.Get("current_key"),
		},
		UUID: r.Form.Get("UUID"),
	}

	if !validator.IsValidUUID(PostUser.UUID) {
		http.Error(w, "Invalid form data", 406)
		return
	}

	db, err := models.DBConn(os.Getenv("db"))
	if err != nil {
		panic(err.Error())
	}
	defer db.Close()

	creds, err := models.CreateUser(db, PostUser)
	if err != nil {
		println(err)
	}

	c, err := json.Marshal(creds)
	_, _ = w.Write(c)
}

func APIHandler(w http.ResponseWriter, r *http.Request) {
	var n models.Notification

	err := r.ParseForm()
	if err != nil {
		http.Error(w, "Invalid form data", 406)
		return
	}

	err = decoder.Decode(&n, r.PostForm)
	if err != nil {
		http.Error(w, "Invalid form data", 406)
		return
	}

	err = models.NotificationValidation(&n)
	if err != nil {
		http.Error(w, err.Error(), 407)
		return
	}

	db, err := models.DBConn(os.Getenv("db"))
	if err != nil {
		panic(err.Error())
	}
	defer db.Close()

	err = models.StoreNotification(db, n)
	if err != nil {
		http.Error(w, err.Error(), 408)
		return
	}
}

func main() {
	http.HandleFunc("/ws", WSHandler)
	http.HandleFunc("/code", CodeHandler)
	http.HandleFunc("/api", APIHandler)
	_ = http.ListenAndServe(":8123", nil)
}
