fs = require 'fs'
path = require 'path'

controllers = (callback) ->
  read_dir = (dir) =>
    return unless fs.existsSync(dir)
    
    for filename in fs.readdirSync(dir)
      file_path = path.join(dir, filename)
      return read_dir(file_path) if fs.statSync(file_path)?.isDirectory()
      read_file(file_path)
  
  read_file = (file_path) =>
    require(file_path)?(@)
  
  read_dir(@path.controllers)
  
  callback()

module.exports = (app) ->
  app.path.controllers = path.join(app.path.app, 'controllers')
  
  app.sequence('http').insert(
    'controllers', controllers,
    after: 'middleware'
  )
