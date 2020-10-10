package errors

import "fmt"

func NewErrExpectedOrd(left, right int, operator string) error {
	return &ErrExpectedOrd{
		Left:     left,
		Right:    right,
		Operator: operator,
	}
}

type ErrExpectedOrd struct {
	Left     int
	Right    int
	Operator string
}

func (t *ErrExpectedOrd) Error() string {
	return fmt.Sprintf("expected %d %s %d", t.Left, t.Operator, t.Right)
}
