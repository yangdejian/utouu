--[[
	使用了C++机器人中的函数
]]
xutility={}
xutility.decode=function(s)
	return string.gsub(s, '%%(%x%x)', function(h) return string.char(tonumber(h, 16)) end)
end
xutility.encode=function(s)
	local  v= string.gsub(s, "([^%w%.%- ])", function(c) return string.format("%%%02X", string.byte(c)) end)
    return string.gsub(v, " ", "+")
end

-----md5聽 鍔犲瘑
xutility.md5={}
xutility.md5.encrypt=function(s, encoding)
	return base.Sign(s, string.format("%s/md5/hex", encoding or "gbk"))
	--[[local core = require "md5"
	 k = core.sum(s)
	  return (string.gsub(k, ".", function (c)
	           return string.format("%02x", string.byte(c))
	         end))]]
end

-----base64聽 鍔犺В瀵?
xutility.b64={}
xutility.b64.encrypt=function(s)
	local mime=require("mime")
	return mime.b64(s)
end
xutility.b64.decrypt=function(s)
	local mime=require("mime")
	return mime.unb64(s)
end






