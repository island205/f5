http=require "http"
io=require "socket.io"
url=require "url"
fs=require "fs"
path=require "path"
{types}=require "./mime"
config=require "./config"
watcher=require("watch-tree-maintained").watchTree ".",{"ignore":/\.swp$/}

SOCKET_TEMPLATE="""
	<script src="/socket.io/socket.io.js"></script>
	<script>
		var socket = io.connect('http://localhost');
		socket.on('reload', function (data) {
			window.location.reload();
		});
	</script>	

"""
insertSocket=(file)->
	if file.indexOf("</body>") is -1
		file+=SOCKET_TEMPLATE
	else
		file
createServer=->
	server=http.createServer (req,res)->
		pathname=url.parse(req.url).pathname
		realPath="."+pathname
		
		###
		path exist
		###
		path.exists realPath,(exists)->
			if not exists
				res.writeHead 404,{"Content-Type":"text/plain"}
				res.write "404 Not Found"
				res.end()
			else if fs.statSync(realPath).isDirectory()
				res.writeHead 200,{"Content-Type":"text/plain"}
				res.end("It is a directory.")
			else
				ext=path.extname realPath
				if ext
					ext=ext.slice 1
				else
					ext="unknown"
				res.setHeader "Content-Type",types[ext] or "text/plian"
			
				fs.readFile realPath,"binary",(err,file)->
					if err
						res.writeHead 500,{"Content-Type":"text/plain"}
						res.end err
					else
						res.writeHead 200,"Ok"
						if ext is "html"
							file=insertSocket file
						res.write file,"binary"
						res.end()
	_sockets=[]
	{sockets}=io.listen server
	sockets.on "connection",(socket)->
		_sockets.push socket
	for change in ["fileCreated","fileModified","fileDeleted"]
		watcher.on change,->
			console.log "change"
			for socket in _sockets
				socket.emit "reload"
	server.listen 8888
	console.log "Your static is starting on port 8888 !"

exports.createServer=createServer
