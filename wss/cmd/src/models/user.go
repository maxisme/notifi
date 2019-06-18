package models

import (
	"crypt"
	"database/sql"
)

type User struct {
	ID              int
	Created         string
	Credentials     Credentials
	LastLogin       string
	isConnected     string
	AppVersion      string
	NotificationCnt string
	UUID            string
}

type Credentials struct {
	Value string `json:"credentials"`
	Key   string `json:"key"`
}

// create user or update user with new credentials depending on whether the user passes current credentials
// in the User struct.
func CreateUser(db *sql.DB, u User) (Credentials, error) {
	// create new credentials
	creds := Credentials{
		crypt.RandomString(25),
		crypt.RandomString(100),
	}

	dbu := FetchUserWithUUID(db, u.UUID)
	isnewuser := true
	if len(dbu.Credentials.Value) > 0 {
		// UUID already exists
		if len(u.Credentials.Key) > 0 && len(u.Credentials.Value) > 0 {
			// if client passes current details they are asking for new credentials

			// verify the credentials passed are valid
			if VerifyUser(db, u) {
				isnewuser = false
			}
		}
	}

	var query string
	if isnewuser {
		// create new user
		query = `
		INSERT INTO users (credentials, credential_key, UUID) 
		VALUES (?, ?, ?)`
	} else {
		// update users credentials
		query = `
		UPDATE users SET credentials = ?, credential_key = ?
		WHERE UUID = ?`
	}

	_, err := db.Exec(query, crypt.Hash(creds.Value), crypt.PassHash(creds.Key), crypt.Hash(u.UUID))
	if err != nil {
		return Credentials{}, err
	}
	return creds, nil
}

func FetchUser(db *sql.DB, credentials string) User {
	var u User
	_ = db.QueryRow(`
	SELECT credential_key, UUID
	FROM users 
	WHERE credentials = ?`, crypt.Hash(credentials)).Scan(&u.Credentials.Key, &u.UUID)
	return u
}

func FetchUserWithUUID(db *sql.DB, UUID string) User {
	var u User
	_ = db.QueryRow(`
	SELECT credential_key, credentials
	FROM users 
	WHERE UUID = ?`, crypt.Hash(UUID)).Scan(&u.Credentials.Key, &u.Credentials.Value)
	return u
}

func VerifyUser(db *sql.DB, u User) bool {
	storeduser := FetchUser(db, u.Credentials.Value)
	valid_key := crypt.VerifyPassHash(storeduser.Credentials.Key, u.Credentials.Key)
	valid_UUID := storeduser.UUID == crypt.Hash(u.UUID)
	if valid_key && valid_UUID {
		return true
	}
	return false
}

// stores the current timestamp that the user has connected to the wss
// as well as the app version the client is using
func SetLastLogin(db *sql.DB, u User) error {
	_, err := db.Exec(`UPDATE users
	SET last_login = NOW(), app_version = ?, is_connected = 1
	WHERE credentials = ? AND UUID = ?`, u.AppVersion, crypt.Hash(u.Credentials.Value), crypt.Hash(u.UUID))
	return err
}

func Logout(db *sql.DB, u User) error {
	_, err := db.Exec(`UPDATE users
	SET is_connected = 0
	WHERE credentials = ? AND UUID = ?`, crypt.Hash(u.Credentials.Value), crypt.Hash(u.UUID))
	return err
}

func LogoutAll(db *sql.DB) error {
	_, err := db.Exec(`UPDATE users
	SET is_connected = 0`)
	return err
}
