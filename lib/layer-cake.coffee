process.env.NODE_ENV or= 'development'

path = require 'path'
async = require 'async'
express = require 'express'
config = require './config'

require('./response')(express)

class App
  constructor: (root) ->
    @_before_callbacks = {}
    @_after_callbacks = {}
    @__defineGetter__ 'environment', -> process.env.NODE_ENV
    
    @express = express()
    for k in ['use', 'get', 'put', 'post', 'delete']
      @[k] = @express[k].bind(@express)
    @__defineGetter__ 'router', => @express.router
    
    @path =
      root: root
      config: path.join(root, 'config')
      lib: path.join(root, 'lib')
      app: path.join(root, 'app')
      controllers: path.join(root, 'app', 'controllers')
  
  _user_initialize: (callback) ->
    try
      initializer = require path.join(@path.app, 'initialize')
      initializer?(@)
      callback()
    catch err
      callback(err)
  
  _read_config: (callback) ->
    @config ?= config(
      @path.config
      path.join(@path.config, process.env.NODE_ENV or 'development')
    )
    callback()
  
  _configure_app: (callback) ->
    @express.configure =>
      @express.set 'root', @path.root
      
      @express.use (req, res, next) ->
        res.respond_with.callback = (err, data) -> res.respond_with(err ? data)
        res.respond_with.callback_with_fields = (fields) ->
          (err, data) -> res.respond_with(err ? data, fields)
        next()
      
      try
        middleware = require path.join(@path.app, 'middleware')
        middleware(@)
        callback()
      catch err
        callback(err)
  
  _configure_controllers: (callback) ->
    try
      require('./controllers')(@)
      callback()
    catch err
      callback(err)
  
  _before: (event) ->
    (callback) =>
      async.series(@_before_callbacks[event] or [], callback)
  
  _after: (event) ->
    (callback) =>
      async.series(@_after_callbacks[event] or [], callback)
  
  _initialize: (callback) ->
    return callback() if @_initialized is true
    
    async.series [
      @_user_initialize.bind(@)
      
      @_before('initialize').bind(@)
      @_before('read-config').bind(@)
      @_read_config.bind(@)
      @_after('read-config').bind(@)
      @_before('configure-app').bind(@)
      @_configure_app.bind(@)
      @_after('configure-app').bind(@)
      @_before('configure-controllers').bind(@)
      @_configure_controllers.bind(@)
      @_after('configure-controllers').bind(@)
      @_after('initialize').bind(@)
    ], (err) ->
      return callback(err) if err?
      
      @_initialized = true
      callback()
  
  before: (event, callback) ->
    @_before_callbacks[event] ?= []
    @_before_callbacks[event].push(callback)
    
  after: (event, callback) ->
    @_after_callbacks[event] ?= []
    @_after_callbacks[event].push(callback)
  
  listen: (callback) ->
    @_initialize (err) =>
      return callback?(err) if err?
      
      port = @config.server?.port or 3000
      async.series [
        @_before('listen').bind(@)
        (cb) =>
          @http = @express.listen(port, cb)
        @_after('listen').bind(@)
        (cb) => require('./console')(@, cb)
      ], (err) =>
        return callback?(err) if err?
        callback(null, @http.address())

module.exports = (root) -> new App(root)
