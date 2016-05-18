--[[
功能:提供http执行存储过程参数列表使用
作者:游书兵
]]

_array={}
function _array:new(oo)
	 local o = oo or {}
	setmetatable(o,self)
	self.__index=self
	return o
end
--[[
功能：构造参数对象
参数:
]]
function array()
	local ret = _array:new()
	return ret
end

--[[
功能：添加元素
参数：
	value-值
]]
function _array:add(value)
	local index=#self+1
	if(value==nil) then
		value = ""
	end
	self[index] = value
end

