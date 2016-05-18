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

--跳过空白
function _windowPathTokenStream:empty()
	local len = string.len(self._path)
	return self._pos > len
end

--跳过空白
function _windowPathTokenStream:skipBlank()
	local len = string.len(self._path)
	for i = self._pos,len do
		if(not self.isBlank(self._path:sub(i,i))) then
			break
		end
		self._pos = self._pos + 1
	end
end

--取标识符
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

--取操作符
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

--取边界符
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

--预取边界符
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

--获取文本
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
			elseif(ch ~= "\\") then--不是转义符
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
			elseif(ch ~= "\\") then--不是转义符
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

--判断是否是数字字符串
_windowPathTokenStream.isDigital = function(str)
	if(str:find("^[0-9]+$") ~= nil) then
		return true
	else
		return false
	end
end

--判断是否是标识符
_windowPathTokenStream.isIdentifier = function(str)
	if(str:find("^[_%a][_%w]*$") ~= nil) then
		return true
	else
		return false
	end
end

--判断是否是空白符
_windowPathTokenStream.isBlank = function(ch)
	if(ch == " " or ch == "\r" or ch == "\n" or ch == "\t") then
		return true
	else
		return false
	end
end

--判断是否分割符
_windowPathTokenStream.isSeparate = function(ch)
	local seps = {"[","]","/",",","\\","\"","=",">","<","!",' ','\r','\n','\t'}
	for i = 1,#seps do
		if(ch == seps[i]) then
			return true
		end
	end
	return false
end

--是否是边界符
_windowPathTokenStream.isBoudary = function(ch)
	local seps = {"[","]","/",","}
	for i = 1,#seps do
		if(ch == seps[i]) then
			return true
		end
	end
	return false
end
