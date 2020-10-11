package cli

import (
	"github.com/txgruppi/pigo8/actions"
	"github.com/urfave/cli/v2" // imports as package "cli"
)

func NewApp() *cli.App {
	app := &cli.App{
		Name: "pigo8",
		Commands: []*cli.Command{
			&cli.Command{
				Name: "split",
				Flags: []cli.Flag{
					&cli.StringFlag{Name: "input"},
					&cli.StringFlag{Name: "output-folder"},
				},
				Action: func(c *cli.Context) error {
					return actions.Split(c.String("input"), c.String("output-folder"))
				},
			},
			&cli.Command{
				Name: "join",
				Flags: []cli.Flag{
					&cli.StringFlag{Name: "output"},
					&cli.IntFlag{Name: "version"},
					&cli.StringFlag{Name: "lua"},
					&cli.StringFlag{Name: "gfx"},
					&cli.StringFlag{Name: "gff"},
					&cli.StringFlag{Name: "map"},
					&cli.StringFlag{Name: "sfx"},
					&cli.StringFlag{Name: "music"},
					&cli.StringFlag{Name: "label"},
				},
				Action: func(c *cli.Context) error {
					return actions.Join(
						c.String("output"),
						c.Int("version"),
						c.String("lua"),
						c.String("gfx"),
						c.String("gff"),
						c.String("map"),
						c.String("sfx"),
						c.String("music"),
						c.String("label"),
					)
				},
			},
		},
	}
	return app
}
