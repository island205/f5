unittest=require "../lib/unittest"

exports["getTemplate"]=(test)->
	console.log unittest.getTemplate "qunit","js"
	console.log unittest.getTemplate "qunit","html"
	console.log unittest.getTemplate "qunit","html",{
		"title":"foo",
		"jsFilePath":"foo.js",
		"testJsFilePath":"test/foo-test.js"
	}
	
	console.log unittest.getTemplate "jasmine","js"
	console.log unittest.getTemplate "jasmine","html"
	console.log unittest.getTemplate "jasmine","html",{
		"title":"foo",
		"jsFilePath":"foo.js",
		"testJsFilePath":"test/foo-test.js"
	}
	
	test.done()

exports["unittest"]=(test)->
	unittest.generate "boo"
	test.done()
