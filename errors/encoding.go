package errors

func NewErrInvalidHeader() error {
	return &ErrInvalidHeader{}
}

type ErrInvalidHeader struct {
}

func (t *ErrInvalidHeader) Error() string {
	return "header information is invalid"
}
