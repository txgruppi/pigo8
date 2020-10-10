package types

import (
	"github.com/txgruppi/pigo8/checks"
	"github.com/txgruppi/pigo8/errors"
	"github.com/txgruppi/pigo8/utils"
)

func NewLabelSection() LabelSection {
	return &_LabelSection{
		items: map[int]color{},
	}
}

type LabelSection interface {
	GetPixel(x, y int) (color, error)
	SetPixel(x, y int, c color) error
}

type _LabelSection struct {
	items map[int]color
}

func (t *_LabelSection) GetPixel(x, y int) (color, error) {
	if !checks.IsUint7(x) {
		return Color0, errors.NewErrValueRangeUint7(x)
	}
	if !checks.IsUint7(y) {
		return Color0, errors.NewErrValueRangeUint7(y)
	}
	i := utils.CoordsToIndex(128, x, y)
	return t.items[i], nil
}

func (t *_LabelSection) SetPixel(x, y int, c color) error {
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
