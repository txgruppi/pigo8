package encoding

import (
	"github.com/txgruppi/pigo8/types"
)

type Encoding interface {
	Decode([]byte) (types.Cart, error)
	Encode(types.Cart) ([]byte, error)
}
