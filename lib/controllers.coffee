fs = require 'fs'
path = require 'path'

module.exports = (app) ->
  for file in fs.readdirSync(app.path.controllers)
    require(path.join(app.path.controllers, file))(app)
