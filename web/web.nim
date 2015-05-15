import jester, asyncdispatch, htmlgen, parsetoml, db_mysql, times, strutils, macros

var t = parsetoml.parseFile("../sobot.toml")

include "./templates/main.tmpl"
include "./templates/error.tmpl"
include "./templates/logs.tmpl"

var
  dbhost = t.getString("database.host")
  dbuser = t.getString("database.username")
  dbpass = t.getString("database.password")
  dbname = t.getString("database.database")

  db = db_mysql.open(dbhost, dbuser, dbpass, dbname)
  query = sql"SELECT id, mytime, nick, line FROM Chatlines WHERE target = ?"

const
  robotstxt      = staticRead "robots.txt"

settings:
  port = 5000.Port
  bindAddr = "0.0.0.0"

macro myRoutes(xs: expr, s: stmt): stmt {.immediate.} =
  var list = newStmtList()
  for x in xs.children:
    let file = $x[0]
    let mime = $x[1]
    list.add parseExpr """
      get "/static/$1":
        const content = staticRead "public/$1"
        headers["Cache-Control"] = "public, max-age=31536000"
        resp content, "$2"
    """ % [file, mime]
  for x in s.children:
    list.add x
  result = newCall("routes", list)
 
myRoutes([
  ("css/materialize.min.css", "text/css"),
  ("js/materialize.min.js", "text/javascript"),
  ("js/jquery-2.1.1.min.js", "text/javascript"),
  ("font/roboto/Roboto-Regular.woff2", "application/font-woff2"),
  ("font/roboto/Roboto-Regular.woff", "application/font-woff"),
  ("font/roboto/Roboto-Regular.ttf", "application/octet-stream"),
]):
  get "/robots.txt":
    resp robotstxt, "text/plain"

  get "/":
    resp "No logs selected".errorPage.baseTemplate

  get "/logs/?@channel?":
    var
      channel = @"channel"

    if channel == "":
      channel = t.getString("bot.channel")
    else:
      channel = "#" & channel

    try:
      var rows = db.getAllRows(query, channel)

      if rows.len() == 0:
        resp baseTemplate(errorPage("No logs available"))
      else:
        resp baseTemplate(showLogs(channel, rows), channel)
    except:
      resp baseTemplate(errorPage(getCurrentExceptionMsg()))

runForever()
