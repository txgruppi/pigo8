package main

import (
	"io/ioutil"
	"log"

	"github.com/txgruppi/pigo8/encoding/p8"
)

func main() {
	if err := run(); err != nil {
		log.Fatal(err)
	}
}

func run() error {
	data, err := ioutil.ReadFile("/mnt/code/src/github.com/txgruppi/pigo8/original.p8")
	if err != nil {
		return err
	}
	encoding := &p8.P8Encoding{}
	cart, err := encoding.Decode(data)
	if err != nil {
		return err
	}
	newData, err := encoding.Encode(cart)
	if err != nil {
		return err
	}
	return ioutil.WriteFile("/mnt/code/src/github.com/txgruppi/pigo8/ln.p8", newData, 0600)
}
