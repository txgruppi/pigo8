package p8

import (
	"bytes"
	"sort"
	"strconv"

	"github.com/txgruppi/pigo8/errors"
	"github.com/txgruppi/pigo8/utils"

	"github.com/txgruppi/pigo8/types"
)

func (t *P8Encoding) Decode(data []byte) (types.Cart, error) {
	sections := utils.NewSectionsMap()
	cart := types.NewCart()
	lines := bytes.Split(data, []byte("\n"))

	for i := range lines {
		if sections.IsSectionTag(string(lines[i])) {
			sections.Set(string(lines[i]), i)
		}
	}
	sort.Sort(sections)

	if err := t.decodeHeader(cart, lines); err != nil {
		return nil, err
	}

	for i := 0; i < sections.Len(); i++ {
		start := sections.Value(i)
		if start == -1 {
			continue
		}

		end := sections.Value(i + 1)
		if end == -1 {
			end = len(lines)
		}
		key := sections.Key(i)

		switch key {
		case "__lua__":
			{
				if err := t.DecodeCode(cart, lines[start+1:end]); err != nil {
					return nil, err
				}
			}

		case "__gfx__":
			{
				if err := t.DecodeSprite(cart, lines[start+1:end]); err != nil {
					return nil, err
				}
			}

		case "__gff__":
			{
				if err := t.DecodeSpriteFlag(cart, lines[start+1:end]); err != nil {
					return nil, err
				}
			}

		case "__map__":
			{
				if err := t.DecodeMap(cart, lines[start+1:end]); err != nil {
					return nil, err
				}
			}

		case "__sfx__":
			{
				if err := t.DecodeSoundEffect(cart, lines[start+1:end]); err != nil {
					return nil, err
				}
			}

		case "__music__":
			{
				if err := t.DecodeMusic(cart, lines[start+1:end]); err != nil {
					return nil, err
				}
			}

		case "__label__":
			{
				if err := t.DecodeLabel(cart, lines[start+1:end]); err != nil {
					return nil, err
				}
			}
		}
	}

	return cart, nil
}

func (t *P8Encoding) decodeHeader(cart types.Cart, lines [][]byte) error {
	if !bytes.HasPrefix(lines[0], []byte("pico-8 cartridge")) {
		return errors.NewErrInvalidHeader()
	}
	if !bytes.HasPrefix(lines[1], []byte("version ")) || len(lines[1]) < 9 {
		return errors.NewErrInvalidHeader()
	}
	n, err := strconv.Atoi(string(lines[1][8:]))
	if err != nil {
		return err
	}
	header := types.NewHeader()
	header.SetVersion(n)
	cart.SetHeader(header)
	return nil
}

func (t *P8Encoding) DecodeCode(cart types.Cart, lines [][]byte) error {
	lines = t.trimLines(lines)

	tabs := [][]byte{}
	for i, j := 0, 0; i < len(lines); i++ {
		if bytes.Equal(lines[i], []byte("-->8")) || i == len(lines)-1 {
			if i == len(lines)-1 {
				i++
			}
			tabs = append(tabs, bytes.Join(lines[j:i], []byte("\n")))
			j = i + 1
		}
	}

	codeSection := types.NewCodeSection()
	for i, v := range tabs {
		if err := codeSection.SetTab(i, v); err != nil {
			return err
		}
	}

	cart.SetCode(codeSection)
	return nil
}

func (t *P8Encoding) DecodeSprite(cart types.Cart, lines [][]byte) error {
	lines = t.trimLines(lines)

	spriteSection := types.NewSpriteSection()

	for y := 0; y < len(lines); y++ {
		for x := 0; x < len(lines[y]); x++ {
			n, err := t.parseIntFromHex(lines[y], x, 1)
			if err != nil {
				return err
			}
			c, err := types.ColorFromInt(n)
			if err != nil {
				return err
			}
			if err := spriteSection.SetPixel(x, y, c); err != nil {
				return err
			}
		}
	}

	cart.SetSprite(spriteSection)

	return nil
}

func (t *P8Encoding) DecodeSpriteFlag(cart types.Cart, lines [][]byte) error {
	lines = t.trimLines(lines)

	spriteFlagSection := types.NewSpriteFlagSection()

	id := 0
	for y := 0; y < len(lines); y++ {
		for x := 0; x < len(lines[y]); x += 2 {
			n, err := t.parseIntFromHex(lines[y], x, 2)
			if err != nil {
				return err
			}
			if err := spriteFlagSection.SetFlags(id, uint8(n)); err != nil {
				return err
			}
			id++
		}
	}

	cart.SetSpriteFlag(spriteFlagSection)

	return nil
}

func (t *P8Encoding) DecodeMap(cart types.Cart, lines [][]byte) error {
	lines = t.trimLines(lines)

	mapSection := types.NewMapSection()
	for y := 0; y < len(lines); y++ {
		for x := 0; x < len(lines[y]); x += 2 {
			n, err := t.parseIntFromHex(lines[y], x, 2)
			if err != nil {
				return err
			}
			if err := mapSection.SetTile(x/2, y, int(n)); err != nil {
				return err
			}
		}
	}

	cart.SetMap(mapSection)

	return nil
}

func (t *P8Encoding) DecodeSoundEffect(cart types.Cart, lines [][]byte) error {
	lines = t.trimLines(lines)

	soundEffectSection := types.NewSoundEffectSection()
	id := 0
	for y := 0; y < len(lines); y++ {
		soundEffect := types.NewSoundEffect()
		n, err := t.parseIntFromHex(lines[y], 0, 2)
		if err != nil {
			return err
		}
		mode, err := types.SoundEffectModeFromInt(int(n))
		if err != nil {
			return err
		}
		soundEffect.SetMode(mode)
		n, err = t.parseIntFromHex(lines[y], 2, 2)
		if err != nil {
			return err
		}
		soundEffect.SetDuration(uint8(n))
		n, err = t.parseIntFromHex(lines[y], 4, 2)
		if err != nil {
			return err
		}
		m, err := t.parseIntFromHex(lines[y], 6, 2)
		if err != nil {
			return err
		}
		if err := soundEffect.SetLoopRange(n, m); err != nil {
			return err
		}
		noteID := 0
		for x := 8; x < len(lines[y]); {
			note := types.NewNote()
			n, err = t.parseIntFromHex(lines[y], x, 2)
			if err != nil {
				return err
			}
			if err := note.SetPitch(n); err != nil {
				return err
			}
			x += 2
			n, err = t.parseIntFromHex(lines[y], x, 1)
			if err != nil {
				return err
			}
			if err := note.SetWaveform(n); err != nil {
				return err
			}
			x++
			n, err = t.parseIntFromHex(lines[y], x, 1)
			if err != nil {
				return err
			}
			if err := note.SetVolume(n); err != nil {
				return err
			}
			x++
			n, err = t.parseIntFromHex(lines[y], x, 1)
			if err != nil {
				return err
			}
			if err := note.SetEffect(n); err != nil {
				return err
			}
			x++
			if err := soundEffect.SetNote(noteID, note); err != nil {
				return err
			}
			noteID++
		}
		if err := soundEffectSection.SetSoundEffect(id, soundEffect); err != nil {
			return err
		}
		id++
	}

	cart.SetSoundEffect(soundEffectSection)

	return nil
}

func (t *P8Encoding) DecodeMusic(cart types.Cart, lines [][]byte) error {
	lines = t.trimLines(lines)

	musicSection := types.NewMusicSection()

	id := 0
	for y := 0; y < len(lines); y++ {
		music := types.NewMusic()
		n, err := t.parseIntFromHex(lines[y], 0, 2)
		if err != nil {
			return err
		}
		pattern, err := types.MusicPatternFromInt(n)
		if err != nil {
			return err
		}
		if err := music.SetPatternFlags(pattern); err != nil {
			return err
		}
		for x := 0; x < 4; x++ {
			n, err := t.parseIntFromHex(lines[y], 3+x*2, 2)
			if err != nil {
				return err
			}
			if err := music.SetChannel(x, n); err != nil {
				return err
			}
		}
		musicSection.SetMusic(id, music)
		id++
	}

	cart.SetMusic(musicSection)

	return nil
}

func (t *P8Encoding) DecodeLabel(cart types.Cart, lines [][]byte) error {
	lines = t.trimLines(lines)

	labelSection := types.NewLabelSection()

	for y := 0; y < len(lines); y++ {
		for x := 0; x < len(lines[y]); x++ {
			n, err := t.parseIntFromHex(lines[y], x, 1)
			if err != nil {
				return err
			}
			c, err := types.ColorFromInt(n)
			if err != nil {
				return err
			}
			if err := labelSection.SetPixel(x, y, c); err != nil {
				return err
			}
		}
	}

	cart.SetLabel(labelSection)

	return nil
}

func (t *P8Encoding) trimLines(lines [][]byte) [][]byte {
	if lines == nil {
		return lines
	}
	for len(lines) > 0 && (lines[0] == nil || len(lines[0]) == 0) {
		lines = lines[1:]
	}
	for len(lines) > 0 && (lines[len(lines)-1] == nil || len(lines[len(lines)-1]) == 0) {
		lines = lines[:len(lines)-1]
	}
	return lines
}

func (t *P8Encoding) parseIntFromHex(line []byte, i, n int) (int, error) {
	v, err := strconv.ParseInt(string(line[i:i+n]), 16, 0)
	if err != nil {
		return 0, err
	}
	return int(v), nil
}
