###*
 * Send file to the user
 * @param {string} path - file path
 * @param {Boolean} options.inline - Inline or attachement
 * @param {String} options.name - override file name
 * @param {Object} options - npm send options @see https://www.npmjs.com/package/send
###
CONTEXT_PROTO.sendFile= (path, options)->
	options ?= _create null
	options.headers ?= _create null
	# add file name and content disposition
	options.headers['Content-Disposition'] ?= ContentDisposition options.name || path, type: if options.inline is false then 'attachment' else 'inline'
	# return promise
	new Promise (resolve, reject)=>
		# control
		throw new Error 'path expected string' unless typeof path is 'string'
		path = encodeurl path

		# Prepare file streaming
		file = SendFile @req, path, options
		# flags
		streaming = off
		# done = no
		# Add callbacks
		file.on 'directory', ->
			reject new GError 'EISDIR', 'EISDIR, read'
		file.on 'stream', ->
			streaming = on
			return
		file.on 'file', ->
			streaming = off
			return
		file.on 'error', (err) ->
			unless err
				err = new GError 0, 'Uncknown Error'
			else if err.status is 404
				err = new GError '404-file', err.message, err
			else
				err = new GError err.code, err.message, err
			reject err
		file.on 'end', (event)->
			streaming = off
		# 	resolve event
		# Execute a callback when a HTTP request closes, finishes, or errors.
		onFinishLib this, (err)->
			# err.code = 'ECONNRESET'
			reject err if err
			setImmediate ->
				if streaming
					reject new GError 'ECONNABORTED', 'Request aborted'
				else
					resolve()
		# add headers
		if options.headers
			file.on 'headers', (res)->
				for k,v of options.headers
					res.setHeader k, v
		# pipe file
		file.pipe this
		return

CONTEXT_PROTO.download= (path, options)->
	# set headers
	options ?= _create null
	options.inline = false
	# send
	@sendFile path, options