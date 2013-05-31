url = require 'url'
readline = require 'readline'

coffee = require __dirname+'/../node_modules/coffee-script'

tid = null
proc = require 'child_process'
shell = proc.spawn 'mongo', process.argv.slice 2
rl = readline.createInterface process.stdin, process.stdout

query = ->
	rl.question '>', (data) ->
		try
			if data.match /^(show|use)/ then c = data+"\n"
			else c = coffee.compile data.toString(), {bare:true}
			shell.stdin.write c
		catch e
			shell.stdin.write data
		query()

shell.stdout.on 'data', (data) ->
	process.stdout.write data.toString()
	if tid then clearTimeout tid
	tid = setTimeout query, 100

shell.stderr.on 'data', (data) ->
	process.stderr.write data.toString()
	if tid then clearTimeout tid
	tid = setTimeout query, 100

shell.on 'exit', -> 
	process.exit(0)