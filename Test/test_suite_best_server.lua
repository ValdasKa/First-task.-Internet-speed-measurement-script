TestBestServer = {}
MockEasy = {}
package.path = package.path .. ";../?.lua"
local lu = require("luaunit")
local speed_test = require("speed_test")
local curl = require("cURL")

function TestBestServer:setUp()
    self.easy = curl.easy
    local easy = curl.easy
    function MockEasy:perform() return nil end
    function MockEasy:getinfo(...) return 0 end
    function MockEasy:close() return easy():close() end
    curl.easy = function (...) return MockEasy end
end

function TestBestServer:TestBestServerReturnErrorNoLocation()
    lu.assertErrorMsgEquals("Error couldnt find best server for this location",speed_test.FindBestServer,({}))
end
-- function TestBestServer:TestBestServerErrorListEmpty()
--     lu.assertIsTrue(speed_test.FindBestServer)
-- end


function TestBestServer:tearDown()
    curl.easy = self.easy
    MockEasy = {}
end
return TestBestServer