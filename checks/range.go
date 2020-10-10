package checks

const (
	MaxUint2 int = 0b11
	MaxUint3     = 0b111
	MaxUint4     = 0b1111
	MaxUint5     = 0b11111
	MaxUint6     = 0b111111
	MaxUint7     = 0b1111111
	MaxUint8     = 0b11111111
)

func IsUint2(n int) bool {
	return n >= 0 && n <= MaxUint2
}

func IsUint3(n int) bool {
	return n >= 0 && n <= MaxUint3
}

func IsUint4(n int) bool {
	return n >= 0 && n <= MaxUint4
}

func IsUint5(n int) bool {
	return n >= 0 && n <= MaxUint5
}

func IsUint6(n int) bool {
	return n >= 0 && n <= MaxUint6
}

func IsUint7(n int) bool {
	return n >= 0 && n <= MaxUint7
}

func IsUint8(n int) bool {
	return n >= 0 && n <= MaxUint8
}
