require "custom.ui.windowLib"
require "custom.common.luadate"
_wclient={}
--[[
���ܣ�ʵ��������
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
���ܣ����캯��
]]
function wclient()
	return _wclient:new()
end

--[[
���ܣ���ȡ����������Ľ���id
]]
function _wclient:getpid()
	return self.client.pid
end

--[[
����:�������ʱ�Ƿ�����������,����������ڵ�ǰ���ڴ򿪵�����URL
����:(1)true/false
]]
function _wclient:enable_pop(flag)
	print("EnablePopupWindow:"..tostring(flag))
	self.client:EnablePopup(flag)
end


--[[
����:����download�Ƿ���תҳ��
����:(1)true/false
]]
function _wclient:enable_redirect(flag)
	print("EnableAutoRedirect:"..tostring(flag))
	self.client:EnableAutoRedirect(flag)
end

--[[
����:���ô���
����:
	(1)�Ƿ��Ǿֲ�����,true/false
	(2)�����ַ
	(3)�����û���
	(4)��������
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
����:ȡ������
]]
function _wclient:cancel_proxy()
	print("ȡ������IP")
	self.client:CancelProxy()
end

--[[
����:ȡ��IEȫ�ִ���
]]
function _wclient:cancel_ie_proxy()
	print("ȡ������IP")
	self.client:CancelGlobalProxy()
end

--[[
����:downloadҳ��
����:
	(1)��ҳ��ַ
	(2)���ʷ���
	(3)����ͷ
	(4)�ύ����
	(5)���ʳ�ʱʱ��
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
���ܣ���ȡ����ҳ��ı�����
����:
	(1)������Ϣͷ
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
����:���뺯��
������
	(1)Դ��ַ
	(2)����
	(3)����
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

--[[
����:��ȡhttp����ͷ��Ϣ
����:
	(1)��ȡheader�е�ĳ�����ԣ�Ϊ�շ���ȫ��header
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
����:����ģ�������ҳ
����:
	(1)����ģ��
	(2)�������
	(3)���ʳ�ʱ
]]
function _wclient:query(params,input,timeout)
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
	    timeout = 120000
	end

	if(params.action == "navigate") then--�����ҳ
	    --�����ҳʱԤ����
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
		--���
		if(params.target == nil or string.len(params.target) <= 0) then
			self.client:Navigate(url,header,post)
		else
			self.client:Navigate(url,header,post,params.target)
		end
	elseif(params.action == "click") then--�����ҳ��ĳ��Ԫ��
		if(not self:wait_html(params.path,timeout)) then
			self.lastStatus = false
		end
	    --���Ԥ����
		local path = params.path

		--���
		self:click(path)
	else--������ҳ
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
		local data = self:download(url,method,header,post,timeout)

		self.lastStatus = true

		--��ȡͷ
		local strHeader = self.client:GetResponseHeader()

		--����
		local contentEncoding = self:get_content_encoding(strHeader)

		if(contentEncoding == "gzip") then
			local temp = base.CharVector()
			base.GUnzip(data,temp)
			data = temp
		end

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
end

--[[
����:�ȴ��������
����:
	(1)��������
	(2)�ȴ���ʱ
]]
function _wclient:wait_for(col,timeout)
	--����
	local evts = {}
	for i = 1,#col do
		local n = string.find(col[i],":")
		if(n == nil) then
			error("���������")
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
			error("���������")
		end
	end
	--�ж�
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
����:�ȴ�URL������
����:
	(1)url��ַ
	(2)�ȴ���ʱ
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
����:�ȴ�HTMLԪ�س���
����:
	(1)Ԫ��·��
	(2)�ȴ���ʱ
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
����:�ȴ�WINDOW����
����:
	(1)����·��
	(2)�ȴ���ʱ
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
����:����htmlԪ�ص�����
����:
	(1)Ԫ��·��
	(2)Ԫ������
	(3)Ԫ��ֵ
]]
function _wclient:set_attr(path,attr,value)
	local doc = self:get_document()
	local ele = doc:SelectOneElement(path)
	if(ele == nil or not ele.valid) then
		doc:Release()
		return false,"Ԫ�ز�����"
	end

	ele:SetAttribute(attr,value)
	ele:Release()
	doc:Release()
	return true
end

--[[
����:��ȡhtmlԪ�ص�����
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
����:�ж�htmlԪ���Ƿ����
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
����:��ȡ�������html�ı�
]]
function _wclient:get_html()
	local doc = self:get_document()
	local str = doc.html
	doc:Release()
	return str
end

--[[
����:��ȡ���������Ƕ�ı�
]]
function _wclient:get_text()
	local doc = self:get_document()
	local str = doc.text
	doc:Release()
	return str
end

--[[
����:��ȡ�����ʵ��
]]
function _wclient:get_browser()
	return self.client
end

--[[
����:��ȡ�������html�ĵ�����
]]
function _wclient:get_document()
	return self.client:GetHtmlDocument()
end

--[[
����:���htmlԪ��
]]
function _wclient:click(path)
	local doc = self:get_document()
	local ele = doc:SelectOneElement(path)
	if(ele == nil or not ele.valid) then
		doc:Release()
		return false,"Ԫ�ز�����"
	end

	ele:Click()
	ele:Release()
	doc:Release()
	return true
end

--[[
����:����html�¼�
]]
function _wclient:fire_event(path,e)
	local doc = self:get_document()
	local ele = doc:SelectOneElement(path)
	doc:Release()
	if(ele == nil or not ele.valid) then
		doc:Release()
		return false,"Ԫ�ز�����"
	end

	ele:FireEvent(e)
	ele:Release()
	doc:Release()
	return true
end

---**************ģ�����************--
--[[
����:��ȡ����cookie
]]
function _wclient:get_one_cookie(domain,cname)
	return self.client:GetCookie(domain,cname)
end

--[[
����:��ȡ��վ������cookie
]]
function _wclient:get_all_cookie(domain)
	return self.client:GetCookie(domain)
end

--[[
���ܣ�ɾ����վ������cookie
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
����:����http only���Ե�cookie
]]
function _wclient:set_httponly_cookie(domain,cname)
	self.client:SetCookie(domain,cname,0x2000)
end

--ִ��javascript
function _wclient:exec_script(script)
	self.client:Execute(script)
end

--����cookie
function _wclient:reset_cookie(domain,cookies)
	self:clear_all_cookie(domain)
	self:set_cookies(domain,cookies)

end

--����cookies
function _wclient:set_cookies(domain,cookies)
    local cnames = self:split(cookies,";")
	for i=1,#cnames do
        self.client:SetCookie(domain,cnames[i])
	end
end

--����cookie
function _wclient:set_cookie(domain,cname)
	return self.client:SetCookie(domain,cname)
end

--��ȡ
function _wclient:read(path)
	local file = io.open(path,"r")
	local data=""
	if (file) then
		data=file:read("*a")
		file:close()
	end
	return data
end

--д�ļ�
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
   ��ȡ��Ӧͷ
--]]
function _wclient:get_response_headers()
	return self.client:GetResponseHeader()
end

--[[
   ��ȡ��Ӧͷ
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
		--����ð�Ž��зָ�
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
   ��ȡ��Ӧ����
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
��ȡ��Ӧ״̬
]]
function _wclient:get_response_status()
	return self.client:GetResponseStatus()
end


function _wclient:split(text,sep,removeBlank)
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
--���alert�ĵ����Ի���
function _wclient:clear_alert_window()

end
