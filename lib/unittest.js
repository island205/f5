(function() {
  var TEST_FOLDER_NAME, fs, generate, generateAll, generateFolder, path, templates;
  fs = require("fs");
  path = require("path");
  templates = require("./template").templates;
  console.log(templates);
  TEST_FOLDER_NAME = "test";
  generateFolder = function(name) {
    if (!path.existsSync("./" + name)) {
      fs.mkdirSync("./" + name, "0777");
      return console.log("	" + name + " is generated.");
    }
  };
  generateAll = function() {
    var dir, fileName, _i, _len, _results;
    generateFolder(TEST_FOLDER_NAME);
    dir = fs.readdirSync(".");
    _results = [];
    for (_i = 0, _len = dir.length; _i < _len; _i++) {
      fileName = dir[_i];
      _results.push(/^.*\.js$/.test(fileName) ? generate(fileName) : void 0);
    }
    return _results;
  };
  generate = function(fileName) {
    var html, htmlFilePath, jsFilePath, testJsFilePath, title;
    generateFolder(TEST_FOLDER_NAME);
    title = "" + fileName + ".js test";
    jsFilePath = "../" + fileName + ".js";
    testJsFilePath = "./" + TEST_FOLDER_NAME + "/" + fileName + "-test.js";
    htmlFilePath = "./" + TEST_FOLDER_NAME + "/" + fileName + "-test.html";
    if (!path.existsSync(testJsFilePath)) {
      fs.writeFileSync(testJsFilePath, templates["qunit"]["js"]);
      console.log(" " + testJsFilePath + " is generated.");
    }
    if (!path.existsSync(htmlFilePath)) {
      html = templates["qunit"]["html"].replace("#jsFilePath#", jsFilePath).replace("#testJsFilePath#", testJsFilePath.replace("/test", "")).replace("#title#", title);
      fs.writeFileSync(htmlFilePath, html);
      return console.log(" " + htmlFilePath + " is genrated.");
    }
  };
  exports.generateAll = generateAll;
  exports.generate = generate;
}).call(this);
