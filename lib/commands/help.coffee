chalk = require 'chalk'

exports.help = (cb) ->
  @logger.help chalk.underline('Commands')
  @logger.help('')
  @logger.help chalk.cyan('layer-cake console [address]')
  @logger.help chalk.gray("Open a console to your layer-cake server.")
  @logger.help chalk.gray("  address: something like localhost:3000 or api.foo.com")
  @logger.help('')
  @logger.help chalk.cyan('layer-cake server')
  @logger.help chalk.gray("Run this server!")
  
  cb()
