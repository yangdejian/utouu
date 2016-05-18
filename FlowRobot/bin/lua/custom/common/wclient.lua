require "custom.ui.windowLib"
require "custom.common.luadate"
_wclient={}
--[[
功能：实例化对象
]]
function _wclient:new(oo)
	 local o = oo or {}
	setmetatable(o,self)
	self.__index=self
	o.client=ie.Browser.Create(5000)
	if(o.client == nil) then
		error("create browser failed")
	end
	return o
end

--[[
功能：构造函数
]]
function wclient()
	return _wclient:new()
end

--[[
功能：获取外置浏览器的进程id
]]
function _wclient:getpid()
	return self.client.pid
end

--[[
功能:设置浏览时是否允许弹出窗口,如果允许则在当前窗口打开弹出的URL
参数:(1)true/false
]]
function _wclient:enable_pop(flag)
	print("EnablePopupWindow:"..tostring(flag))
	self.client:EnablePopup(flag)
end


--[[
功能:设置download是否跳转页面
参数:(1)true/false
]]
function _wclient:enable_redirect(flag)
	print("EnableAutoRedirect:"..tostring(flag))
	self.client:EnableAutoRedirect(flag)
end

--[[
功能:设置代理
参数:
	(1)是否是局部代理,true/false
	(2)代理地址
	(3)代理用户名
	(4)代理密码
]]
function _wclient:set_proxy(blocal,proxyaddr,user,pass)
    if(blocal == nil) then
	    blocal = true
	end
	if(user == nil) then
	    user = ""
	end

	if(pass == nil) then
	    pass = ""
	end

	if(blocal) then
		self.client:SetProxy(proxyaddr,user,pass)
	else
		self.client:SetGlobalProxy(proxyaddr,user,pass)
	end
end

--[[
功能:取消代理
]]
function _wclient:cancel_proxy()
	print("取消代理IP")
	self.client:CancelProxy()
end

--[[
功能:取消IE全局代理
]]
function _wclient:cancel_ie_proxy()
	print("取消代理IP")
	self.client:CancelGlobalProxy()
end

--[[
功能:download页面
参数:
	(1)网页地址
	(2)访问方法
	(3)访问头
	(4)提交参数
	(5)访问超时时间
]]
function _wclient:download(url,method,header,params,t)
	if(method=="" or method==nil) then
		method="get"
	end
	if(header=="" or header==nil) then
		header=""
	end
	if(params=="" or params==nil) then
		params=""
	end
	local timeout=t==nil and 120000 or tonumber(t)
	timeout=timeout==nil and 120000 or timeout
	local data = base.CharVector()
	self.client:Download(data,url,method,header,params,true,timeout)
	return data
end

--[[
功能：获取下载页面的编码名
参数:
	(1)下载信息头
]]
function _wclient:get_content_encoding(strHeader)
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
功能:翻译函数
参数：
	(1)源地址
	(2)输入
	(3)编码
]]
function _wclient:translate(src,input,encoding)
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

--[[
功能:获取http请求头信息
参数:
	(1)获取header中的某个属性，为空返回全部header
]]
function _wclient:getheader(param)
	local strHeader = self.client:GetResponseHeader()
	if(param==nil or param=="") then
		return strHeader
	end
	local strLowerHeader = string.lower(strHeader)
	local nStart = string.find(strLowerHeader,string.lower(param),1,true)

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
功能:根据模板访问网页
参数:
	(1)访问模板
	(2)输入参数
	(3)访问超时
]]
function _wclient:query(params,input,timeout)
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
	    timeout = 120000
	end

	if(params.action == "navigate") then--浏览网页
	    --浏览网页时预处理
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
		--浏览
		if(params.target == nil or string.len(params.target) <= 0) then
			self.client:Navigate(url,header,post)
		else
			self.client:Navigate(url,header,post,params.target)
		end
	elseif(params.action == "click") then--点击网页中某个元素
		if(not self:wait_html(params.path,timeout)) then
			self.lastStatus = false
		end
	    --点击预处理
		local path = params.path

		--点击
		self:click(path)
	else--下载网页
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
		local data = self:download(url,method,header,post,timeout)

		self.lastStatus = true

		--获取头
		local strHeader = self.client:GetResponseHeader()

		--解码
		local contentEncoding = self:get_content_encoding(strHeader)

		if(contentEncoding == "gzip") then
			local temp = base.CharVector()
			base.GUnzip(data,temp)
			data = temp
		end

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
end

--[[
功能:等待多个对象
参数:
	(1)对象数组
	(2)等待超时
]]
function _wclient:wait_for(col,timeout)
	--解析
	local evts = {}
	for i = 1,#col do
		local n = string.find(col[i],":")
		if(n == nil) then
			error("错误的条件")
		end
		local type = string.sub(col[i],1,n-1)
		local info = string.sub(col[i],n+1)
		if(type == "html") then
			evts[#evts+1] = {name = "html",value=info}
		elseif(type == "url") then
			evts[#evts+1] = {name = "url",value=info}
		elseif(type == "window") then
			evts[#evts+1] = {name = "window",value=info}
		else
			error("错误的条件")
		end
	end
	--判断
	local start = luadate.micro_time()--flowlib.microTime()
	while(luadate.micro_time() < start:add_sec(timeout/1000)) do
		local bFin = true
		for i = 1,#evts do
			if(evts[i].name == "html") then
				if(not self.client:ExistsObject(evts[i].value)) then
					bFin = false
					break
				end
			elseif(evts[i].name == "url") then
				if(not self.client:ObjectHasCompleted(evts[i].value,false)) then
					bFin = false
					break
				end
			elseif(evts[i].name == "window") then
				local wnd = windowlib.selectOne(self.client.pid,path)
				if(wnd == nil) then
					bFin = false
					break
				end
			end
		end

		if(bFin) then
			return true
		end
		flowlib.sleep_sync(100)
	end
	return false
end

--[[
功能:等待URL浏览完成
参数:
	(1)url地址
	(2)等待超时
]]
function _wclient:wait_url(url,timeout)
	local start = luadate.micro_time()--flowlib.microTime()
	while(luadate.micro_time() < start:add_sec(timeout/1000)) do
		if(self.client:ObjectHasCompleted(url,false)) then
			return true
		end
		flowlib.sleep_sync(100)
	end
	return false
end

--[[
功能:等待HTML元素出现
参数:
	(1)元素路径
	(2)等待超时
]]
function _wclient:wait_html(path,timeout)
	local start = luadate.micro_time()--flowlib.microTime()
	while(luadate.micro_time() < start:add_sec(timeout/1000)) do
		local doc = self:get_document()
		local ele = doc:SelectOneElement(path)
		if(ele ~= nil and ele.valid) then
			ele:Release()
			doc:Release()
			return true
		end
		doc:Release()
		flowlib.sleep_sync(100)
	end
	return false
end


--[[
功能:等待WINDOW出现
参数:
	(1)窗口路径
	(2)等待超时
]]
function _wclient:wait_window(path,timeout)
	local start = luadate.micro_time()--flowlib.microTime()
	while(luadate.micro_time() < start:add_sec(timeout/1000)) do
		local wnd = windowlib.selectOne(self.client.pid,path)
		if(wnd ~= nil) then
			return true
		end
		flowlib.sleep_sync(100)
	end
	return false
end


--[[
功能:设置html元素的属性
参数:
	(1)元素路径
	(2)元素属性
	(3)元素值
]]
function _wclient:set_attr(path,attr,value)
	local doc = self:get_document()
	local ele = doc:SelectOneElement(path)
	if(ele == nil or not ele.valid) then
		doc:Release()
		return false,"元素不存在"
	end

	ele:SetAttribute(attr,value)
	ele:Release()
	doc:Release()
	return true
end

--[[
功能:获取html元素的属性
]]
function _wclient:getattr(path,attr)
	local doc = self:get_document()
	local ele = doc:SelectOneElement(path)
	if(ele == nil or not ele.valid) then
		doc:Release()
		return nil
	end
	local str = ele:GetAttribute(attr)
	ele:Release()
	doc:Release()
	return str
end

--[[
功能:判断html元素是否存在
]]
function _wclient:exists(path)
	local doc = self:get_document()
	local ele = doc:SelectOneElement(path)
	if(ele == nil or not ele.valid) then
		doc:Release()
		return false
	else
		ele:Release()
		doc:Release()
		return true
	end
end

--[[
功能:获取浏览器的html文本
]]
function _wclient:get_html()
	local doc = self:get_document()
	local str = doc.html
	doc:Release()
	return str
end

--[[
功能:获取浏览器的内嵌文本
]]
function _wclient:get_text()
	local doc = self:get_document()
	local str = doc.text
	doc:Release()
	return str
end

--[[
功能:获取浏览器实例
]]
function _wclient:get_browser()
	return self.client
end

--[[
功能:获取浏览器的html文档对象
]]
function _wclient:get_document()
	return self.client:GetHtmlDocument()
end

--[[
功能:点击html元素
]]
function _wclient:click(path)
	local doc = self:get_document()
	local ele = doc:SelectOneElement(path)
	if(ele == nil or not ele.valid) then
		doc:Release()
		return false,"元素不存在"
	end

	ele:Click()
	ele:Release()
	doc:Release()
	return true
end

--[[
功能:引起html事件
]]
function _wclient:fire_event(path,e)
	local doc = self:get_document()
	local ele = doc:SelectOneElement(path)
	doc:Release()
	if(ele == nil or not ele.valid) then
		doc:Release()
		return false,"元素不存在"
	end

	ele:FireEvent(e)
	ele:Release()
	doc:Release()
	return true
end

---**************模拟完成************--
--[[
功能:获取单个cookie
]]
function _wclient:get_one_cookie(domain,cname)
	return self.client:GetCookie(domain,cname)
end

--[[
功能:获取网站下所有cookie
]]
function _wclient:get_all_cookie(domain)
	return self.client:GetCookie(domain)
end

--[[
功能：删除网站下所有cookie
]]
function _wclient:clear_all_cookie(domain)
	local cookies=self.client:GetCookie(domain)
	if(string.len(tostring(cookies))>4) then
		local cookieArr = self:split(cookies,";",true)
		for i=1,#cookieArr do
			self:set_cookie(domain,string.format("%s;expires=Sun, 2-Oct-11 01:50:15 GMT;Path=/",cookieArr[i]))
			self:set_httponly_cookie(domain,string.format("%s;expires=Sun, 2-Oct-11 01:50:15 GMT;Path=/",cookieArr[i]))
		end
	end
end

--[[
功能:设置http only属性的cookie
]]
function _wclient:set_httponly_cookie(domain,cname)
	self.client:SetCookie(domain,cname,0x2000)
end

--执行javascript
function _wclient:exec_script(script)
	self.client:Execute(script)
end

--重置cookie
function _wclient:reset_cookie(domain,cookies)
	self:clear_all_cookie(domain)
	self:set_cookies(domain,cookies)

end

--设置cookies
function _wclient:set_cookies(domain,cookies)
    local cnames = self:split(cookies,";")
	for i=1,#cnames do
        self.client:SetCookie(domain,cnames[i])
	end
end

--设置cookie
function _wclient:set_cookie(domain,cname)
	return self.client:SetCookie(domain,cname)
end

--读取
function _wclient:read(path)
	local file = io.open(path,"r")
	local data=""
	if (file) then
		data=file:read("*a")
		file:close()
	end
	return data
end

--写文件
function _wclient:write(filename,content)
	local file = io.open(filename,"w")
	local data=""
	if (file) then
		data=file:write(content)
		file:close()
	end
	return data
end

function _wclient:file_exists(path)
   local file = io.open(path, "rb")
   if file then file:close() end
   return file ~= nil
end

--[[
   获取响应头
--]]
function _wclient:get_response_headers()
	return self.client:GetResponseHeader()
end

--[[
   获取响应头
--]]
function _wclient:get_response_Header(headerName)
	local retHeader = {}
	if(headerName == nil or string.len(headerName) <= 0) then
	    return retHeader
	end
	local name= string.lower(headerName)
    local headerText = self.client:GetResponseHeader()
	headerText = string.gsub(headerText,"\r","")
    local headers = self:split(headerText,"\n")


	local nCntr = 0
    for i=2,#headers do
		--根据冒号进行分割
        local pos = string.find(headers[i],":")
		if(pos ~= nil) then
		    local title = string.sub(headers[i],1,pos-1)
			title = string.gsub(title," ","")
			title = string.lower(title)
			if(title == name) then
			    retHeader[nCntr+1] = string.sub(headers[i],pos+1)
				nCntr = nCntr +1
			end
		end
	end
	return retHeader
end


--[[
   获取响应标题
--]]
function _wclient:get_response_flag()
    local headerText = self.client:GetResponseHeader()
	headerText = string.gsub(headerText,"\r","")
    local headers = self:split(headerText,"\n")
	if(#headers > 0) then
	    return headers[1]
	else
	    return ""
	end
end

--[[
获取响应状态
]]
function _wclient:get_response_status()
	return self.client:GetResponseStatus()
end


function _wclient:split(text,sep,removeBlank)
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
--清除alert的弹出对话框
function _wclient:clear_alert_window()

end
