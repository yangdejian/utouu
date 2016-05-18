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
	 return false,"��֤������ʧ��"
end

--�����ļ���Ӳ��
function __recognizelib:save(path,data)
	 base.SaveFile(path,data)
end


-------------.net��-ʶ��-----------------


--local net_params={net="test.net",value=0.5,len=0,url="",id="",result=""}
function __recognizelib:net_recognize(http,config)
	print("���Զ�ʶ�����")
	---������֤��ͼƬ
	local d,data=__recognizelib:download(http,config)
	if(not(d)) then
		return false,data
	end
	--base.SaveFile("c:\\a\\"..loginlib.net_params.times..".bmp",data)
	---ʶ����֤��
	 local __rec=ui.Recognizer(config.net,true)
	 local x,y=pcall(__rec.Recognize,__rec,data,config.value)
     if(x) then
		if( y==nil or string.len(y)==0 or (tonumber(config.len)~=0 and
		string.len(tostring(y))~=config.len)) then
			return false,string.format("ʶ��ʧ��:"..tostring(y))
		end
		config.result=y
		return true,"��֤��ʶ��ɹ�:"..tostring(y)
	 end
	 return false,"��֤��ʶ��ʧ��:"..tostring(y)
end


-------------�첽ʶ��-------------------

--local manual_params={save=function()
--end,get=function()end,retry_count=3,sleep=1000,url=""}
--��δ����get,save����ʱ
--local manual_params={retry_count=3,sleep=1000,url="",db={},order_id=0,timeout=90,path="",dbpath="",id="",result=""}

function __recognizelib:manual_recognize(http,config)
	print("�����˹�У����")
	---������֤��ͼƬ
	local d,data=__recognizelib:download(http,config)
	if(not(d)) then
		return false,data
	end

	config.data=data
	--�����ñ���
	config.save()
	--��ȡָ��ģʽ������
	for i=1,config.retry_count,1 do
		local s,v=config.get()
		if(s) then
			config.result=v
			print("��֤��ʶ��ɹ�:"..tostring(v))
			return true
		end
		print("�ȴ��˹�У��������,����:"..tostring(i))
		thread.sleep(xstring.tonumber(config.sleep,1000))
	end
	print("�ȴ�У���볬ʱ")
	return false
end


--------------������ʶ��------------------------------

--local other_params={dll="",lib="",pwd="",len=0,len=0,url="",id="",result="",needlib=true}
function __recognizelib:other_recognize(http,config)
	print("��3������У����")
	---������֤��ͼƬ
	local d,data=__recognizelib:download(http,config)
	--SaveBinary("c:\\cmpay\\"..tostring(os.time())..".jpg",data)
	if(not(d)) then
		return false,data
	end
    --print("download end")
	---����������
	local y=""
	if(config.needlib==false) then
		local reco = ui.OtherRecognizer(config.dll)  --dll
		local vec = data
		y =reco:DirectRecognize(vec)
	else
		local reco = ui.OtherRecognizer(config.dll,config.lib,config.pwd)  --dll,lib,����
		local vec = data
		y =reco:Recognize(vec)
	end

	if(string.len(tostring(y))>0 and
	((xstring.tonumber(config.len,0)==0	or string.len(tostring(y))==string:tonumber(config.len)))) then
		config.result=y
		print("��֤��ʶ��ɹ�:"..tostring(y))
		return true
	end
	print("��֤��ʶ��ʧ��")
	return false
 end

---�ⲿ�ӿ�
 function __recognizelib:recognize(http,config)

	__recognizelib:filter(http,config)

   if(config.type==0) then  --��.netʶ��
		return __recognizelib:net_recognize(http,config)
	elseif(config.type==1) then  --�����˹�У����
		return __recognizelib:manual_recognize(http,config)
	elseif(config.type==2) then --����ʶ��
		return __recognizelib:other_recognize(http,config)
   end
end



 function __recognizelib:filter(http,config)
	---�˹���֤��,��������
   if(config.type==1 and config.save==nil) then
		config.save=function()
			--���浽Ӳ��
			__recognizelib:save(config.path,config.data)

			--���浽���ݿ�
			local input=array()
			input:add(config.order_id)
			input:add(config.timeout)
			input:add(config.dbpath)
			local ret=config.db.execute("mr_sp_manual_imgcode_add",input)
			if(ret[1]=="100") then
				config.id=ret[2]
				return true
			else
				return false,"����ʧ��"
			end
		end
   end
	---�˹���֤��,��ȡ����
   if(config.type==1 and config.get==nil) then
		config.get=function()
			local input=array()
			input:add(config.id)
			local ret=config.db.execute("mr_sp_manual_imgcode_get",input)
			if(ret[1]=="100") then
				return true,ret[2]
			else
				return false,"��ȡʧ��"
			end
		end
   end
end

---�����ַ������ָ������Ƿ�ȥ��������
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



