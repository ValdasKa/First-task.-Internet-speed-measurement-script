package.path = package.path .. ";../?.lua"
TestUpload = {}
local MockEasy = {}
local curl = require("cURL")
local lu = require("luaunit")
local speed_test = require("speed_test")


function TestUpload:setUp()
    self.easy = curl.easy
    local easy = curl.easy
    function MockEasy:perform() return nil end
    function MockEasy:getinfo(...) return 0 end
    function MockEasy:close() return easy():close() end
    MockEasy.index = curl.Easy
    curl.easy = function (...) return MockEasy end
end

function TestUpload:TestUploadSpeedTryErrorPerform()
    function MockEasy:perform() return error("Error with perform",0) end
    lu.assertErrorMsgContains("Error with perform", speed_test.TestUploadSpeed, "speed-kaunas.telia.lt:8080")
end
function TestUpload:TestUploadSpeedTryErrorGetinfo()
    function MockEasy:getinfo(...) return error("Error with getinfo", 0) end
    lu.assertErrorMsgContains("Error with getinfo", speed_test.TestUploadSpeed, "speed-kaunas.telia.lt:8080")
end
function TestUpload:TestUploadSpeedTryErrorBadUrl()
    curl.easy = self.easy
    lu.assertErrorMsgContains("Error [CURL-EASY]" , speed_test.TestUploadSpeed,"super test fail")
end
function TestUpload:TestUploadSpeedTryErrorNoUrl()
    curl.easy = self.easy
    lu.assertErrorMsgContains("attempt to concatenate local 'url' (a nil value)", speed_test.TestUploadSpeed)
end

function TestUpload:TestUploadSpeedFileOpen()
    self.fopen = io.open
    function io.open(...)return false end
    lu.assertErrorMsgContains("Error for /dev/zero open", speed_test.TestUploadSpeed, "speed-kaunas.telia.lt:8080")
    io.open = self.fopen
end

function TestUpload:tearDown()
    curl.easy = self.easy
    MockEasy = {}
end
return TestUpload