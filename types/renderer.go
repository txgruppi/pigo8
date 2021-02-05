package types

import "image"

type Renderer interface {
	SpriteSection(section SpriteSection, scale int) (image.Image, error)
}
