TestReadList = {}
package.path = package.path .. ";../?.lua"
local lu = require("luaunit")
require("speed_test")


function TestReadList:setUp()
    self.fname = 'speedtest_server_list.json'
    
end
function TestReadList:TestReadServerListFile()
    self.fopen = io.open
    function io.open(...) return false end
    lu.assertErrorMsgEquals("../speed_test.lua:129: Error opening server list file for reading",ReadServerList)
    io.open = self.fopen
    end

function TestReadList.TestReadServerListDecodeData()
    lu.assertEvalToTrue(ReadServerList)
end

   return TestReadList
