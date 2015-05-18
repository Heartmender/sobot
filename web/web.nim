import jester, asyncdispatch, htmlgen, parsetoml, db_mysql, times, strutils, macros

var t = parsetoml.parseFile("../sobot.toml")

include "./templates/main.tmpl"
include "./templates/error.tmpl"
include "./templates/logs.tmpl"
include "./templates/summary.tmpl"

var
  dbhost = t.getString("database.host")
  dbuser = t.getString("database.username")
  dbpass = t.getString("database.password")
  dbname = t.getString("database.database")

  db = db_mysql.open(dbhost, dbuser, dbpass, dbname)
  query = sql"SELECT id, mytime, nick, line FROM Chatlines WHERE target = ?"
  distinctquery = sql"SELECT DISTINCT target FROM Chatlines;"
  calloutquery = sql"SELECT id, target, mytime, nick, line FROM Chatlines WHERE target = ? ORDER BY id DESC LIMIT 1;"

const
  robotstxt      = staticRead "robots.txt"

settings:
  port = 5000.Port
  bindAddr = "0.0.0.0"

routes:
  get "/robots.txt":
    resp robotstxt, "text/plain"

  get "/":
    var
      channels = db.getAllRows(distinctquery)
      res: seq[TRow]

    for channelseq in channels:
      res = res & db.getRow(calloutquery, channelseq[0])

    resp res.logSummary.baseTemplate

  get "/logs/@channel":
    var
      channel = @"channel"

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
