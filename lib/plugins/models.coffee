path = require 'path'

module.exports = (app) ->
  app.path.models = path.join(app.path.app, 'models')
  
  app.sequence('models').runs_after('init')
