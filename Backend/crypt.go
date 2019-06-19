package main

import (
	"crypto/aes"
	"crypto/cipher"
	r "crypto/rand"
	"crypto/sha256"
	b64 "encoding/base64"
	"golang.org/x/crypto/bcrypt"
	"io"
	"math/rand"
)

func Encrypt(str string, key []byte) string {
	if len(str) == 0 {
		return ""
	}

	c, err := aes.NewCipher(key)
	if err != nil {
		println(err)
		return ""
	}

	gcm, err := cipher.NewGCM(c)
	if err != nil {
		println(err)
		return ""
	}

	nonce := make([]byte, gcm.NonceSize())
	if _, err = io.ReadFull(r.Reader, nonce); err != nil {
		println(err)
		return ""
	}

	return b64.StdEncoding.EncodeToString(gcm.Seal(nonce, nonce, []byte(str), nil))
}

func Decrypt(encryptedstr string, key []byte) (string, error) {
	if len(encryptedstr) == 0 {
		return "", nil
	}

	encryptedbytes, _ := b64.StdEncoding.DecodeString(encryptedstr)
	c, err := aes.NewCipher(key)
	if err != nil {
		return "", err
	}

	gcm, err := cipher.NewGCM(c)
	if err != nil {
		return "", err
	}

	nonceSize := gcm.NonceSize()
	if len(encryptedbytes) < nonceSize {
		return "", err
	}

	nonce, ciphertext := encryptedbytes[:nonceSize], encryptedbytes[nonceSize:]
	plaintext, err := gcm.Open(nil, nonce, ciphertext, nil)
	if err != nil {
		return "", err
	}

	return string(plaintext), nil
}

func RandomString(n int) string {
	var letter = []rune("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789")

	b := make([]rune, n)
	for i := range b {
		b[i] = letter[rand.Intn(len(letter))]
	}
	return string(b)
}

func Hash(str string) string {
	v := sha256.Sum256([]byte(str))
	return string(b64.StdEncoding.EncodeToString(v[:]))
}

func PassHash(str string) string {
	hash, _ := bGenerateFromPassword([]byte(str), bMinCost)
	return string(hash)
}

func VerifyPassHash(str string, expectedstr string) bool {
	err := bCompareHashAndPassword([]byte(str), []byte(expectedstr))
	return err == nil
}
