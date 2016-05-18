--[[
���ܣ�һЩ���ߺ���
���ߣ�����
�޸ļ�¼��
]]
utils={}

--[[
���ܣ������ֺ�ֵ���õ�������
������
	names-���ּ���
	values-ֵ����
	array-Ŀ������
	startPos-ֵ�������ʼλ��
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
���ܣ��ж��ַ������Ƿ���������е��ַ�
������
	str_source-Դ�ַ���
	contain_list - ָ���ַ���
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
���ܣ��ж��ַ����Ƿ�Ϊ��
]]
utils.stringIsEmpty = function(str)
	if(str == nil or string.len(str) <= 0) then
		return true
	else
		return false
	end
end

--[[
���ܣ�˽�м��ܺ���
]]
utils.privateEncrypt = function(data,key,algo)
	return base.PrivateEncrypt(data,key,algo)
end

--[[
���ܣ�˽�н��ܺ���
]]
utils.privateDecrypt = function(data,key,algo)
	return base.PrivateDecrypt(data,key,algo)
end

--[[
����:ǩ������
]]
utils.sign = function(data,algo)
	return base.Sign(data,algo)
end

--[[
����:MD5ǩ������
]]
utils.md5 = function(data,encoding)
	if(encoding==nil or encoding=="") then
		encoding = "gb2312"
	end
	local algo = string.format("%s/md5/hex",encoding)
	return base.Sign(data,algo)
end

--[[
���ܣ���ini��ȡ��������
]]
utils.getIniNum = function(section,key,def,filename)
	return base.ReadInt(section,key,tonumber(def),filename)
end

--[[
���ܣ���ini��ȡ�ַ�������
]]
utils.getIniStr = function(section,key,def,filename)
	return base.ReadString(section,key,tostring(def),filename)
end


--[[
����:�ָ��ַ���
����:
	(1)Դ�ַ���
	(2)�ָ��
	(3)�Ƿ�ɾ�����ַ�������ȱʡ��ȱʡʱɾ�����ַ���)
]]
utils.split = function(text,sep,removeBlank)
	if(removeBlank == nil) then
	    removeBlank = true
	end

    local retList = {}

	--���ݻ��з����в��
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
���ܣ�ȥ��ǰ��Ŀո�
]]
utils.trimLeft = function(str)
	return string.gsub(str,"^%s*","")
end

--[[
���ܣ�ȥ������Ŀո�
]]
utils.trimRight = function(str)
	return string.gsub(str,"%s*$","")
end

--[[
���ܣ�ȥ�����˵Ŀո�
]]
utils.trim = function(str)
	return string.gsub(str,"^%s*(.-)%s*$","%1")
end

--[[
���ܣ�ȥ���ַ������пո�
]]
utils.trimAll = function(str)
	return  (string.gsub(s, "%s*(.-)%s*", "%1"))
end

--[[
���ܣ�ȥ��ת���
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
���ܣ��ַ���ת��Ϊ����
]]
utils.tonumber = function(str)
	return tonumber(str)
end

--[[
���ܣ���ʽ���ַ���
]]
utils.tostring = function(str)
	if(str==nil) then
		return ""
	end
	return string.gsub(str,"^%s*(.-)%s*$","%1")
end

--[[
���ܣ��ж��Ƿ�Ϊ��
]]
utils.is_null = function(str)
	if(str~=nil and str~="") then
		return false
	end
	return true
end

--����
utils.pad_left = function(str,len,pad)
	local l = string.len(str)
	local ret = ""
	for i = l,len-1 do
	    ret = ret .. pad
	end
	ret = ret .. str
	return ret
end

--�Ҳ���
utils.pad_right = function(str,len,pad)
	local l = string.len(str)
	local ret = ""
	for i = l,len-1 do
	    ret = ret .. pad
	end
	ret = str .. ret
	return ret
end
