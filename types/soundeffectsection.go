package types

import (
	"github.com/txgruppi/pigo8/checks"
	"github.com/txgruppi/pigo8/errors"
)

func NewSoundEffectSection() SoundEffectSection {
	return &_SoundEffectSection{
		items: map[int]SoundEffect{},
	}
}

type SoundEffectSection interface {
	GetSoundEffect(index int) (SoundEffect, error)
	SetSoundEffect(index int, s SoundEffect) error
}

type _SoundEffectSection struct {
	items map[int]SoundEffect
}

func (t *_SoundEffectSection) GetSoundEffect(index int) (SoundEffect, error) {
	if !checks.IsUint6(index) {
		return nil, errors.NewErrValueRangeUint6(index)
	}
	return t.items[index], nil
}

func (t *_SoundEffectSection) SetSoundEffect(index int, s SoundEffect) error {
	if !checks.IsUint6(index) {
		return errors.NewErrValueRangeUint6(index)
	}
	t.items[index] = s
	return nil
}
