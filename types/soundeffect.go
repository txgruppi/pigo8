package types

import (
	"github.com/txgruppi/pigo8/checks"
	"github.com/txgruppi/pigo8/errors"
)

type soundEffectMode uint8

func NewSoundEffect() SoundEffect {
	return &_SoundEffect{
		items: map[int]Note{},
	}
}

const (
	PitchMode soundEffectMode = iota
	NoteMode
)

type SoundEffect interface {
	GetMode() soundEffectMode
	SetMode(soundEffectMode)
	GetDuration() uint8
	SetDuration(uint8)
	GetLoopRange() (int, int)
	SetLoopRange(int, int) error
	GetNote(index int) (Note, error)
	SetNote(index int, n Note) error
}

type _SoundEffect struct {
	mode      soundEffectMode
	duration  uint8
	loopStart int
	loopEnd   int
	items     map[int]Note
}

func (t *_SoundEffect) GetMode() soundEffectMode {
	return t.mode
}

func (t *_SoundEffect) SetMode(m soundEffectMode) {
	t.mode = m
}

func (t *_SoundEffect) GetDuration() uint8 {
	return t.duration
}

func (t *_SoundEffect) SetDuration(v uint8) {
	t.duration = v
}

func (t *_SoundEffect) GetLoopRange() (int, int) {
	return t.loopStart, t.loopEnd
}

func (t *_SoundEffect) SetLoopRange(start, end int) error {
	if !checks.IsUint6(start) {
		return errors.NewErrValueRangeUint6(start)
	}
	if !checks.IsUint6(end) {
		return errors.NewErrValueRangeUint6(end)
	}
	if start > end {
		return errors.NewErrExpectedOrd(start, end, "<=")
	}
	return nil
}

func (t *_SoundEffect) GetNote(index int) (Note, error) {
	if !checks.IsUint5(index) {
		return nil, errors.NewErrValueRangeUint5(index)
	}
	return t.items[index], nil
}

func (t *_SoundEffect) SetNote(index int, n Note) error {
	if !checks.IsUint5(index) {
		return errors.NewErrValueRangeUint5(index)
	}
	t.items[index] = n
	return nil
}
