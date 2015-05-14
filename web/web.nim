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

settings:
  port = 5000.Port
  bindAddr = "0.0.0.0"

routes:
  get "/@channel?":
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
