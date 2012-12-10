{exec} = require "child_process"

_buildcmd   = "coffee -co lib/ src/"
_watchcmd   = "coffee -cwo lib/ src/"
_installcmd = ["sudo install -g","npm install -g"][0 <= process.env.os.toLowerCase().search 'nt']
_testcmd    = "node bin/f5"

task "watch","auto compile src to lib",->
    child = exec _watchcmd, (e,s,se)->
        if e
            console.log e
            throw new Error "Error while compiling .coffee to .js"
    child.stdout.on "data",(data)->
        console.log data

task "build","compile src to lib",->
    child = exec _buildcmd, (e,s,se)->
        if e
            console.log e
    child.stdout.on "data",(data)->
        console.log data

task "test", "run server for test", ->
    invoke "build"
    child = exec _testcmd,(err,s)->
        if err
            console.log err
        else
            console.log s
     child.stdout.on "data",(data)->
        console.log data

task "install","install f5 local",->
    invoke "build"
    child = exec _installcmd,(err,s)->
        if err
            console.log err
        else
            console.log s
    child.stdout.on "data",(data)->
        console.log data
