environment = process.env.NODE_ENV ? 'development'

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
    require './plugins/views'
    require './plugins/models'
    
    require './plugins/remote-console'
  ]
  
  constructor: (root) ->
    super()
    
    @environment = environment
    
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
        if p[0] is '.'
          p = path.join(@path.root, p)
        else if p[0] isnt '/'
          p = path.join(@path.root, 'node_modules', p)
        Array::push.call(LayerCake.plugins, require(p))
      catch err
        console.log 'There was an error loading plugin ' + p
        console.log err.stack
  
  load_plugins: ->
    p?(@) for p in LayerCake.plugins
    @

module.exports.LayerCake = LayerCake
