package.path = package.path .. ";../?.lua"
TestServerPing = {}
local MockEasy = require("mock_module")
local easy = require("easy_curl_module")
local lu = require("luaunit")
require("speed_test")

function TestServerPing:setUp()
    self.easy = easy
end

function TestServerPing:TestServerPingStatusGetErrorPerform()
    function MockEasy:perform() return error("Error ", 0) end
    lu.assertErrorMsgContains("Error[CURL-EASY]", ServerTestPing, "superbadserver")
end
function TestServerPing:TestServerPingGetErrorGetinfo()
    function MockEasy:getinfo(...) return error("Error", 0) end
    lu.assertErrorMsgContains("Error[CURL-EASY]", ServerTestPing, "superbadserver")
end

function TestServerPing:TestServerPingBadUrl()
    easy = self.curl
    lu.assertErrorMsgContains("Error[CURL-EASY]", ServerTestPing, "super test")
end

function TestServerPing:TestServerPingNoUrl()
    easy = self.easy
    lu.assertErrorMsgContains("attempt to concatenate local 'url' (a nil value)", ServerTestPing)
end

function TestServerPing:TestServerPingFileOpen()
    self.fopen = io.open
    function io.open(...) return false end 
    lu.assertErrorMsgContains("Error for /dev/null open", ServerTestPing, "speed-kaunas.telia.lt:8080")
    io.open = self.fopen
end

function TestServerPing:tearDown()
    easy = self.easy
end
return TestServerPing