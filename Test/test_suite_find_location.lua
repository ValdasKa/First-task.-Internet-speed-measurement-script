package.path = package.path .. ";../?.lua"
TestLocation = {}
local MockEasy = {}
local curl = require("cURL")
local lu = require("luaunit")
local speed_test = require("speed_test")

function TestLocation:setUp()
    self.easy = curl.easy
    local easy = curl.easy
    function MockEasy:perform() return nil end
    function MockEasy:getinfo(...) return 0 end
    function MockEasy:close() return easy():close() end
    MockEasy.index = curl.Easy
    curl.easy = function (...) return MockEasy end
end
function TestLocation:TestFindMyLocationErrorPerform()
    function MockEasy:perform() return error("Error with perform ")   end
    lu.assertErrorMsgContains("Error with perform ", speed_test.FindMyLocation)
end
function TestLocation:TestFindMyLocationGetAllInfo()
    curl.easy = self.easy
    lu.assertIsTable(speed_test.FindMyLocation())
end

function TestLocation:TestFindMyLocationGetCountry()
    curl.easy = self.easy
    lu.assertIsString(speed_test.FindMyLocation()["country"])
end

function TestLocation:tearDown()
    curl.easy = self.easy
    MockEasy = {}
end
return TestLocation