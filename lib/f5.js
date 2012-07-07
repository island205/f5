(function() {
  var SOCKET_TEMPLATE, createServer, fs, http, insertSocket, io, path, rendDir, res500, types, url, watcher;
  http = require("http");
  io = require("socket.io");
  url = require("url");
  fs = require("fs");
  path = require("path");
  types = require("./mime").types;
  watcher = require("watch-tree-maintained").watchTree(".", {
    "ignore": "~$|\\.swp$"
  });
  SOCKET_TEMPLATE = "<script src=\"/socket.io/socket.io.js\"></script>\n<script>\n	var socket = io.connect('http://localhost');\n	socket.on('reload', function (data) {\n		window.location.reload();\n	});\n</script>	\n";
  insertSocket = function(file) {
    var index;
    index = file.indexOf("</body>");
    if (index === -1) {
      return file += SOCKET_TEMPLATE;
    } else {
      file = file.slice(0, index) + SOCKET_TEMPLATE + file.slice(index);
      return file;
    }
  };
  res500 = function(err, res) {
    res.writeHead(500, {
      "Content-Type": "text/plain"
    });
    return res.end(err);
  };
  rendDir = function(realPath, files) {
    var file, html, _i, _len;
    if (realPath[realPath.length - 1] !== "/") {
      realPath += "/";
    }
    html = [];
    html.push("<ul>");
    if (realPath !== "./") {
      html.push("<li><a href='../'>..</a></li>");
    }
    for (_i = 0, _len = files.length; _i < _len; _i++) {
      file = files[_i];
      if (fs.statSync(realPath + file).isDirectory()) {
        html.push("<li><a href='./" + file + "/'>" + file + "</a></li>");
      } else {
        html.push("<li><a href='./" + file + "'>" + file + "</a></li>");
      }
    }
    html.push("</ul>");
    return html.join("");
  };
  createServer = function(_path) {
    var change, server, sockets, _i, _len, _ref, _sockets;
    if (_path == null) {
      _path = ".";
    }
    server = http.createServer(function(req, res) {
      var pathname, realPath;
      pathname = url.parse(req.url).pathname;
      realPath = _path + pathname;
      /*
      		path exist
      		*/
      return fs.exists(realPath, function(exists) {
        var ext;
        if (!exists) {
          res.writeHead(404, {
            "Content-Type": "text/plain"
          });
          res.write("404 Not Found");
          return res.end();
        } else if (fs.statSync(realPath).isDirectory()) {
          return fs.readdir(realPath, function(err, files) {
            if (err) {
              return res500(err, res);
            } else {
              res.writeHead(200, {
                "Content-Type": types["html"]
              });
              res.write(insertSocket(rendDir(realPath, files)));
              return res.end();
            }
          });
        } else {
          ext = path.extname(realPath);
          if (ext) {
            ext = ext.slice(1);
          } else {
            ext = "unknown";
          }
          res.setHeader("Content-Type", types[ext] || "text/plian");
          return fs.readFile(realPath, "binary", function(err, file) {
            if (err) {
              return res500(err, res);
            } else {
              res.writeHead(200, "Ok");
              if (ext === "html" || ext === "htm") {
                file = insertSocket(file);
              }
              res.write(file, "binary");
              return res.end();
            }
          });
        }
      });
    });
    _sockets = [];
    sockets = io.listen(server).sockets;
    sockets.on("connection", function(socket) {
      return _sockets.push(socket);
    });
    _ref = ["fileCreated", "fileModified", "fileDeleted"];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      change = _ref[_i];
      watcher.on(change, function() {
        var socket, _j, _len2, _results;
        _results = [];
        for (_j = 0, _len2 = _sockets.length; _j < _len2; _j++) {
          socket = _sockets[_j];
          _results.push(socket.emit("reload"));
        }
        return _results;
      });
    }
    server.listen(8888);
    return console.log("Your static is starting on port 8888 !");
  };
  exports.version = "v0.0.1";
  exports.createServer = createServer;
}).call(this);
