import jester, asyncdispatch, htmlgen, parsetoml, db_mysql

include "./templates/main.tmpl"

routes:
  get "/@channel?/?@date?":
    resp baseTemplate(h1("Hello, world!"))

runForever()
