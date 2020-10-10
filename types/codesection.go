package types

import (
	"github.com/txgruppi/pigo8/checks"
	"github.com/txgruppi/pigo8/clone"
	"github.com/txgruppi/pigo8/errors"
)

func NewCodeSection() CodeSection {
	return &_CodeSection{
		items: map[int][]byte{},
	}
}

type CodeSection interface {
	GetTab(index int) ([]byte, error)
	SetTab(index int, b []byte) error
}

type _CodeSection struct {
	items map[int][]byte
}

func (t *_CodeSection) GetTab(index int) ([]byte, error) {
	if !checks.IsUint4(index) {
		return nil, errors.NewErrValueRangeUint4(index)
	}
	return clone.Bytes(t.items[index]), nil
}

func (t *_CodeSection) SetTab(index int, b []byte) error {
	if !checks.IsUint4(index) {
		return errors.NewErrValueRangeUint4(index)
	}
	t.items[index] = b
	return nil
}
