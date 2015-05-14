import jester, asyncdispatch, htmlgen, parsetoml, db_mysql, times, strutils

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
  materializeCSS = staticRead "public/css/materialize.min.css"
  materializeJS  = staticRead "public/js/materialize.min.js"
  jqueryJS       = staticRead "public/js/jquery-2.1.1.min.js"
  robotoregwoff2 = staticRead "public/font/roboto/Roboto-Regular.woff2"
  robotoregwoff  = staticRead "public/font/roboto/Roboto-Regular.woff"
  robotoregttf   = staticRead "public/font/roboto/Roboto-Regular.ttf"

settings:
  port = 5000.Port
  bindAddr = "0.0.0.0"

routes:
  get "/static/css/materialize.min.css":
    headers["Cache-Control"] = "public, max-age=31536000"
    resp materializeCSS, "text/css"

  get "/static/js/materialize.min.js":
    headers["Cache-Control"] = "public, max-age=31536000"
    resp materializeJS, "text/javascript"

  get "/static/js/jquery-2.1.1.min.js":
    headers["Cache-Control"] = "public, max-age=31536000"
    resp jqueryJS, "text/javascript"

  get "/static/font/roboto/Roboto-Regular.woff2":
    headers["Cache-Control"] = "public, max-age=31536000"
    resp robotoregwoff2, "application/font-woff2"

  get "/static/font/roboto/Roboto-Regular.woff":
    headers["Cache-Control"] = "public, max-age=31536000"
    resp robotoregwoff, "application/font-woff"

  get "/static/font/roboto/Roboto-Regular.ttf":
    headers["Cache-Control"] = "public, max-age=31536000"
    resp robotoregttf, "application/octet-stream"

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
