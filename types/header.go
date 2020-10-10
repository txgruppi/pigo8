package types

func NewHeader() Header {
	return &_Header{}
}

type Header interface {
	GetVersion() int
	SetVersion(int)
}

type _Header struct {
	version int
}

func (t *_Header) GetVersion() int {
	return t.version
}

func (t *_Header) SetVersion(v int) {
	t.version = v
}
