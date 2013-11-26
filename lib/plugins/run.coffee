fs = require 'fs'
path = require 'path'

module.exports = (app) ->
  app.commandline.commands.run = run(app)
  app.commandline.commands.run.help = 'run [script]'
  app.commandline.commands.run.description = 'Initialize then run the script specified'

run = (app) ->
  (script, callback) ->
    return callback(new Error('Must pass a script to layer-cake run')) if typeof script is 'function'
    
    script = path.join(process.cwd(), script) unless script[0] is '/'
    
    return callback(new Error(script + ' does not exist')) unless fs.existsSync(script)
    
    app.execute 'init', (err) ->
      return callback(err) if err?
      
      require(script)
