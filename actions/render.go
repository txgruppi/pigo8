package actions

import (
	"fmt"
	"image"
	"image/png"
	"io/ioutil"
	"os"

	"github.com/txgruppi/pigo8/types"

	"github.com/txgruppi/pigo8/renderer"

	"github.com/txgruppi/pigo8/encoding/p8"
)

func Render(section, inputFile, outputFile string, scale int) error {
	if scale <= 0 {
		return fmt.Errorf("scale must be > 0")
	}

	data, err := ioutil.ReadFile(inputFile)
	if err != nil {
		return err
	}

	encoding := &p8.P8Encoding{}
	cart, err := encoding.Decode(data)
	if err != nil {
		return err
	}

	renderer := renderer.NewRenderer(types.NewDefaultPalette())

	var img image.Image
	switch section {
	case "sprite":
		{
			img, err = renderer.SpriteSection(cart.GetSprite(), scale)
		}

	default:
		return fmt.Errorf("unknown render type %q", section)
	}
	if err != nil {
		return err
	}

	file, err := os.OpenFile(outputFile, os.O_CREATE|os.O_TRUNC|os.O_WRONLY, 0600)
	if err != nil {
		return err
	}
	defer file.Close()

	if err := png.Encode(file, img); err != nil {
		return err
	}

	return nil
}
