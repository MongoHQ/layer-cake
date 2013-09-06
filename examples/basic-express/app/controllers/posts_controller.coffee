module.exports = (app) ->
  app.get('/', index(app.config.posts))
  app.get('/posts', index(app.config.posts))
  app.get('/posts/:id', get_post(app.config.posts), show)

get_post = (posts) ->
  (req, res, next) ->
    for post in posts
      if post.slug is req.params.id
        req.post = post
        return next()
    next()

index = (posts) ->
  (req, res, next) ->
    res.render('index', posts: posts)

show = (req, res, next) ->
  return next() unless req.post?
  res.render('show', post: req.post)
