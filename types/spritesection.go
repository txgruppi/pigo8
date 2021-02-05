package types

import (
	"github.com/txgruppi/pigo8/checks"
	"github.com/txgruppi/pigo8/errors"
	"github.com/txgruppi/pigo8/utils"
)

func NewSpriteSection() SpriteSection {
	return &_SpriteSection{
		items: map[int]color{},
	}
}

type SpriteSection interface {
	GetSprite(id int) (Sprite, error)
	GetPixel(x, y int) (color, error)
	SetPixel(x, y int, c color) error
}

type _SpriteSection struct {
	items map[int]color
}

func (t *_SpriteSection) GetSprite(id int) (Sprite, error) {
	if !checks.IsUint8(id) {
		return nil, errors.NewErrValueRangeUint8(id)
	}
	x, y := utils.IndexToCoords(16, id)
	return &_Sprite{
		section: SpriteSection(t),
		xOffset: x * 8,
		yOffset: y * 8,
	}, nil
}

func (t *_SpriteSection) GetPixel(x, y int) (color, error) {
	if !checks.IsUint7(x) {
		return Color0, errors.NewErrValueRangeUint7(x)
	}
	if !checks.IsUint7(y) {
		return Color0, errors.NewErrValueRangeUint7(y)
	}
	i := utils.CoordsToIndex(128, x, y)
	return t.items[i], nil
}

func (t *_SpriteSection) SetPixel(x, y int, c color) error {
	if !checks.IsUint7(x) {
		return errors.NewErrValueRangeUint7(x)
	}
	if !checks.IsUint7(y) {
		return errors.NewErrValueRangeUint7(y)
	}
	i := utils.CoordsToIndex(128, x, y)
	t.items[i] = c
	return nil
}
