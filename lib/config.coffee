fs = require 'fs'
vm = require 'vm'
path = require 'path'

apply_config_from_dir = (config, dir) ->
  return config unless fs.existsSync(dir)
  
  for file in fs.readdirSync(dir) when path.extname(file) is '.json'
    config_file = path.join(dir, file)
    content = fs.readFileSync(config_file).toString()
    sandbox = {process: process}
    
    try
      vm.runInNewContext("this.config = #{content};", sandbox, config_file)
    catch err
      throw new Error('Error parsing config file ' + config_file + ': ' + err.message)
    config[file.slice(0, -5)] = sandbox.config
  
  config

module.exports = (dirs...) ->
  config = {}
  config = apply_config_from_dir(config, d) for d in dirs
  config
