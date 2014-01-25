# PrettyError

A small tool to render node.js errors with less clutter, like this:

![screenshot of PrettyError](https://github.com/AriaMinaei/pretty-error/raw/master/docs/images/pretty-error-screenshot.png)

... which is more readable compared to node's unformatted errors:

![screenshot of normal errors](https://github.com/AriaMinaei/pretty-error/raw/master/docs/images/normal-error-screenshot.png)

## Installation

Install with npm:

	npm install pretty-error

## Usage

To see all errors rendered with colors, there is a shortcut for it:
```javascript
require('pretty-error').start(function(){
	startTheApp();
});
```

... which is essentially equal to:
```javascript
PrettyError = require('pretty-error');

// instantiate PrettyError, which can then be used to
// render error objects
pe = new PrettyError();

// catch uncaught exceptions in node.js
process.on('uncaughtException', function(error){

	// this would render the caught error into a string...
	var rendered = pe.render(error);

	// ... which we can then use to log to the console
	console.error(rendered);

	// we should then exit the program, as advised in node's documentation:
	// http://nodejs.org/docs/v0.10.0/api/process.html#process_event_uncaughtexception
	process.exit(1);
});

// 'uncaughtException' will start listening on the next tick,
// so we must postpone everything that might generate errors
// to the next tick:
process.nextTick(function(){
	startTheApp();
});

// and of course, you can use it to render handled exceptions too:
try {

	aNonExistingFunction(); // this will throw an error

} catch (error) {

	// and we can render it out, just like unhandled errors
	console.log(pe.render(error));

}
```

## How it Works

PrettyError turns error objects into something similar to an html document, and then uses the upcoming [RenderKid](https://github.com/AriaMinaei/renderkid) to render the document using simple html/css-like commands for the console. This allows PrettyError to be themed using simple css-like declarations.

## Theming

PrettyError's default theme is a bunch of simple css-like declarations. [Here](https://github.com/AriaMinaei/pretty-error/blob/master/scripts/coffee/lib/prettyError/defaultStyle.coffee) is the source of the default theme.

Surely, you can change all aspects of this theme. Let's do a minimal theme:
```javascript
// the start() shortcuts returns an instance of PrettyError ...
pe = require('pretty-error').start();

// ... which we can then use to customize with css declarations:
pe.adppendStyle({

	// this is a simple selector to the element that says 'Error'
	'pretty-error > header > title > kind':

		// which we can hide:
		display: 'none'

	},

	// the 'colon' after 'Error':
	'pretty-error > header > colon': {

		// we hide that too
		display: 'none'

	},

	// our error message
	'pretty-error > header > message': {

		// let's change its color
		color: 'bright-white',

		// I could use black, red, green, yellow, blue, magenta, cyan, white,
		// grey, bright-red, bright-green, bright-yellow, bright-blue,
		// bright-magenta, bright-cyan, and bright-white

		// we can also change the background color:
		background: 'cyan',

		// it understands paddings too!
		padding: '0 1' // top/bottom left/right

	},

	// each trace item ...
	'pretty-error > trace > item': {

		// ... can have a margin ...
		marginLeft: 2,

		// ... and a bullet character!
		bullet: '"<grey>o</grey>"'

		// Notes on bullets:
		//
		// The string inside the quotation mark will be used for bullets.
		//
		// You can set its color/background color using tags.
		//
		// This example set the background color to white, and the text color
		// to cyan, the character will be a hyphen with a space character
		// on each side:
		// example: '<bg-white><cyan> - </cyan></bg-white>'
		// (Note that we should use a margin of 3, since the bullet will be
		// 3characters long.)

	},

	'pretty-error > trace > item > header > pointer > file': {

		color: 'bright-cyan'

	},

	'pretty-error > trace > item > header > pointer > colon': {

		color: 'cyan'

	},

	'pretty-error > trace > item > header > pointer > line': {

		color: 'bright-cyan'

	},

	'pretty-error > trace > item > header > what': {

		color: 'bright-white'

	},

	'pretty-error > trace > item > footer > addr': {

		display: 'none'

});
```

Here is how our minimal theme will look like:
![screenshot of our custom theme](https://github.com/AriaMinaei/pretty-error/raw/master/docs/images/custom-theme-screenshot.png)