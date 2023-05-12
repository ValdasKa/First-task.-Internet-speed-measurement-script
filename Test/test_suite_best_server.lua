TestBestServer = {}
package.path = package.path .. ";../?.lua"
local easy = require("easy_curl_module")
local lu = require("luaunit")
local speed_test = require("speed_test")
local curl = require("cURL")

function TestBestServer:setUp()
    self.easy = easy
end

function TestBestServer:TestBestServerReturnErrorNoLocation()
    lu.assertErrorMsgEquals("Error couldnt find best server for this location"
    ,speed_test.FindBestServer,({}))
end

function TestBestServer:TestBestServerErrorNotNil()
    lu.assertNotNil(speed_test.FindBestServer)
end

function TestBestServer:tearDown()
    easy = self.easy
end
return TestBestServer