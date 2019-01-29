###*
 * Gridfw 
 * @copyright khalid RAFIK 2019
###
'use strict'
SendFile	= require 'send'
ETag		= require 'etag'
ContentDisposition = require 'content-disposition'
MimeType	= require 'mime-types'
OnFinishLib	= require 'on-finished'
Buffer		= require('safe-buffer').Buffer

#=include _utils.coffee
#=include _default-settings.coffee

CONTEXT_PROTO = _create null
#=include _send.coffee
#=include _otherMethods.coffee
#=include _send-file.coffee
#=include _attributes.coffee


class Downloader
	constructor: (@app)->
		@enabled = on # the plugin is enabled
	###*
	 * Reload parser
	###
	reload: (settings)->
		# load settings
		_initSettings @app, settings
		# enable
		@enable()
		return
	###*
	 * destroy
	###
	destroy: -> @disable()
	###*
	 * Disable, enable
	###
	disable: ->
		@app.removeProperties
			Context: CONTEXT_PROTO
		return
	enable: ->
		@app.addProperties
			Context: CONTEXT_PROTO
		return


module.exports = Downloader