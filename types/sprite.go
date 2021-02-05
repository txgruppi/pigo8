package types

import (
	"github.com/txgruppi/pigo8/checks"
	"github.com/txgruppi/pigo8/errors"
	"github.com/txgruppi/pigo8/utils"
)

type Sprite interface {
	GetPixel(x, y int) (color, error)
	SetPixel(x, y int, c color) error
	At(i int) (color, error)
}

type _Sprite struct {
	section SpriteSection
	xOffset int
	yOffset int
}

func (t *_Sprite) GetPixel(x, y int) (color, error) {
	if !checks.IsUint3(x) {
		return Color0, errors.NewErrValueRangeUint3(x)
	}
	if !checks.IsUint3(y) {
		return Color0, errors.NewErrValueRangeUint3(y)
	}
	return t.section.GetPixel(t.xOffset+x, t.yOffset+y)
}

func (t *_Sprite) SetPixel(x, y int, c color) error {
	if !checks.IsUint3(x) {
		return errors.NewErrValueRangeUint3(x)
	}
	if !checks.IsUint3(y) {
		return errors.NewErrValueRangeUint3(y)
	}
	return t.section.SetPixel(t.xOffset+x, t.yOffset+y, c)
}

func (t *_Sprite) At(i int) (color, error) {
	x, y := utils.IndexToCoords(8, i)
	return t.GetPixel(x, y)
}
