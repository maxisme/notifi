package crypt

import (
	"testing"
)

var key = []byte("M2nMpY6lowXfscMSyMhH5eyWeImEXzD8")
var teststr = RandomString(10)

func Test(t *testing.T) {
	encryptedstr := Encrypt(teststr, key)
	decryptedstr, _ := Decrypt(encryptedstr, key)
	if decryptedstr != teststr {
		t.Errorf("Encryption did not work!")
	}
}

func TestInvalidKey(t *testing.T) {
	key2 := []byte(RandomString(10))
	encryptedstr := Encrypt(teststr, key)
	_, err := Decrypt(encryptedstr, key2)
	if err == nil {
		t.Errorf("Invalid key did not break!")
	}
}

func TestInvalidString(t *testing.T) {
	testenryptedstr := RandomString(10)
	str, _ := Decrypt(testenryptedstr, key)
	if str != "" {
		t.Errorf("Invalid string did not break!")
	}
}

func TestHash(t *testing.T) {
	if len(Hash(RandomString(10))) != 44 {
		t.Errorf("Hash algo not working as expected")
	}
	if Hash(RandomString(10)) == Hash(RandomString(10)){
		t.Errorf("Hash is not hashing properly")
	}
	str := RandomString(10)
	if Hash(str) != Hash(str){
		t.Errorf("Hash is not hashing properly 2")
	}
}