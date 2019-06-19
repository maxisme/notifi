package main

import "testing"

func TestIsValidUUID(t *testing.T) {
	if IsValidUUID("62b5873e-71bf-4659-af9d796581f126f8") {
		t.Errorf("Should be invalid UUID")
	}

	if !IsValidUUID("BB8C9950-286C-5462-885C-0CFED585423B") {
		t.Errorf("Should be valid UUID")
	}
}

var versiontests = []struct {
	in  string
	out bool
}{
	{"", false},
	{" ", false},
	{"1", true},
	{"a", false},
	{"1.", true},
	{"1.2", true},
	{"1.2aa2.3a", false},
	{"1.a.3", false},
}

func TestIsValidVersion(t *testing.T) {
	for _, tt := range versiontests {
		t.Run(tt.in, func(t *testing.T) {
			v := IsValidVersion(tt.in)
			if v != tt.out {
				t.Errorf("got %v, wanted %v", v, tt.out)
			}
		})
	}
}
