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
	.subdir ul{box-shadow:0 0 5px #ccc inset;background: #fff;}
	.folded ul{display: none;}
	.unfold ul{display:block;}
</style>
	<script language='javascript'>
var subdirs = document.getElementsByClassName('subdir');
var l = subdirs.length;
for(var i = 0;i < l;i ++) {
	(function(index){
		subdirs[i].addEventListener('click',function(){		// toggle className
			cn = this.className;
			console.log(cn);
			if( /\\bfolded\\b/.test( cn ) ) {				// if folded
				this.className = cn.replace(/\\bfolded\\b/,'');
				this.className += " unfold";
			}else{
				this.className = cn.replace(/\\bunfold\\b/g,''); 	// if unfold
				this.className += " folded";
			}
			this.className = this.className.replace("  "," ")
		})
	})( i )
}
	</script>
"""

insertTempl = (file, templ)->
	index=file.indexOf "</body>"
	if index is -1
		file += templ.join ''
	else
		file = file[ 0...index ] + templ.join('')  + file[ index... ]

insertSocket = ( file )->
	insertTempl( file, [SOCKET_TEMPLATE] )
insertStyle = ( file )->
	insertTempl( file, [STYLE_TEMPLATE] )

res500=(err,res)->
	res.writeHead 500,{"Content-Type":"text/plain"}
	res.end err

renderDir=(realPath,files)->
	if realPath[realPath.length-1] isnt "/"
        realPath+="/"
    html=[]
	html.push "<ul>"
	if realPath isnt "./"
		html.push ''#"<li><span class='folder'></span><a href='../'>..</a></li>"
	for file in files
		_path = realPath + file
		if fs.statSync(realPath+file).isDirectory()
			_files = fs.readdirSync(_path)
			html.push "<li class='subdir'><span class='folder'></span><a href='javascript:void(0)'>#{file}#{renderDir _path,_files}</a></li>"
		else
			_split = file.split('.')
			_extname = _split[_split.length-1]
			filetype=''
			switch _extname
				when 'css' 	then filetype = 'css'
				when 'html','htm' then filetype = 'html'
				when 'js'	then filetype = 'javascript'
				when 'jpg','jpeg','psd','gif','png' then filetype = 'image'
				when 'rar','zip','7z' then filetype = 'zipfile'
				else filetype = 'defaulttype'

			html.push "<li><span class='file ft_#{filetype}'></span><a href='./#{file}'>#{file}</a></li>"
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
						_htmltext = renderDir realPath,files
						res.write insertTempl _htmltext, [STYLE_TEMPLATE,SOCKET_TEMPLATE]
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

exports.version="v0.0.3"
exports.createServer=createServer
