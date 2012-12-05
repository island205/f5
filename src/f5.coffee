http    = require "http"
io      = require "socket.io"
url     = require "url"
fs      = require "fs"
path    = require "path"
{types} = require "./mime"
watcher = require("watch-tree-maintained").watchTree ".",{"ignore":"^\..*|~$|\\.swp$"}

SOCKET_TEMPLATE=\
"""
    <script src="/socket.io/socket.io.js"></script>
    <script>
        var socket = io.connect('http://localhost');
        socket.on('reload', function (data) {
            window.location.reload();
        });
</script>
"""
STYLE_TEMPLATE=\
"""
<style type="text/css">
    ul{padding:5px 8px; background:#F8F8F8; margin:5px; border: 1px solid #CACACA; border-radius:3px; box-shadow:0 0 5px #ccc;}
    ul li{list-style-type:none; border-bottom:1px solid #eee; padding:3px;}
    ul li a{color:#4183C4; text-decoration:none}
    ul li a:hover{text-decoration:underline}
    ul li span{background-image:url(http://pic.yupoo.com/island205/CjJzay6Y/BaDLi.png); display:inline-block; width:20px; height:14px; margin:0 3px}
    ul li .folder{}
    ul li .file{ background-position-y:18px;}
</style>
"""

insertSocket=(file)->
	index=file.indexOf "</body>"
	if index is -1
		file += SOCKET_TEMPLATE
	else
		file = file[ 0...index ] + SOCKET_TEMPLATE  + file[ index... ]

res500=(err,res)->
	res.writeHead 500,{"Content-Type":"text/plain"}
	res.end err

renderDir=(realPath,files)->
	if realPath[realPath.length-1] isnt "/"
        realPath+="/"
    html=[]
    html.push STYLE_TEMPLATE
	html.push "<ul>"
	if realPath isnt "./"
		html.push "<li><span class='folder'></span><a href='../'>..</a></li>"
	for file in files
		if fs.statSync(realPath+file).isDirectory()
			html.push "<li><span class='folder'></span><a href='./#{file}/'>#{file}</a></li>"
		else
			html.push "<li><span class='file'></span><a href='./#{file}'>#{file}</a></li>"
	html.push "</ul>"
	html.join ""

createServer=(config)->
	_path = config.path
	_port = config.port
	server=http.createServer (req,res)->
		pathname = url.parse(req.url).pathname
		realPath = _path+pathname
		#support chinese filename or path
		realPath = decodeURIComponent realPath
		
		###
		path exist
		###
		fs.exists realPath,(exists)->
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
						res.write insertSocket renderDir realPath,files
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
						if ext is "html" or ext is "htm"
							file=insertSocket file
						res.write file,"binary"
						res.end()
    _sockets=[]
    _io={sockets}=io.listen server, "log level":0
    sockets.on "connection",(socket)->
        _sockets.push socket
	for change in ["fileCreated","fileModified","fileDeleted"]
		watcher.on change,->
			for socket in _sockets
				socket.emit "reload"
	server.listen _port
	console.log "f5 is on localhost:#{_port} now."

exports.version="v0.0.2"
exports.createServer=createServer
