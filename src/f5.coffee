http    = require "http"
io      = require "socket.io"
ejs     = require "ejs"
url     = require "url"
fs      = require "fs"
path    = require "path"
{types} = require "mime"

watcher = require("watch-tree-maintained").watchTree ".", {"ignore":/(.*\/\.\w+|.*~$)/}

SOCKET_TEMPLATE="""
    <script src="/socket.io/socket.io.js"></script>
    <script src="/f5static/reflesh.js"></script>
"""

getTempl = (file)->
    templDir = path.join(__dirname,'..','./template/')
    file = templDir + file
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
sortFiles = (realPath,files)->
    _folders = []
    _files   = []
    if realPath[realPath.length-1] isnt "/"
        realPath += "/"
    for file in files
        if fs.statSync(realPath+file).isDirectory()
            _folders.push file
        else
            _files.push file
    _folders.concat _files

renderDir = (realPath,files)->
    files = sortFiles(realPath,files)

    if realPath[realPath.length-1] isnt "/"
        realPath += "/"
    html = []
    html.push "<ul>"
    for file in files
        if file[0] is '.'       # ingore dot files
            continue
        _path = realPath + file
        if fs.statSync(_path).isDirectory()
            _files = fs.readdirSync(_path)
            html.push ejs.render getTempl("dir.ejs"), {
                _path  : _path,
                file   : file,
                subdir : renderDir _path, _files
            }
        else
            _split = file.split('.')
            _extname = _split[_split.length-1]
            filetype = ''
            switch _extname
                when 'css'  then filetype = 'css'
                when 'html','htm' then filetype = 'html'
                when 'js','coffee'   then filetype = 'javascript'
                when 'jpg','jpeg','psd','gif','png' then filetype = 'image'
                when 'rar','zip','7z' then filetype = 'zipfile'
                else filetype = 'defaulttype'

            html.push ejs.render getTempl("file.ejs"), {
                filetype:filetype,
                _path:_path,
                file:file
            }
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
                res.writeHead 404,{"Content-Type":"text/html"}
                res.write ejs.render(getTempl("404.ejs"),{
                    _htmltext: "404 Not Found"
                    title: "404 Not Found"
                })
                res.end()
            else if fs.statSync(realPath).isDirectory()
                fs.readdir realPath,(err,files)->
                    if err
                        res500 err,res
                    else
                        res.writeHead 200,{"Content-Type":types["html"]}
                        _htmltext = renderDir realPath,files
                        res.write ejs.render(getTempl("tree.ejs"), {
                            _htmltext: _htmltext,
                            title: realPath
                        })
                        res.end()
            else
                # redirect to f5static file
                if (realPath.split "/")[1] == 'f5static'
                    realPath = path.join( __dirname, '..', realPath )

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
        watcher.on change,( file )->
            for socket in _sockets
                socket.emit "reload",file
    server.listen _port
    console.log "f5 is on localhost:#{_port} now."

exports.version = 'v0.0.6'
exports.createServer = createServer
