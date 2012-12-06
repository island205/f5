{exec}=require "child_process"

task "watch","watch file change and compile to js",->
	child=exec "coffee -cwo lib/ src/",(e,s,se)->
		if e
			console.log e
			throw new Error "Error while compiling .coffee to .js"
	child.stdout.on "data",(data)->
		console.log data

task "install","install f5 local",->
	child=exec "sudo npm install -g",(err,s)->
		if err
			console.log err
		else
			console.log s
	child.stdout.on "data",(data)->
		console.log data

#task "test","run test",->
#	exec "nodeunit test/*-test.coffee",(err,s)->
#		if err
#			console.log err
#		else
#			console.log s
