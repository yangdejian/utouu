--[[
����:�ṩhttpִ�д洢���̲����б�ʹ��
����:�����
]]

_array={}
function _array:new(oo)
	 local o = oo or {}
	setmetatable(o,self)
	self.__index=self
	return o
end
--[[
���ܣ������������
����:
]]
function array()
	local ret = _array:new()
	return ret
end

--[[
���ܣ����Ԫ��
������
	value-ֵ
]]
function _array:add(value)
	local index=#self+1
	if(value==nil) then
		value = ""
	end
	self[index] = value
end

