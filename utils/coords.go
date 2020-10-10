package utils

func CoordsToIndex(w, x, y int) int {
	return x + y*w
}

func IndexToCoords(w, i int) (int, int) {
	return i % w, i / w
}
