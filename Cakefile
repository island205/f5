{exec}=require "child_process"
task "watch","watch file change and compile to js",->
	child=exec "coffee -cwo lib/ src/",(e,s,se)->
		if e
			console.log e
			throw new Error "Error while compiling .coffee to .js"
	child.stdout.on "data",(data)->
		console.log data
