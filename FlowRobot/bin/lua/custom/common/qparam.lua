--[[
功能:提供http请求query参数的封装
作者:康勇
]]

_qparam={}
function _qparam:new(oo)
	 local o = oo or {}
	setmetatable(o,self)
	self.__index=self
	return o
end
--[[
功能：构造参数对象
参数:
	needSort-是否需要排序(目前仅支持从小到大的顺序排序)
]]
function qparam(needSort)
	local ret = _qparam:new()
	if(needSort == nil) then
		ret.needSort = false
	else
		ret.needSort = needSort
	end
	ret.names={}
	ret.values={}

	return ret
end

--[[
功能：添加元素
参数：
	name-参数名
	value-值
	isMust-是否必须参数
]]
function _qparam:append(name,value,isMust)
	--处理能数为nil的情况
	if(name == nil or string.len(name) <= 0) then
		error("error:no name")
	end
	local v = ""
	if(v ~= nil) then
		v = tostring(value)
	end
	local m = false
	if(isMust ~= nil) then
		m = isMust
	end
	--生成数据
	local item = {value=v,isMust = m}
	self.values[name] = item
	--添加到名字集合中
	if(not self.needSort) then
		self.names[#self.names + 1] = name
	else
	    local pos = 1
		for i=#self.names,1,-1 do
			if(self.names[i] > name) then
				self.names[i+1] = self.names[i]
			elseif(self.names[i] < name) then
				pos = i+1
				break
			else
				pos = i
				break
			end
		end
		self.names[pos] = name
	end
end
--[[
功能：生成请求字符串
参数:
	nvsep-名字与值之间的连接符
	sep  -单项之间的连接符
	canIncludeName - 是否需要包含名
	onlyIncludeMust-是否仅包括必须项
	needEncoding -是否需要url编码
	encoding - 编码名称
]]
function _qparam:make(nvsep,sep,onlyIncludeMust,canIncludeName,needEncoding,encoding)
	local str = nil
	if(onlyIncludeMust) then
		for i=1,#self.names do
			local name = self.names[i]
			local val  = self.values[name]
			if(val.isMust) then
				if(str == nil) then
					str = self:makeOne(name,val.value,nvsep,canIncludeName,needEncoding,encoding)
				else
					str = str ..sep .. self:makeOne(name,val.value,nvsep,canIncludeName,needEncoding,encoding)
				end
			end
		end
	else
		for i=1,#self.names do
			local name = self.names[i]
			local val  = self.values[name]
			if(str == nil) then
				str = self:makeOne(name,val.value,nvsep,canIncludeName,needEncoding,encoding)
			else
				str = str .. sep .. self:makeOne(name,val.value,nvsep,canIncludeName,needEncoding,encoding)
			end
		end
	end
	return str
end

--[[
功能：生成单条数据的请求字符串(仅限于内部使用)
]]
function _qparam:makeOne(name,value,nvsep,canIncludeName,needEncoding,encoding)
	local str = ""
	if(not needEncoding) then
		if(canIncludeName) then
			str = name .. nvsep
		end
		str = str .. value
	else
		if(canIncludeName) then
			str = base.UrlEncode(name,encoding,"all") .. nvsep
		end
		str = str .. base.UrlEncode(value,encoding,"all")
	end
	return str
end

--打印名字集合
function _qparam:printNames()
	for i=1,#self.names do
		print(self.names[i])
	end
end

--打印值集合
function _qparam:printValues()
	for k,v in pairs(self.values) do
		print(v.value)
	end
end
