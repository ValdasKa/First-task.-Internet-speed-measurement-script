package.path = package.path .. ";../?.lua"
TestDownload = {}
local MockEasy = require("mock_module")
local easy = require("easy_curl_module")
local lu = require("luaunit")
local speed_test = require("speed_test")

function TestDownload:setUp()
    self.easy = easy
 end
function TestDownload:TestDownloadSpeedTryErrorPerform()
    function MockEasy:perform() return error("Error", 0)  end
    lu.assertErrorMsgContains("Error [CURL-EASY]", speed_test.TestDownloadSpeed, "randomserver") --"speed-kaunas.telia.lt:8080"
end
function TestDownload:TestDownloadSpeedTryErrorBadUrl()
    easy = self.easy
    lu.assertErrorMsgContains("Error [CURL-EASY]" , speed_test.TestDownloadSpeed,"super test fail")
end
function TestDownload:TestDownloadSpeedTryErrorNoUrl()
    easy = self.easy
    lu.assertErrorMsgContains("attempt to concatenate local 'url' (a nil value)", speed_test.TestDownloadSpeed)
end

function TestDownload:TestDownloadSpeedFileOpen()
    self.fopen = io.open
    function io.open(...)return false end
    lu.assertErrorMsgContains("Error for /dev/null open", speed_test.TestDownloadSpeed, "speed-kaunas.telia.lt:8080")
    io.open = self.fopen
end

function TestDownload:tearDown()
    easy = self.easy
end
return TestDownload