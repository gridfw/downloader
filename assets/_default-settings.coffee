### default settings ###
_initSettings = <%= initSettings %>
	pretty:
		default: true
		check: (value)->
			throw new Error "Options.pretty expected boolean" unless typeof value is 'boolean'
			value
	jsonp:
		default: -> (ctx)-> ctx.query.cb or 'callback'
		check: (value) ->
			throw new Error "Options.jsonp expected function" unless typeof value is 'function'
			value
	etag:
		default: -> ETag
		check: (value) ->
			if value is false
				return -> undefined
			else if value is true
				return ETag
			else if typeof value is 'function'
				return value
			else
				throw 'Expected boolean or sync function'
	