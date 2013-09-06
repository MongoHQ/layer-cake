path = require 'path'

module.exports = (app) ->
  app.path.views = path.join(app.path.app, 'views')
  app.path.public = path.join(app.path.root, 'public')
