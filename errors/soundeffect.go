package errors

import "fmt"

func NewErrInvalidSoundEffectMode(actual int) error {
	return &ErrInvalidSoundEffectMode{
		Actual: actual,
	}
}

type ErrInvalidSoundEffectMode struct {
	Actual int
}

func (t *ErrInvalidSoundEffectMode) Error() string {
	return fmt.Sprintf("invalid sound effect mode %d", t.Actual)
}
