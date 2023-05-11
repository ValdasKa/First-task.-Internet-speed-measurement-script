local speed_test = {}
local cjson = require("cjson")
local curl= require("cURL")
local socket = require("socket")

-----------------------download test start -----------------
  --callback function 
  local function DownloadCallback(_, downloadspeednow, _, _)
    local time = socket.gettime() - timedownload
    local downloadspeedcallback = downloadspeednow / time / 1024 / 1024 * 8
    speed = tonumber(string.format("%.2f", downloadspeedcallback))
    if downloadspeedcallback > 0 then
        print(cjson.encode({download_speed_Mbps_currently = speed}))
    end
end
--Function to test download speed
    function speed_test.TestDownloadSpeed(url)
    local outfile = io.open("/dev/null", "r+")
    if not outfile then
        error("Error for /dev/null open", 0)
    end
    easy = curl.easy({
    httpheader = {"User-Agent:curl/7.81.0","Accept:*/*",["Cache-Control"] = "no-cache"},
    url = url .. "/download",
    writefunction = outfile,
    noprogress = false,
    progressfunction = DownloadCallback,
    timeout = 10
    })
    timedownload = socket.gettime()
    status, value = pcall(easy.perform, easy)
    local downloadspeed = easy:getinfo(curl.INFO_SPEED_DOWNLOAD) / 1024 / 1024 * 8
    io.close(outfile)
    easy:close()
    if not status and value ~="[CURL-EASY][OPERATION_TIMEDOUT] Timeout was reached (28)" then
       error("Error " .. value.. " with download host",0)
    end
    
    return string.format("%d", downloadspeed)
end
-----------------------download test finish----------------------

-----------------------upload test start ------------------------

--upload call back
local function UploadCallback(_, _, _,uploadspeednow )
    local time = socket.gettime() - uploadtime
    local uploadspeedcallback = uploadspeednow / time / 1024 / 1024 * 8
    speed = tonumber(string.format("%.2f", uploadspeedcallback))
    
    if uploadspeedcallback > 0 then
        print(cjson.encode({upload_speed_Mbps_currently  = speed}))
    end
end
-- function for upload speed test
    function speed_test.TestUploadSpeed(url)
    local outfile = io.open("/dev/zero", "r+")
    if not outfile then
        error("Error for /dev/zero open",0)
    end
    easy = curl.easy({
        httpheader = {"User-Agent:curl/7.81.0","Accept:*/*",["Cache-Control"] = "no-cache"},
        url = url .. "/upload",
        writefunction = outfile,
        noprogress = false,
        progressfunction = UploadCallback,
        httppost = curl.form({
            file = {file = "/dev/zero"}}),
        timeout = 10
    })
    uploadtime = socket.gettime()
    status, value = pcall(easy.perform, easy)
    
    local uploadspeed = easy:getinfo(curl.INFO_SPEED_UPLOAD) / 1024 / 1024 * 8 
    io.close(outfile)
    easy:close()
    if not status and value ~="[CURL-EASY][OPERATION_TIMEDOUT] Timeout was reached (28)" then
        error("Error " .. value.. " with upload host", 0)
     end
    return string.format("%d", uploadspeed)
end

-------------------------Upload test finish ----------------------

-------------------------Download server list file----------------
--function to download server list file
function DownloadServerFile()
    local outfile = io.open("speedtest_server_list.json", "r")
    if outfile==nil then
        local http = require("socket.http")
        local body, code = http.request("https://raw.githubusercontent.com/ValdasKa/Internet-speed-test-servers-json/main/speedtest_server_list.json")
        -- if not body then pcall(code) end      
        local outfile = assert(io.open('speedtest_server_list.json', 'wb'))
        outfile:write(body)
        outfile:close()
        -- if not body then
        --     error("Error " .. code .. "with file download")
        -- end
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
    easy:close()
    local status, data = pcall(cjson.decode, pingdata)
    if not status then
        error("Error" .. value.. "with ipinfo.io host",0)
     end
    return data
end
-------------------------Find my location finish---------------------- 

-------------------------Best server for my location start----------------------
----------------------ReadServerList from json file
function ReadServerList()
    local serverlist = io.open("speedtest_server_list.json", "r")
    if not serverlist then
        error("Error opening server list file for reading",0)
    end
    local status, data = pcall(serverlist.read, serverlist, "*all")
    io.close(serverlist)
    if data ~= "" then
        local decodedata = cjson.decode(data)
        return decodedata
    end
    if not status then
        error("Error " .. data .. "with read server list",0)
    end
    print(data)
    return false
end

--ping Function to ping servers

 function ServerTestPing(url)
    local outfile = io.open("/dev/null", "r")
    if not outfile then error("Error for /dev/null open",0) end
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
    if not status then
        error("Error" .. value.. "with ping host",0)
     end
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
    if not servlist then
        error("Error server list is empty")
    end
    return servlist
end

--best server finding function
function speed_test.FindBestServer(servers, mycountry)

    local bestping = 10
    local bestserver = ""
    local status, servlist = pcall(GoodServers, servers, mycountry)
    if not status then
        error("Error" .. servlist .. " with best server find",0)
    end
    for _, val in ipairs(servlist) do
        local ping = ServerTestPing(val)
        if ping ~= nil and ping < bestping then
            bestserver = val
            bestping = ping
        end
    end
    if bestping == 10 or bestserver == ""  then
        error("Error couldnt find best server for this location",0)
    end
    return bestserver, bestping
    end
--location = FindMyLocation()
--location['country'] = "Lithuania"
-------------------------Best server for my location finish----------------------

return speed_test
