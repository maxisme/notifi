package validator

import (
	url2 "net/url"
	"regexp"
	"strings"
)

var validversion = regexp.MustCompile(`^[\d\.]*$`)

func IsValidVersion(version string) bool{
	version = strings.TrimSpace(version)
	if len(version) == 0 {
		return false
	}
	return validversion.MatchString(version)
}

func IsValidUUID(uuid string) bool {
	r := regexp.MustCompile("^[a-fA-F0-9]{8}-[a-fA-F0-9]{4}-4[a-fA-F0-9]{3}-[8|9|aA|bB][a-fA-F0-9]{3}-[a-fA-F0-9]{12}$")
	return r.MatchString(uuid)
}

func IsValidCredentials(credentials string) bool {
	return len(credentials) == 25
}

func IsValidURL(url string) error {
	if url == ""{
		return nil
	}
	_, err := url2.ParseRequestURI(url)
	return err
}