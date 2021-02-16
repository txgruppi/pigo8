package main

import (
	"log"
	"os"

	"github.com/txgruppi/pigo8/cli"
)

func main() {
	if err := cli.NewApp().Run(os.Args); err != nil {
		log.Fatal(err)
	}
}
