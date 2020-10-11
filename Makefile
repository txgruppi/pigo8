from-p8:
	cp "/home/txgruppi/.lexaloffle/pico-8/carts/ln.p8" ./ln.p8

to-p8:
	cp ./ln.p8 "/home/txgruppi/.lexaloffle/pico-8/carts/ln.p8"

generate:
	go generate ./...

split-clean:
	rm -rf ./local/split/*

split: generate split-clean
	go run cmd/pigo8/main.go split --input original.p8 --output-folder ./local/split

join: generate
	go run cmd/pigo8/main.go join --output ln.p8 --version 29 --lua ./local/split/original.lua --gfx ./local/split/original.gfx.txt --gff ./local/split/original.gff.txt --map ./local/split/original.map.txt --sfx ./local/split/original.sfx.txt --music ./local/split/original.music.txt --label ./local/split/original.label.txt