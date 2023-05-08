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

-----------------------download test start -----------------
  --callback function 
  local function DownloadCallback(_, downloadspeednow, _, _)
    local time = socket.gettime()
    local downloadspeedcallback = downloadspeednow / time / 1024 / 1024 * 8
    if downloadspeedcallback > 0 then
        print(cjson.encode({dlspeed = downloadspeedcallback}))
    end
end
--Function to test download speed
    function TestDownloadSpeed(url)
    local outfile = io.open("/dev/null", "r+")
    if outfile == nil then
        print("Error for /dev/null open")
    end
    easy = curl.easy({
    httpheader = {"User-Agent:curl/7.81.0","Accept:*/*",["Cache-Control"] = "no-cache"},
    url = url .. "/download",
    writefunction = outfile,
    noprogress = false,
    --progressfunction = DownloadCallback, --galima naudoti pamatyti parsiuntimo greiti
    timeout = 1
    })
    status, value = pcall(easy.perform, easy)
    local downloadspeed = easy:getinfo(curl.INFO_SPEED_DOWNLOAD) / 1024 / 1024 * 8
    io.close(outfile)
    easy:close()
    return downloadspeed
end
-- args download speed test 
if (args.download) then dl = TestDownloadSpeed(args.download)
    if dl then print(cjson.encode({dl = dl}))end
    end
-----------------------download test finish----------------------

-----------------------upload test start ------------------------

--upload call back
local function UploadCallback(_, _, _,uploadspeednow )
    local time = socket.gettime()
    local uploadspeedcallback = uploadspeednow / time / 1024 / 1024 * 8
    if uploadspeedcallback > 0 then
        print(cjson.encode({upspeed = uploadspeedcallback}))
    end
end
-- function for upload speed test
local function TestUploadSpeed(url)
    local outfile = io.open("/dev/zero", "r+")
    if outfile ==nil then
        print("Error for /dev/zero open")
    end
    easy = curl.easy({
        httpheader = {"User-Agent:curl/7.81.0","Accept:*/*",["Cache-Control"] = "no-cache"},
        url = url .. "/upload",
        writefunction = outfile,
        noprogress = false,
        --progressfunction = UploadCallback, --galima naudoti pamatyti issiuntimo greiti
        httppost = curl.form({
            file = {file = "/dev/zero"}}),
        timeout = 1
    })
    status, value = pcall(easy.perform, easy)
    local uploadspeed = easy:getinfo(curl.INFO_SPEED_UPLOAD) / 1024 / 1024 * 8 
    io.close(outfile)
    easy:close()
    return uploadspeed
end
--args upload speed test 
if args.upload then up = TestUploadSpeed(args.upload)
    if up then print(cjson.encode({up = up}))end
    end

-------------------------upload test finish ----------------------

-------------------------Download server list file----------------
--function to check if server list file exist
local function FileExist()
    local outfile = io.open("speedtest_server_list.json", "r")
    if outfile~= nil then io.close(outfile) 
        return print(true, "file already exist")
    else
        print(false, "I need to download file")
        local http = require("socket.http")
        local body, code = http.request("https://raw.githubusercontent.com/ValdasKa/Internet-speed-test-servers-json/main/speedtest_server_list.json")
        if not body then pcall(code) end
        local outfile = assert(io.open('speedtest_server_list.json', 'wb'))
        outfile:write(body)
        outfile:close()
        return print("I am done downloading it now")
    end
end
--args to check if file exist
if args.filecheck then filexist = FileExist() if filexist then
    print(cjson.encode({filexist = filexist})) end
end
-------------------------Download finish server list file----------------

-------------------------Find my location start----------------------
--find my location
local function FindMyLocation()
    local pingdata = ""
    easy = curl.easy({
    httpheader =  {["Cache-Control"] = "no-cache"},
    url = "https://ipinfo.io/",
    writefunction = function (response) pingdata = pingdata .. response end
    })
    status, value = pcall(easy.perform, easy)
    easy:close()
    local status, data = pcall(cjson.decode, pingdata)
    return data
end
-- find location args command
if args.location then loc = FindMyLocation() if loc then
    print(cjson.encode({loc = loc["loc"]}))end
    end
-------------------------Find my location finish---------------------- 

-------------------------Best server for my location start----------------------
----------------------ReadServerList from json file
function ReadServerList()
    local serverlist = io.open("speedtest_server_list.json", "r")
    local status, data = pcall(serverlist.read, serverlist, "*all")
    io.close(serverlist)
    if data ~= "" then
        local decodedata = cjson.decode(data)
        return decodedata
    end
    return false
end

--ping Function to ping servers
 function TestPing(url)
    local outfile = io.open("/dev/null", "r")
    easy = curl.easy({
    httpheader = {"User-Agent:curl/7.81.0","Accept:*/*",["Cache-Control"] = "no-cache"},
    [curl.OPT_CONNECTTIMEOUT] = 1,
    url = url .. "/hello",
    writefunction = outfile
    })
    status, value = pcall(easy.perform, easy)
    local ping = easy:getinfo(curl.INFO_TOTAL_TIME)
    easy:close()
    io.close(outfile)
    return ping
end
--Find good server and add then to list
local function GoodServers(servers, mycountry)
    local servlist = {}
    for _, val in ipairs(servers) do
        if val["country"] == mycountry
        then
            table.insert(servlist, val["host"])
        end
    end
    if servlist == nil then
        print("Error server list is empty")
    end
    return servlist
end

--best server finding function
function FindBestServer(servers, mycountry)

    local bestping = 10
    local bestserver = ""
    local status, servlist = pcall(GoodServers, servers, mycountry)
    if status == nil then
        print("error")
    end
    for _, val in ipairs(servlist) do
        local ping = TestPing(val)
        if ping ~= nil and ping < bestping then
            bestserver = val
            bestping = ping
        end
    end
    return bestserver, bestping
    end
location = FindMyLocation()
location['country'] = "Lithuania"
--Bestserver args start
if args.bestserver then
    bestserver, ping = FindBestServer(ReadServerList(), args.bestserver)
    if bestserver then print(cjson.encode({bestserver = bestserver, ping = ping}))end
end
-------------------------Best server for my location finish----------------------


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
