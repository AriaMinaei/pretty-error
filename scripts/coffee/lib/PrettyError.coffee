{object, array} = require 'utila'
defaultStyle = require './prettyError/defaultStyle'
ParsedError = require './ParsedError'
nodePaths = require './nodePaths'
RenderKid = require 'renderkid'

module.exports = class PrettyError

	self = @

	@_filters:

		'module.exports': (item) ->

			return unless item.what?

			item.what = item.what.replace /\.module\.exports\./g, ' - '

			return

	@_getDefaultStyle: ->

		defaultStyle()

	@start: (cb) ->

		pe = new self

		pe.start cb

		pe

	constructor: ->

		@_maxItems = 50

		@_packagesToSkip = []

		@_pathsToSkip = []

		@_skipCallbacks = []

		@_filterCallbacks = []

		@_aliases = []

		@_renderer = new RenderKid

		@_style = self._getDefaultStyle()

		@_renderer.style @_style

	start: (cb) ->

		process.on 'uncaughtException', (exc) =>

			@render exc, yes

			process.exit 1

			return

		process.nextTick cb if cb?

		@

	config: (c) ->

		if c.skipPackages?

			if c.skipPackages is no

				@unskipAllPackages()

			else

				@skipPackage.apply @, c.skipPackages

		if c.skipPaths?

			if c.skipPaths is no

				@unskipAllPaths()

			else

				@skipPath.apply @, c.skipPaths

		if c.skip?

			if c.skip is no

				@unskipAll()

			else

				@skip.apply @, c.skip

		if c.maxItems?

			@setMaxItems c.maxItems

		if c.skipNodeFiles is yes

			@skipNodeFiles()

		else if c.skipNodeFiles is no

			@unskipNodeFiles()

		if c.filters?

			if c.filters is no

				@removeAllFilters()

			else

				@filters.apply @, c.filters

		if c.aliases?

			if object.isBareObject c.aliases

				@alias path, alias for path, alias of c.aliases

			else if c.aliases is no

				@removeAllAliases()

		@

	skipPackage: (packages...) ->

		@_packagesToSkip.push String pkg for pkg in packages

		@

	unskipPackage: (packages...) ->

		array.pluckOneItem(@_packagesToSkip, pkg) for pkg in packages

		@

	unskipAllPackages: ->

		@_packagesToSkip.length = 0

		@

	skipPath: (paths...) ->

		@_pathsToSkip.push path for path in paths

		@

	unskipPath: (paths...) ->

		array.pluckOneItem(@_pathsToSkip, path) for path in paths

		@

	unskipAllPaths: ->

		@_pathsToSkip.length = 0

		@

	skip: (callbacks...) ->

		@_skipCallbacks.push cb for cb in callbacks

		@

	unskip: (callbacks...) ->

		array.pluckOneItem(@_skipCallbacks, cb) for cb in callbacks

		@

	unskipAll: ->

		@_skipCallbacks.length = 0

		@

	skipNodeFiles: ->

		@skipPath.apply @, nodePaths

	unskipNodeFiles: ->

		@unskipPath.apply @, nodePaths

	filter: (callbacks...) ->

		@_filterCallbacks.push cb for cb in callbacks

		@

	removeFilter: (callbacks...) ->

		array.pluckOneItem(@_filterCallbacks, cb) for cb in callbacks

		@

	removeAllFilters: ->

		@_filterCallbacks.length = 0

		@

	setMaxItems: (maxItems = 50) ->

		if maxItems is 0 then maxItems = 1000

		@_maxItems = maxItems|0

		@

	alias: (stringOrRx, alias) ->

		@_aliases.push {stringOrRx, alias}

		@

	removeAlias: (stringOrRx) ->

		array.pluckByCallback @_aliases, (pair) ->

			pair.stringOrRx is stringOrRx

		@

	removeAllAliases: ->

		@_aliases.length = 0

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

		console.error rendered if logIt is yes

		rendered

	getObject: (e) ->

		unless e instanceof ParsedError

			e = new ParsedError e

		header =

			title: do ->

				ret = {}

				# some errors are thrown to display other errors.
				# we call them wrappers here.
				if e.wrapper isnt ''

					ret.wrapper = "#{e.wrapper}"

				ret.kind = e.kind

				ret

			colon: ':'

			message: do ->

				msg = String(e.message).trim()

				return msg unless msg.match(/\n/)

				splitted = msg.split "\n"

				ret = []

				for line, i in splitted

					ret.push line

					if i < splitted.length - 1

						ret.push br: {}

				ret

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

				footer: do ->

					foooter = addr: item.shortenedAddr

					if item.extra? then foooter.extra = item.extra

					foooter

		obj = 'pretty-error':

			header: header

		if traceItems.length > 0

			obj['pretty-error'].trace = traceItems

		obj

	_skipOrFilter: (item, itemNumber) ->

		if typeof item is 'object'

			return yes if item.modName in @_packagesToSkip

			return yes if item.path in @_pathsToSkip

			for modName in item.packages

				return yes if modName in @_packagesToSkip

			if typeof item.shortenedAddr is 'string'

				for pair in @_aliases

					item.shortenedAddr = item.shortenedAddr.replace pair.stringOrRx,

						pair.alias

		for cb in @_skipCallbacks

			return yes if cb(item, itemNumber) is yes

		for cb in @_filterCallbacks

			cb(item, itemNumber)

		return no

for prop in ['renderer', 'style'] then do ->

	methodName = '_get' + prop[0].toUpperCase() + prop.substr(1, prop.length)

	PrettyError::__defineGetter__ prop, -> do @[methodName]