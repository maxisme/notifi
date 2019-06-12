package models

import (
	"crypt"
	"database/sql"
	"errors"
	"log"
	"net/http"
	"strconv"
	"strings"
	"validator"
)

type Notification struct {
	ID          int
	Credentials string
	Time        string
	Title       string
	Message     string
	Image       string
	Link        string
}

var maxtitle = 1000
var maxmessage = 10000
var maximage = 100
var key = []byte("YQeucLKeOk19iL9YQuitPoZKSp6luVJF")

func StoreNotification(db *sql.DB, n Notification) error {
	_, err := db.Exec(`
	INSERT INTO notifications 
    (title, message, image, link, credentials) 
    VALUES(?, ?, ?, ?, ?)`,
		crypt.Encrypt(n.Title, key), crypt.Encrypt(n.Message, key),
		crypt.Encrypt(n.Image, key), crypt.Encrypt(n.Link, key), crypt.Encrypt(n.Credentials, key),
	)
	return err
}

func FetchAllNotifications(db *sql.DB, credentials string) ([]Notification, error) {
	query := `
	SELECT
		id,
		DATE_FORMAT(time, '%Y-%m-%d %T') as time,
		title, 
		message,
		image,
		link
	FROM notifications
	WHERE credentials = ?
	AND title != ''
	`
	rows, err := db.Query(query, credentials)
	if err != nil {
		log.Fatal(err)
	}
	defer rows.Close()

	notifications := []Notification{}
	for rows.Next() {
		var n Notification
		err := rows.Scan(&n.Time, &n.Title, &n.Message, &n.Image, &n.Link)
		if err != nil {
			return nil, err
		}
		notifications = append(notifications, n)
	}
	return notifications, nil
}

func NotificationValidation(n *Notification) error {
	if len(n.Credentials) == 0 {
		return errors.New("Invalid credentials!")
	}

	if n.Credentials == "<credentials>" {
		return errors.New("You have not set your personal credentials given to you by the notifi app! You instead used the placeholder '<credentials>'!")
	}

	if len(n.Title) == 0 {
		return errors.New("You must enter a title!")
	}else if len(n.Title) > maxtitle {
		return errors.New("You must enter a shorter title!")
	}

	if len(n.Message) > maxmessage {
		return errors.New("You must enter a shorter message!")
	}

	if validator.IsValidURL(n.Link) != nil || validator.IsValidURL(n.Image) != nil {
		return errors.New("Invalid URL!")
	}

	if len(n.Image) > 0 {
		if strings.Contains(n.Image, "http://") {
			return errors.New("Image URL must be https!")
		}

		resp, _ := http.Head(n.Image)
		contentlen, _ := strconv.Atoi(resp.Header.Get("Content-Length"))
		if contentlen > maximage {
			return errors.New("Image from URL too large!")
		}
	}

	return nil
}
