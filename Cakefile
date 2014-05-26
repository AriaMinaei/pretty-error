exec = require('child_process').exec
fs = require 'fs'
sysPath = require 'path'

# This is in place until we replace the test suite runner with popo
task 'test', ->

	runTestsIn 'test', '_prepare.coffee'

runInCoffee = (path, cb) ->

	exec 'node ./node_modules/coffee-script/bin/coffee ' + path, cb

runTestsIn = (shortPath, except) ->

	fullPath = sysPath.resolve shortPath

	fs.readdir fullPath, (err, files) ->

		if err then throw Error err

		for file in files

			continue if file is except

			fullFilePath = sysPath.resolve(fullPath, file)
			shortFilePath = shortPath + '/' + file

			if sysPath.extname(file) is '.coffee'

				runAsTest shortFilePath, fullFilePath

			else if fs.statSync(fullFilePath).isDirectory()

				runTestsIn shortFilePath

		return

didBeep = no

runAsTest = (shortPath, fullPath) ->

	runInCoffee fullPath, (error, stdout, stderr) ->

		output = 'Running ' + shortPath + '\n'

		if stderr

			unless didBeep

				`console.log("\007")`

				didBeep = yes

			output += 'Error\n' + stdout + stderr + '\n'

		else if stdout

			output += '\n' + stdout

		console.log output