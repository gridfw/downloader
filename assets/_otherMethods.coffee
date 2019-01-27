###*
 * Http status
###
CONTEXT_PROTO.status= (statusCode, statusMessage)->
	# status code
	throw new Error "Status code expected positive integer" unless Number.isSafeInteger statusCode
	@statusCode = statusCode
	# status text
	switch arguments.length
		when 1
			break
		when 2
			throw new Error "Status message expected string" unless typeof statusMessage is 'string'
			@statusMessage= statusMessage
		else
			throw new Error "Illegal arguments"
	# return self
	this

###*
 * Send JSON
###
CONTEXT_PROTO.json= (data)->
	# stringify data
	if @app.s[<%= settings.pretty %>]
		data = JSON.stringify data, null, "\t"
	else
		data = JSON.stringify data
	# send data
	@contentType ?= 'application/json'
	@send data

###*
 * Send JSON
###
CONTEXT_PROTO.jsonp= (data)->
	settings = @app.s
	# stringify data
	if settings[<%= settings.pretty %>]
		data = JSON.stringify data, null, "\t"
	else
		data = JSON.stringify data
	# add cb name
	data = "#{settings[<%= settings.json %>](this)}(#{data});"
	# send data
	@contentType ?= 'application/javascript'
	@send data