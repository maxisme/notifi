package main

import (
	"encoding/json"
	"github.com/google/uuid"
	"io/ioutil"
	"math/rand"
	"models"
	"net/http"
	"net/http/httptest"
	"net/url"
	"os"
	"strings"
	"testing"
	"time"
)

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

func PostRequest(url string, form url.Values, handler http.HandlerFunc) *httptest.ResponseRecorder {
	req, err := http.NewRequest("POST", url, strings.NewReader(form.Encode()))
	if err != nil {
		println(err)
		return nil
	}
	req.Header.Add("Content-Type", "application/x-www-form-urlencoded")
	req.Header.Add("Sec-Key", os.Getenv("server_key"))

	rr := httptest.NewRecorder()
	handler.ServeHTTP(rr, req)
	return rr
}

func GenUser() (models.Credentials, url.Values){
	UUID, _ := uuid.NewRandom()
	form := url.Values{}
	form.Add("UUID", UUID.String())
	rr := PostRequest("/code", form, http.HandlerFunc(CodeHandler))
	var creds models.Credentials
	_ = json.Unmarshal(rr.Body.Bytes(), &creds)
	return creds, form
}

func TestCreateNewUser(t *testing.T) {
	rand.Seed(time.Now().UTC().UnixNano())

	// create new user
	var creds, form = GenUser()
	if len(creds.Key) == 0 || len(creds.Value) == 0 {
		t.Errorf("Error fetching new credentials")
	}

	// update user credentials
	r := PostRequest("/code", form, http.HandlerFunc(CodeHandler))
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
	form.Add("title", "test")

	r := PostRequest("/code", form, http.HandlerFunc(APIHandler))
	println(r.Body.String())
}
