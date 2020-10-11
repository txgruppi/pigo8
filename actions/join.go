package actions

import (
	"bytes"
	"io/ioutil"

	"github.com/txgruppi/pigo8/encoding/p8"
	"github.com/txgruppi/pigo8/types"
)

func Join(
	outputFile string,
	version int,
	luaFile string,
	gfxFile string,
	gffFile string,
	mapFile string,
	sfxFile string,
	musicFile string,
	labelFile string,
) error {
	cart := types.NewCart()
	header := types.NewHeader()
	header.SetVersion(version)
	cart.SetHeader(header)

	encoding := &p8.P8Encoding{}

	if luaFile != "" {
		data, err := ioutil.ReadFile(luaFile)
		if err != nil {
			return err
		}
		if err := encoding.DecodeCode(cart, bytes.Split(data, []byte("\n"))); err != nil {
			return err
		}
	}
	if gfxFile != "" {
		data, err := ioutil.ReadFile(gfxFile)
		if err != nil {
			return err
		}
		if err := encoding.DecodeSprite(cart, bytes.Split(data, []byte("\n"))); err != nil {
			return err
		}
	}
	if gffFile != "" {
		data, err := ioutil.ReadFile(gffFile)
		if err != nil {
			return err
		}
		if err := encoding.DecodeSpriteFlag(cart, bytes.Split(data, []byte("\n"))); err != nil {
			return err
		}
	}
	if mapFile != "" {
		data, err := ioutil.ReadFile(mapFile)
		if err != nil {
			return err
		}
		if err := encoding.DecodeMap(cart, bytes.Split(data, []byte("\n"))); err != nil {
			return err
		}
	}
	if sfxFile != "" {
		data, err := ioutil.ReadFile(sfxFile)
		if err != nil {
			return err
		}
		if err := encoding.DecodeSoundEffect(cart, bytes.Split(data, []byte("\n"))); err != nil {
			return err
		}
	}
	if musicFile != "" {
		data, err := ioutil.ReadFile(musicFile)
		if err != nil {
			return err
		}
		if err := encoding.DecodeMusic(cart, bytes.Split(data, []byte("\n"))); err != nil {
			return err
		}
	}
	if labelFile != "" {
		data, err := ioutil.ReadFile(labelFile)
		if err != nil {
			return err
		}
		if err := encoding.DecodeLabel(cart, bytes.Split(data, []byte("\n"))); err != nil {
			return err
		}
	}

	data, err := encoding.Encode(cart)
	if err != nil {
		return err
	}
	if err := ioutil.WriteFile(outputFile, data, 0600); err != nil {
		return err
	}

	return nil
}
