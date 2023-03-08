-- LuaTools需要PROJECT和VERSION这两个信息
PROJECT = "thingscloud_example"
VERSION = "1.0"
PRODUCT_KEY = "s1uUnY6KA06ifIjcutm5oNbG3MZf5aUv" --换成自己的

-- sys库是标配
_G.sys = require("sys")
_G.sysplus = require("sysplus")
log.style(1)

require "demo"

sys.run()
