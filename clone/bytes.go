package clone

func Bytes(src []byte) []byte {
	if src == nil {
		return nil
	}
	dst := make([]byte, len(src))
	for k, v := range src {
		dst[k] = v
	}
	return dst
}
