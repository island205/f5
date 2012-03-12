unittest=require "../lib/unittest"

exports["unittest"]=(test)->
	unittest.generate "boo"
	test.done()
