require './_prepare'

error = (what) ->

	if typeof what is 'string'

		return error -> throw Error what

	else if what instanceof Function

		try

			do what

		catch e

			return e

	throw Error "bad argument for error"

PrettyError = mod 'PrettyError'

describe "constructor()"

it "should work", ->

	p = new PrettyError

describe "getObject"

it "should return a string", ->

	p = new PrettyError

	p.getObject(error "hello").should.be.an 'object'

describe "style"

it "should, by default, return the contents in prettyError/defaultStyle", ->

	p = new PrettyError

	defaultStyle = mod 'prettyError/defaultStyle'

	p.style.should.be.like defaultStyle()

it "should return different contents after appending some styles", ->

	p = new PrettyError

	p.appendStyle 'some selector': 'display': 'block'

	defaultStyle = mod 'prettyError/defaultStyle'

	p.style.should.not.be.like defaultStyle()

describe "render()"

it "should work", ->

	p = new PrettyError

	p.skipNodeFiles()

	p.appendStyle 'pretty-error':

		marginLeft: 4

	e = error -> "a".should.equal "b"

	console.log p.render e, no

	e2 = error -> Array.split(Object)

	console.log p.render e2, no

	e3 = "Plain error message"

	console.log p.render e3, no

	e4 =

		message: "Custom error message"

		kind: "Custom Error"

	console.log p.render e4, no

	e5 =

		message: "Error with custom stack"

		stack: ['line one', 'line two']

		wrapper: 'UnhandledRejection'

	console.log p.render e5, no