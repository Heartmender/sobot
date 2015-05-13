import command, db_mysql, asyncdispatch, irc, os, strutils, times, parsetoml

type
  Bot = object
    nick: string
    channel: string

  Server = object
    host: string
    password: string

var t = parsetoml.parseFile("./sobot.toml")

var
  bot: Bot = Bot()
  server: Server = Server()
  cmd: Command

bot.nick = t.getString("bot.nick")
bot.channel = t.getString("bot.channel")

server.host = t.getString("server.host")
server.password = t.getString("server.password")

var
  dbhost = t.getString("database.host")
  dbuser = t.getString("database.username")
  dbpass = t.getString("database.password")
  dbname = t.getString("database.database")

var
  db = db_mysql.open(dbhost, dbuser, dbpass, dbname)
  schema = sql"""
    CREATE TABLE IF NOT EXISTS Chatlines(
      id INTEGER PRIMARY KEY AUTO_INCREMENT,
      time   INTEGER,
      nick   VARCHAR(31),
      user   VARCHAR(10),
      host   VARCHAR(150),
      target VARCHAR(150),
      line   VARCHAR(510)
    );
  """

discard db.tryExec(schema)

proc onIrcEvent(client: PAsyncIrc, event: TIrcEvent) {.async.} =
  case event.typ
  of EvDisconnected, EvTimeout:
    await client.reconnect()
  of EvMsg:
    if event.cmd == MNumeric:
      if event.numeric == "001":
        echo event.params[event.params.high]
        await client.privmsg("NickServ", "id " & server.password)
        echo "Identifying to NickServ..."
        os.sleep(3000)
        await client.join(bot.channel)
        echo "Connected and joined to " & bot.channel
    if event.cmd == MPrivMsg:
      var msg = event.params[event.params.high]
      case msg
      of "!test":
        await client.privmsg(event.origin, "hello")
      of "!lag":
        await client.privmsg(event.origin, formatFloat(client.getLag))
      of "!load":
        cmd = loadCommand("hello")
        var result = cmd.handler(
          event.nick.cstring, event.user.cstring, event.host.cstring, event.origin.cstring, msg.cstring)
        await client.privmsg(event.origin, $result)
        cmd.unloadCommand()
      else:
        discard
      db.exec(sql"INSERT INTO Chatlines VALUES(0, ?, ?, ?, ?, ?, ?);", getTime().toSeconds(), event.nick, event.user, event.host, event.params[0], msg)
  else:
    discard

var client = newAsyncIrc(server.host, nick=bot.nick, callback=onIrcEvent)

echo "Connecting to " & server.host & "..."

asyncCheck client.run()

runForever()
