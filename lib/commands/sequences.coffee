_ = require 'underscore'

exports.sequences = (callback) ->
  app = @create_app()
  sequences = _(app.sequences).values()
  
  for x in [0...sequences.length]
    @log('') unless x is 0
    @log '===', sequences[x].name, (if sequences[x]._dependencies.length is 0 then '' else '[' + sequences[x]._dependencies.join(', ') + ']')
    @log('   ', s.name) for s in sequences[x].steps
  
  callback()
