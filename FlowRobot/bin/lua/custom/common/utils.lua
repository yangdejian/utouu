--[[
功能：一些工具函数
作者：康勇
修改记录：
]]
utils={}

--[[
功能：将名字和值设置到数组中
参数：
	names-名字集合
	values-值集合
	array-目标数组
	startPos-值数组的起始位置
]]
utils.setParams = function(names,values,array,startPos)
	for i=1,#names do
		if(startPos+i-1 <= #values) then
			array[names[i]] = values[startPos+i-1]
		else
			array[names[i]] = nil
		end
	end
end

--[[
功能：判断字符串中是否包括对象中的字符
参数：
	str_source-源字符串
	contain_list - 指定字符串
]]
utils.strContains = function(str_source,contain_list)
	for i=1,#contain_list do
		local defind_list=utils.split(contain_list[i].kw,"&")
		local flag = true
		for j=1,#defind_list do
			if(string.find(str_source,defind_list[j])==nil) then
				flag = false
			end
		end
		if(flag) then
			return contain_list[i]
		end
	end
	return nil
end

--[[
功能：判断字符串是否为空
]]
utils.stringIsEmpty = function(str)
	if(str == nil or string.len(str) <= 0) then
		return true
	else
		return false
	end
end

--[[
功能：私有加密函数
]]
utils.privateEncrypt = function(data,key,algo)
	return base.PrivateEncrypt(data,key,algo)
end

--[[
功能：私有解密函数
]]
utils.privateDecrypt = function(data,key,algo)
	return base.PrivateDecrypt(data,key,algo)
end

--[[
功能:签名函数
]]
utils.sign = function(data,algo)
	return base.Sign(data,algo)
end

--[[
功能:MD5签名函数
]]
utils.md5 = function(data,encoding)
	if(encoding==nil or encoding=="") then
		encoding = "gb2312"
	end
	local algo = string.format("%s/md5/hex",encoding)
	return base.Sign(data,algo)
end

--[[
功能：从ini获取整数函数
]]
utils.getIniNum = function(section,key,def,filename)
	return base.ReadInt(section,key,tonumber(def),filename)
end

--[[
功能：从ini获取字符串函数
]]
utils.getIniStr = function(section,key,def,filename)
	return base.ReadString(section,key,tostring(def),filename)
end


--[[
功能:分割字符串
参数:
	(1)源字符串
	(2)分割符
	(3)是否删除空字符串，可缺省（缺省时删除空字符串)
]]
utils.split = function(text,sep,removeBlank)
	if(removeBlank == nil) then
	    removeBlank = true
	end

    local retList = {}

	--根据换行符进行拆分
	local prev = 0
	local pos = string.find(text,sep,prev)
	local len = 0
	while(pos ~= nil) do
	    local t = string.sub(text,prev,pos-1)
		if((not removeBlank) or (t ~= nil and string.len(t) > 0)) then
		    retList[len+1] = t
			len = len+1
		end
		prev = pos+string.len(sep)
		pos = string.find(text,sep,prev)
	end
	local t = string.sub(text,prev)

	if((not removeBlank) or (t ~= nil and string.len(t) > 0)) then
		retList[len+1] = t
		len = len+1
	end
	return retList
end

--[[
功能：去除前面的空格
]]
utils.trimLeft = function(str)
	return string.gsub(str,"^%s*","")
end

--[[
功能：去除后面的空格
]]
utils.trimRight = function(str)
	return string.gsub(str,"%s*$","")
end

--[[
功能：去除两端的空格
]]
utils.trim = function(str)
	return string.gsub(str,"^%s*(.-)%s*$","%1")
end

--[[
功能：去除字符串所有空格
]]
utils.trimAll = function(str)
	return  (string.gsub(s, "%s*(.-)%s*", "%1"))
end

--[[
功能：去掉转义符
]]
utils.unescape = function(str,es)
	local ret = ""
	local len = string.len(str)
	local i = 1
	while(i <= len) do
		local ch = string.sub(str,i,i)
		if(ch == es) then
			ret = ret .. string.sub(str,i+1,i+1)
			i = i + 2
		else
			ret = ret .. ch
			i = i + 1
		end
	end
	return ret
end

--[[
功能：字符串转换为数字
]]
utils.tonumber = function(str)
	return tonumber(str)
end

--[[
功能：格式化字符串
]]
utils.tostring = function(str)
	if(str==nil) then
		return ""
	end
	return string.gsub(str,"^%s*(.-)%s*$","%1")
end

--[[
功能：判断是否为空
]]
utils.is_null = function(str)
	if(str~=nil and str~="") then
		return false
	end
	return true
end

--左补齐
utils.pad_left = function(str,len,pad)
	local l = string.len(str)
	local ret = ""
	for i = l,len-1 do
	    ret = ret .. pad
	end
	ret = ret .. str
	return ret
end

--右补齐
utils.pad_right = function(str,len,pad)
	local l = string.len(str)
	local ret = ""
	for i = l,len-1 do
	    ret = ret .. pad
	end
	ret = str .. ret
	return ret
end
