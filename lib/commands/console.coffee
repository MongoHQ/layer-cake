chalk = require 'chalk'

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

start_repl = (ws, server, callback) ->
  @log(line) for line in welcome(server).split('\n')
  @log()
  
  process.stdin.setRawMode(true)
  ws.pipe(process.stdout)
  process.stdin.resume()
  process.stdin.pipe(ws)
  
  ws.on 'close', =>
    @log()
    @log goodbye[parseInt(4 * Math.random())]
    @log()
    process.exit()
    callback()

remote_console = (server, callback) ->
  WebSocket = require 'faye-websocket'
  
  ws = new WebSocket.Client('ws://' + server + '/__layer-cake_console__')
  was_opened = false
  ws.on 'open', -> was_opened = true
  ws.on 'close', ->
    return callback(new Error('Could not connect to ' + server)) if was_opened is false
    callback()
  
  get_creds = (cb) =>
    @prompt.get(
      properties:
        username:
          required: true
        password:
          required: true
          hidden: true
    , cb)
  
  on_message = (msg) =>
    switch msg.data.toString()
      when 'OK'
        ws.removeListener('message', on_message)
        start_repl.call(@, ws, server, callback)
      when 'AUTHENTICATE'
        get_creds (err, data) ->
          return callback(err) if err?
          ws.send(new Buffer(data.username + data.password).toString('base64'))
  
  ws.on('message', on_message)

local_console = (callback) ->
  app = @create_app()
  
  prompt = require(require('path').join(app.path.root, 'package.json')).name or 'layer-cake'
  
  app.initialize 'init', (err) ->
    return callback(err) if err?
  
    repl = require('repl').start(
      prompt: prompt + '> '
    )
    repl.context.app = app
    repl.context.$_ = -> console.log(arguments)

    repl.on 'exit', -> callback()

exports.console = (server, callback) ->
  return local_console.call(@, server) if typeof server is 'function'
  remote_console.call(@, server, callback)
