_xxml={doc=http.XmlDocument()}

function xxml()
	return _xxml
end

function _xxml:load(xml)
	if(xml==nil or xml=="") then
		return false
	end
	return _xxml.doc:LoadXML(xml)
end


function _xxml:get(path,attr)
	local node=_xxml.doc:SelectSingleNode(path)
	if(attr~=nil and attr~="" and string.lower(attr)~="innertext") then
		return node:GetAttribute(attr)
	else
		return node:GetInnerText()
	end
end

function _xxml:gets(path)
	local nodes=__node_s:new(_xxml.doc:SelectNodes(path)) --创建新节点
	return nodes
end


__node_s={node=nil}
function __node_s:new(_xnode,oo)
	 local o = oo or {}
	setmetatable(o,self)
	self.__index=__node_s
	o.node=_xnode
	return o
end

function __node_s:get_count()
	if(self.node==nil) then
		return 0
	end
	return self.node:GetCount()
end


function __node_s:get(index)
	if(self.node==nil) then
		return {}
	end
	local item=self.node:GetItem(index)
	local cnode=__node:new(item) --创建新节点
	return cnode
end


__node={node=nil}
function __node:new(_mnode,oo)
	 local o = oo or {}
	setmetatable(o,self)
	self.__index=__node
	o.node=_mnode
	return o
end

function __node:get(path,text)
	if(self.node==nil) then
		return ""
	end

	if(text==nil) then
		text=path
		if(string.lower(text)=="innertext") then
			return self.node:GetInnerText()
		elseif(string.lower(text)=="innerxml") then
			return self.node:GetInnerXml()
		else
			return self.node:GetAttribute(text)
		end
	else
		local node=self.node:SelectSingleNode(path)
		local cnode=__node:new(node)
		return cnode:get(text)
	end
end




function __node:getpv(path,attr)
	local node=self.node:SelectSingleNode(path)
	if(attr~=nil and attr~="" and string.lower(attr)~="innertext") then
		return node:GetAttribute(attr)
	else
		return node:GetInnerText()
	end
end

function __node:is_valid()
	if(self.node==nil) then
		return false
	end
	return self.node:IsValid()
end



function __node:gets(path)
	if(self.node==nil) then
		return ""
	end
	local nnodes=__node_s:new(self.node:SelectNodes(path)) --创建新节点
	return nnodes
end


