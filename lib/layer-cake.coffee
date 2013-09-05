process.env.NODE_ENV or= 'development'

fs = require 'path'
path = require 'path'
{Container} = require 'sequences'

class LayerCake extends Container
  @plugins: [
    require './plugins/commandline'
    require './plugins/initializer'
    require './plugins/config'
    
    require './plugins/http'
    require './plugins/express'
    require './plugins/middleware'
    require './plugins/controllers'
    require './plugins/remote-console'
  ]
  
  constructor: (root) ->
    super()
    @__defineGetter__ 'environment', -> process.env.NODE_ENV
    
    @path =
      root: root
      app: path.join(root, 'app')
      lib: path.join(root, 'lib')
    
    global.APP = @
    
    try
      @package = require(path.join(@path.root, 'package.json'))
    catch err
    
    for p in (@package?.plugins or [])
      try
        p = path.join(@path.root, p) if p[0] is '.'
        Array::push.call(LayerCake.plugins, require(p))
      catch err
        console.log 'There was an error loading plugin ' + p
        console.log err.stack
  
  load_plugins: ->
    p?(@) for p in LayerCake.plugins
    @

module.exports.LayerCake = LayerCake
