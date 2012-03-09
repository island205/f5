http=require "http"
io=require "socket.io"
url=require "url"
fs=require "fs"
path=require "path"
{types}=require "./mime"
config=require "./config"

createServer=->
    server=http.createServer (req,res)->
        pathname=url.parse(req.url).pathname
        console.log pathname
        realPath="."+pathname
        path.exists realPath,(exists)->
            if not exists
                res.writeHead 404,{"content-Type":"text/plain"}
                res.write "Not Found"
                res.end()
            else
                ext=path.extname realPath
                if ext
                    ext=ext.slice 1
                else
                    ext="unknown"
                contentType=types[ext] or "text/plain"
                res.setHeader "Content-Type",contentType
                
                ###
                last modified
                ###
                stat=fs.statSync realPath
                lastModified=stat.mtime.toUTCString()
                res.setHeader "Last-Modified",lastModified
                        
                ###
                expires and cache control
                ###
                if ext.match config.Expires.fileMatcth
                    expires=new Date()
                    expires.setTime expires.getTime()+config.Expires.maxAge*1000
                    res.setHeader "Expires",expires.toUTCString()
                    res.setHeader "Cache-control","max-age=#{config.Expires.maxAge}"
                        
                ifModifiedSince="If-Modified-Since".toLowerCase()
                if req.headers[ifModifiedSince] && (lastModified is req.headers[ifModifiedSince])
                    res.writeHead 304,"Not Modified"
                    res.end()
                else    
                    fs.readFile realPath,"binary",(err,file)->
                        if err
                            res.writeHead 500,{"content-Type":"text/plain"}
                            res.end(err)
                        else
                            res.writeHead 200,"Ok"
                            res.write file,"binary"
                            res.end()
            return
        return
    server.listen 8888
    console.log "You static server is running at port: 8888"
exports.createServer=createServer