package errors

import "fmt"

func NewErrInvalidMusicPattern(actual int) error {
	return &ErrInvalidMusicPattern{
		Actual: actual,
	}
}

type ErrInvalidMusicPattern struct {
	Actual int
}

func (t *ErrInvalidMusicPattern) Error() string {
	return fmt.Sprintf("invalid music pattern %d", t.Actual)
}
