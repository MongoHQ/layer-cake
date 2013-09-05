welcome = (app) ->
  chalk = require 'chalk'
  
  """
  You're connected to #{chalk.cyan(app.package?.name or 'layer-cake')}! Take a look around!

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

exports.console = (callback) ->
  chalk = require 'chalk'
  prompt = @app.package?.name or 'layer-cake'
  
  @app.execute 'init', (err) =>
    return callback(err) if err?
    
    @log(line) for line in welcome(@).split('\n')
    
    repl = require('repl').start(
      prompt: chalk.magenta(prompt + '> ')
    )
    repl.context.app = @app
    repl.context.$_ = -> console.log(arguments)

    repl.on 'exit', -> callback()

exports.console.description = 'Open a local console.'
