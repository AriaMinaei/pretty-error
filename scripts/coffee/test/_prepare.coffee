# Let's write our tests using this little module until popo is ready


do ->

	path = require 'path'

	pathToLib = path.resolve __dirname, '../../js/lib'

	global.mod = (p) ->

		require path.resolve pathToLib, p

do ->
	purify = (obj) ->

		if typeof obj isnt 'object' then return obj

		ret = {}

		for own key, val of obj

			continue if key in ['prev', 'next', 'parent', 'attribs', 'length']

			continue if val instanceof Function

			ret[key] = purify val

		ret

	global.inspectDom = (obj) ->

		inspect purify obj

	global.inspect = require('eyespect').inspector pretty: yes, maxLength: 10200

color = do ->

	codes = off: 0, red: 31, green: 32, yellow: 33, blue: 34

	# https://github.com/loopj/commonjs-ansi-color
	setColor = (str, color) ->

		str = "\u001b[" + codes[color] + "m" +

		str + "\u001b[" + codes.off + "m"

		str

class TestRunner

	constructor: ->

		@done = no

		@report = []

		@pending = 0

		didBeep = no

	checkDone: ->

		return if @pending > 0 or @done

		@done = yes

		for item, id in @report

			if item.type is 'description'

				@renderDescription id, item

			else

				@renderTestcase id, item

		return

	renderDescription: (id, item) ->

		if id > 0 then console.log()

		console.log '       %s', item.name

	renderTestcase: (id, item) ->

		if item.skipped?

			@renderSkipped id, item

		else if item.success

			@renderSucess id, item

		else

			@renderFailure id, item

	renderSucess: (id, item) ->

		console.log '     √ \x1b[32m%s\x1b[0m', item.name

	renderSkipped: (id, item) ->

		console.log '     - \x1b[90m%s\x1b[0m', item.name

	handleSuccess: (id, name) ->

		@report[id].success = yes

		@checkDone()

	processErrorMessage: (msg) ->

		"       " + msg

	handleError: (id, name, err) ->

		@report[id].success = no
		@report[id].error = err

		@checkDone()

	renderFailure: (id, item) ->

		err = item.error

		console.log '       ' + color(item.name, 'red') + '\n'

		if err.actual?

			console.log '       Expected:'

			console.log '       "' + color(err.expected, 'yellow') + '"\n'

			console.log '       Actual:'
			console.log '       "' + color(err.actual, 'yellow') + '"\n'

		console.log '       Stack:'

		console.log color(@processErrorMessage(err.stack), 'yellow')

		unless @didBeep

			`console.log("\007")`

			@didBeep = yes

	describe: (name) ->

		@report.push type: 'description', name: name

		return

	skip: (name) ->

		@report.push type: 'test', name: name, skipped: yes

	test: (name, rest...) ->

		@pending++

		@report.push type: 'test', name: name, result: 'pending'

		id = @report.length - 1

		if rest.length is 1

			checkTimeout = yes

			fn = rest[0]

		else if rest.length is 2

			checkTimeout = Boolean rest[0]

			fn = rest[1]

		promise = w().then =>

			do fn

		if checkTimeout

			promise = timeout promise, 100

		promise.then =>

			@pending--
			@handleSuccess id, name

		, (err) =>

			@pending--
			@handleError id, name, err

tests = new TestRunner

global.test = global.it = tests.test.bind tests

global.test.skip = tests.skip.bind tests

global._test = tests.skip.bind tests

global.describe = tests.describe.bind tests

w = require 'when'

timeout = require 'when/timeout'

require 'when/monitor/console'

do ->

	global.chai = require 'chai'

	chai.should()

	global.expect = chai.expect

	chai.use require 'chai-fuzzy'

	chai.Assertion.includeStack = yes

	process.on 'exit', ->

		tests.checkDone()

		console.log "\n\n"

	delay = require 'when/delay'

	global.after = (ms, cb) ->

		delay(ms).then -> do cb