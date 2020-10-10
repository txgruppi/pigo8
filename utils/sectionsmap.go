package utils

func NewSectionsMap() *SectionsMap {
	return &SectionsMap{
		m: map[string]int{
			"__lua__":   -1,
			"__gfx__":   -1,
			"__gff__":   -1,
			"__label__": -1,
			"__map__":   -1,
			"__sfx__":   -1,
			"__music__": -1,
		},
		i: []string{
			"__lua__",
			"__gfx__",
			"__gff__",
			"__label__",
			"__map__",
			"__sfx__",
			"__music__",
		},
	}
}

type SectionsMap struct {
	m map[string]int
	i []string
}

func (t *SectionsMap) IsSectionTag(s string) bool {
	_, ok := t.m[s]
	return ok
}

func (t *SectionsMap) Key(i int) string {
	if i >= len(t.i) {
		return ""
	}
	return t.i[i]
}

func (t *SectionsMap) Value(i int) int {
	if i >= len(t.i) {
		return -1
	}
	return t.m[t.i[i]]
}

func (t *SectionsMap) Pair(i int) (string, int) {
	if i >= len(t.i) {
		return "", -1
	}
	return t.i[i], t.m[t.i[i]]
}

func (t *SectionsMap) Set(s string, v int) {
	if t.IsSectionTag(s) {
		t.m[s] = v
	}
}

func (t *SectionsMap) Len() int {
	return len(t.m)
}

func (t *SectionsMap) Less(i, j int) bool {
	return t.m[t.i[i]] < t.m[t.i[j]]
}

func (t *SectionsMap) Swap(i, j int) {
	t.i[i], t.i[j] = t.i[j], t.i[i]
}
