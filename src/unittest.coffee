fs=require "fs"
mustache=require "mustache"
path=require "path"
{templates}=require "./template"
TEST_FOLDER_NAME="test"

templatePath="./template/"

getTemplate=(name,type,data={})->
	if name is "qunit"
		file="#{name}-template-test.#{type}"
	else
		file="#{name}-template-spec.#{type}"
	filePath=templatePath+file
	file=fs.readFileSync(filePath,"utf-8")
	file=mustache.to_html file,data
	file
	

generateFolder=(name)->
	if not path.existsSync "./#{name}"
		fs.mkdirSync "./#{name}","0777"
		console.log  "	#{name} is generated."	
	
generateAll=->
	generateFolder TEST_FOLDER_NAME
	dir=fs.readdirSync "."
	for fileName in dir
		if /^.*\.js$/.test fileName
			generate fileName

generate=(fileName)->
	generateFolder TEST_FOLDER_NAME
	title="#{fileName}.js test"
	jsFilePath="../#{fileName}.js"
	testJsFilePath="./#{TEST_FOLDER_NAME}/#{fileName}-test.js"
	htmlFilePath="./#{TEST_FOLDER_NAME}/#{fileName}-test.html"
	if not path.existsSync testJsFilePath
		fs.writeFileSync testJsFilePath,templates["qunit"]["js"]
		console.log  " #{testJsFilePath} is generated."	
	if not path.existsSync htmlFilePath
		html=templates["qunit"]["html"].replace("#jsFilePath#",jsFilePath)
						  .replace("#testJsFilePath#",testJsFilePath.replace("/test",""))
						  .replace "#title#",title
		fs.writeFileSync htmlFilePath,html
		console.log  " #{htmlFilePath} is genrated."

exports.getTemplate=getTemplate
exports.generateAll=generateAll
exports.generate=generate
