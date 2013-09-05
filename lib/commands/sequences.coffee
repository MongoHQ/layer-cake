exports.sequences = (callback) ->
  _ = require 'underscore'
  chalk = require 'chalk'
  
  sequences = _(@app.sequences).values()
  
  for x in [0...sequences.length]
    @log('') unless x is 0
    
    @log '===',chalk.cyan(sequences[x].name)
    if sequences[x]._dependencies.length > 0
      @log '   ', chalk.gray('depends on ' + sequences[x]._dependencies.join(', '))
    if sequences[x]._followed_by.length > 0
      @log '   ', chalk.gray('followed by ' + sequences[x]._followed_by.join(', '))
    
    @log('   ', s.name) for s in sequences[x].steps
  
  callback()
