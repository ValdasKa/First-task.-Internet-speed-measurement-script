package.path = package.path .. ";../?.lua"
TestDownload = {}
local MockEasy = {}
local curl = require("cURL")
local lu = require("luaunit")
local speed_test = require("speed_test")

function TestDownload:setUp()
    self.easy = curl.easy
    local easy = curl.easy
    function MockEasy:perform() return nil end
    function MockEasy:getinfo(...) return 0 end
    function MockEasy:close() return easy():close() end
    MockEasy.index = curl.Easy
    curl.easy = function (...) return MockEasy end
end

function TestDownload:TestDownloadSpeedTryErrorPerform()
    function MockEasy:perform() return error("Error with perform", 0)  end
    lu.assertErrorMsgContains("Error with perform", speed_test.TestDownloadSpeed, "randomserver") --"speed-kaunas.telia.lt:8080"
end
function TestDownload:TestDownloadSpeedTryErrorGetinfo()
    function MockEasy:getinfo(...) return error("Error with getinfo")    end
    lu.assertErrorMsgContains("Error with getinfo", speed_test.TestDownloadSpeed, "speed-kaunas.telia.lt:8080")
end
function TestDownload:TestDownloadSpeedTryErrorBadUrl()
    curl.easy = self.easy
    lu.assertErrorMsgContains("Error [CURL-EASY]" , speed_test.TestDownloadSpeed,"super test fail")
end
function TestDownload:TestDownloadSpeedTryErrorNoUrl()
    curl.easy = self.easy
    lu.assertErrorMsgContains("attempt to concatenate local 'url' (a nil value)", speed_test.TestDownloadSpeed)
end

function TestDownload:TestDownloadSpeedFileOpen()
    self.fopen = io.open
    function io.open(...)return false end
    lu.assertErrorMsgContains("Error for /dev/null open", speed_test.TestDownloadSpeed, "speed-kaunas.telia.lt:8080")
    io.open = self.fopen
end

function TestDownload:tearDown()
    curl.easy = self.easy
    MockEasy = {}
end
return TestDownload