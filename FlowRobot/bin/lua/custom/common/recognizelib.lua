__recognizelib={}

function __recognizelib:new(oo)
	 local o = oo or {}
	setmetatable(o,self)
	self.__index=__recognizelib
	return o
end

function recognize()
	return __recognizelib:new()
end



function __recognizelib:download(http,config)
	local data=http:download(config.url,"get",config.header,"",config.timeout)
	 if(data:size()~=0) then
		return true,data
	 end
	 return false,"验证码下载失败"
end

--保存文件到硬盘
function __recognizelib:save(path,data)
	 base.SaveFile(path,data)
end


-------------.net库-识别-----------------


--local net_params={net="test.net",value=0.5,len=0,url="",id="",result=""}
function __recognizelib:net_recognize(http,config)
	print("康自动识别程序")
	---下载验证码图片
	local d,data=__recognizelib:download(http,config)
	if(not(d)) then
		return false,data
	end
	--base.SaveFile("c:\\a\\"..loginlib.net_params.times..".bmp",data)
	---识别验证码
	 local __rec=ui.Recognizer(config.net,true)
	 local x,y=pcall(__rec.Recognize,__rec,data,config.value)
     if(x) then
		if( y==nil or string.len(y)==0 or (tonumber(config.len)~=0 and
		string.len(tostring(y))~=config.len)) then
			return false,string.format("识别失败:"..tostring(y))
		end
		config.result=y
		return true,"验证码识别成功:"..tostring(y)
	 end
	 return false,"验证码识别失败:"..tostring(y)
end


-------------异步识别-------------------

--local manual_params={save=function()
--end,get=function()end,retry_count=3,sleep=1000,url=""}
--当未设置get,save函数时
--local manual_params={retry_count=3,sleep=1000,url="",db={},order_id=0,timeout=90,path="",dbpath="",id="",result=""}

function __recognizelib:manual_recognize(http,config)
	print("本地人工校验码")
	---下载验证码图片
	local d,data=__recognizelib:download(http,config)
	if(not(d)) then
		return false,data
	end

	config.data=data
	--按配置保存
	config.save()
	--获取指定模式的数据
	for i=1,config.retry_count,1 do
		local s,v=config.get()
		if(s) then
			config.result=v
			print("验证码识别成功:"..tostring(v))
			return true
		end
		print("等待人工校验码输入,次数:"..tostring(i))
		thread.sleep(xstring.tonumber(config.sleep,1000))
	end
	print("等待校验码超时")
	return false
end


--------------三方库识别------------------------------

--local other_params={dll="",lib="",pwd="",len=0,len=0,url="",id="",result="",needlib=true}
function __recognizelib:other_recognize(http,config)
	print("第3方购买校验码")
	---下载验证码图片
	local d,data=__recognizelib:download(http,config)
	--SaveBinary("c:\\cmpay\\"..tostring(os.time())..".jpg",data)
	if(not(d)) then
		return false,data
	end
    --print("download end")
	---加载三方库
	local y=""
	if(config.needlib==false) then
		local reco = ui.OtherRecognizer(config.dll)  --dll
		local vec = data
		y =reco:DirectRecognize(vec)
	else
		local reco = ui.OtherRecognizer(config.dll,config.lib,config.pwd)  --dll,lib,密码
		local vec = data
		y =reco:Recognize(vec)
	end

	if(string.len(tostring(y))>0 and
	((xstring.tonumber(config.len,0)==0	or string.len(tostring(y))==string:tonumber(config.len)))) then
		config.result=y
		print("验证码识别成功:"..tostring(y))
		return true
	end
	print("验证码识别失败")
	return false
 end

---外部接口
 function __recognizelib:recognize(http,config)

	__recognizelib:filter(http,config)

   if(config.type==0) then  --康.net识别
		return __recognizelib:net_recognize(http,config)
	elseif(config.type==1) then  --本地人工校验码
		return __recognizelib:manual_recognize(http,config)
	elseif(config.type==2) then --三方识别
		return __recognizelib:other_recognize(http,config)
   end
end



 function __recognizelib:filter(http,config)
	---人工验证码,保存数据
   if(config.type==1 and config.save==nil) then
		config.save=function()
			--保存到硬盘
			__recognizelib:save(config.path,config.data)

			--保存到数据库
			local input=array()
			input:add(config.order_id)
			input:add(config.timeout)
			input:add(config.dbpath)
			local ret=config.db.execute("mr_sp_manual_imgcode_add",input)
			if(ret[1]=="100") then
				config.id=ret[2]
				return true
			else
				return false,"保存失败"
			end
		end
   end
	---人工验证码,获取数据
   if(config.type==1 and config.get==nil) then
		config.get=function()
			local input=array()
			input:add(config.id)
			local ret=config.db.execute("mr_sp_manual_imgcode_get",input)
			if(ret[1]=="100") then
				return true,ret[2]
			else
				return false,"获取失败"
			end
		end
   end
end

---输入字符串，分隔符，是否去除空数据
function string:split(str, separator,r)
	if(str==nil or str=="") then
		return {}
	end
	local start_index = 1
	local split_index = 1
	local output_array = {}
	while true do
	   local last_index = string.find(str, separator, start_index)
	   if not last_index then
		  output_array[split_index] = string.sub(str, start_index, string.len(str))
		break
	   end

	   local current=string.sub(str, start_index, last_index - 1)
	   if((string.len(current)>0 and r) or not(r)) then
		   output_array[split_index] =current
		   split_index = split_index + 1
	   end
	  start_index = last_index + string.len(separator)
	  if(start_index>=string.len(str) and r) then
			break
	   end
	end
	return output_array
end



