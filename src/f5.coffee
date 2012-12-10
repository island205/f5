http    = require "http"
io      = require "socket.io"
ejs     = require "ejs"
url     = require "url"
fs      = require "fs"
path    = require "path"
{types} = require "./mime"
watcher = require("watch-tree-maintained").watchTree "."

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

getTempl = (file)->
    file = "./html/" + file
    return "" + fs.readFileSync(file)

insertTempl = (file, templ)->
    index = file.indexOf "</body>"
    if index is -1
        file += templ.join ''
    else
        file = file[ 0...index ] + templ.join('')  + file[ index.. ]

insertSocket = ( file )->
    insertTempl( file, [SOCKET_TEMPLATE] )

res500 = (err,res)->
    res.writeHead 500,{"Content-Type":"text/plain"}
    res.end err

renderDir = (realPath,files)->
    if realPath[realPath.length-1] isnt "/"
        realPath += "/"
    html = []
    html.push "<ul>"
    for file in files
        _path = realPath + file
        if fs.statSync(_path).isDirectory()
            _files = fs.readdirSync(_path)
            html.push \
                    "<li class='subdir folded'>\
                        <span class='folder'></span>\
                        <a href='##{_path}'onclick='toggleFold(this)'>#{file}</a>\
                        #{renderDir _path,_files}\
                    </li>"
        else
            _split = file.split('.')
            _extname = _split[_split.length-1]
            filetype = ''
            switch _extname
                when 'css'  then filetype = 'css'
                when 'html','htm' then filetype = 'html'
                when 'js'   then filetype = 'javascript'
                when 'jpg','jpeg','psd','gif','png' then filetype = 'image'
                when 'rar','zip','7z' then filetype = 'zipfile'
                else filetype = 'defaulttype'

            html.push "<li><span class='file ft_#{filetype}'></span><a href='./#{_path}'>#{file}</a></li>"
    html.push "</ul>"
    html.join ""

createServer = (config)->
    _path = config.path
    _port = config.port
    server = http.createServer (req,res)->
        pathname = url.parse(req.url).pathname
        realPath = decodeURIComponent _path+pathname

        ### path exist ###
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
                        res.write ejs.render(getTempl("files.ejs"), {
                            _htmltext: _htmltext,
                            title: realPath
                        })
                        res.end()
            else
                ext = path.extname realPath
                if ext
                    ext = ext[1..]
                else
                    ext = "unknown"
                res.setHeader "Content-Type",types[ext] or "text/plian"

                fs.readFile realPath,"binary",(err,file)->
                    if err
                        res500 err,res
                    else
                        res.writeHead 200,"Ok"
                        if ext is "html" or ext is "htm"
                            file = insertSocket file
                        res.write file,"binary"
                        res.end()
    _sockets = []
    _io = {sockets} = io.listen server, "log level":0
    sockets.on "connection",(socket)->
        _sockets.push socket
    for change in ["fileCreated","fileModified","fileDeleted"]
        watcher.on change,->
            for socket in _sockets
                socket.emit "reload"
    server.listen _port
    console.log "f5 is on localhost:#{_port} now."

exports.version = "v0.0.3"
exports.createServer = createServer
