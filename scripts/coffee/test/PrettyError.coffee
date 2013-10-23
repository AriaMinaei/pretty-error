require './_prepare'

error = (what) ->

	if typeof what is 'string'

		return error -> throw Error what

	else if what instanceof Function

		try

			do what

			return null

		catch e

			return e

	else

		throw Error "bar argument for error"

PrettyError = mod 'PrettyError'

describe "constructor()"

it "should work", ->

	p = new PrettyError

describe "toMarkup"

it "should return a string", ->

	p = new PrettyError

	p.toMarkup(error "hello").should.be.a 'string'

describe "getStyle()"

it "should, by default, return the contents in prettyError/defaultStyle", ->

	p = new PrettyError

	defaultStyle = mod 'prettyError/defaultStyle'

	p.getStyle().should.be.like defaultStyle()

it "should return different contents after appending some styles", ->

	p = new PrettyError

	p.appendStyle 'some selector': 'display': 'block'

	defaultStyle = mod 'prettyError/defaultStyle'

	p.getStyle().should.not.be.like defaultStyle()

describe "render()"

it "should work", ->

	p = new PrettyError

	global.tip = yes

	p.appendStyle 'pretty-error':

		marginLeft: 7

	e = error(-> "a".should.equal "b")

	markup = p.toMarkup e

	require('fs').writeFileSync 'f:/someFile.txt', markup, flag: 'w+'

	p.render e, yes