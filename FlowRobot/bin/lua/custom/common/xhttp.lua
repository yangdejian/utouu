_xhttp={}

function _xhttp:new(oo)
	 local o = oo or {}
	setmetatable(o,self)
	self.__index=self
	return o
end

--[[
���ܣ����캯��
����:
	usedExternal-�Ƿ�ʹ���ⲿ�����
]]
function xhttp(usedExternal)
	local obj = _xhttp:new()
	if(usedExternal) then
		obj.usedExternal = true
		obj.downloader = ie.Browser.Create(60000)
	else
		obj.usedExternal = false
		obj.downloader = http.EasyBrowser()
	end
	return obj
end

--[[
���ܣ���ȡ���ĵ�
]]
function _xhttp:getHtmlDocument()
	if(self.usedExternal) then
		return self.downloader:GetHtmlDocument()
	else
		return nil
	end
end

--[[
���ܣ�����һ���հ��ĵ�
]]
function _xhttp:createHtmlDocument()
	if(self.usedExternal) then
		return self.downloader:CreateHtmlDocument()
	else
		return nil
	end
end

--[[
���ܣ����ض���������
������
	url-http��ַ
	timeout-����ĳ�ʱʱ��
	method-���󷽷���get��post,ȱʡΪget
	header-����ͷ����ȱʡ
	post  -�ύ��������ȱʡ
]]
function _xhttp:getBinaray(url,timeout,method,header,post)
    --����ȱʡ����
	local acTimeout = 30000
	local acMethod  = "get"
	local acHeader  = ""
	local acPost    = ""
	if(timeout ~= nil) then
		acTimeout = timeout
	end
	if(method ~= nil) then
		acMethod = method
	end
	if(header ~= nil) then
		acHeader = header
	end
	if(post ~= nil) then
		acPost = post
	end

	--��������
	local data = base.CharVector()
	self.downloader:Download(data,url,acMethod,acHeader,acPost,true,acTimeout)
	--��ȡͷ
	local strHeader = self.downloader:GetResponseHeader()

	--����
	local contentEncoding = self:get_content_encoding(strHeader)

	if(contentEncoding == "gzip") then
		local temp = base.CharVector()
		base.GUnzip(data,temp)
		data = temp
	end
	return data
end

--[[
���ܣ������ı�����
������
	url-http��ַ
	timeout-����ĳ�ʱʱ��
	method-���󷽷���get��post,ȱʡΪget
	header-����ͷ����ȱʡ
	post  -�ύ��������ȱʡ
]]
function _xhttp:getText(url,encoding,timeout,method,header,post)
	local data = self:getBinaray(url,timeout,method,header,post)
	local text = base.FromEncoding(data,encoding)
	return text
end

--Get��ʽ�����ı�����
function _xhttp:get(url,encoding,timeout,header)
	if(timeout==nil) then
		timeout = 30000
	end
	return self:getText(url,encoding,timeout,header)
end

--Post��ʽ�����ı�����
function _xhttp:post(url,data,encoding,timeout,header)
	if(timeout==nil) then
		timeout = 30000
	end
	return self:getText(url,encoding,timeout,"post",header,data)
end

--[[
���ܣ�����������������
����:
	params-��������
	input -�������
	timeout -����ʱʱ��
]]
function _xhttp:query(params,input,timeout)
    --�������
	local encoding = "gb2312"
	if params.encoding ~= nil then
		encoding = params.encoding
	end

    --����ʱ��
    if(timeout == nil) then
	   timeout = params.timeout
	end
	if(timeout == nil) then
	    timeout = 30000
	end

	--����Ԥ����
	--����URL
	local url = self:translate(params.url,input,encoding)

	--�����ύ�Ĳ���
	local post = ""
	if(params.data ~= nil) then
		post = self:translate(params.data,input,encoding)
	end

	--����header
	local header = ""
	if(params.header ~= nil) then
		header = self:translate(params.header,input,encoding)
	end

	--���󷽷�
	local method = "get"
	if(params.method == "post") then
		method = "post"
	end


	--��������
	local data = self:getBinaray(url,timeout,method,header,post)
	self.lastStatus = true

	if(TrimMidChar~=nil) then
		data=TrimMidChar(data,0)
	end

	--�������ݽ��з���
	if(params.content == "html" or params.content == "text" or params.content == "json") then
		local text = base.FromEncoding(data,encoding)
		return text
	else
		return data
	end
end


--[[
���ܣ���ȡ�Ƿ�ѹ����־
������
	strHeader-http��Ӧͷ
]]
function _xhttp:get_content_encoding(strHeader)
    local strLowerHeader = string.lower(strHeader)
	local nStart = string.find(strLowerHeader,string.lower("Content-Encoding"),1,true)

	if(nStart == nil) then
	    return ""
	end
	local nEnd = string.find(strLowerHeader,"\r\n",nStart)
	local nEncodingHeader = ""
	if(nEnd <= 0) then
	    nEncodingHeader = string.sub(strHeader,nStart)
	else
        nEncodingHeader = string.sub(strHeader,nStart,nEnd)
	end

	--��ȡ��������
	local n = string.find(nEncodingHeader,':')
	if(n == nil) then
	    return ""
	end

	local nEncodingName = string.sub(nEncodingHeader,n+1)
	nEncodingName = string.gsub(nEncodingName," ","")
	nEncodingName = string.gsub(nEncodingName,"\r","")
	nEncodingName = string.gsub(nEncodingName,"\n","")
	nEncodingName = string.gsub(nEncodingName,"\t","")
	return nEncodingName
end

--[[
���ܣ��������뺯��
]]
function _xhttp:translate(src,input,encoding)
	if(src=="*") then
		local param_data=""
		for i,v in pairs(input) do
			param_data=param_data..string.format("&%s=%s",i,base.UrlEncode(tostring(v),encoding,"All"))
		end
		if(string.len(param_data)>1) then
			return string.sub(param_data,2)
		end
		return ""
	end


	local pattern = "({[@#][%w_.]+})" --�����@����Ҫ����url���룬���������url����
	local dst = src
	for match in string.gmatch(dst,pattern) do
        local name = string.sub(match,3,string.len(match)-1)
        local needencode = false
		if(string.sub(match,2,2) == "#") then
		    needencode = true
		end

        if(input[name] == nil or string.len(input[name]) <= 0) then
			dst = string.gsub(dst,match,"")
		elseif(needencode) then
		    local v = base.UrlEncode(tostring(input[name]),encoding,"All")
			v = string.gsub(v,"%%","%%%%")
			dst = string.gsub(dst,match,v)
		else
            local v = tostring(input[name])
			v = string.gsub(v,"%%","%%%%")
            dst = string.gsub(dst,match,v)
		end
    end
    return dst
end
