defaultStyle = require './PrettyError/defaultStyle'
ParsedError = require './ParsedError'
RenderKid = require 'RenderKid'
{object} = require 'utila'

module.exports = class PrettyError

	self = @

	@_getDefaultStyle: ->

		defaultStyle()

	constructor: ->

		@_maxItems = 50

		@_modulesToSkip = []

		@_pathsToSkip = []

		@_skipCallbacks = []

		@_renderer = new RenderKid

		@_style = self._getDefaultStyle()

		@_renderer.style @_style

	config: (c) ->

		if c.modulesToSkip?

			@skipModule.apply @, c.modulesToSkip

		if c.pathsToSkip?

			@skipPath.apply @, c.pathsToSkip

		if c.skip?

			@skip.apply @, c.skip

		if c.maxItems?

			@setMaxItems c.maxItems

		if c.skipNodeFiles

			@skipNodeFiles()

		@

	skipModule: (modNames...) ->

		@_modulesToSkip.push String modName for modName in modNames

		@

	skipPath: (fileNames...) ->

		@_pathsToSkip.push fileName for fileName in fileNames

		@

	skip: (callbacks...) ->

		@_skipCallbacks.push cb for cb in callbacks

		@

	skipNodeFiles: ->

		@skipPath 'timers.js'

	setMaxItems: (maxItems = 50) ->

		if maxItems is 0 then maxItems = 1000

		@_maxItems = maxItems|0

		@

	_getStyle: ->

		@_style

	appendStyle: (toAppend) ->

		object.appendOnto @_style, toAppend

		@_renderer.style toAppend

		@

	_getRenderer: ->

		@_renderer

	render: (e, logIt = no) ->

		obj = @getObject e

		rendered = @_renderer.render(obj)

		if logIt is yes

			console.log rendered

		rendered

	_skipOrFilter: (item, itemNumber) ->

		if typeof item is 'object'

			return yes if item.modName in @_modulesToSkip

			return yes if item.path in @_pathsToSkip

			for modName in item.modules

				return yes if modName in @_modulesToSkip

		for cb in @_skipCallbacks

			return yes if cb(item, itemNumber) is yes

		# console.log item

		return no

	getObject: (e) ->

		unless e instanceof ParsedError

			e = new ParsedError e

		header =

			title: do ->

				ret = {}

				# some errors are thrown to display other errors.
				# we call them wrappers here.
				if e.wrapper isnt ''

					ret.wrapper = e.wrapper + ":"

				ret.kind = e.kind

				ret

			colon: ':'

			message: e.message

		traceItems = []

		count = -1

		for item, i in e.trace

			continue unless item?

			if @_skipOrFilter(item, i) is yes

				continue

			count++

			break if count > @_maxItems

			if typeof item is 'string'

				traceItems.push

					item: custom: item

				continue

			traceItems.push item:

				header:

					pointer: do ->

						unless item.file?

							return ''

						{
							file: item.file

							colon: ':'

							line: item.line

						}

					what: item.what

				footer:

					addr: item.shortenedAddr

		obj = 'pretty-error':

			header: header

		if traceItems.length > 0

			obj['pretty-error'].trace = traceItems

		obj

for prop in ['renderer', 'style'] then do ->

	methodName = '_get' + prop[0].toUpperCase() + prop.substr(1, prop.length)

	PrettyError::__defineGetter__ prop, -> do @[methodName]