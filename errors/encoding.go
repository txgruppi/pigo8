package errors

import "fmt"

func NewErrInvalidHeader() error {
	return &ErrInvalidHeader{}
}

type ErrInvalidHeader struct {
}

func (t *ErrInvalidHeader) Error() string {
	return "header information is invalid"
}

func NewErrUnkownFormat(actual string) error {
	return &ErrUnknownFormat{Actual: actual}
}

type ErrUnknownFormat struct {
	Actual string
}

func (t *ErrUnknownFormat) Error() string {
	return fmt.Sprintf("unknown format %s", t.Actual)
}
