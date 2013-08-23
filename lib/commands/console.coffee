chalk = require 'chalk'
WebSocket = require 'faye-websocket'

welcome = (server) -> """
You're connected to #{chalk.cyan(server)}! Take a look around!

== Objects ==
  app      Your application

== Commands ==
  .break   Sometimes you get stuck, this gets you out
  .clear   Break, and also clear the local context
  .exit    Exit the repl
  .help    Show repl options
  .load    Load JS from a file into the REPL session
  .save    Save all evaluated commands in this REPL session to a file
"""

goodbye = [
  'Bye bye now'
  'Thanks for stopping by'
  "It's been a blast"
  'Next time wipe your feet'
]

exports.console = (server, cb) ->
  if typeof server is 'function'
    cb = server
    server = null
  
  return cb(new Error('Usage: console [server]      # like localhost:3000')) unless server?
  
  ws = new WebSocket.Client 'ws://' + server + '/__layers_console__'

  process.stdin.setRawMode(true)
  ws.pipe(process.stdout)
  process.stdin.pipe(ws)
  
  ws.on 'open', =>
    @log(line) for line in welcome(server).split('\n')
    @log()
  
  ws.on 'close', =>
    @log()
    @log goodbye[parseInt(4 * Math.random())]
    @log()
    process.exit()
    cb()
