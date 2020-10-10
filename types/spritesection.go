package types

import (
	"github.com/txgruppi/pigo8/checks"
	"github.com/txgruppi/pigo8/errors"
)

func NewSpriteSection() SpriteSection {
	return &_SpriteSection{
		items: map[int]Sprite{},
	}
}

type SpriteSection interface {
	GetSprite(index int) (Sprite, error)
	SetSprite(index int, s Sprite) error
}

type _SpriteSection struct {
	items map[int]Sprite
}

func (t *_SpriteSection) GetSprite(index int) (Sprite, error) {
	if !checks.IsUint8(index) {
		return nil, errors.NewErrValueRangeUint8(index)
	}
	return t.items[index], nil
}

func (t *_SpriteSection) SetSprite(index int, s Sprite) error {
	if !checks.IsUint8(index) {
		return errors.NewErrValueRangeUint8(index)
	}
	t.items[index] = s
	return nil
}
