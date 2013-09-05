path = require 'path'

initializer_registration = (callback) ->
  try
    initializer = require path.join(@path.app, 'initialize')
    initializer?(@)
    callback()
  catch err
    return callback() if err.code is 'MODULE_NOT_FOUND'
    callback(err)

module.exports = (app) ->
  app.sequence('init').insert(
    'initializer-registration', initializer_registration.bind(app),
    before: '*'
  )
