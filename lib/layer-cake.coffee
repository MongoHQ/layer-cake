process.env.NODE_ENV or= 'development'

path = require 'path'
async = require 'async'
Sequence = require './sequence'

class LayerCake
  @plugins: [
    require './plugins/initializer'
    require './plugins/config'
    
    require './plugins/http'
    require './plugins/express'
    require './plugins/middleware'
    require './plugins/controllers'
    require './plugins/remote_console'
  ]
  
  constructor: (root) ->
    @__defineGetter__ 'environment', -> process.env.NODE_ENV
    
    @path =
      root: root
      app: path.join(root, 'app')
      lib: path.join(root, 'lib')
    
    @sequences = {}
    
    p?(@) for p in LayerCake.plugins
  
  sequence: (name) ->
    unless @sequences[name]?
      seq = @sequences[name] = new Sequence(name)
      seq._dependencies = []
      seq._followed_by = []
      
      seq.depends_on = (other_sequence) =>
        seq._dependencies.push(other_sequence)
        seq
      seq.follows = (other_sequence) =>
        @sequences[other_sequence]._followed_by.push(name)
        seq
    @sequences[name]
  
  before: (event, callback) ->
    [seq_name, key_name] = event.split(':')
    return unless @sequences[seq_name]?
    @sequences[seq_name].before(key_name, callback)
  
  after: (event, callback) ->
    [seq_name, key_name] = event.split(':')
    return unless @sequences[seq_name]?
    @sequences[seq_name].after(key_name, callback)
  
  _create_sequence_execution_list: (name) ->
    return [] unless @sequences[name]?
    
    visited = {}
    
    deps = []
    queue = [name]
    while queue.length > 0
      c = queue.shift()
      Array::push.apply(deps, @sequences[c]._followed_by)
      deps.push(c)
      continue if visited[c] is true
      visited[c] = true
      Array::push.apply(queue, @sequences[c]._dependencies)
    
    visited = {}
    deps.reverse().filter (d) ->
      return false if visited[d] is true
      visited[d] = true
      true
  
  _execute_sequence: (name, callback) ->
    seq = @sequences[name]
    return callback() unless seq?
    return callback() if seq._executed is true
    
    seq.execute @, (err) ->
      return callback(err) if err?
      
      seq._executed = true
      callback()
  
  initialize: (name, callback) ->
    list = @_create_sequence_execution_list(name)
    return callback() if list.length is 0
    
    async.eachSeries(list, @_execute_sequence.bind(@), callback)

module.exports.LayerCake = LayerCake
