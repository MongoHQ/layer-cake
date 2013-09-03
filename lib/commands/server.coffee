chalk = require 'chalk'

# help:    layer-cake server
# help:    Run this server!

exports.server = (callback) ->
  app = @create_app()
  
  app.listen (err, addr) =>
    return callback(err) if err?
    
    @log "Your server is now listening on port #{chalk.cyan(addr.port)}"
    @log('')
  
  process.on 'exit', -> callback()
