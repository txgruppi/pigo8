package types

import (
	"github.com/txgruppi/pigo8/checks"
	"github.com/txgruppi/pigo8/errors"
)

func NewMusicSection() MusicSection {
	return &_MusicSection{
		items: map[int]Music{},
	}
}

type MusicSection interface {
	GetMusic(index int) (Music, error)
	SetMusic(index int, m Music) error
}

type _MusicSection struct {
	items map[int]Music
}

func (t *_MusicSection) GetMusic(index int) (Music, error) {
	if !checks.IsUint6(index) {
		return nil, errors.NewErrValueRangeUint6(index)
	}
	return t.items[index], nil
}

func (t *_MusicSection) SetMusic(index int, m Music) error {
	if !checks.IsUint6(index) {
		return errors.NewErrValueRangeUint6(index)
	}
	t.items[index] = m
	return nil
}
