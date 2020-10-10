from-p8:
	cp "/Users/txgruppi/Library/Application Support/pico-8/carts/ln.p8" ./ln.p8

to-p8:
	cp ./ln.p8 "/Users/txgruppi/Library/Application Support/pico-8/carts/ln.p8"

generate:
	go generate ./...

run: generate
	go run main.go