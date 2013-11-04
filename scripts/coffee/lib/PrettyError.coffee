defaultStyle = require './PrettyError/defaultStyle'
ParsedError = require './ParsedError'
RenderKid = require 'RenderKid'
{object} = require 'utila'

module.exports = class PrettyError

	self = @

	@_getDefaultStyle: ->

		defaultStyle()

	constructor: ->

		@_renderer = new RenderKid

		@_style = self._getDefaultStyle()

		@_renderer.style @_style

	_getStyle: ->

		@_style

	appendStyle: (toAppend) ->

		object.appendOnto @_style, toAppend

		@_renderer.style toAppend

		@

	_getRenderer: ->

		@_renderer

	render: (e, logIt = no, skipModules = no) ->

		obj = @getObject e, skipModules

		rendered = @_renderer.render(obj)

		if logIt is yes

			console.log rendered

		rendered

	getObject: (e, skipModules = no) ->

		unless e instanceof ParsedError

			e = new ParsedError e

		unless typeof skipModules is 'boolean' or Array.isArray skipModules

			throw Error "skipModules only accepts a boolean or an array of module names"

		header =

			title: do ->

				ret = {}


				if e.wrapper isnt ''

					ret.wrapper = e.wrapper + ":"

				ret.kind = e.kind

				ret


			colon: ':'

			message: e.message

		traceItems = []

		for item, i in e.trace

			if typeof item is 'string'

				traceItems.push

					item: custom: item

				continue

			if skipModules isnt no and i > 0

				continue if skipModules is yes and item.modName is '[current]'

				continue if item.modName in skipModules

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