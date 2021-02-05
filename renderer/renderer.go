package renderer

import (
	"image"
	"image/color"

	"github.com/txgruppi/pigo8/utils"

	"github.com/txgruppi/pigo8/types"
)

func NewRenderer(palette types.Palette) types.Renderer {
	return &Renderer{
		palette: palette,
	}
}

type Renderer struct {
	palette types.Palette
}

func (t *Renderer) renderPixel(img *image.RGBA, c *color.RGBA, ox, oy, scale int) error {
	for y := 0; y < scale; y++ {
		for x := 0; x < scale; x++ {
			img.SetRGBA(x+ox, y+oy, *c)
		}
	}
	return nil
}

func (t *Renderer) renderSprite(img *image.RGBA, s types.Sprite, ox, oy, scale int) error {
	for y := 0; y < 8; y++ {
		for x := 0; x < 8; x++ {
			pixel, err := s.GetPixel(x, y)
			if err != nil {
				return err
			}
			color, err := t.palette.GetColor(int(pixel))
			if err != nil {
				return err
			}
			if err := t.renderPixel(img, color, (x*scale)+ox, (y*scale)+oy, scale); err != nil {
				return err
			}
		}
	}
	return nil
}

func (t *Renderer) SpriteSection(s types.SpriteSection, scale int) (image.Image, error) {
	img := image.NewRGBA(image.Rect(0, 0, 128*scale, 128*scale))
	for y := 0; y < 16; y++ {
		for x := 0; x < 16; x++ {
			sprite, err := s.GetSprite(utils.CoordsToIndex(16, x, y))
			if err != nil {
				return nil, err
			}
			if err := t.renderSprite(img, sprite, x*8*scale, y*8*scale, scale); err != nil {
				return nil, err
			}
		}
	}
	return img, nil
}
