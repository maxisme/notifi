package validator

import "testing"

func TestIsValidUUID(t *testing.T) {
	if IsValidUUID("62b5873e-71bf-4659-af9d796581f126f8"){
		t.Errorf("Should be invalid UUID")
	}

	if !IsValidUUID("62b5873e-71bf-4659-af9d-796581f126f8"){
		t.Errorf("Should be valid UUID")
	}
}