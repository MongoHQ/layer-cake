remote_console = (app) ->
  (done) ->
    WebSocket = require 'faye-websocket'
  
    upgrade_listeners = app.http.listeners('upgrade')
    app.http.removeAllListeners('upgrade')
  
    app.http.on 'upgrade', (req, socket, body) ->
      unless req.url is '/__layer-cake_console__'
        l(arguments...) for l in upgrade_listeners
        return
      return unless WebSocket.isWebSocket(req)
    
      ws = new WebSocket(req, socket, body)
    
      ws.on 'open', ->
        return start_repl(ws, app) unless app.config['layer-cake']?.console?.auth?.username? and app.config['layer-cake']?.console?.auth?.password?
      
        {username, password} = app.config['layer-cake']?.console?.auth
        ws.send('AUTHENTICATE')
      
        on_message = (msg) ->
          return ws.end() unless new Buffer(username + password).toString('base64') is msg.data.toString()
        
          ws.removeListener('message', on_message)
          start_repl(ws, app)
      
        ws.on('message', on_message)
  
    done()

start_repl = (ws, app) ->
  repl = require 'repl'
  
  ws.send('OK')

  try
    prompt = require(app.path.root + '/package').name
  catch err
    prompt = 'shell'
  
  ws.repl = repl.start(
    prompt: prompt + '> '
    input: ws
    output: ws
    terminal: true
    useColors: true
  )
  ws.repl.context.app = app

  ws.repl.on 'exit', -> ws.end()

module.exports = (app) ->
  app.after('http:listen', remote_console(app))
