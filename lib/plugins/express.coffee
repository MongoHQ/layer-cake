path = require 'path'

create_express = (callback) ->
  express = require 'express'
  
  @express = express()
  
  for k in ['use', 'get', 'put', 'post', 'delete']
    @[k] = @express[k].bind(@express)
  
  @__defineGetter__ 'router', => @express.router
  
  @express.configure =>
    @express.set('root', @path.root)
    callback()

module.exports = (app) ->
  app.sequence('http').insert(
    'express', create_express.bind(app),
    before: '*'
  )
