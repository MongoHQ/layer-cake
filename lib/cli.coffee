fs = require 'fs'
path = require 'path'
Commandment = require 'commandment'
{LayerCake} = require './layer-cake'

commands = new Commandment(name: 'layer-cake', command_dir: __dirname + '/commands')

find_app_root = (dir) ->
  try
    pkg = require(path.join(dir, 'package.json'))
    return dir if pkg?
    null
  catch err
    new_dir = path.dirname(dir)
    return null if new_dir is dir
    find_root(new_dir)

create_app = (cb) ->
  root = find_app_root(process.cwd())
  return cb(new Error("It doesn't look like you're in a layer-cake project.")) unless root?
  
  pkg = require(root + '/package.json')
  # unless pkg.dependencies?['layer-cake']?
  #   @logger.warn('')
  #   @logger.warn "You don't have layer-cake in your dependencies. Why not?"
  #   @logger.warn('')
  
  if pkg.plugins?
    plugins = pkg.plugins.map (p) =>
      try
        p = path.join(root, p) if p[0] in ['/', '.']
        require(p)
      catch err
        @error('')
        @error "There was an error loading plugin at #{p}"
        console.log err.stack
        @error('')
    
    Array::push.apply(LayerCake.plugins, plugins)
  
  global.APP = new LayerCake(root)



handle_error = (err) ->
  console.log err.stack
  
  text = err.body?.error
  text ?= err.body
  text ?= err.message
  text ?= JSON.stringify(err, null, 2)
  
  @logger.error('')
  @logger.error(line) for line in text.split('\n')
  @logger.error('')

commands.before_execute (context, next) ->
  context.create_app = create_app
  next()

commands.before_execute (context, next) ->
  context.log('')
  next()

commands.after_execute (context, err, next) ->
  handle_error.call(context, err) if err?
  context.log('')
  next()

commands.execute(process.argv)
