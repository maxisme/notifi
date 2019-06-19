package main

import (
	"./model"
	"./validator"
	"encoding/json"
	"github.com/didip/tollbooth"
	"github.com/didip/tollbooth/limiter"
	"github.com/gorilla/schema"
	"github.com/gorilla/websocket"
	"log"
	"net/http"
	"os"
	"time"
)

var upgrader = websocket.Upgrader{
	ReadBufferSize:  1024,
	WriteBufferSize: 1024,
}
var decoder = schema.NewDecoder()

var server_key = os.Getenv("server_key")
var clients = make(map[string]*websocket.Conn)

func WSHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method != "GET" {
		http.Error(w, "Method not allowed", 405)
		return
	}

	if r.Header.Get("Sec-Key") != server_key {
		http.Error(w, "Invalid key", 406)
		return
	}

	c := model.Credentials{
		Value: r.Header.Get("Credentials"),
		Key:   r.Header.Get("Credential_key"),
	}
	u := model.User{
		Credentials: c,
		UUID:        r.Header.Get("Uuid"),
		AppVersion:  r.Header.Get("Version"),
	}

	// validate inputs
	if !validator.IsValidUUID(r.Header.Get("Uuid")) {
		http.Error(w, "Invalid UUID", 408)
		return
	} else if !validator.IsValidVersion(r.Header.Get("Version")) {
		http.Error(w, "Invalid Version", 409)
		return
	}

	db, err := model.DBConn(os.Getenv("db"))
	if err != nil {
		log.Panicln(err.Error())
	}
	defer db.Close()

	if !model.VerifyUser(db, u) {
		http.Error(w, "Invalid key", 406)
		return
	}

	if err := model.SetLastLogin(db, u); err != nil {
		http.Error(w, "Invalid key", 406)
	}

	wsconn, _ := upgrader.Upgrade(w, r, nil)
	clients[u.Credentials.Value] = wsconn // add conn to clients

	log.Println("connected: ", u.Credentials.Value)

	notifications, _ := model.FetchAllNotifications(db, u.Credentials.Value)
	if len(notifications) > 0 {
		bytes, _ := json.Marshal(notifications)
		if err := wsconn.WriteMessage(websocket.TextMessage, bytes); err != nil {
			log.Println(err.Error())
		}
	}

	for {
		_, message, err := wsconn.ReadMessage()
		if err != nil {
			log.Println(err.Error())
			break
		}

		if err = model.DeleteNotifications(db, u.Credentials.Value, string(message)); err != nil {
			log.Println(err.Error())
		}
	}

	delete(clients, u.Credentials.Value)
	log.Println("disconnected: ", u.Credentials.Value)

	// close connection
	if err := model.Logout(db, u); err != nil {
		log.Println(err.Error())
	}
}

func CredentialHandler(w http.ResponseWriter, r *http.Request) {
	if r.Method != "POST" {
		http.Error(w, "Method not allowed", 405)
		return
	}

	if r.Header.Get("Sec-Key") != server_key {
		log.Println("Invalid key ?", r.Header.Get("Sec-Key"))
		http.Error(w, "Invalid form data", 406)
		return
	}

	err := r.ParseForm()
	if err != nil {
		http.Error(w, "Invalid form data", 406)
		return
	}

	// store POST data in struct
	PostUser := model.User{
		Credentials: model.Credentials{
			Value: r.Form.Get("current_credentials"),
			Key:   r.Form.Get("current_key"),
		},
		UUID: r.Form.Get("UUID"),
	}

	if !validator.IsValidUUID(PostUser.UUID) {
		http.Error(w, "Invalid form data", 406)
		return
	}

	db, err := model.DBConn(os.Getenv("db"))
	if err != nil {
		panic(err.Error())
	}
	defer db.Close()

	creds, err := model.CreateUser(db, PostUser)
	if err != nil {
		println(err.Error())
	}

	c, err := json.Marshal(creds)
	_, _ = w.Write(c)
}

func APIHandler(w http.ResponseWriter, r *http.Request) {
	var n model.Notification

	if err := r.ParseForm(); err != nil {
		http.Error(w, "Invalid form data", 406)
		return
	}

	if err := decoder.Decode(&n, r.Form); err != nil {
		http.Error(w, "Invalid form data", 406)
		return
	}

	if err := model.NotificationValidation(&n); err != nil {
		http.Error(w, err.Error(), 407)
		return
	}

	db, err := model.DBConn(os.Getenv("db"))
	if err != nil {
		panic(err.Error())
	}
	defer db.Close()

	// send notification to client
	if val, ok := clients[n.Credentials]; ok {
		t := time.Now()
		ts := t.Format("2006-01-02 15:04:05") // arbitrary values
		n.Time = ts
		n.Credentials = ""

		bytes, _ := json.Marshal([]model.Notification{n}) // pass as array

		if err = val.WriteMessage(websocket.TextMessage, bytes); err != nil {
			log.Println(err.Error())
		} else {
			return // skip storing the notification
		}
	}

	if err = model.StoreNotification(db, n); err != nil {
		log.Println(err.Error())
	}
}

var lmt = tollbooth.NewLimiter(1, &limiter.ExpirableOptions{DefaultExpirationTTL: time.Hour}).SetIPLookups([]string{
	"RemoteAddr", "X-Forwarded-For", "X-Real-IP",
})

func main() {
	http.Handle("/ws", tollbooth.LimitFuncHandler(lmt, WSHandler))
	http.Handle("/code", tollbooth.LimitFuncHandler(lmt, CredentialHandler))
	http.Handle("/api", tollbooth.LimitFuncHandler(lmt, APIHandler))
	err := http.ListenAndServe(":8123", nil)
	if err != nil {
		panic(err.Error())
	}
}
