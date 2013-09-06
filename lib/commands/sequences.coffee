exports.sequences = (name, callback) ->
  if typeof name is 'function'
    callback = name
    name = null
  
  _ = require 'underscore'
  chalk = require 'chalk'
  
  sequences = _(@app.sequences).values()
  
  for x in [0...sequences.length]
    @log('') unless x is 0
    
    @log '===',chalk.cyan(sequences[x].name)
    if sequences[x]._runs_after.length > 0
      @log '   ', chalk.gray('runs after ' + sequences[x]._runs_after.join(', '))
    if sequences[x]._depends_on.length > 0
      @log '   ', chalk.gray('depends on ' + sequences[x]._depends_on.join(', '))
    
    @log('   ', s.name) for s in sequences[x].steps
  
  if name?
    @log()
    @log 'The sequence for ' + name + ' is'
    @log('  - ' + s) for s in @app.sequence_execution_list(name)
  
  callback()

exports.sequences.help = 'sequences [type]'
exports.sequences.description = 'Display the sequences defined in your app.\n  - type: optionally display the load sequence for a certain type'
