package p8

import (
	"bytes"
	"fmt"
	"strings"

	"github.com/txgruppi/pigo8/types"
)

func (t *P8Encoding) Encode(cart types.Cart) ([]byte, error) {
	var b bytes.Buffer

	if err := t.EncodeHeader(cart.GetHeader(), &b); err != nil {
		return nil, err
	}
	if err := t.EncodeCode(cart.GetCode(), &b, true); err != nil {
		return nil, err
	}
	if err := t.EncodeSprite(cart.GetSprite(), &b, true); err != nil {
		return nil, err
	}
	if err := t.EncodeSpriteFlag(cart.GetSpriteFlag(), &b, true); err != nil {
		return nil, err
	}
	if err := t.EncodeMap(cart.GetMap(), &b, true); err != nil {
		return nil, err
	}
	if err := t.EncodeSoundEffect(cart.GetSoundEffect(), &b, true); err != nil {
		return nil, err
	}
	if err := t.EncodeMusic(cart.GetMusic(), &b, true); err != nil {
		return nil, err
	}
	if err := t.EncodeLabel(cart.GetLabel(), &b, true); err != nil {
		return nil, err
	}

	return b.Bytes(), nil
}

func (t *P8Encoding) EncodeHeader(s types.Header, b *bytes.Buffer) error {
	if s == nil {
		return nil
	}
	if _, err := b.WriteString(fmt.Sprintf("pico-8 cartridge // http://www.pico-8.com\nversion %d\n", s.GetVersion())); err != nil {
		return err
	}
	return nil
}

func (t *P8Encoding) EncodeCode(s types.CodeSection, b *bytes.Buffer, includeTag bool) error {
	if s == nil {
		return nil
	}

	if includeTag {
		if _, err := b.WriteString(fmt.Sprintf("__lua__\n")); err != nil {
			return err
		}
	}

	for i := 0; i < 16; i++ {
		data, err := s.GetTab(i)
		if err != nil {
			return err
		}
		if data == nil {
			continue
		}
		if i != 0 {
			if _, err := b.WriteString("-->8\n"); err != nil {
				return err
			}
		}
		if _, err := b.Write(data); err != nil {
			return err
		}
		if !bytes.HasSuffix(data, []byte("\n")) {
			if err := b.WriteByte('\n'); err != nil {
				return err
			}
		}
	}

	return nil
}

func (t *P8Encoding) EncodeSprite(s types.SpriteSection, b *bytes.Buffer, includeTag bool) error {
	if s == nil {
		return nil
	}

	if includeTag {
		if _, err := b.WriteString(fmt.Sprintf("__gfx__\n")); err != nil {
			return err
		}
	}

	for y := 0; y < 128; y++ {
		for x := 0; x < 128; x++ {
			c, err := s.GetPixel(x, y)
			if err != nil {
				return err
			}
			if _, err := b.WriteString(fmt.Sprintf("%x", uint8(c))); err != nil {
				return err
			}
		}
		if err := b.WriteByte('\n'); err != nil {
			return err
		}
	}

	return nil
}

func (t *P8Encoding) EncodeSpriteFlag(s types.SpriteFlagSection, b *bytes.Buffer, includeTag bool) error {
	if s == nil {
		return nil
	}

	if includeTag {
		if _, err := b.WriteString(fmt.Sprintf("__gff__\n")); err != nil {
			return err
		}
	}

	for i := 0; i < 256; i++ {
		c, err := s.GetFlags(i)
		if err != nil {
			return err
		}
		if _, err := b.WriteString(fmt.Sprintf("%02x", c)); err != nil {
			return err
		}
		if i == 127 || i == 255 {
			if err := b.WriteByte('\n'); err != nil {
				return err
			}
		}
	}

	return nil
}

func (t *P8Encoding) EncodeMap(s types.MapSection, b *bytes.Buffer, includeTag bool) error {
	if s == nil {
		return nil
	}

	if includeTag {
		if _, err := b.WriteString(fmt.Sprintf("__map__\n")); err != nil {
			return err
		}
	}

	for y := 0; y < 32; y++ {
		for x := 0; x < 128; x++ {
			id, err := s.GetTile(x, y)
			if err != nil {
				return err
			}
			if _, err := b.WriteString(fmt.Sprintf("%02x", id)); err != nil {
				return err
			}
		}
		if err := b.WriteByte('\n'); err != nil {
			return err
		}
	}

	return nil
}

func (t *P8Encoding) EncodeSoundEffect(s types.SoundEffectSection, b *bytes.Buffer, includeTag bool) error {
	if s == nil {
		return nil
	}

	if includeTag {
		if _, err := b.WriteString(fmt.Sprintf("__sfx__\n")); err != nil {
			return err
		}
	}

	for y := 0; y < 64; y++ {
		sound, err := s.GetSoundEffect(y)
		if err != nil {
			return err
		}
		if sound == nil {
			if _, err := b.WriteString(strings.Repeat("0", 168)); err != nil {
				return err
			}
			continue
		}
		if _, err := b.WriteString(fmt.Sprintf("%02x", uint8(sound.GetMode()))); err != nil {
			return err
		}
		if _, err := b.WriteString(fmt.Sprintf("%02x", uint8(sound.GetDuration()))); err != nil {
			return err
		}
		start, end := sound.GetLoopRange()
		if _, err := b.WriteString(fmt.Sprintf("%02x", start)); err != nil {
			return err
		}
		if _, err := b.WriteString(fmt.Sprintf("%02x", end)); err != nil {
			return err
		}
		for x := 0; x < 32; x++ {
			note, err := sound.GetNote(x)
			if err != nil {
				return err
			}
			if note == nil {
				if _, err := b.WriteString("00000"); err != nil {
					return err
				}
				continue
			}
			if _, err := b.WriteString(fmt.Sprintf("%02x", note.GetPitch())); err != nil {
				return err
			}
			if _, err := b.WriteString(fmt.Sprintf("%x", note.GetWaveform())); err != nil {
				return err
			}
			if _, err := b.WriteString(fmt.Sprintf("%x", note.GetVolume())); err != nil {
				return err
			}
			if _, err := b.WriteString(fmt.Sprintf("%x", note.GetEffect())); err != nil {
				return err
			}
		}
		if err := b.WriteByte('\n'); err != nil {
			return err
		}
	}

	return nil
}

func (t *P8Encoding) EncodeMusic(s types.MusicSection, b *bytes.Buffer, includeTag bool) error {
	if s == nil {
		return nil
	}

	if includeTag {
		if _, err := b.WriteString(fmt.Sprintf("__music__\n")); err != nil {
			return err
		}
	}

	for y := 0; y < 64; y++ {
		music, err := s.GetMusic(y)
		if err != nil {
			return err
		}
		if music == nil {
			if _, err := b.WriteString("00 00000000\n"); err != nil {
				return err
			}
			continue
		}
		if _, err := b.WriteString(fmt.Sprintf("%02x ", music.GetPatternFlags())); err != nil {
			return err
		}
		for i := 0; i < 4; i++ {
			c, err := music.GetChannel(i)
			if err != nil {
				return err
			}
			if _, err := b.WriteString(fmt.Sprintf("%02x", c)); err != nil {
				return err
			}
		}
		if err := b.WriteByte('\n'); err != nil {
			return err
		}
	}

	return nil
}

func (t *P8Encoding) EncodeLabel(s types.LabelSection, b *bytes.Buffer, includeTag bool) error {
	if s == nil {
		return nil
	}

	if includeTag {
		if _, err := b.WriteString(fmt.Sprintf("__label__\n")); err != nil {
			return err
		}
	}

	for y := 0; y < 128; y++ {
		for x := 0; x < 128; x++ {
			c, err := s.GetPixel(x, y)
			if err != nil {
				return err
			}
			if _, err := b.WriteString(fmt.Sprintf("%x", uint8(c))); err != nil {
				return err
			}
		}
		if err := b.WriteByte('\n'); err != nil {
			return err
		}
	}

	return nil
}
