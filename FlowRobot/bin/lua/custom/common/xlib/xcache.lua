
require('memcached')
require('xtable')
require 'xxml'
require 'xconfig'
module ("xcache", package.seeall)

function xcache:new(p)
	assert(p,"�����������ļ�·��")
	local o={}
    setmetatable(o,self)
    self.__index = self
	o.config=xconfig:new(p,{format="/caches/cache[name=%s]/item[name=%s]",attr="key"})
	o.basepath=string.format("%s",o.config:find("caches","name"))
	return o
end

function xcache:get_path(p)
	local sp=xstring.split(p,"/")
	assert(#sp>=2,"����·�����Ϸ�")
	local f=sp[1]
	local s=xtable.concat(sp,2,"_")
	local key=self.config:get(f,s)
	return string.format("%s_%s_%s",self.basepath,f,s,key)
end



print(xcache:new("c:\\Cache.Config"):get_path("/comm/company/one"))



