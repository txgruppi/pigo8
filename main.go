package main

import (
	"io/ioutil"
	"log"

	"github.com/davecgh/go-spew/spew"
	"github.com/txgruppi/pigo8/encoding/p8"
)

func main() {
	if err := run(); err != nil {
		log.Fatal(err)
	}
}

func run() error {
	data, err := ioutil.ReadFile("/Users/txgruppi/code/src/github.com/txgruppi/pigo8/original.p8")
	if err != nil {
		return err
	}
	encoding := &p8.P8Encoding{}
	cart, err := encoding.Decode(data)
	if err != nil {
		return err
	}
	if true {
		spew.Dump(cart)
	}
	return nil
}
