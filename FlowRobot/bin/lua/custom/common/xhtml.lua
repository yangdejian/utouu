_xhtml={}

tagid = "Custom_Message"
g_bf_jsscript="<script language=\"javascript\" type=\"text/javascript\">window.alert=function(msg,dr){writeEle(msg);return null;}\r\n"..
				"window.confirm=function(msg,dr){writeEle(msg);return null;}\r\n"..
				"window.prompt=function(msg,dr){return null;}\r\n"..
				"window.open=function(a,b,c,d){return null;}\r\n"..
				"function killErrors() {return true;}\r\n"..
				"window.onerror = killErrors;\r\n"..
				"var el=document.createElement('span');\r\n"..
				"el.id='"..tagid.."';\r\n"..
				"function writeEle(msg)\r\n"..
				"{\r\n"..
				"el.innerHTML+=msg;\r\n"..
				"}\r\n"..
				"</script>"

g_sft_jsscript="<script language=\"javascript\" type=\"text/javascript\">\r\n"..
"document.body.appendChild(el);\r\n"..
"</script>"

function _xhtml:new(oo)
	 local o = oo or {}
	setmetatable(o,self)
	self.__index=_xhtml
	return o
end

function xhtml(doc)
	local ret = _xhtml:new()
	if(doc == nil) then
	    ret.doc = http.HtmlDocument()
	else
		ret.doc = doc
	end

	return ret
end

function _xhtml:load(html)
	if(html==nil or html=="") then
		return false
	end
	html=string.gsub(string.gsub(html,"window.location","//window.location"),"window.open","//window.open")
	html=tostring(g_bf_jsscript..html..g_sft_jsscript)
	return self.doc:Load(html)
end

function _xhtml:get(path,attr)
	local ele=self.doc:SelectOneElement(path)
	if(not(ele:IsValid())) then
		print("未找到"..path)
		return nil
	end
	local ret=tostring(ele:GetAttribute(attr))
	return string.gsub(tostring(ret), "^%s*(.-)%s*$", "%1")--trim
end

function _xhtml:getElements(path)
	local eles=self.doc:SelectElements(path)
	return eles
end


function _xhtml:gets(path)
	local nodes=__h_node_s:new(self.doc:SelectElements(path)) --创建新节点
	return nodes
end


__h_node_s={node=nil}
function __h_node_s:new(_xnode,oo)
	 local o = oo or {}
	setmetatable(o,self)
	self.__index=__h_node_s
	o.node=_xnode
	return o
end

function __h_node_s:get_count()
	if(self.node==nil) then
		return 0
	end
	return self.node:GetLength()
end


function __h_node_s:get(index)
	if(self.node==nil) then
		return {}
	end
	local item=self.node:Get(index)
	local cnode=__h_node:new(item) --创建新节点
	return cnode
end


__h_node={node=nil}
function __h_node:new(_mnode,oo)
	 local o = oo or {}
	setmetatable(o,self)
	self.__index=__h_node
	o.node=_mnode
	return o
end

function __h_node:get(path,text)
	if(self.node==nil) then
		return ""
	end

	if(text==nil) then
		text=path
		if(string.lower(text)=="innertext") then
			return self.node:GetInnerText()
		elseif(string.lower(text)=="innerxml") then
			return self.node:GetInnerHtml()
		else
			return self.node:GetAttribute(text)
		end
	else
		local node=self.node:SelectOneElement(path)
		local cnode=__h_node:new(node)
		return cnode:get(text)
	end
end


function __h_node:getpv(path,attr)
	local node=self.node:SelectOneElement(path)
	if(attr~=nil and attr~="" and string.lower(attr)~="innertext") then
		return node:GetAttribute(attr)
	else
		return node:GetInnerText()
	end
end

function __h_node:is_valid()
	if(self.node==nil) then
		return false
	end
	return self.node:IsValid()
end



function __h_node:gets(path)
	if(self.node==nil) then
		return ""
	end
	local nnodes=__h_node_s:new(self.node:SelectElements(path)) --创建新节点
	return nnodes
end






function _xhtml:set(path,attr,value)
	local ele=self.doc:SelectOneElement(path)
	if(not(ele:IsValid())) then
		print("设置属性未找到元素"..path)
		return false
	end

	ele:SetAttribute(attr,value)
	return true
end

function _xhtml:exists(path)
	local ele=self.doc:SelectOneElement(path)
	if(not(ele:IsValid())) then
		return false
	end
	return true
end

function _xhtml:getFormInputs(path,doc)
    --首先寻找表单

	local v=doc==nil and self.doc or doc
    local form = v:SelectOneElement(path)
	if not form:IsValid() then
		print("未找到指定form")
	    return {}
	end

	----- 将input-name中重复值过滤掉
	local function addElement(arr,element)
		for i,v in pairs(arr) do
			if(tostring(v) == tostring(element)) then
				return
			end
		end
		table.insert(arr,element)
	end

    local ret = {keys={},values={}}
    local eles=form:SelectElements("input")
	for i = 0,eles:GetLength()-1 do
	    local e = eles:Get(i)
		local name = e:GetAttribute("name")
		if(name ~= nil and string.len(name) > 0) then --  and ret.values[name] == nil
			local v = e:GetAttribute("value")
			if(ret.values[name] == nil) then
				table.insert(ret.keys,name)
				ret.values[name] = v
			elseif(type(ret.values[name])=='string') then
				-- (input:checkbox之类的控件会有重复的name)
				local first_element = ret.values[name]
				ret.values[name] = {}
				addElement(ret.values[name],first_element)
				addElement(ret.values[name],v)
			elseif(type(ret.values[name])=='table') then
				-- (input:checkbox之类的控件会有重复的name)
				addElement(ret.values[name],v)
			else
				print('Err-getFormInputs:不能处理的情况!')
			end
		end
	end

	return ret
end

--[[
与子窗口相关的函数
]]

--[[
功能:判断窗口是否存在
参数:classname-类名，可缺省
     caption  -标题，可缺省
]]
function _xhtml:existsWindow(classname,caption)
    local wnd = self:getWindow(classname,caption)
	if(wnd == nil or not wnd:IsValid()) then
	    return false
	else
	    return true
	end
end

--[[
功能:获取窗口
参数:classname-类名，可缺省
     caption  -标题，可缺省
]]
function _xhtml:getWindow(classname,caption)
    local proxy = CExplorerProxy()
	if((classname == nil or string.len(classname) <= 0) and (caption == nil or string.len(caption) <= 0)) then
	    return nil
	end
	local wnd = nil
	if(classname == nil or string.len(classname) <= 0) then
	    wnd = proxy:FindWindowByCaption(0,caption)
	elseif(caption == nil or string.len(caption) <= 0) then
	    wnd = proxy:FindWindowByClass(0,classname)
	else
	    wnd = proxy:FindWindow(0,caption,classname)
	end

	if(wnd == nil or not wnd:IsValid()) then
	    return nil
	else
	    return wnd
	end
end

