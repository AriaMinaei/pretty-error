sysPath = require 'path'

module.exports = class ParsedError

	constructor: (@error) ->


		unless @error instanceof Error

			throw Error "Unrecognized Error type"

		@_trace = []

		do @_parse

	_parse: ->

		@_message = @error.message

		stack = @error.stack

		@_kind = 'Error'

		if m = stack.match /^([a-zA-Z0-9\_\$]+):\ /

			@_kind = m[1]

		do @_parseLines

	_parseLines: ->

		text = @error.stack

		# remove the error kind
		text = text.replace /^([a-zA-Z0-9\_\$]+):\ /, ''

		# remove the message, if it matches
		if text.substr(0, @message.length) is @message

			text = text.substr(@message.length, text.length)

		text = text.trim()

		for line in text.split "\n"

			@_addTraceItem line

		return

	_addTraceItem: (text) ->


		text = text.trim()

		return if text is ''

		unless text.match /^at\ /

			throw Error "cannot read line `#{text}`"

		# remove the 'at ' part
		text = text.replace /^at /, ''

		original = text

		# the part that comes before the address
		what   = null

		# address, including path to module and line/col
		addr   = null

		# path to module
		path   = null

		# module dir
		dir    = null

		# module basename
		file   = null

		# line number (if using a compiler, the line number of the module
		# in that compiler will be used)
		line   = null

		# column, same as above
		col 	 = null

		# if using a compiler, this will translate to the line number of
		# the js equivalent of that module
		jsLine = null

		# same as above
		jsCol  = null

		modName = '[current]'

		# pick out the address
		if m = text.match /\(([^\)]+)\)$/

			addr = m[1].trim()

		if addr?

			what = text.substr 0, text.length - addr.length - 2

			what = what.trim()

		# might not have a 'what' clause
		unless addr?

			addr = text.trim()

		remaining = addr

		# remove the <js> clause if the file is a compiled one
		if m = remaining.match /\,\ <js>:(\d+):(\d+)$/

			jsLine = m[1]
			jsCol = m[2]

			remaining = remaining.substr 0, remaining.length - m[0].length

		# the line/col part
		if m = remaining.match /:(\d+):(\d+)$/

			line = m[1]
			col = m[2]

			remaining = remaining.substr 0, remaining.length - m[0].length

			path = remaining

		# file and dir
		if path?

			file = sysPath.basename path
			dir = sysPath.dirname path

			if dir is '.' then dir = ''

		if dir?

			d = dir.replace ///\\///g, '/'

			if m = d.match ///
					node_modules/([^/]+)(?!.*node_modules.*)
				///

				modName = m[1]

		unless jsLine?

			jsLine = line
			jsCol = col

		@_trace.push

			original: original
			what: what
			addr: addr
			path: path
			dir: dir
			file: file
			line: parseInt line
			col: parseInt col
			jsLine: parseInt jsLine
			jsCol: parseInt jsCol
			modName: modName

		return

	_getMessage: ->

		@_message

	_getKind: ->

		@_kind

	_getStack: ->

		@error.stack

	_getArguments: ->

		@error.arguments

	_getType: ->

		@error.type

	_getTrace: ->

		@_trace

for prop in ['message', 'kind', 'arguments', 'type', 'stack', 'trace'] then do ->

	methodName = '_get' + prop[0].toUpperCase() + prop.substr(1, prop.length)

	ParsedError::__defineGetter__ prop, -> do @[methodName]