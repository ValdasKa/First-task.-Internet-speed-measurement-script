local speedtest = require("speed_test")
local cjson = require("cjson")
curl= require("cURL")
easy = curl.easy()
local argparse = require("argparse")
local socket = require("socket")
local value, status = "", true
local timedl = 0



--------------------------args start for runing fuctions---------------
local parser = argparse("test.lua", "Internet speed measurement")
parser:option("-l --location", "Get my current locations using ipinfo.io"):args(0)
parser:option("-b --bestserver", "Get best server for my input location"):args(1)
parser:option("-d --download", "Get download speed from server you input"):args(1)
parser:option("-u --upload", "Get upload speed from server you input"):args(1)
parser:option("-f --filecheck", "Check if server list file exist"):args(0)
parser:option("-a --auto", "Make all tests auto"):args(0)
local args = parser:parse()
-------------------------args end for runing functions-----------------

-- args download speed test 
if (args.download) then dl = TestDownloadSpeed(args.download)
    if dl then print(cjson.encode({dl = dl}))end
    end
--args upload speed test 
if args.upload then up = TestUploadSpeed(args.upload)
    if up then print(cjson.encode({up = up}))end
    end
--args to check if file exist
if args.filecheck then filexist = FileExist() if filexist then
    print(cjson.encode({filexist = filexist})) end
end
-- find location args command
if args.location then loc = speedtest.FindMyLocation() if loc then
    print(cjson.encode({loc = loc["loc"]}))end
    end
--Bestserver args start
if args.bestserver then
    bestserver, ping = FindBestServer(ReadServerList(), args.bestserver)
    if bestserver then print(cjson.encode({bestserver = bestserver, ping = ping}))end
end

-------------------------Auto run everything start--------------------------
if args.auto then
    dl= TestDownloadSpeed('speedtest.litnet.lt:8080')
    up = TestUploadSpeed('speedtest.litnet.lt:8080')
    filexist = FileExist()
    bestserver, ping =FindBestServer(ReadServerList(), location['country'])
    loc = FindMyLocation()
    print(cjson.encode({filexist = filexist}))
    print(cjson.encode({up = up}))
    print(cjson.encode({dl = dl}))
    print(cjson.encode({bestserver = bestserver, ping = ping}))
    print(cjson.encode({loc = loc["loc"]}))
    end
    
    
    -------------------------Auto run everything finish--------------------------
    
