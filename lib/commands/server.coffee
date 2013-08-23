fs = require 'fs'
path = require 'path'

find_root = (dir) ->
  try
    pkg = require(path.join(dir, 'package.json'))
    return dir if pkg?
    null
  catch err
    new_dir = path.dirname(dir)
    return null if new_dir is dir
    find_root(new_dir)

exports.server = (cb) ->
  root = find_root(process.cwd())
  return cb(new Error("It doesn't look like you're in a layer-cake project.")) unless root?
  
  pkg = require(root + '/package.json')
  unless pkg.dependencies?['layer-cake']?
    @logger.warn('')
    @logger.warn "You don't have layer-cake in your dependencies. Why not?"
    @logger.warn('')
  
  app = require('../layer-cake')(root)

  app.listen (err, addr) =>
    return console.log(err.stack) if err?
    @log('')
    @log "Your server is now listening on port #{addr.port}"
    @log('')
  
  process.on 'exit', =>
    cb()
