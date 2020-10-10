//go:generate stringer -type=color
package types

import (
	"github.com/txgruppi/pigo8/errors"
)

type color uint8

const (
	Color0 color = iota
	Color1
	Color2
	Color3
	Color4
	Color5
	Color6
	Color7
	Color8
	Color9
	Color10
	Color11
	Color12
	Color13
	Color14
	Color15
)

func ColorFromInt(i int) (color, error) {
	switch i {
	case 0:
		return Color0, nil
	case 1:
		return Color1, nil
	case 2:
		return Color2, nil
	case 3:
		return Color3, nil
	case 4:
		return Color4, nil
	case 5:
		return Color5, nil
	case 6:
		return Color6, nil
	case 7:
		return Color7, nil
	case 8:
		return Color8, nil
	case 9:
		return Color9, nil
	case 10:
		return Color10, nil
	case 11:
		return Color11, nil
	case 12:
		return Color12, nil
	case 13:
		return Color13, nil
	case 14:
		return Color14, nil
	case 15:
		return Color15, nil
	default:
		return Color0, errors.NewErrInvalidColorIndex(i)
	}
}
