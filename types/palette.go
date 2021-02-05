package types

import (
	stdColor "image/color"

	"github.com/txgruppi/pigo8/checks"
	"github.com/txgruppi/pigo8/errors"
)

func NewDefaultPalette() Palette {
	p := NewPalette()
	p.SetColor(0, &stdColor.RGBA{R: 0x00, G: 0x00, B: 0x00, A: 0xFF})
	p.SetColor(1, &stdColor.RGBA{R: 0x1D, G: 0x2B, B: 0x53, A: 0xFF})
	p.SetColor(2, &stdColor.RGBA{R: 0x7E, G: 0x25, B: 0x53, A: 0xFF})
	p.SetColor(3, &stdColor.RGBA{R: 0x00, G: 0x87, B: 0x51, A: 0xFF})
	p.SetColor(4, &stdColor.RGBA{R: 0xAB, G: 0x52, B: 0x36, A: 0xFF})
	p.SetColor(5, &stdColor.RGBA{R: 0x5F, G: 0x57, B: 0x4F, A: 0xFF})
	p.SetColor(6, &stdColor.RGBA{R: 0xC2, G: 0xC3, B: 0xC7, A: 0xFF})
	p.SetColor(7, &stdColor.RGBA{R: 0xFF, G: 0xF1, B: 0xE8, A: 0xFF})
	p.SetColor(8, &stdColor.RGBA{R: 0xFF, G: 0x00, B: 0x4D, A: 0xFF})
	p.SetColor(9, &stdColor.RGBA{R: 0xFF, G: 0xA3, B: 0x00, A: 0xFF})
	p.SetColor(10, &stdColor.RGBA{R: 0xFF, G: 0xEC, B: 0x27, A: 0xFF})
	p.SetColor(11, &stdColor.RGBA{R: 0x00, G: 0xE4, B: 0x36, A: 0xFF})
	p.SetColor(12, &stdColor.RGBA{R: 0x29, G: 0xAD, B: 0xFF, A: 0xFF})
	p.SetColor(13, &stdColor.RGBA{R: 0x83, G: 0x76, B: 0x9C, A: 0xFF})
	p.SetColor(14, &stdColor.RGBA{R: 0xFF, G: 0x77, B: 0xA8, A: 0xFF})
	p.SetColor(15, &stdColor.RGBA{R: 0xFF, G: 0xCC, B: 0xAA, A: 0xFF})
	return p
}

func NewPalette() Palette {
	return &_Palette{
		items: map[int]*stdColor.RGBA{},
	}
}

type Palette interface {
	GetColor(int) (*stdColor.RGBA, error)
	SetColor(int, *stdColor.RGBA) error
}

type _Palette struct {
	items map[int]*stdColor.RGBA
}

func (t *_Palette) GetColor(index int) (*stdColor.RGBA, error) {
	if !checks.IsUint4(index) {
		return nil, errors.NewErrValueRangeUint4(index)
	}
	return t.items[index], nil
}

func (t *_Palette) SetColor(index int, c *stdColor.RGBA) error {
	if !checks.IsUint4(index) {
		return errors.NewErrValueRangeUint4(index)
	}
	t.items[index] = c
	return nil
}
