express = require 'express'

module.exports = (app) ->
  app.use express.logger()
  app.use express.bodyParser()
  app.use express.methodOverride()
  app.use express.cookieParser()
  app.use express.session(secret: "shhh, don't tell anyone")
  
  app.use app.router
