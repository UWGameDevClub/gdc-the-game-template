class_name ConnectionTest
extends HTTPRequest

var most_recent_result : bool = false

func test_connection()->void:
	var err := request("http://www.msftncsi.com/ncsi.txt")
	await request_completed
	most_recent_result = err == 0
