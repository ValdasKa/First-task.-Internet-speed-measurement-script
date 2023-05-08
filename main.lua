local speedtest = require("speed_test")
local cjson = require("cjson")
local argparse = require("argparse")

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
if (args.download) then download_speed_Mbps = speedtest.TestDownloadSpeed(args.download)
    if download_speed_Mbps then print(cjson.encode({download_speed_Mbps = download_speed_Mbps}))end
--args upload speed test 
else if args.upload then upload_speed_Mbps = speedtest.TestUploadSpeed(args.upload)
    if upload_speed_Mbps then print(cjson.encode({upload_speed_Mbps = upload_speed_Mbps}))end
--args to check if file exist
elseif args.filecheck then file_exist = speedtest.FileExist() if file_exist then
    print(cjson.encode({file_exist = file_exist})) end
-- find location args command
elseif args.location then location = speedtest.FindMyLocation() if location then
    print(cjson.encode({location = location}))end
--Bestserver args start
elseif args.bestserver then
    best_server, latency_sec = speedtest.FindBestServer(ReadServerList(), args.bestserver)
    if best_server then print(cjson.encode({best_server = best_server, latency_sec = latency_sec}))end
-------------------------Auto run everything start--------------------------
elseif args.auto then
    download_speed_Mbps= speedtest.TestDownloadSpeed('speedtest.litnet.lt:8080')
    upload_speed_Mbps = speedtest.TestUploadSpeed('speedtest.litnet.lt:8080')
    file_exist = speedtest.FileExist()
    location = speedtest.FindMyLocation()
    location['country'] = "Lithuania"
    best_server, latency_sec =speedtest.FindBestServer(ReadServerList(), location['country'])
    location = speedtest.FindMyLocation()
    print(cjson.encode({file_exist = file_exist}))
    print(cjson.encode({upload_speed_Mbps = upload_speed_Mbps}))
    print(cjson.encode({download_speed_Mbps = download_speed_Mbps}))
    print(cjson.encode({best_server = best_server, latency_sec = latency_sec}))
    print()
    print(cjson.encode({location = location}))
----------------------------------Print help if none args used-------------------
else
    print("main.lua: try use ' lua main.lua -h, --help ' for help") 
end
end
-------------------------Auto run everything finish--------------------------