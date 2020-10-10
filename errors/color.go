package errors

import "fmt"

func NewErrInvalidColorIndex(actual int) error {
	return &ErrInvalidColorIndex{Actual: actual}
}

type ErrInvalidColorIndex struct {
	Actual int
}

func (t *ErrInvalidColorIndex) Error() string {
	return fmt.Sprintf("color index %d is invalid", t.Actual)
}
