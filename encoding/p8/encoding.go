package p8

import (
	"bytes"
	"sort"
	"strconv"

	"github.com/txgruppi/pigo8/errors"
	"github.com/txgruppi/pigo8/utils"

	"github.com/txgruppi/pigo8/types"
)

type P8Encoding struct {
}

func (t *P8Encoding) Decode(data []byte) (types.Cart, error) {
	sections := utils.NewSectionsMap()
	cart := types.NewCart()
	lines := bytes.Split(data, []byte("\n"))

	for i := range lines {
		lines[i] = bytes.TrimSpace(lines[i])
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
		key := sections.Key(i)

		switch key {
		case "__lua__":
			{
				if err := t.decodeCodeSection(cart, lines, start, end); err != nil {
					return nil, err
				}
			}

		case "__gfx__":
			{
				if err := t.decodeSpriteSection(cart, lines, start, end); err != nil {
					return nil, err
				}
			}

		case "__gff__":
			{
				if err := t.decodeSpriteFlags(cart, lines, start, end); err != nil {
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

func (t *P8Encoding) decodeCodeSection(cart types.Cart, lines [][]byte, start, end int) error {
	lines = t.trimLines(lines[start:end], "__lua__")

	tabs := [][]byte{}
	for i, j := 0, 0; i < len(lines); i++ {
		if bytes.Equal(lines[i], []byte("-->8")) || i == len(lines)-1 {
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

func (t *P8Encoding) decodeSpriteSection(cart types.Cart, lines [][]byte, start, end int) error {
	lines = t.trimLines(lines[start:end], "__gfx__")

	spriteSection := cart.GetSprite()
	if spriteSection == nil {
		spriteSection = types.NewSpriteSection()
	}

	for y := 0; y < len(lines); y++ {
		for x := 0; x < len(lines[y]); x++ {
			i, err := strconv.ParseInt(string(lines[y][x]), 16, 0)
			if err != nil {
				return err
			}
			id := utils.CoordsToIndex(16, x/8, y/8)
			sprite, err := spriteSection.GetSprite(id)
			if err != nil {
				return err
			}
			if sprite == nil {
				sprite = types.NewSprite()
			}
			c, err := types.ColorFromInt(int(i))
			if err != nil {
				return err
			}
			if err := sprite.SetPixel(x%8, y%8, c); err != nil {
				return err
			}
			err = spriteSection.SetSprite(id, sprite)
			if err != nil {
				return err
			}
		}
	}

	cart.SetSprite(spriteSection)

	return nil
}

func (t *P8Encoding) decodeSpriteFlags(cart types.Cart, lines [][]byte, start, end int) error {
	lines = t.trimLines(lines[start:end], "__gff__")

	spriteSection := cart.GetSprite()
	if spriteSection == nil {
		spriteSection = types.NewSpriteSection()
	}

	id := 0
	for y := 0; y < len(lines); y++ {
		for x := 0; x < len(lines[y]); x += 2 {
			d0, err := strconv.ParseInt(string(lines[y][x]), 16, 0)
			if err != nil {
				return err
			}
			d1, err := strconv.ParseInt(string(lines[y][x+1]), 16, 0)
			if err != nil {
				return err
			}
			sprite, err := spriteSection.GetSprite(id)
			if err != nil {
				return err
			}
			if sprite == nil {
				sprite = types.NewSprite()
			}
			sprite.SetFlags(uint8((d0 << 4) | d1))
			err = spriteSection.SetSprite(id, sprite)
			if err != nil {
				return err
			}
			id++
		}
	}

	return nil
}

func (t *P8Encoding) trimLines(lines [][]byte, tagToSkip string) [][]byte {
	for lines[0] == nil || (tagToSkip != "" && bytes.Equal(lines[0], []byte(tagToSkip))) {
		lines = lines[1:]
	}
	for lines[len(lines)-1] == nil {
		lines = lines[:len(lines)-1]
	}
	return lines
}
