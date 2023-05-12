Mock = {}
local easy = require("easy_curl_module")
function Mock:perform() return nil end
function Mock:getinfo(...) return 0 end
function Mock:close() easy():close() end
Mock.index = Easy
easy = function(...) return Mock end
return Mock