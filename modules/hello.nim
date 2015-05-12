proc doCommand*(nick: cstring,
                user: cstring,
                host: cstring,
                target: cstring,
                msg: cstring): cstring {.exportc.} =
  return "Hello!"
