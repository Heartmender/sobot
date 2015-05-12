import db_sqlite, irc, os, strutils, times, parsetoml

type
  Bot = object
    nick: string
    channel: string
    database: string

  Server = object
    host: string
    password: string

var t = parsetoml.parseFile("./sobot.conf")

var
  bot: Bot = Bot()
  server: Server = Server()

bot.nick = t.getString("bot.nick")
bot.channel = t.getString("bot.channel")
bot.database = t.getString("bot.database")

server.host = t.getString("server.host")
server.password = t.getString("server.password")

var
  client = newIrc(server.host, nick=bot.nick)
  db = db_sqlite.open(bot.database, "", "", "")
  schema = sql"""
    CREATE TABLE IF NOT EXISTS Chatlines(
      id INTEGER PRIMARY KEY,
      time INTEGER,
      nick TEXT,
      user TEXT,
      host TEXT,
      target TEXT,
      line TEXT
    );
  """

discard db.tryExec(schema)

client.connect()

while true:
  var event: TIRCEvent
  if client.poll(event):
    case event.typ
    of EvMsg:
      if event.cmd == MNumeric:
        if event.numeric == "001":
          client.privmsg("NickServ", "id " & server.password)
          os.sleep(3000)
          client.join(bot.channel)
      if event.cmd == MPrivMsg:
        var msg = event.params[event.params.high]
        case msg
        of "!test":
          client.privmsg(event.origin, "hello")
        of "!lag":
          client.privmsg(event.origin, formatFloat(client.getLag))
        else:
          discard
        discard db.tryExec(sql"INSERT INTO Chatlines VALUES(NULL, ?, ?, ?, ?, ?, ?);", getTime().toSeconds(), event.nick, event.user, event.host, event.params[0], msg)

      echo(event.raw)
    else:
      discard
