package actions

import (
	"bytes"
	"io/ioutil"
	"path"

	"github.com/txgruppi/pigo8/encoding/p8"
)

func Split(input, outputFolder string) error {
	encoding := &p8.P8Encoding{}

	data, err := ioutil.ReadFile(input)
	if err != nil {
		return err
	}

	cart, err := encoding.Decode(data)
	if err != nil {
		return err
	}

	ext := path.Ext(input)
	basename := path.Base(input)
	basename = basename[:len(basename)-len(ext)]
	var b bytes.Buffer
	if cart.GetCode() != nil {
		if err := encoding.EncodeCode(cart.GetCode(), &b, false); err != nil {
			return err
		}
		if err := ioutil.WriteFile(path.Join(outputFolder, basename+".lua"), b.Bytes(), 0600); err != nil {
			return err
		}
		b.Reset()
	}
	if cart.GetSprite() != nil {
		if err := encoding.EncodeSprite(cart.GetSprite(), &b, false); err != nil {
			return err
		}
		if err := ioutil.WriteFile(path.Join(outputFolder, basename+".gfx.txt"), b.Bytes(), 0600); err != nil {
			return err
		}
		b.Reset()
	}
	if cart.GetSpriteFlag() != nil {
		if err := encoding.EncodeSpriteFlag(cart.GetSpriteFlag(), &b, false); err != nil {
			return err
		}
		if err := ioutil.WriteFile(path.Join(outputFolder, basename+".gff.txt"), b.Bytes(), 0600); err != nil {
			return err
		}
		b.Reset()
	}
	if cart.GetMap() != nil {
		if err := encoding.EncodeMap(cart.GetMap(), &b, false); err != nil {
			return err
		}
		if err := ioutil.WriteFile(path.Join(outputFolder, basename+".map.txt"), b.Bytes(), 0600); err != nil {
			return err
		}
		b.Reset()
	}
	if cart.GetSoundEffect() != nil {
		if err := encoding.EncodeSoundEffect(cart.GetSoundEffect(), &b, false); err != nil {
			return err
		}
		if err := ioutil.WriteFile(path.Join(outputFolder, basename+".sfx.txt"), b.Bytes(), 0600); err != nil {
			return err
		}
		b.Reset()
	}
	if cart.GetMusic() != nil {
		if err := encoding.EncodeMusic(cart.GetMusic(), &b, false); err != nil {
			return err
		}
		if err := ioutil.WriteFile(path.Join(outputFolder, basename+".music.txt"), b.Bytes(), 0600); err != nil {
			return err
		}
		b.Reset()
	}
	if cart.GetLabel() != nil {
		if err := encoding.EncodeLabel(cart.GetLabel(), &b, false); err != nil {
			return err
		}
		if err := ioutil.WriteFile(path.Join(outputFolder, basename+".label.txt"), b.Bytes(), 0600); err != nil {
			return err
		}
		b.Reset()
	}
	return nil
}
