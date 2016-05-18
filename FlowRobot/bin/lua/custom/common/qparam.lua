--[[
����:�ṩhttp����query�����ķ�װ
����:����
]]

_qparam={}
function _qparam:new(oo)
	 local o = oo or {}
	setmetatable(o,self)
	self.__index=self
	return o
end
--[[
���ܣ������������
����:
	needSort-�Ƿ���Ҫ����(Ŀǰ��֧�ִ�С�����˳������)
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
���ܣ����Ԫ��
������
	name-������
	value-ֵ
	isMust-�Ƿ�������
]]
function _qparam:append(name,value,isMust)
	--��������Ϊnil�����
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
	--��������
	local item = {value=v,isMust = m}
	self.values[name] = item
	--��ӵ����ּ�����
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
���ܣ����������ַ���
����:
	nvsep-������ֵ֮������ӷ�
	sep  -����֮������ӷ�
	canIncludeName - �Ƿ���Ҫ������
	onlyIncludeMust-�Ƿ������������
	needEncoding -�Ƿ���Ҫurl����
	encoding - ��������
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
���ܣ����ɵ������ݵ������ַ���(�������ڲ�ʹ��)
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

--��ӡ���ּ���
function _qparam:printNames()
	for i=1,#self.names do
		print(self.names[i])
	end
end

--��ӡֵ����
function _qparam:printValues()
	for k,v in pairs(self.values) do
		print(v.value)
	end
end
