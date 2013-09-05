path = require 'path'

middleware = (callback) ->
  try
    middleware = require path.join(@path.app, 'middleware')
    middleware?(@)
    callback()
  catch err
    return callback() if err.code is 'MODULE_NOT_FOUND'
    callback(err)

module.exports = (app) ->
  app.sequence('http').insert(
    'middleware', middleware.bind(app),
    after: 'express'
  )
