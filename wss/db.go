package main

import (
	"database/sql"
)

func DBConn(dataSourceName string) (*sql.DB, error) {
	db, err := sql.Open("mysql", dataSourceName)
	if err != nil {
		return nil, err
	}
	if err = db.Ping(); err != nil {
		return nil, err
	}
	return db, nil
}

// stores the current timestamp that the user has connected to the wss
// as well as the app version the client is using
func SetLastLogin(db *sql.DB, version string, credentials string, credential_key string, UUID string) error {
	//
	// prepare query
	query := `UPDATE users
	SET last_login = NOW(), app_version = ? 
	WHERE credentials = ? AND credential_key = ? AND UUID = ?`
	prep, err := db.Prepare(query)
	if err != nil {
		return err
	}
	defer prep.Close()

	// execute query
	_, err = prep.Exec(version, credentials, credential_key, UUID)
	if err != nil {
		return err
	}

	return nil
}