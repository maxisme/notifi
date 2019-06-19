package model

import (
	"../crypt"
	"../validator"
	"database/sql"
	"errors"
	"log"
	"net/http"
	"strconv"
	"strings"
	"time"
)

type Notification struct {
	ID          int    `json:"id"`
	Credentials string `json:"-"`
	Time        string `json:"time"`
	Title       string `json:"title"`
	Message     string `json:"message"`
	Image       string `json:"image"`
	Link        string `json:"link"`
}

var maxtitle = 1000
var maxmessage = 10000
var maximage = 100000
var key = []byte("YQeucLKeOk19iL9YQuitPoZKSp6luVJF")

func StoreNotification(db *sql.DB, n Notification) error {
	_, err := db.Exec(`
	INSERT INTO notifications 
    (id, title, message, image, link, credentials) 
    VALUES(?, ?, ?, ?, ?, ?)`, n.ID, crypt.Encrypt(n.Title, key), crypt.Encrypt(n.Message, key),
		crypt.Encrypt(n.Image, key), crypt.Encrypt(n.Link, key), crypt.Hash(n.Credentials),
	)
	return err
}

func DeleteNotifications(db *sql.DB, credentials string, ids string) error {
	idarr := []interface{}{crypt.Hash(credentials)}

	for _, element := range strings.Split(ids, ",") {
		if val, err := strconv.Atoi(element); err != nil {
			return errors.New(element + " is not a number!")
		} else {
			idarr = append(idarr, val)
		}
	}

	query := `
	DELETE FROM notifications
	WHERE credentials = ?
	AND id IN (?` + strings.Repeat(",?", len(idarr)-2) + `)`
	_, err := db.Exec(query, idarr...)
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
	WHERE credentials = ?`
	rows, err := db.Query(query, crypt.Hash(credentials))
	if err != nil {
		log.Fatal(err)
	}
	defer rows.Close()

	notifications := []Notification{}
	for rows.Next() {
		var n Notification
		err := rows.Scan(&n.ID, &n.Time, &n.Title, &n.Message, &n.Image, &n.Link)
		if err != nil {
			return nil, err
		}
		err = DecryptNotification(&n)
		if err == nil {
			notifications = append(notifications, n)
		}
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
	} else if len(n.Title) > maxtitle {
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

		timeout := time.Duration(300 * time.Millisecond)
		client := http.Client{
			Timeout: timeout,
		}
		resp, _ := client.Head(n.Image)
		contentlen, err := strconv.Atoi(resp.Header.Get("Content-Length"))
		if err != nil {
			println(err.Error())
			n.Image = ""
		}
		if contentlen > maximage {
			return errors.New("Image from URL too large!" + string(contentlen))
		}
	}

	return nil
}

func DecryptNotification(notification *Notification) error {
	title, err := crypt.Decrypt(notification.Title, key)
	if err != nil {
		return err
	} else {
		notification.Title = title
	}

	message, err := crypt.Decrypt(notification.Message, key)
	if err == nil {
		notification.Message = message
	}

	image, err := crypt.Decrypt(notification.Image, key)
	if err == nil {
		notification.Image = image
	}

	link, err := crypt.Decrypt(notification.Link, key)
	if err == nil {
		notification.Link = link
	}
	return err
}

func IncreaseNotificationCnt(db *sql.DB, credentials string) error {
	_, err := db.Exec(`UPDATE users 
	SET notification_cnt = notification_cnt + 1 WHERE credentials = ?`, crypt.Hash(credentials))
	return err
}

func FetchTotalNumNotifications(db *sql.DB) int {
	id := 0
	rows, _ := db.Query("SELECT SUM(notification_cnt) from users;")
	if rows.Next() {
		_ = rows.Scan(&id)
	}
	return id
}
