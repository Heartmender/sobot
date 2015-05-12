[Package]
name          = "sobot"
version       = "0.1.0"
author        = "Quora"
description   = "An IRC bot in Nim."
license       = "CC0"

srcDir        = "src"
bin           = "sobot"

[Deps]
Requires: "nim >= 0.10.0, irc, parsetoml"
