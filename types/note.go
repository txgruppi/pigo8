package types

import (
	"github.com/txgruppi/pigo8/checks"
	"github.com/txgruppi/pigo8/errors"
)

const (
	pitchMask    int = 0b00000000000011111111000000000000
	waveformMask     = 0b00000000000000000000111100000000
	volumeMask       = 0b00000000000000000000000011110000
	effectMask       = 0b00000000000000000000000000001111

	pitchOffset    int = 12
	waveformOffset     = 8
	volumeOffset       = 4
	effectOffset       = 0
)

func NewNote() Note {
	return &_Note{}
}

type Note interface {
	GetPitch() int
	SetPitch(int) error
	GetWaveform() int
	SetWaveform(int) error
	GetVolume() int
	SetVolume(int) error
	GetEffect() int
	SetEffect(int) error
}

type _Note struct {
	value int
}

func (t *_Note) GetPitch() int {
	return (t.value & pitchMask) >> pitchOffset
}

func (t *_Note) SetPitch(v int) error {
	if !checks.IsUint6(v) {
		return errors.NewErrValueRangeUint6(v)
	}
	t.value |= (v << pitchOffset) & pitchMask
	return nil
}

func (t *_Note) GetWaveform() int {
	return (t.value & waveformMask) >> waveformOffset
}

func (t *_Note) SetWaveform(v int) error {
	if !checks.IsUint4(v) {
		return errors.NewErrValueRangeUint4(v)
	}
	t.value |= (v << waveformOffset) & waveformMask
	return nil
}

func (t *_Note) GetVolume() int {
	return (t.value & volumeMask) >> volumeOffset
}

func (t *_Note) SetVolume(v int) error {
	if !checks.IsUint3(v) {
		return errors.NewErrValueRangeUint3(v)
	}
	t.value |= (v << volumeOffset) & volumeMask
	return nil
}

func (t *_Note) GetEffect() int {
	return (t.value & effectMask) >> effectOffset
}

func (t *_Note) SetEffect(v int) error {
	if !checks.IsUint3(v) {
		return errors.NewErrValueRangeUint3(v)
	}
	t.value |= (v << effectOffset) & effectMask
	return nil
}
