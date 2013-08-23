module.exports = (express) ->
  express.response.respond_with = (promise_or_data, fields) ->
    is_error = (e) ->
      proto = e.__proto__
      while proto? and proto isnt Object.prototype
        return true if proto.toString() is Error.prototype.toString()
        proto = proto.__proto__
      false

    respond = (err, data) =>
      return @send(500, {error: err.message}) if err?
      return @send(404, 'Not Found') unless data?

      extract = (data, field) ->
        if Array.isArray(data)
          _(data).pluck(field)
        else
          _([data]).pluck(field)[0]

      only = (data, list) ->
        list = list.split(',') unless Array.isArray(list)
        if Array.isArray(data)
          data.map (d) -> _(d).pick(list)
        else
          _([data]).pluck(list)[0]

      except = (data, list) ->
        list = list.split(',') unless Array.isArray(list)
        if Array.isArray(data)
          data.map (d) -> _(d).omit(list)
        else
          _(data).omit(list)

      if fields?
        if typeof fields is 'function'
          data = fields(data)
        else if typeof fields is 'string' or Array.isArray(fields)
          data = only(data, fields)
        else
          data = only(data, fields.only) if fields.only?
          data = except(data, fields.except) if fields.except?
          data = extract(data, fields.extract) if fields.extract?

      @send(200, data)

    return respond() unless promise_or_data?
    if promise_or_data.onAll? and typeof promise_or_data.onAll is 'function'
      promise_or_data.onAll(respond)
    else
      return respond(promise_or_data) if is_error(promise_or_data)
      respond(null, promise_or_data)
