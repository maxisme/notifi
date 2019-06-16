package main

import (
	"crypt"
	"encoding/json"
	"github.com/google/uuid"
	"github.com/gorilla/websocket"
	"io/ioutil"
	"math/rand"
	"models"
	"net/http"
	"net/http/httptest"
	"net/url"
	"os"
	"strconv"
	"strings"
	"testing"
	"time"
)

/////////////
// helpers //
/////////////
func PostRequest(url string, form url.Values, handler http.HandlerFunc) *httptest.ResponseRecorder {
	req, _ := http.NewRequest("POST", url, strings.NewReader(form.Encode()))
	req.Header.Add("Content-Type", "application/x-www-form-urlencoded")
	req.Header.Add("Sec-Key", os.Getenv("server_key"))

	rr := httptest.NewRecorder()
	handler.ServeHTTP(rr, req)
	return rr
}

func GenUser() (models.Credentials, url.Values) {
	UUID, _ := uuid.NewRandom()
	form := url.Values{}
	form.Add("UUID", UUID.String())
	rr := PostRequest("/code", form, http.HandlerFunc(CredentialHandler))
	var creds models.Credentials
	_ = json.Unmarshal(rr.Body.Bytes(), &creds)
	return creds, form
}

func ConnectWSS(creds models.Credentials, form url.Values) (*httptest.Server, *websocket.Conn, error) {
	s := httptest.NewServer(http.HandlerFunc(WSHandler))

	// socket connection header values based on generated user
	wsheader := http.Header{}
	wsheader.Add("Sec-Key", os.Getenv("server_key"))
	wsheader.Add("Credentials", creds.Value)
	wsheader.Add("Credential_key", creds.Key)
	wsheader.Add("Uuid", form.Get("UUID"))
	wsheader.Add("Version", "1.0")

	ws, req, err := websocket.DefaultDialer.Dial("ws"+strings.TrimPrefix(s.URL, "http"), wsheader)
	println(req.StatusCode)
	return s, ws, err
}

func SendNotification(credentials string, title string) {
	nform := url.Values{}
	nform.Add("credentials", credentials)
	nform.Add("title", title)
	req, _ := http.NewRequest("GET", "/api?"+nform.Encode(), nil)
	rr := httptest.NewRecorder()
	http.HandlerFunc(APIHandler).ServeHTTP(rr, req)
}

////////////////////
// TEST FUNCTIONS //
////////////////////
func init() {
	// initialise db
	db, err := models.DBConn("root:@tcp(127.0.0.1:3306)/?multiStatements=True")
	if err != nil {
		panic(err.Error())
	}
	defer db.Close()

	schema, _ := ioutil.ReadFile("../internal/schema.sql")
	_, err = db.Exec("DROP DATABASE notifi_test; CREATE DATABASE notifi_test; USE notifi_test;" + string(schema))

	if err != nil {
		panic(err.Error())
	}
}

func TestCreateNewUser(t *testing.T) {
	rand.Seed(time.Now().UTC().UnixNano())

	// create new user
	var creds, form = GenUser()
	if len(creds.Key) == 0 || len(creds.Value) == 0 {
		t.Errorf("Error fetching new credentials")
	}

	// update user credentials
	r := PostRequest("", form, http.HandlerFunc(CredentialHandler))
	var creds2 models.Credentials
	_ = json.Unmarshal(r.Body.Bytes(), &creds2)
	if len(creds2.Key) == 0 && creds.Value == creds2.Value {
		t.Errorf("Error fetching new credentials")
	}
}

func TestAddNotification(t *testing.T) {
	var creds, _ = GenUser()

	form := url.Values{}
	form.Add("credentials", creds.Value)
	form.Add("title", crypt.RandomString(10))

	// POST test
	r := PostRequest("", form, http.HandlerFunc(APIHandler))
	if status := r.Code; status != 200 {
		t.Errorf("handler returned wrong status code: got %v want %v", status, 200)
	}

	// GET test
	req, err := http.NewRequest("GET", "/api?"+form.Encode(), nil)
	if err != nil {
		t.Fatalf(err.Error())
	}
	rr := httptest.NewRecorder()
	http.HandlerFunc(APIHandler).ServeHTTP(rr, req)
	if status := rr.Code; status != 200 {
		t.Errorf("handler returned wrong status code: got %v want %v", status, 200)
	}
}

func TestAddNotificationWithoutTitle(t *testing.T) {
	var creds, _ = GenUser()

	form := url.Values{}
	form.Add("credentials", creds.Value)

	r := PostRequest("", form, http.HandlerFunc(APIHandler))
	if status := r.Code; status != 407 {
		t.Errorf("handler returned wrong status code: got %v want %v", status, 407)
	}
}

func TestAddNotificationWithInvalidCredentials(t *testing.T) {
	form := url.Values{}
	form.Add("credentials", crypt.RandomString(25))

	r := PostRequest("", form, http.HandlerFunc(APIHandler))
	if status := r.Code; status != 407 {
		t.Errorf("handler returned wrong status code: got %v want %v", status, 407)
	}
}

func TestWSHandler(t *testing.T) {
	creds, form := GenUser() // generate user

	// socket connection header values based on generated user
	wsheader := http.Header{}
	wsheader.Add("Sec-Key", os.Getenv("server_key"))
	wsheader.Add("Credentials", creds.Value)
	wsheader.Add("Credential_key", creds.Key)
	wsheader.Add("Uuid", form.Get("UUID"))
	wsheader.Add("Version", "1.0.1")

	// Connect to wss without headers
	s := httptest.NewServer(http.HandlerFunc(WSHandler))
	defer s.Close()
	u := "ws" + strings.TrimPrefix(s.URL, "http")
	_, _, err := websocket.DefaultDialer.Dial(u, nil)
	if err == nil {
		t.Fatalf("Should have returned error connecting to wss without valid credentials!")
	}

	// Connect to wss with headers
	_, _, err = websocket.DefaultDialer.Dial(u, wsheader)
	if err != nil {
		t.Fatalf("Should have connected to wss!")
	}
}

func TestStoredNotificationsOnWSConnect(t *testing.T) {
	var creds, uform = GenUser() // generate user

	TITLE := crypt.RandomString(100)

	// send notification to not connected user
	SendNotification(creds.Value, TITLE)

	// connect to ws
	wsheader := http.Header{}
	wsheader.Add("Sec-Key", os.Getenv("server_key"))
	wsheader.Add("Credentials", creds.Value)
	wsheader.Add("Credential_key", creds.Key)
	wsheader.Add("Uuid", uform.Get("UUID"))
	wsheader.Add("Version", "1.0.1")
	s := httptest.NewServer(http.HandlerFunc(WSHandler))
	defer s.Close()
	u := "ws" + strings.TrimPrefix(s.URL, "http")
	ws, _, err := websocket.DefaultDialer.Dial(u, wsheader)
	if err != nil {
		t.Fatalf(err.Error())
	}
	defer ws.Close()

	// fetch stored notifications on server that were sent when not connected
	for {
		_, mess, err := ws.ReadMessage()
		if err != nil {
			t.Fatalf(err.Error())
		}
		var notifications []models.Notification
		_ = json.Unmarshal(mess, &notifications)

		if notifications[0].Title != TITLE {
			t.Error("Incorrect title returned!")
		}
		break
	}
}

// send notification while offline, connect to websocket to receive said notification
// tell server to delete notification, reconnect to websocket and service should not recieve a message
func TestDeleteNotification(t *testing.T) {
	var creds, uform = GenUser() // generate user

	// send notification to not connected user
	SendNotification(creds.Value, crypt.RandomString(10))

	// connect to wss
	s, ws, _ := ConnectWSS(creds, uform)

	// delete notification
	_, mess, _ := ws.ReadMessage()
	var notifications []models.Notification
	_ = json.Unmarshal(mess, &notifications)
	_ = ws.WriteMessage(websocket.TextMessage, []byte(strconv.Itoa(notifications[0].ID)))

	// disconnect from ws
	s.Close()
	ws.Close()

	// reconnect to ws
	s, ws, _ = ConnectWSS(creds, uform)

	// expect timeout on read notification
	_ = ws.SetReadDeadline(time.Now().Add(100 * time.Millisecond))
	_, _, err := ws.ReadMessage()
	if err == nil {
		t.Errorf("Should have had i/o timeout and received nothing")
	}
}

func TestReceivingNotificationOnline(t *testing.T) {
	var creds, form = GenUser() // generate user

	// connect to ws
	s, ws, _ := ConnectWSS(creds, form)
	defer s.Close()
	defer ws.Close()

	// send notification over http
	TITLE := crypt.RandomString(10)
	SendNotification(creds.Value, TITLE)

	// read notification over ws
	_, mess, _ := ws.ReadMessage()
	var notification models.Notification
	_ = json.Unmarshal(mess, &notification)

	if notification.Title != TITLE {
		t.Errorf("Titles do not match!")
	}
}
