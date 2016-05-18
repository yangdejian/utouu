_xhttp={}

function _xhttp:new(oo)
	 local o = oo or {}
	setmetatable(o,self)
	self.__index=self
	return o
end

--[[
功能：构造函数
参数:
	usedExternal-是否使用外部浏览器
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
功能：获取主文档
]]
function _xhttp:getHtmlDocument()
	if(self.usedExternal) then
		return self.downloader:GetHtmlDocument()
	else
		return nil
	end
end

--[[
功能：创建一个空白文档
]]
function _xhttp:createHtmlDocument()
	if(self.usedExternal) then
		return self.downloader:CreateHtmlDocument()
	else
		return nil
	end
end

--[[
功能：下载二进制数据
参数：
	url-http地址
	timeout-请求的超时时间
	method-请求方法，get或post,缺省为get
	header-请求头，可缺省
	post  -提交参数，可缺省
]]
function _xhttp:getBinaray(url,timeout,method,header,post)
    --处理缺省参数
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

	--下载数据
	local data = base.CharVector()
	self.downloader:Download(data,url,acMethod,acHeader,acPost,true,acTimeout)
	--获取头
	local strHeader = self.downloader:GetResponseHeader()

	--解码
	local contentEncoding = self:get_content_encoding(strHeader)

	if(contentEncoding == "gzip") then
		local temp = base.CharVector()
		base.GUnzip(data,temp)
		data = temp
	end
	return data
end

--[[
功能：下载文本数据
参数：
	url-http地址
	timeout-请求的超时时间
	method-请求方法，get或post,缺省为get
	header-请求头，可缺省
	post  -提交参数，可缺省
]]
function _xhttp:getText(url,encoding,timeout,method,header,post)
	local data = self:getBinaray(url,timeout,method,header,post)
	local text = base.FromEncoding(data,encoding)
	return text
end

--Get方式下载文本数据
function _xhttp:get(url,encoding,timeout,header)
	if(timeout==nil) then
		timeout = 30000
	end
	return self:getText(url,encoding,timeout,header)
end

--Post方式下载文本数据
function _xhttp:post(url,data,encoding,timeout,header)
	if(timeout==nil) then
		timeout = 30000
	end
	return self:getText(url,encoding,timeout,"post",header,data)
end

--[[
功能：根据配置下载数据
参数:
	params-配置数据
	input -输入参数
	timeout -请求超时时间
]]
function _xhttp:query(params,input,timeout)
    --翻译参数
	local encoding = "gb2312"
	if params.encoding ~= nil then
		encoding = params.encoding
	end

    --更改时间
    if(timeout == nil) then
	   timeout = params.timeout
	end
	if(timeout == nil) then
	    timeout = 30000
	end

	--下载预处理
	--翻译URL
	local url = self:translate(params.url,input,encoding)

	--翻译提交的参数
	local post = ""
	if(params.data ~= nil) then
		post = self:translate(params.data,input,encoding)
	end

	--翻译header
	local header = ""
	if(params.header ~= nil) then
		header = self:translate(params.header,input,encoding)
	end

	--请求方法
	local method = "get"
	if(params.method == "post") then
		method = "post"
	end


	--下载数据
	local data = self:getBinaray(url,timeout,method,header,post)
	self.lastStatus = true

	if(TrimMidChar~=nil) then
		data=TrimMidChar(data,0)
	end

	--根据内容进行返回
	if(params.content == "html" or params.content == "text" or params.content == "json") then
		local text = base.FromEncoding(data,encoding)
		return text
	else
		return data
	end
end


--[[
功能：获取是否压缩标志
参数：
	strHeader-http响应头
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

	--获取编码名称
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
功能：参数翻译函数
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


	local pattern = "({[@#][%w_.]+})" --如果是@则不需要进行url编码，否则需进行url编码
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
