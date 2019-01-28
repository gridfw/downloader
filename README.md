# gridfw-downloader
This plugin will manage all data sending to the user.


## Configuration
Add this as plugin inside your config file (or any other configuration method)

```javascript
{
	plugins:{
		downloader:{
			require: 'gridfw-downloader'
			// options
		}
	}
}
```

## Options:
We recommand keeping default values for all options (just do not set any option). Keeping "Convention over configuration" will make your life easier ;)

### Pretty
Show the JSON, XML, ... in pretty format
By default: true in dev mode, false in production
```coffeescript
plugins:
	downloader:
		require: 'gridfw-downloader'
		pretty: false # @default: true in dev mode, false in production
# <!> The default behaviour is recommanded for most cases. Do not set this option.
```

#### Etag
Etag is an HTTP response header to manage browser cache.
Those are possible values:
1. false, null or undefined: Disable generating this header
2. true: Use default hashing function to generate this header
3. function(data, encoding): This function will be used to generate the header. It must be sycronized and returns the hash of the data (async and promises are not allowed, we need hash!).

By default, this option will have true for production mode, false in dev mode.

```javascript
{
	plugins:{
		downloader:{
			require: 'gridfw-downloader'
			etag: function(data, encoding){
				// generate a hash from the data to send it as
				// the Etag value
				return hashGen(data, encoding);
			}
		}
	}
}
```

#### jsonp
A sync function that will returns the name of the jsonp callback.
By default, the framework will use: ctx.query.cb or 'callback'

```javascript
{
	plugins:{
		downloader:{
			require: 'gridfw-downloader'
			jsonp: function(ctx){ return ctx.query['jsonp-callback-name'] }
		}
	}
}
```

#### acceptRanges
Accept ranged requests.
This will enable the user to resume downloads, seek inside video players event the video is not fully loaded.


## Context attributes

### ctx.statusCode, ctx.statusMessage
Set the http response status code and message

Example
```coffeescript
app.get '/', (ctx)->
	ctx.statusCode = 200
	ctx.statusMessage = 'OK'

	# if you didn't set "ctx.statusMessage", the framework will add
	# the default message for it.
	# Example: 200 = OK, 201: created, 404: page not found, ...
	# We highly recommande to keep default messages.
```


## Context methods
Those methods will be added to the context:

### <context> ctx.status(statusCode [, statusMessage])
Set the http response status

Example
```coffeescript
app.get '/', (ctx)->
	ctx.status(201, 'created')
```

### <Promise> ctx.send(data)
This function is used by all other methods, if sends data to user and returns a promise.

Examples:

```coffeescript
app.get '/', (ctx)->
	await ctx.send 'Hello world' # Will send "hello world" to user and close the connection

	await ctx.send {value: 'hello world'} # Equivalent to: ctx.json {value: 'hello world'}
	await ctx.send Buffer # Send buffer binary content
```

### <Promise> ctx.json(data)
Serialize data as json and send it to the user.

### <Promise> ctx.jsonp(data [, callBackName = ctx.query.cb || 'callback'])
Serialize data as jsonp and send it to the user.
The name of the callback will be extracted from request query (see configuration) if not set as second param.

### <Promise> ctx.sendFile(filePath, options)
Send a file to the user. By default it will be send as "inline" file (used to load data by the browser instead of executing download)

This method uses [npm send](https://www.npmjs.com/package/send). (click on it to see available options)

### <Promise> ctx.download(data, options)
Send a file to the user as attachement (use download manager if found)
This equivatent to: ctx.sendFile(filePath, {inline: false})