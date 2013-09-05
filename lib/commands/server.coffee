exports.server = (callback) ->
  chalk = require 'chalk'
  
  @app.listen (err, addr) =>
    return callback(err) if err?
    
    @log "Your server is now listening on port #{chalk.cyan(addr.port)}"
    @log('')
  
  process.on 'exit', -> callback()

exports.server.description = 'Run this server!'
