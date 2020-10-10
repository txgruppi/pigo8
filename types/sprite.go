package types

import (
	"github.com/txgruppi/pigo8/checks"
	"github.com/txgruppi/pigo8/errors"
	"github.com/txgruppi/pigo8/utils"
)

func NewSprite() Sprite {
	return &_Sprite{
		items: map[int]color{},
	}
}

type Sprite interface {
	GetPixel(x, y int) (color, error)
	SetPixel(x, y int, c color) error
	GetFlags() uint8
	SetFlags(uint8)
}

type _Sprite struct {
	items map[int]color
	flags uint8
}

func (t *_Sprite) GetPixel(x, y int) (color, error) {
	if !checks.IsUint3(x) {
		return Color0, errors.NewErrValueRangeUint3(x)
	}
	if !checks.IsUint3(y) {
		return Color0, errors.NewErrValueRangeUint3(y)
	}
	i := utils.CoordsToIndex(8, x, y)
	return t.items[i], nil
}

func (t *_Sprite) SetPixel(x, y int, c color) error {
	if !checks.IsUint3(x) {
		return errors.NewErrValueRangeUint3(x)
	}
	if !checks.IsUint3(y) {
		return errors.NewErrValueRangeUint3(y)
	}
	if !checks.IsUint4(int(c)) {
		return errors.NewErrValueRangeUint4(int(c))
	}
	i := utils.CoordsToIndex(8, x, y)
	t.items[i] = c
	return nil
}

func (t *_Sprite) GetFlags() uint8 {
	return t.flags
}

func (t *_Sprite) SetFlags(f uint8) {
	t.flags = f
}
