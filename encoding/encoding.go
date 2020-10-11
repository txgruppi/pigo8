package encoding

import (
	"bytes"

	"github.com/txgruppi/pigo8/types"
)

type Encoding interface {
	Decode([]byte) (types.Cart, error)
	DecodeCode(types.Cart, [][]byte) error
	DecodeSprite(types.Cart, [][]byte) error
	DecodeSpriteFlag(types.Cart, [][]byte) error
	DecodeMap(types.Cart, [][]byte) error
	DecodeSoundEffect(types.Cart, [][]byte) error
	DecodeMusic(types.Cart, [][]byte) error
	DecodeLabel(types.Cart, [][]byte) error

	Encode(types.Cart) ([]byte, error)
	EncodeHeader(types.Header, *bytes.Buffer) error
	EncodeCode(types.CodeSection, *bytes.Buffer, bool) error
	EncodeSprite(types.SpriteSection, *bytes.Buffer, bool) error
	EncodeSpriteFlag(types.SpriteFlagSection, *bytes.Buffer, bool) error
	EncodeMap(types.MapSection, *bytes.Buffer, bool) error
	EncodeSoundEffect(types.SoundEffectSection, *bytes.Buffer, bool) error
	EncodeMusic(types.MusicSection, *bytes.Buffer, bool) error
	EncodeLabel(types.LabelSection, *bytes.Buffer, bool) error
}
