# layer-cake

layer-cake is a little node.js web framework care of your friends at [MongoHQ](http://www.mongohq.com).

![Yummy Layer Cake image](http://farm3.staticflickr.com/2764/4093466966_78be1bc8c3.jpg)

The basic idea is to remove a lot of the normal boilerplate that goes into almost every express
application, while adding some nice features to make your life easier.

## Installation

```sh
$ npm install --save layer-cake
```

## Usage

### Command-Line

![layer-cake command line image](http://content.screencast.com/users/racobac/folders/Jing/media/c5677722-5fae-49de-bf74-6ab510a49e6a/00000077.png)

### Expected Directory Structure

```
my-project
|- app/
|  |- controllers/
|  |  |- app_controller.coffee
|  |- initialize.coffee
|  |- middleware.coffee
|- config/
|  |- server.json
|  |- development/
|  |  |- mongodb.json
|  |- production/
|  |  |- mongodb.json
|- lib/
|- package.json
```

### Components

#### Controllers

All controllers are located in the `app/controllers` directory. All files inside of this directory will
be required and then called, being passed the `app` object. Controllers can then attach route handlers to
this object the same way they would to an express app.

For instance, the app_controller.coffee file could look like:

```coffeescript
module.exports = (app) ->
  app.get('/', index)

index = (req, res) ->
  res.send(hello: 'world')
```

#### Middleware

Middlewares work the exact same way they do in express. layer-cake will attempt to require a file at
`app/middleware` and then pass the `app` object to it.

A simple middleware.coffee might look like this:

```coffeescript
express = require 'express'

module.exports = (app) ->
  app.use express.logger()
  app.use express.bodyParser()
  app.use express.methodOverride()
  app.use app.router
```

#### Initializer

#### Configuration

All configuration is located in the config directory. All `.json`, `.yml`, and `.yaml` files will be parsed
and made available on the `app.config` object. Any configuration files in an environment-specific directory
will override files from the main config directory. The current environment is read from `process.env.NODE_ENV`
and will always default to `development`.

For instance, the above directory structure will result in `app.config` looking like this in development:

```javascript
{
  "server": {
    // contents of my-project/app/config/server.json
  },
  "mongodb": {
    // contents of my-project/app/config/development/mongodb.json
  }
}
```

## License
Copyright (c) 2013 MongoHQ Inc.
Licensed under the MIT license.
