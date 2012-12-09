{exec}=require "child_process"

task "build","compile src to lib",->
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

task "test", "run server for test", ->
    child=exec "node bin/f5",(err,s)->
        if err
            console.log err
        else
            console.log s
     child.stdout.on "data",(data)->
        console.log data
