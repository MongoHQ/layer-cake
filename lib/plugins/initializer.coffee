path = require 'path'

initializer_registration = (callback) ->
  try
    initializer = require path.join(@path.app, 'initialize')
    initializer?(@)
    callback()
  catch err
    return callback() if err.message.indexOf('Cannot find module') is 0
    callback(err)

module.exports = (app) ->
  app.sequence('init').insert(
    'initializer-registration', initializer_registration,
    before: '*'
  )
