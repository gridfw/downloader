###*
 * Gridfw 
 * @copyright khalid RAFIK 2019
###
'use strict'
SendFile	= require 'send'
ETag		= require 'etag'
ContentDisposition = require 'content-disposition'

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
		# copy default settings
		options = SETTINGS.slice 0
		# prepare options, we use array for best performance
		if settings
			for k,v of settings
				defSet = SETTINGS_INIT[k]
				if defSet
					options[defSet.i]= defSet.check v # check the value is correct
				else unless k is 'require'
					throw new Error "Unknown option: #{k}"
		# enable
		@enable()
		return
	###*
	 * destroy
	###
	destroy: ->
		# remove all properties
		ctxProto = @app.Context
		for k,v of ctxProto
			if v is CONTEXT_PROTO[k]
				delete ctxProto[k]
		return
	###*
	 * Disable, enable
	###
	disable: -> @destroy()
	enable: ->
		# get the descriptor
		ctxDescriptor= Object.getOwnPropertyDescriptors CONTEXT_PROTO
		for k,v of ctxDescriptor
			v.writable = off
			v.enumerable = off
		# add to context
		_defineProperties @app.Context, ctxDescriptor
		return


module.exports = Downloader