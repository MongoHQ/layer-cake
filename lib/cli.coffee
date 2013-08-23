Commandment = require('./commandment')
commands = new Commandment(name: 'layer-cake', command_dir: __dirname + '/commands')

handle_error = (err) ->
  text = err.body?.error
  text ?= err.body
  text ?= err.message
  text ?= JSON.stringify(err, null, 2)
  
  @logger.error('')
  @logger.error(line) for line in text.split('\n')
  @logger.error('')

commands.before_execute (context, next) ->
  context.log('')
  next()

commands.after_execute (context, err, next) ->
  handle_error.call(context, err) if err?
  context.log('')
  next()

commands.execute(process.argv)
