package types

import (
	"github.com/txgruppi/pigo8/checks"
	"github.com/txgruppi/pigo8/errors"
)

type musicPattern uint8

const (
	NoPattern          musicPattern = 0
	BeginPatternLoop                = 1
	EndPatternLoop                  = 2
	StopAtEndOfPattern              = 4

	ch0Mute int = 0x41
	ch1Mute int = 0x42
	ch2Mute int = 0x43
	ch3Mute int = 0x44
)

func NewMusic() Music {
	return &_Music{
		items: map[int]int{},
	}
}

func MusicPatternFromInt(i int) (musicPattern, error) {
	switch i {
	case 0:
		return NoPattern, nil
	case 1:
		return BeginPatternLoop, nil
	case 2:
		return EndPatternLoop, nil
	case 3:
		return BeginPatternLoop | EndPatternLoop, nil
	case 4:
		return StopAtEndOfPattern, nil
	case 5:
		return BeginPatternLoop | StopAtEndOfPattern, nil
	case 6:
		return EndPatternLoop | StopAtEndOfPattern, nil
	case 7:
		return BeginPatternLoop | EndPatternLoop | StopAtEndOfPattern, nil
	default:
		return BeginPatternLoop, errors.NewErrInvalidMusicPattern(i)
	}
}

type Music interface {
	GetPatternFlags() musicPattern
	SetPatternFlags(musicPattern) error
	GetChannel(int) (int, error)
	SetChannel(int, int) error
	MuteChannel(int) error
}

type _Music struct {
	flags musicPattern
	items map[int]int
}

func (t *_Music) GetPatternFlags() musicPattern {
	return t.flags
}

func (t *_Music) SetPatternFlags(f musicPattern) error {
	t.flags = f
	return nil
}

func (t *_Music) GetChannel(index int) (int, error) {
	if !checks.IsUint2(index) {
		return 0, errors.NewErrValueRangeUint2(index)
	}
	return t.items[index], nil
}

func (t *_Music) SetChannel(index, id int) error {
	if !checks.IsUint2(index) {
		return errors.NewErrValueRangeUint2(index)
	}
	if !checks.IsUint6(id) {
		return errors.NewErrValueRangeUint6(index)
	}
	t.items[index] = id
	return nil
}

func (t *_Music) MuteChannel(index int) error {
	if !checks.IsUint2(index) {
		return errors.NewErrValueRangeUint2(index)
	}
	var id int
	switch index {
	case 0:
		id = ch0Mute
	case 1:
		id = ch1Mute
	case 2:
		id = ch2Mute
	case 3:
		id = ch3Mute
	}
	t.items[index] = id
	return nil
}
