package.path = package.path .. ";../?.lua"
TestLocation = {}
local easy = require("easy_curl_module")
local lu = require("luaunit")
local speed_test = require("speed_test")

function TestLocation:setUp()
    self.easy = easy
end
function TestLocation:TestFindMyLocationGetAllInfo()
    easy = self.easy
    lu.assertIsTable(speed_test.FindMyLocation())
end

function TestLocation:TestFindMyLocationGetCountry()
    easy = self.easy
    lu.assertIsString(speed_test.FindMyLocation()["country"])
end

function TestLocation:tearDown()
    easy = self.easy
end
return TestLocation