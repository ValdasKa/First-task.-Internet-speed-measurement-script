local speed_test = {}
local cjson = require("cjson")
curl= require("cURL")
local argparse = require("argparse")
local socket = require("socket")
easy = curl.easy()
local value, status = "", true
local timedl = 0


-----------------------download test start -----------------
  --callback function 
  local function DownloadCallback(_, downloadspeednow, _, _)
    local time = socket.gettime()
    local downloadspeedcallback = downloadspeednow / time / 1024 / 1024 * 8
    if downloadspeedcallback > 0 then
        print(cjson.encode({download_speed_Mbps_currently = downloadspeedcallback}))
    end
end
--Function to test download speed
    function speed_test.TestDownloadSpeed(url)
    local outfile = io.open("/dev/null", "r+")
    if not outfile then
        print("Error for /dev/null open")
    end
    easy = curl.easy({
    httpheader = {"User-Agent:curl/7.81.0","Accept:*/*",["Cache-Control"] = "no-cache"},
    url = url .. "/download",
    writefunction = outfile,
    noprogress = false,
    progressfunction = DownloadCallback, --galima naudoti pamatyti parsiuntimo greiti
    timeout = 10
    })
    status, value = pcall(easy.perform, easy)
    if not status and value ~="[CURL-EASY][OPERATION_TIMEDOUT] Timeout was reached (28)" then
       print("Error " .. value.. " with download host")
    end
    local downloadspeed = easy:getinfo(curl.INFO_SPEED_DOWNLOAD) / 1024 / 1024 * 8
    io.close(outfile)
    easy:close()
    return string.format("%d", downloadspeed)
end
-----------------------download test finish----------------------

-----------------------upload test start ------------------------

--upload call back
local function UploadCallback(_, _, _,uploadspeednow )
    local time = socket.gettime()
    local uploadspeedcallback = uploadspeednow / time / 1024 / 1024 * 8
    if uploadspeedcallback > 0 then
        print(cjson.encode({upload_speed_Mbps_currently  = uploadspeedcallback}))
    end
end
-- function for upload speed test
    function speed_test.TestUploadSpeed(url)
    local outfile = io.open("/dev/zero", "r+")
    if outfile ==nil then
        print("Error for /dev/zero open")
    end
    easy = curl.easy({
        httpheader = {"User-Agent:curl/7.81.0","Accept:*/*",["Cache-Control"] = "no-cache"},
        url = url .. "/upload",
        writefunction = outfile,
        noprogress = false,
        progressfunction = UploadCallback, --galima naudoti pamatyti issiuntimo greiti
        httppost = curl.form({
            file = {file = "/dev/zero"}}),
        timeout = 10
    })
    status, value = pcall(easy.perform, easy)
    if not status and value ~="[CURL-EASY][OPERATION_TIMEDOUT] Timeout was reached (28)" then
        print("Error " .. value.. " with upload host")
     end
    local uploadspeed = easy:getinfo(curl.INFO_SPEED_UPLOAD) / 1024 / 1024 * 8 
    io.close(outfile)
    easy:close()
    return string.format("%d", uploadspeed)
end

-------------------------Upload test finish ----------------------

-------------------------Download server list file----------------
--functio to check if File exist
 function speed_test.FileExist()
    local outfile = io.open("speedtest_server_list.json", "r")
    if outfile~= nil then io.close(outfile)
        return true
    end
end
--function to download server list file
function DownloadServerFile()
    local outfile = io.open("speedtest_server_list.json", "r")
    if outfile==nil then
        local http = require("socket.http")
        local body, code = http.request("https://raw.githubusercontent.com/ValdasKa/Internet-speed-test-servers-json/main/speedtest_server_list.json")
        if not body then pcall(code) end
        if not body then
            print("Error " .. code .. "with file download")
        end
        local outfile = assert(io.open('speedtest_server_list.json', 'wb'))
        outfile:write(body)
        outfile:close()
    end
end
DownloadServerFile()

-------------------------Download finish server list file----------------

-------------------------Find my location start----------------------
--find my location
 function speed_test.FindMyLocation()
    local pingdata = ""
    easy = curl.easy({
    httpheader =  {["Cache-Control"] = "no-cache"},
    url = "https://ipinfo.io/",
    writefunction = function (response) pingdata = pingdata .. response end
    })
    status, value = pcall(easy.perform, easy)
    if not status then
        print("Error" .. value.. "with ipinfo.io host")
     end
    easy:close()
    local status, data = pcall(cjson.decode, pingdata)
    return data
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
    if not status then
        print("Error" .. value.. "with ping host")
     end
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
function speed_test.FindBestServer(servers, mycountry)

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
--location = FindMyLocation()
--location['country'] = "Lithuania"
-------------------------Best server for my location finish----------------------

return speed_test