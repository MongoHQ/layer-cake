listen = (callback) ->
  port = @config.server?.port or 3000
  @http = @express.listen(port, callback)

module.exports = (app) ->
  app.sequence('http').depends_on('init').add('listen', listen)
  
  app.listen = (callback) ->
    @initialize 'http', (err) =>
      return callback?(err) if err?
      callback?(null, @http.address())
