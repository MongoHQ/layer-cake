version = ->
  chalk = require 'chalk'
  version = require('../../package.json').version
  "You are running layer-cake #{chalk.magenta(version)}"

command_help = (c) ->
  chalk = require 'chalk'
  
  lines = [chalk.cyan('layer-cake ' + c.help)]
  if c.description?
    lines.push(chalk.gray(line)) for line in c.description.split('\n')
  
  lines.join('\n')

help_commands = (app, commands...) ->
  chalk = require 'chalk'
  
  commands = Object.keys(app.commandline.commands).sort() if commands.length is 0
  
  commands = commands.map (k) ->
    c = app.commandline.commands[k]
    c.help ?= k
    c

  [chalk.underline('Commands')].concat(
    commands.map (c) -> '\n' + command_help(c)
  ).join('\n')

exports.help = (callback) ->
  if @opts.version is true or @opts.v is true
    message = version()
  else if @opts.all is true or @opts.a is true
    message = help_commands(@app)
  else
    message = help_commands(@app, 'console', 'remote-console', 'server')
  
  @logger.help(line) for line in message.split('\n')
  callback()

exports.help.description = 'Display the help!'
