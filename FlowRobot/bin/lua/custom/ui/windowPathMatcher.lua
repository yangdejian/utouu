_windowPathMatcher=
{
	_rules = {}
}
--caption,class,id,x,y,width,height,innerText,visible,enabled,readonly,pos
_windowPathMatcher._rules["caption"]	={operator={"=",">","<",">=","<="},type="text"}
_windowPathMatcher._rules["class"]		={operator={"=",">","<",">=","<="},type="text"}
_windowPathMatcher._rules["innerText"]	={operator={"=",">","<",">=","<="},type="text"}
_windowPathMatcher._rules["id"]			={operator={"=","!="},type="number"}
_windowPathMatcher._rules["pos"]		={operator={"=","!="},type="number"}
_windowPathMatcher._rules["x"]			={operator={"=",">","<",">=","<="},type="number"}
_windowPathMatcher._rules["y"]			={operator={"=",">","<",">=","<="},type="number"}
_windowPathMatcher._rules["width"]		={operator={"=",">","<",">=","<="},type="number"}
_windowPathMatcher._rules["height"]		={operator={"=",">","<",">=","<="},type="number"}
_windowPathMatcher._rules["visible"]	={operator={"=","!="},type="bool"}
_windowPathMatcher._rules["enabled"]	={operator={"=","!="},type="bool"}
_windowPathMatcher._rules["readonly"]	={operator={"=","!="},type="bool"}
--添加校验规则

function _windowPathMatcher:new(oo)
	 local o = oo or {}
	setmetatable(o,self)
	self.__index=self
	o._expression={}
	return o
end

--进行语法分析
function windowPathMatcher(stream)
	local obj = _windowPathMatcher:new()

	--取边界符
	local begin = stream:getBoundary()
	if(begin ~= "[") then
		error("syntax error:no expression begin boundary")
	end

	while(not stream:empty()) do
			--取标识符
		local name = string.lower(stream:getIdentifer())
		if(not stream.isIdentifier(name)) then
			error("syntax error:name is not Identifier")
		end
		--取操作符
		local oper = string.lower(stream:getOperator())
		if(oper == "") then
			error("syntax error:no operator")
		end
		--取值
		local text = stream:getText()

		--检验规则
		obj:validExpress(name,oper,text)


		--保存表达式
		local exp = {_name=name,_oper=oper,_value=text}
		obj._expression[#obj._expression + 1] = exp

		--预取边界符
		local ch = stream:pregetBoundary()
		if(ch =="") then
			error("syntax error:no boundary")
		elseif(ch == "]") then
			break
		elseif(ch == ",") then
			stream:getBoundary()
		else
			error("syntax error:unknown")
		end
	end
	local ch = stream:getBoundary()
	if(ch ~= "]") then
		error("syntax error:no expression end boundary")
	end

	return obj
end

--匹配规则
function _windowPathMatcher:match(wnd)
	for i=1,#self._expression do
		--根据规则进行匹配
		if(not self:matchExpress(self._expression[i],wnd)) then
			return false
		end
	end
	return true
end

function _windowPathMatcher:matchExpress(expr,wnd)
	if(expr._name == "caption") then
		return self:matchString(expr._oper,wnd.caption,expr._value)
	elseif(expr._name=="class") then
		return self:matchString(expr._oper,wnd.className,expr._value)
	elseif(expr._name=="innerText") then
		return self:matchString(expr._oper,wnd.innerText,expr._value)
	elseif(expr._name=="id") then
		return self:matchNumber(expr._oper,wnd.controlId,expr._value)
	elseif(expr._name=="pos") then
		local v = tonumber(expr._value)
		if(v == 0) then
			return true
		end
		if(v > 0) then
			return self:matchNumber(expr._oper,wnd.pos,v)
		else
			return self:matchNumber(expr._oper,wnd.backpos,v)
		end
		--暂不支持负数

	elseif(expr._name=="x") then
		return self:matchNumber(expr._oper,wnd.x,expr._value)
	elseif(expr._name=="y") then
		return self:matchNumber(expr._oper,wnd.y,expr._value)
	elseif(expr._name=="width") then
		return self:matchNumber(expr._oper,wnd.width,expr._value)
	elseif(expr._name=="height") then
		return self:matchNumber(expr._oper,wnd.height,expr._value)
	elseif(expr._name=="visible") then
		return self:matchBool(expr._oper,wnd.visible,expr._value)
	elseif(expr._name=="enabled") then
		return self:matchBool(expr._oper,wnd.enabled,expr._value)
	elseif(expr._name=="readonly") then
		return self:matchBool(expr._oper,wnd.readonly,expr._value)
	end
end

--字符串匹配,v1为窗口的值，v2为表达式中的值
function _windowPathMatcher:matchString(op,v1,v2)
	local s1 = tostring(v1)
	local s2 = tostring(v2)

	if(op == "=") then
		return s1 == s2
	end
	if(op == ">" or op == ">=" or op == "like") then
		return self:includeString(s1,s2) ~= nil
	else
		return self:includeString(s2,s1) ~= nil
	end
end
--整数匹配
function _windowPathMatcher:matchNumber(op,v1,v2)
	local n1 = tonumber(v1)
	local n2 = tonumber(v2)
	if(op == "=") then
		return n1 == n2
	elseif(op == "!=") then
		return n1 ~= n2
	elseif(op == ">" ) then
		return  n1 > n2
	elseif(op == "<" ) then
		return  n1 < n2
	elseif(op == ">=" ) then
		return  n1 >= n2
	else
		return n1 <= n2
	end
end

--布尔匹配
function _windowPathMatcher:matchBool(op,v1,v2)
	local s1 = string.lower(tostring(v1))
	local s2 = string.lower(tostring(v2))
	local b1,b2
	if(s1 == "true" or s1 == "yes") then
		b1 = true
	else
		b1 = false
	end
	if(s2 == "true" or s2 == "yes") then
		b2 = true
	else
		b2 = false
	end

	if(op == "=") then
		return b1 == b2
	else
		return b1 ~= b2
	end
end


--打印条件
function _windowPathMatcher:print()
	local str = "["
	for i = 1,#self._expression do
		if(i==1)then
			str = str..string.format("%s%s%s",self._expression[i]._name,self._expression[i]._oper,self._expression[i]._value)
		else
			str = str..string.format(",%s%s%s",self._expression[i]._name,self._expression[i]._oper,self._expression[i]._value)
		end
	end
	print(str.."]")
end

function _windowPathMatcher:includeString(v1,v2)
	local len = v2:len()
	if(len <= 0) then
		return 0,0
	end
	if(v1:len() < len) then
		return nil
	end

	local cntr = v1:len() - len + 1
	for i=1, cntr do
		if(v1:sub(i,i+len-1) == v2) then
			return i,i+len-1
		end
	end
	return nil
end


--校验表达式
function _windowPathMatcher:validExpress(name,oper,value)
	--规则判断
	local r = self._rules[name]
	if(r == nil) then
		error("syntax error:can't support this expression")
	end

	if(not self:isValidOperator(r.operator,oper)) then
		error("syntax error:no operator")
	end

	if(not self:isValidType(r.type,value)) then
		error("syntax error:type is error")
	end
end


--校验操作符
function _windowPathMatcher:isValidOperator(col,oper)
	local op = string.lower(oper)
	for i=1,#col do
		if(col[i] == op) then
			return true
		end
	end
	return false
end

--校验类型
function _windowPathMatcher:isValidType(t,v)
	--规则判断
	if(t=="text" or t == "string") then
		return true
	elseif(t == "number") then
		if(_windowPathTokenStream.isDigital(v)) then
			return true;
		end
	elseif(t == "bool") then
		local val = string.lower(v)
		if(val == "true" or val == "false" or val == "yes" or val == "no" )then
			return true
		end
	end

	return false
end
