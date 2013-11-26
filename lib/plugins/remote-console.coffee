module.exports = (app) ->
  app.after('http:listen', SERVER.remote_console(app))
  c = app.commandline.commands['remote-console'] = CLIENT.remote_console
  
  c.help = 'remote-console [address]'
  c.description = """
Open a console to your layer-cake server.
  - address: something like localhost:3000 or api.foo.com
"""

SERVER =
  remote_console: (app) ->
    (done) ->
      WebSocket = require 'faye-websocket'
  
      upgrade_listeners = app.http.listeners('upgrade')
      app.http.removeAllListeners('upgrade')
  
      app.http.on 'upgrade', (req, socket, body) ->
        unless req.url is '/__layer-cake_console__'
          l(arguments...) for l in upgrade_listeners
          return
        return unless WebSocket.isWebSocket(req)
        
        config = app.config['layer-cake']?.console
        return socket.end() unless config?.auth?.username? and config?.auth?.password?
        
        ws = new WebSocket(req, socket, body)
    
        ws.on 'open', ->
          {username, password} = config.auth
          ws.send('AUTHENTICATE')
      
          on_message = (msg) ->
            return ws.end() unless new Buffer(username + password).toString('base64') is msg.data.toString()
        
            ws.removeListener('message', on_message)
            SERVER.start_repl(ws, app)
      
          ws.on('message', on_message)
  
      done()

  start_repl: (ws, app) ->
    repl = require 'repl'
    chalk = require 'chalk'
  
    ws.send('OK')

    try
      prompt = require(app.path.root + '/package').name
    catch err
      prompt = 'shell'
    
    ws.repl = repl.start(
      prompt: chalk.cyan('remote:' + prompt + '> ')
      input: ws
      output: ws
      terminal: true
      useColors: true
    )
    ws.repl.context.app = app

    ws.repl.on 'exit', -> ws.end()


CLIENT =
  welcome: (server) ->
    chalk = require 'chalk'
    """
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

  goodbye: [
    'Bye bye now'
    'Thanks for stopping by'
    "It's been a blast"
    'Next time wipe your feet'
  ]

  start_repl: (ws, server, callback) ->
    @log(line) for line in CLIENT.welcome(server).split('\n')
    @log()

    process.stdin.setRawMode(true)
    ws.pipe(process.stdout)
    process.stdin.resume()
    process.stdin.pipe(ws)

    ws.on 'close', =>
      @log()
      @log CLIENT.goodbye[parseInt(4 * Math.random())]
      @log()
      process.exit()
      callback()

  remote_console: (server, callback) ->
    if typeof server is 'function'
      callback = server
      server = null
    
    return callback(new Error('You must pass a server address to remote-console.')) unless typeof server is 'string'
    
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
          CLIENT.start_repl.call(@, ws, server, callback)
        when 'AUTHENTICATE'
          get_creds (err, data) ->
            return callback(err) if err?
            ws.send(new Buffer(data.username + data.password).toString('base64'))

    ws.on('message', on_message)
