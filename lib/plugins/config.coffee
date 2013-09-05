path = require 'path'

config = (callback) ->
  configyour = require 'configyour'
  
  @config ?= configyour(@path.config)
  callback()

module.exports = (app) ->
  app.path.config = path.join(app.path.root, 'config')
  
  app.sequence('init').insert(
    'config', config.bind(app)
    after: '*'
  )
