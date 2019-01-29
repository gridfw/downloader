###*
 * send data to the user
 * @param {string | buffer | object} data - data to send
 * @return {Promise}
###
CONTEXT_PROTO.send= (data)->
	encoding = @encoding
	# native request
	req = @req
	switch typeof data
		when 'string'
			@contentType ?= 'text/html'
			data = Buffer.from data, encoding
		when 'object'
			if Buffer.isBuffer data
				@contentType ?= 'application/octet-stream'
			else
				#TODO check accept header if we wants json or xml
				return @json data
		when 'undefined'
			@contentType ?= 'text/plain'
			data = ''
		else
			@contentType ?= 'text/plain'
			data = Buffer.from data.toString(), encoding
	# send headers
	if @headersSent
		@warn 'SEND_DATA', 'Headers already sent!'
	else
		# ETag
		unless @hasHeader 'ETag'
			etag = @s[<%= settings.etag %>] data
			@setHeader 'ETag', etag if etag
		
		# freshness
		@statusCode = 304 if req.fresh

		# strip irrelevant headers
		if @statusCode in [204, 304]
			@removeHeader 'Content-Type'
			@removeHeader 'Content-Length'
			@removeHeader 'Transfer-Encoding'
			data = ''
		else
			# populate Content-Length
			@setHeader 'Content-Length', @contentLength = data.length
			# set content type
			contentType = @contentType
			if typeof contentType is 'string'
				# fix content type
				if contentType.indexOf('/') is -1
					contentType = MimeType.lookup contentType
					contentType = 'application/octet-stream' unless contentType
				# add encoding
				contentType = contentType.concat '; charset=', encoding
			else
				contentType = 'application/octet-stream'
			# set as header
			@setHeader 'Content-Type', contentType

	# send
	if req.method is 'HEAD'
		return @end()
	else
		return @end data, encoding