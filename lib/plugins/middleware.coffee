path = require 'path'

middleware = (callback) ->
  try
    middleware = require path.join(@path.app, 'middleware')
    middleware?(@)
    callback()
  catch err
    if err.code is 'MODULE_NOT_FOUND' and err.message.indexOf("'#{middleware}'") isnt -1
      console.log "You don't have any middleware (looked for #{path.join(@path.app, 'middleware')}). Are you sure you don't want any?"
      return callback()
    callback(err)

module.exports = (app) ->
  app.sequence('http').insert(
    'middleware', middleware.bind(app),
    after: 'express'
  )
