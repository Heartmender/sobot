import dynlib, os

type Handler = proc(nick: cstring,
                    user: cstring,
                    host: cstring,
                    target: cstring,
                    msg: cstring): cstring

type
  Command* = object
    name*: string
    handler*: Handler
    lib: LibHandle

proc loadCommand*(name: string): Command =
  var c = Command(name: name)
  c.lib = dynlib.loadLib("modules/" & name & ".so")
  c.handler = cast[proc(nick: cstring,
                        user: cstring,
                        host: cstring,
                        target: cstring,
                        msg: cstring): cstring {.nimcall.}](
    c.lib.symAddr("doCommand"))

  if c.handler == nil:
    raise newException(Exception, "Could not load modules/" & name & ".so")

  return c

proc unloadCommand*(c: Command) =
  c.lib.unloadLib()
