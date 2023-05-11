package.path = package.path .. ";../?.lua"
local lu = require("luaunit")

TestReadList = require("test_suite_read_list")
TestDownloadList = require("test_suite_download_list")
TestLocation = require("test_suite_find_location")
TestDownload = require("test_suite_download_speed")
TestUpload = require("test_suite_upload_speed")
TestServerPing = require("test_suite_ping_server")
TestBestServer = require("test_suite_best_server")

os.exit(lu.LuaUnit.run())