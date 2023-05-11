package.path = package.path .. ";../?.lua"
TestServerPing = {}
local MockEasy = {}
local curl = require("cURL")
local lu = require("luaunit")
require("speed_test")

function TestServerPing:setUp()
    self.easy = curl.easy
    local easy = curl.easy
    function MockEasy:perform() return nil end
    function MockEasy:getinfo(...) return 0 end
    function MockEasy:close() return easy():close() end
    curl.easy = function (...) return MockEasy end
end

function TestServerPing:TestServerPingStatusGetErrorPerform()
    function MockEasy:perform() return error("Error with perform", 0) end
    lu.assertErrorMsgContains("Error with perform", ServerTestPing, "speed-kaunas.telia.lt:8080")
end
function TestServerPing:TestServerPingGetErrorGetinfo()
    function MockEasy:getinfo(...) return error("Error ping Getinfo", 0) end
    lu.assertErrorMsgEquals("Error ping Getinfo", ServerTestPing, "speed-kaunas.telia.lt:8080")
end

function TestServerPing:TestServerPingBadUrl()
    curl.easy = self.curl
    lu.assertErrorMsgContains("Error[CURL-EASY]", ServerTestPing, "super test")
end

function TestServerPing:TestServerPingNoUrl()
    curl.easy = self.easy
    lu.assertErrorMsgContains("attempt to concatenate local 'url' (a nil value)", ServerTestPing)
end

function TestServerPing:TestServerPingFileOpen()
    self.fopen = io.open
    function io.open(...) return false end 
    lu.assertErrorMsgContains("Error for /dev/null open", ServerTestPing, "speed-kaunas.telia.lt:8080")
    io.open = self.fopen
end

function TestServerPing:tearDown()
    curl.easy = self.easy
    MockEasy = {}
end
return TestServerPing