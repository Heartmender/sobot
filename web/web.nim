import jester, asyncdispatch, htmlgen, parsetoml, db_mysql

include "./templates/main.tmpl"

settings:
  port = 5000.Port
  bindAddr = "0.0.0.0"

routes:
  get "/@channel?/?@date?":
    resp baseTemplate(h1("Hello, world!"))

runForever()
