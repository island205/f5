http=require "http"
io=require "socket.io"
url=require "url"
fs=require "fs"
path=require "path"
{types}=require "./mime"
config=require "./config"
watcher=require("watch-tree-maintained").watchTree ".",{"ignore":"~$|\\.swp$"}

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
res500=(err,res)->
	res.writeHead 500,{"Content-Type":"text/plain"}
	res.end err
rendDir=(realPath,files)->
	if realPath[realPath.length-1] isnt "/"
		realPath+="/"
	html=[]
	html.push "<ul>"
	if realPath isnt "./"
		html.push "<li><a href='../'>..</a></li>"
	for file in files
		if fs.statSync(realPath+file).isDirectory()
			html.push "<li><a href='./#{file}/'>#{file}</a></li>"
		else
			html.push "<li><a href='./#{file}'>#{file}</a></li>"
	html.push "</ul>"
	html.join ""
createServer=(_path=".")->
	server=http.createServer (req,res)->
		pathname=url.parse(req.url).pathname
		realPath=_path+pathname
		
		###
		path exist
		###
		path.exists realPath,(exists)->
			if not exists
				res.writeHead 404,{"Content-Type":"text/plain"}
				res.write "404 Not Found"
				res.end()
			else if fs.statSync(realPath).isDirectory()
				fs.readdir realPath,(err,files)->
					if err
						res500 err,res
					else
						res.writeHead 200,{"Content-Type":types["html"]}
						res.write insertSocket rendDir realPath,files
						res.end()
			else
				ext=path.extname realPath
				if ext
					ext=ext.slice 1
				else
					ext="unknown"
				res.setHeader "Content-Type",types[ext] or "text/plian"
			
				fs.readFile realPath,"binary",(err,file)->
					if err
						res500 err,res
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
			for socket in _sockets
				socket.emit "reload"
	server.listen 8888
	console.log "Your static is starting on port 8888 !"

exports.version="v0.0.1"
exports.createServer=createServer
