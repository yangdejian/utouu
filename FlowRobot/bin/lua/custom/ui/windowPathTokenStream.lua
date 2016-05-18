_windowPathTokenStream={_path="",_pos=1}
function _windowPathTokenStream:new(oo)
	 local o = oo or {}
	setmetatable(o,self)
	self.__index=self
	return o
end


function windowPathTokenStream(path)
	local obj = _windowPathTokenStream:new()
	obj._path = path
	return obj
end

--�����հ�
function _windowPathTokenStream:empty()
	local len = string.len(self._path)
	return self._pos > len
end

--�����հ�
function _windowPathTokenStream:skipBlank()
	local len = string.len(self._path)
	for i = self._pos,len do
		if(not self.isBlank(self._path:sub(i,i))) then
			break
		end
		self._pos = self._pos + 1
	end
end

--ȡ��ʶ��
function _windowPathTokenStream:getIdentifer()
	local len = string.len(self._path)
	self:skipBlank()
	if(self._pos > len) then
		return ""
	end
	local token = ""
	local ch
	while(self._pos <= len) do
		ch = self._path:sub(self._pos,self._pos)
		if(self.isSeparate(ch)) then
			break
		end
		token = token..ch
		self._pos = self._pos + 1
	end

	return token
end

--ȡ������
function _windowPathTokenStream:getOperator()
	local len = string.len(self._path)
	self:skipBlank()
	if(self._pos > len) then
		return ""
	end
	local ch = self._path:sub(self._pos,self._pos)
	if(ch == "=") then
		self._pos = self._pos + 1
		return ch
	elseif(ch == "!") then
		if(self._path:sub(self._pos+1,self._pos+1) == "=") then
			self._pos = self._pos+2
			return "!="
		else
			error("syntax error:error operator")
		end
	elseif(ch == ">") then
		if(self._path:sub(self._pos+1,self._pos+1) == "=") then
			self._pos = self._pos+2
			return ">="
		else
			self._pos = self._pos+1
			return ">"
		end
	elseif(ch == "<") then
		if(self._path:sub(self._pos+1,self._pos+1) == "=") then
			self._pos = self._pos+2
			return "<="
		else
			self._pos = self._pos+1
			return "<"
		end
	end

	return self:getIdentifer()
end

--ȡ�߽��
function _windowPathTokenStream:getBoundary()
	local len = string.len(self._path)
	self:skipBlank()
	if(self._pos > len) then
		return ""
	end
	local ch = self._path:sub(self._pos,self._pos)
	if(self.isBoudary(ch)) then
		self._pos = self._pos + 1
		return ch
	end
	return ""
end

--Ԥȡ�߽��
function _windowPathTokenStream:pregetBoundary()
	local len = string.len(self._path)
	self:skipBlank()
	if(self._pos > len) then
		return ""
	end
	local ch = self._path:sub(self._pos,self._pos)
	if(self.isBoudary(ch)) then
		return ch
	end
	return ""
end

--��ȡ�ı�
function _windowPathTokenStream:getText()
	local len = string.len(self._path)
	self:skipBlank()
	if(self._pos > len) then
		return ""
	end
	local quoted = false

	if(self._path:sub(self._pos,self._pos) == "\"") then
		quoted = true
		self._pos =self._pos + 1
	end

	local token = ""
	local ch
	if(quoted) then
		while(self._pos <= len) do
			ch = self._path:sub(self._pos,self._pos)
			if(ch == "\"") then
				self._pos = self._pos + 1
				quoted = false
				break
			elseif(ch ~= "\\") then--����ת���
				token = token .. ch
			else
				if(self._pos + 1 > len) then
					error("syntax error,escape char")
				end
				self._pos = self._pos + 1
				token = token .. self._path:sub(self._pos,self._pos)
			end

			self._pos = self._pos + 1
		end
	else
		while(self._pos <= len) do
			ch = self._path:sub(self._pos,self._pos)
			if(self.isSeparate(ch)) then
				break
			elseif(ch ~= "\\") then--����ת���
				token = token .. ch
			else
				if(self._pos + 1 > len) then
					error("syntax error,escape char")
				end
				self._pos = self._pos + 1
				token = token .. self._path:sub(self._pos,self._pos)
			end

			self._pos = self._pos + 1
		end
	end
	if(quoted) then
		error("syntax error")
	end
	return token
end

--�ж��Ƿ��������ַ���
_windowPathTokenStream.isDigital = function(str)
	if(str:find("^[0-9]+$") ~= nil) then
		return true
	else
		return false
	end
end

--�ж��Ƿ��Ǳ�ʶ��
_windowPathTokenStream.isIdentifier = function(str)
	if(str:find("^[_%a][_%w]*$") ~= nil) then
		return true
	else
		return false
	end
end

--�ж��Ƿ��ǿհ׷�
_windowPathTokenStream.isBlank = function(ch)
	if(ch == " " or ch == "\r" or ch == "\n" or ch == "\t") then
		return true
	else
		return false
	end
end

--�ж��Ƿ�ָ��
_windowPathTokenStream.isSeparate = function(ch)
	local seps = {"[","]","/",",","\\","\"","=",">","<","!",' ','\r','\n','\t'}
	for i = 1,#seps do
		if(ch == seps[i]) then
			return true
		end
	end
	return false
end

--�Ƿ��Ǳ߽��
_windowPathTokenStream.isBoudary = function(ch)
	local seps = {"[","]","/",","}
	for i = 1,#seps do
		if(ch == seps[i]) then
			return true
		end
	end
	return false
end
