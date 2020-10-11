package types

import (
	"github.com/txgruppi/pigo8/checks"
	"github.com/txgruppi/pigo8/errors"
)

func NewSpriteFlagSection() SpriteFlagSection {
	return &_SpriteFlagSection{
		items: map[int]uint8{},
	}
}

type SpriteFlagSection interface {
	GetFlags(int) (uint8, error)
	SetFlags(int, uint8) error
}

type _SpriteFlagSection struct {
	items map[int]uint8
}

func (t *_SpriteFlagSection) GetFlags(index int) (uint8, error) {
	if !checks.IsUint8(index) {
		return 0, errors.NewErrValueRangeUint8(index)
	}
	return t.items[index], nil
}

func (t *_SpriteFlagSection) SetFlags(index int, flags uint8) error {
	if !checks.IsUint8(index) {
		return errors.NewErrValueRangeUint8(index)
	}
	t.items[index] = flags
	return nil
}
