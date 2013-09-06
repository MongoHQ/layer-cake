path = require 'path'
Commandment = require 'commandment'

handle_error = (err) ->
  console.log err.stack
  
  text = err.body?.error
  text ?= err.body
  text ?= err.message
  text ?= JSON.stringify(err, null, 2)

  @logger.error('')
  @logger.error(line) for line in text.split('\n')
  @logger.error('')

before_execute = (context, next) ->
  context.app = global.APP
  context.log('')
  next()

after_execute = (context, err, next) ->
  handle_error.call(context, err) if err?
  context.log('')
  next()


module.exports = (app) ->
  app.commandline = new Commandment(name: 'layer-cake', command_dir: path.join(__dirname, '..', 'commands'))
  
  app.commandline.before_execute(before_execute)
  app.commandline.after_execute(after_execute)
