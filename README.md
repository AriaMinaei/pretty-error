# PrettyError

[![Dependency status](https://david-dm.org/AriaMinaei/pretty-error.svg)](https://david-dm.org/AriaMinaei/pretty-error)
[![devDependency Status](https://david-dm.org/AriaMinaei/pretty-error/dev-status.svg)](https://david-dm.org/AriaMinaei/pretty-error#info=devDependencies)
[![Build Status](https://secure.travis-ci.org/AriaMinaei/pretty-error.svg?branch=master)](https://travis-ci.org/AriaMinaei/pretty-error)

[![NPM](https://nodei.co/npm/pretty-error.svg)](https://npmjs.org/package/pretty-error)

A small tool to see node.js errors with less clutter:

![screenshot of PrettyError](https://github.com/AriaMinaei/pretty-error/raw/master/docs/images/pretty-error-screenshot.png)

... which is more readable compared to node's unformatted errors:

![screenshot of normal errors](https://github.com/AriaMinaei/pretty-error/raw/master/docs/images/normal-error-screenshot.png)

## Installation

Install with npm:

	npm install pretty-error

## Usage and Examples

To see an error rendered with colors, you can do this:

```javascript
var PrettyError = require('pretty-error');
var pe = new PrettyError();
var renderedError = pe.render(new Error('Some error message'));

console.log(renderedError);
```

Of course, you can render caught exceptions too:

```javascript
try {
   doSomethingThatThrowsAnError();
} catch (error) {
   console.log(pe.render(error));
}
```

But if you wanna see all node errors with colors, there is a shortcut for it:

```javascript
require('pretty-error').start();
```

... which is essentially equal to:

```javascript
var PrettyError = require('pretty-error');

// instantiate PrettyError, which can then be used to render error objects
var pe = new PrettyError();
pe.start();
```

## How it Works

PrettyError turns error objects into something similar to an html document, and then uses the upcoming [RenderKid](https://github.com/AriaMinaei/renderkid) to render the document using simple html/css-like commands. This allows PrettyError to be themed using simple css-like declarations.

## Theming

PrettyError's default theme is a bunch of simple css-like declarations. [Here](https://github.com/AriaMinaei/pretty-error/blob/master/scripts/coffee/lib/prettyError/defaultStyle.coffee) is the source of the default theme.

Surely, you can change all aspects of this theme. Let's do a minimal one:

```javascript
// the start() shortcuts returns an instance of PrettyError ...
pe = require('pretty-error').start();

// ... which we can then use to customize with css declarations:
pe.appendStyle({
   // this is a simple selector to the element that says 'Error'
   'pretty-error > header > title > kind': {
      // which we can hide:
      display: 'none'
   },

   // the 'colon' after 'Error':
   'pretty-error > header > colon': {
      // we hide that too:
      display: 'none'
   },

   // our error message
   'pretty-error > header > message': {
      // let's change its color:
      color: 'bright-white',

      // we can use black, red, green, yellow, blue, magenta, cyan, white,
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
      // This example sets the background color to white, and the text color
      // to cyan, the character will be a hyphen with a space character
      // on each side:
      // example: '"<bg-white><cyan> - </cyan></bg-white>"'
      //
      // Note that we should use a margin of 3, since the bullet will be
      // 3 characters long.
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
   }
});
```

Here is how our minimal theme will look like: ![screenshot of our custom theme](https://github.com/AriaMinaei/pretty-error/raw/master/docs/images/custom-theme-screenshot.png)

I'll post more examples on [RenderKid](https://github.com/AriaMinaei/renderkid) when it comes out of beta.

## Customization

There are a few methods to help you customize the contents of your error logs.

Let's instantiate first:

```javascript
PrettyError = require('pretty-error');
pe = new PrettyError();

// or:
pe = require('pretty-error').start();
```

#### Shortening paths

You might want to substitute long paths with shorter, more readable aliases:

```javascript
pe.alias('E:/open-source/theatrejs/scripts/js', '(Theare.js)');

// to remove the alias:
pe.removeAlias('E:/open-source/theatrejs/scripts/js');

// or:
pe.removeAllAliases();
```

#### Skipping packages

You might want to skip trace lines that belong to specific packages (chai, when, socket.io):

```javascript
pe.skipPackage('chai', 'when', 'socket.io');

// to unskip:
pe.unskipPackage('socket.io');
pe.unskipAllPackages();
```

#### Skipping node files

```javascript
// this will skip node.js, path.js, event.js, etc.
pe.skipNodeFiles();

// also:
pe.unskipNodeFiles();
```

#### Skipping paths

```javascript
pe.skipPath('/home/dir/someFile.js');

// also:
pe.unskipPath('/home/dir/someFile.js');
pe.unskipAllPaths();
```

#### Skipping by callback

You can customize which trace lines get logged and which won't:
```javascript
pe.skip(function(traceLine, lineNumber){
   // if we know which package this trace line comes from, and it isn't
   // our 'demo' package ...
   if (typeof traceLine.packageName !== 'undefined' && traceLine.packageName !== 'demo') {
      // then skip this line
      return true;
   }

   // You can console.log(traceLine) to see all of it's properties.
   // Don't expect all these properties to be present, and don't assume
   // that our traceLine is always an object.
});

// there is also:
pe.unskip(fn);
pe.unskipAll();
```

#### Modifying each trace line's contents

```javascript
pe.filter(function(traceLine, lineNumber){
   // the 'what' clause is something like:
   // 'DynamicTimeline.module.exports.DynamicTimeline._verifyProp'
   if (typeof traceLine.what !== 'undefined'){

      // we can shorten it with a regex:
      traceLine.what = traceLine.what.replace(
         /(.*\.module\.exports\.)(.*)/, '$2'
      );
   }
});

// there is also:
pe.removeFilter(fn);
pe.removeAllFilters();
```

## Disabling colors
```javascript
pe.withoutColors(); // Errors will be rendered without coloring
```

## Integrating with frameworks

PrettyError is very simple to set up, so it should be easy to use within other frameworks.

### Integrating with [express](https://github.com/visionmedia/express)

Most frameworks such as express, catch errors automatically and provide a mechanism to handle those errors. Here is an example of how you can use PrettyError to log unhandled errors in express:

```javascript
// this is app.js

var express = require('express');
var PrettyError = require('pretty-error');

var app = express();

app.get('/', function(req, res) {
   // this will throw an error:
   var a = b;
});

var server = app.listen(3000, function(){
   console.log('Server started \n');
});


// we can now instantiaite Prettyerror:
pe = new PrettyError();

// and use it for our app's error handler:
app.use(function(err, req, res, next){
   console.log(pe.render(err));
});

// we can optionally configure prettyError to simplify the stack trace:

pe.skipNodeFiles(); // this will skip events.js and http.js and similar core node files
pe.skipPackage('express'); // this will skip all the trace lines about express` core and sub-modules
```

## State of the project

This project has been out there for a while and used by fellow devs, but I still consider it a work in progress. Please let me know if something isn't working, or if you have any suggestions. And pull requests are of course, very welcome!

#### P.S.

* If you're on windows, you can get better typography by using an alternative console. I use [ConEmu](http://conemu.codeplex.com).
* Also check out [PrettyMonitor](https://github.com/AriaMinaei/pretty-monitor) if you're using [when.js](https://github.com/cujojs/when). It's PrettyError wrapped to report unhandled when.js rejections.

## License

MIT
