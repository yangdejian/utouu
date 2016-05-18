
require 'xxml'
module("xconfig", package.seeall)

configuration={}
configuration.settings={format="/config/item[name=%s]",attr="value"}
configuration.appsetings={format="/configuration/appSettings/add[key=%s]",attr="value"}
configuration.config=configuration.settings

function xconfig:new(p,f)
	assert(p,"请输入配置文件路径")
	local o={}
    setmetatable(o,self)
    self.__index = self
	self.config=xtable.merge(f,xconfig.configuration.config)
	if(string.sub(p,1,1)=="<") then
		self.xml=xxml:load(p)
	else
		self.xml=xxml:loadfile(p)
	end
	return o
end

function xconfig:get(...)
	local arg=_VERSION=="Lua 5.1" and arg or {...}
	return self.xml:get(string.format(self.config.format,unpack(arg)),self.config.attr)
end

function xconfig:find(p,v)
	return self.xml:get(p,v)
end

local c=xconfig:new("c:\\config.xml")



