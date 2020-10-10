package errors

import (
	"fmt"

	"github.com/txgruppi/pigo8/checks"
)

func NewErrValueRangeUint2(actual int) error {
	return &ErrValueRange{
		Min:    0,
		Max:    checks.MaxUint2,
		Actual: actual,
	}
}

func NewErrValueRangeUint3(actual int) error {
	return &ErrValueRange{
		Min:    0,
		Max:    checks.MaxUint3,
		Actual: actual,
	}
}

func NewErrValueRangeUint4(actual int) error {
	return &ErrValueRange{
		Min:    0,
		Max:    checks.MaxUint4,
		Actual: actual,
	}
}

func NewErrValueRangeUint5(actual int) error {
	return &ErrValueRange{
		Min:    0,
		Max:    checks.MaxUint5,
		Actual: actual,
	}
}

func NewErrValueRangeUint6(actual int) error {
	return &ErrValueRange{
		Min:    0,
		Max:    checks.MaxUint6,
		Actual: actual,
	}
}

func NewErrValueRangeUint7(actual int) error {
	return &ErrValueRange{
		Min:    0,
		Max:    checks.MaxUint7,
		Actual: actual,
	}
}

func NewErrValueRangeUint8(actual int) error {
	return &ErrValueRange{
		Min:    0,
		Max:    checks.MaxUint8,
		Actual: actual,
	}
}

type ErrValueRange struct {
	Min    int
	Max    int
	Actual int
}

func (t *ErrValueRange) Error() string {
	return fmt.Sprintf("expected a value between %d and %d, got %d", t.Min, t.Max, t.Actual)
}
