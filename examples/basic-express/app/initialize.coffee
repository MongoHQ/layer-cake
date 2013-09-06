module.exports = (app) ->
  app.after 'http:express', (done) ->
    app.express.set('views', app.path.views)
    app.express.set('view engine', 'ejs')
    app.express.engine('ejs', require('ejs').__express)
    done()
