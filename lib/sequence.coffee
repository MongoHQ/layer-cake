_ = require 'underscore'
async = require 'async'

index_of = (arr, predicate) ->
  for x in [0...arr.length]
    return x if predicate(arr[x])
  -1

class Sequence
  constructor: (@name) ->
    @steps = []
    @_callbacks =
      before: {}
      after: {}
  
  before: (event, callback) ->
    @_callbacks.before[event] ?= []
    @_callbacks.before[event].push(callback)
    @

  after: (event, callback) ->
    @_callbacks.after[event] ?= []
    @_callbacks.after[event].push(callback)
    @
  
  _before: (event) ->
    (callback) =>
      async.series(@_callbacks.before[event] or [], callback)

  _after: (event) ->
    (callback) =>
      async.series(@_callbacks.after[event] or [], callback)
  
  add: (steps...) ->
    steps = [{name: steps[0], method: steps[1]}] if steps.length is 2 and typeof steps[0] is 'string' and typeof steps[1] is 'function'
    Array::push.apply(@steps, steps)
    @
  
  remove: (names...) ->
    for name in names
      idx = _(@steps).indexOf (s) -> s.name is name
      @steps.splice(idx, 1) if idx isnt -1
    @
  
  insert: (name, method, opts) ->
    step =
      name: name
      method: method
    
    other_name = opts.after or opts.before or opts.replace
    idx = index_of @steps, (s) -> s.name is other_name
    
    if opts.after?
      if idx is -1
        @steps.push(step)
      else
        @steps.splice(idx + 1, 0, step)
    else if opts.before?
      @steps.splice((if idx is -1 then 0 else idx), 0, step)
    else if opts.replace?
      throw new Error('Could not find Sequence step ' + opts.replace + ' to replace with ' + name) if idx is -1
      @steps.splice(idx, 1, step)
    
    @
  
  execute: (context, callback) ->
    if typeof context is 'function'
      callback = context
      context = null
    
    async.eachSeries(@steps, (s, cb) =>
      async.series [
        @_before(s.name)
        s.method.bind(context)
        @_after(s.name)
      ], cb
    , callback)

module.exports = Sequence
