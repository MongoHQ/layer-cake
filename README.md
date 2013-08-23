# layer-cake

layer-cake is a little node.js web framework care of your friends at [MongoHQ](http://www.mongohq.com).

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

#### Middleware

#### Initializer

#### Configuration

## License
Copyright (c) 2013 MongoHQ Inc.
Licensed under the MIT license.
