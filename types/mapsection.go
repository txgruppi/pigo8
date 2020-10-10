package types

import (
	"github.com/txgruppi/pigo8/checks"
	"github.com/txgruppi/pigo8/errors"
	"github.com/txgruppi/pigo8/utils"
)

func NewMapSection() MapSection {
	return &_MapSection{
		items: map[int]int{},
	}
}

type MapSection interface {
	GetTile(x, y int) (int, error)
	SetTile(x, y, spriteID int) error
}

type _MapSection struct {
	items map[int]int
}

func (t *_MapSection) GetTile(x, y int) (int, error) {
	if !checks.IsUint7(x) {
		return 0, errors.NewErrValueRangeUint7(x)
	}
	if !checks.IsUint5(y) {
		return 0, errors.NewErrValueRangeUint5(y)
	}
	i := utils.CoordsToIndex(128, x, y)
	return t.items[i], nil
}

func (t *_MapSection) SetTile(x, y, spriteID int) error {
	if !checks.IsUint7(x) {
		return errors.NewErrValueRangeUint7(x)
	}
	if !checks.IsUint5(y) {
		return errors.NewErrValueRangeUint5(y)
	}
	if !checks.IsUint8(spriteID) {
		return errors.NewErrValueRangeUint8(spriteID)
	}
	i := utils.CoordsToIndex(128, x, y)
	t.items[i] = spriteID
	return nil
}
