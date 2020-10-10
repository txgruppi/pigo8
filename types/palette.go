package types

import (
	stdColor "image/color"

	"github.com/txgruppi/pigo8/checks"
	"github.com/txgruppi/pigo8/errors"
)

func NewPalette() Palette {
	return &_Palette{
		items: map[int]stdColor.Color{},
	}
}

type Palette interface {
	GetColor(int) (stdColor.Color, error)
	SetColor(int, stdColor.Color) error
}

type _Palette struct {
	items map[int]stdColor.Color
}

func (t *_Palette) GetColor(index int) (stdColor.Color, error) {
	if !checks.IsUint4(index) {
		return nil, errors.NewErrValueRangeUint4(index)
	}
	return t.items[index], nil
}

func (t *_Palette) SetColor(index int, c stdColor.Color) error {
	if !checks.IsUint4(index) {
		return errors.NewErrValueRangeUint4(index)
	}
	t.items[index] = c
	return nil
}
