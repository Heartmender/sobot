sobot
=====

A simple IRC bot in Nim for tulpa.im use. You will need the nim compiler (this 
is developed and tested on version 0.11.2), a mysql database and a linux server 
to run it on.

Config
------

This is just a toml file. The bot core and the web module both depend on it.

```ini
[bot]
nick = "Sobot"
channel = "#quoratest123"

[server]
host = "irc.tulpa.im"
password = "foobang"

[database]
host = "127.0.0.1:3306"
username = "database"
password = "asdfasdfasdf"
database = "logs"
```

Despite what it looks like, `server.password` is a NickServ password.

Modules
-------

Making modules is easy. Make a `.nim` file in `modules/` and have it have 
a proc that matches this call signature:

```nimrod
proc doCommand*(nick: cstring,
                user: cstring,
                host: cstring,
                target: cstring,
                msg: cstring): cstring {.exportc.} =
```

Then load it in `src/sobot.nim` and go nuts!

Web
---

Build the project in `web/` and serve it via nginx. It expects to be run with 
the `sobot.toml` file it its parent directory. It expects:

| route            | description                                  |
|:---------------- |:-------------------------------------------- |
| `/`              | The main page (right now a false error page) |
| `/logs/@channel` | logs for `@channel` with `#` prepended       |
