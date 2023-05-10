TestDownloadList = {}
package.path = package.path .. ";../?.lua"
local lu = require("luaunit")
require("speed_test")

function TestDownloadList:setUp()
    self.fname = 'speedtest_server_list.json'
    os.remove(self.fname)
end
function TestDownloadList:TestDownloadFileReturnNil()
    lu.assertNil(DownloadServerFile())
end
function TestDownloadList:TestDownloadFile()
    DownloadServerFile()
    f = io.open(self.fname, "wb")
    lu.assertNotNil(f)
    f:close()
end
function TestDownloadList:TestDownloadFileError()
    self.fwrite = io.write
    function io.write(...) return false end
    lu.assertNotNil(DownloadServerFile)
    io.write = self.fwrite
end

return TestDownloadList