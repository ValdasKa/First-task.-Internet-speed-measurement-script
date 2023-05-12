package.path = package.path .. ";../?.lua"
TestUpload = {}
local MockEasy = require("mock_module")
local easy = require("easy_curl_module")
local lu = require("luaunit")
local speed_test = require("speed_test")


function TestUpload:setUp()
    self.easy = easy
end

function TestUpload:TestUploadSpeedTryErrorPerform()
    function MockEasy:perform() return error("Error",0) end
    lu.assertErrorMsgContains("Error [CURL-EASY]", speed_test.TestUploadSpeed, "superbadserver")
end
function TestUpload:TestUploadSpeedTryErrorGetinfo()
    function MockEasy:getinfo(...) return error("Error", 0) end
    lu.assertErrorMsgContains("Error [CURL-EASY]", speed_test.TestUploadSpeed, "superbadserver")
end
function TestUpload:TestUploadSpeedTryErrorBadUrl()
    easy = self.easy
    lu.assertErrorMsgContains("Error [CURL-EASY]" , speed_test.TestUploadSpeed,"super test fail")
end
function TestUpload:TestUploadSpeedTryErrorNoUrl()
    easy = self.easy
    lu.assertErrorMsgContains("attempt to concatenate local 'url' (a nil value)", speed_test.TestUploadSpeed)
end

function TestUpload:TestUploadSpeedFileOpen()
    self.fopen = io.open
    function io.open(...)return false end
    lu.assertErrorMsgContains("Error for /dev/zero open", speed_test.TestUploadSpeed, "speed-kaunas.telia.lt:8080")
    io.open = self.fopen
end

function TestUpload:tearDown()
    easy = self.easy
end
return TestUpload