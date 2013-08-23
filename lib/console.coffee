repl = require 'repl'
WebSocket = require 'faye-websocket'

upgrade_listeners = []

module.exports = (app, callback) ->
  upgrade_listeners = app.http.listeners('upgrade')
  app.http.removeAllListeners('upgrade')
  
  app.http.on 'upgrade', (req, socket, body) ->
    unless req.url is '/__layers_console__'
      l(arguments...) for l in upgrade_listeners
      return
    return unless WebSocket.isWebSocket(req)
  
    ws = new WebSocket(req, socket, body)
  
    try
      prompt = require(app.path.root + '/package').name
    catch err
      prompt = 'shell'
  
    socket.repl = repl.start(
      prompt: prompt + '> '
      input: ws
      output: ws
      terminal: true
      useColors: true
    )
    socket.repl.context.app = app
  
    socket.repl.on 'exit', -> socket.end()
  
  callback()
