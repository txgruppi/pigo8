package types

func NewCart() Cart {
	return &_Cart{}
}

type Cart interface {
	GetHeader() Header
	SetHeader(Header)
	GetCode() CodeSection
	SetCode(CodeSection)
	GetSprite() SpriteSection
	SetSprite(SpriteSection)
	GetMap() MapSection
	SetMap(MapSection)
	GetSoundEffect() SoundEffectSection
	SetSoundEffect(SoundEffectSection)
	GetMusic() MusicSection
	SetMusic(MusicSection)
	GetLabel() LabelSection
	SetLabel(LabelSection)
}

type _Cart struct {
	header             Header
	codeSection        CodeSection
	spriteSection      SpriteSection
	mapSection         MapSection
	soundEffectSection SoundEffectSection
	musicSection       MusicSection
	labelSection       LabelSection
}

func (t *_Cart) GetHeader() Header {
	return t.header
}

func (t *_Cart) SetHeader(v Header) {
	t.header = v
}

func (t *_Cart) GetCode() CodeSection {
	return t.codeSection
}

func (t *_Cart) SetCode(v CodeSection) {
	t.codeSection = v
}

func (t *_Cart) GetSprite() SpriteSection {
	return t.spriteSection
}

func (t *_Cart) SetSprite(v SpriteSection) {
	t.spriteSection = v
}

func (t *_Cart) GetMap() MapSection {
	return t.mapSection
}

func (t *_Cart) SetMap(v MapSection) {
	t.mapSection = v
}

func (t *_Cart) GetSoundEffect() SoundEffectSection {
	return t.soundEffectSection
}

func (t *_Cart) SetSoundEffect(v SoundEffectSection) {
	t.soundEffectSection = v
}

func (t *_Cart) GetMusic() MusicSection {
	return t.musicSection
}

func (t *_Cart) SetMusic(v MusicSection) {
	t.musicSection = v
}

func (t *_Cart) GetLabel() LabelSection {
	return t.labelSection
}

func (t *_Cart) SetLabel(v LabelSection) {
	t.labelSection = v
}
