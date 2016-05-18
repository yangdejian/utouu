require "custom.common.utils"
require "custom.common.dblib"
_scanlib = {}

--���캯��
function _scanlib:new(oo)
	 local obj = oo or {}
	setmetatable(obj,self)
	self.__index=self
	return obj
end

--���캯��
function scanlib(inifilepath)
	local obj = _scanlib:new()
	--��ʼ������
	obj.params = {}
	obj.params.handler_cntr = utils.getIniNum("system","handlerNumber",0,"../ini/system.ini")	--����ʱ˯��ʱ��
	obj.params.idle_imeout = utils.getIniNum("scan","idle_time",1000,inifilepath)	--����ʱ˯��ʱ��
	obj.params.sleep_timeout = utils.getIniNum("scan","sleep_time",100,inifilepath)		--������˯��ʱ��
	obj.params.is_sync = utils.getIniStr("scan","is_sync","",inifilepath)				--�Ƿ���ͬ��ɨ��
	obj.params.mode = utils.getIniStr("scan","mode","",inifilepath)  				--singleΪ����ģʽ batchΪ����ģʽ
	obj.params.connectionString = utils.getIniStr("db","connection","",inifilepath)
	obj.params.prefix = utils.getIniStr("db","prefix","",inifilepath)

	--����ģʽ����
	if(obj.params.mode == "batch") then
		obj.params.batch={}
		obj.params.batch.command = obj.params.prefix .. utils.getIniStr("batch","command","",inifilepath)			--
		obj.params.batch.count_index = utils.getIniNum("batch","count_index",0,inifilepath)
		obj.params.batch.script_Index = utils.getIniNum("batch","script_index",0,inifilepath)
		local var = utils.getIniStr("batch","params","",inifilepath)
		local vars = utils.split(var,",",false)
		for i = 1,#vars do
			vars[i] = utils.trim(vars[i])
		end
		obj.params.batch.vars = vars
	else
		obj.params.single={}
		obj.params.single.error_index = utils.getIniNum("single","error_index",0,inifilepath)
		obj.params.single.suc_code    = utils.getIniStr("single","error_suc_code","",inifilepath)
		obj.params.single.script_Index = utils.getIniNum("single","script_index",0,inifilepath)
		obj.params.single.command = obj.params.prefix .. utils.getIniStr("single","command","",inifilepath)
		local var = utils.getIniStr("single","params","",inifilepath)
		local vars = utils.split(var,",",false)
		for i = 1,#vars do
			vars[i] = utils.trim(vars[i])
		end
		obj.params.single.vars = vars
	end

	return obj
end

function _scanlib:run()
	--[[print(self.params.mode)
	for i = 1,#self.params.batch.vars do
		print(self.params.batch.vars[i])
	end]]
	local sync_mode = string.lower(self.params.is_sync)
	if(sync_mode == "yes" or sync_mode == "true") then
		self:sync_loop()
	else
		self:async_loop()
	end
end

function _scanlib:sync_loop()
	while(not flowlib.is_stopped()) do
		--��ͣҲ��Ҫ�˳�
		if(flowlib.is_paused()) then
			return
		end
		--ɨ��һ��
		local r,e = pcall(self.scan_once,self)

		if(not r) then
			logger.warn("�쳣:" .. tostring(e))
			flowlib.sleep_sync(self.params.idle_imeout)
		elseif(not e) then
			flowlib.sleep_sync(self.params.idle_imeout)
		else
			flowlib.sleep_sync(self.params.sleep_timeout)
		end

		--��������
		collectgarbage("collect")
	end
end

function _scanlib:async_loop()
	while(not flowlib.is_stopped()) do
		--��ͣҲ��Ҫ�˳�
		if(flowlib.is_paused()) then
			return
		end
		--ɨ��һ��
		local r,e = pcall(self.scan_once,self)
		if(not r) then
			logger.warn("�쳣:" .. tostring(e))
			flowlib.sleep(self.params.idle_imeout)
		elseif(not e) then
			flowlib.sleep(self.params.idle_imeout)
		else
			flowlib.sleep(self.params.sleep_timeout)
		end
		--��������
		collectgarbage("collect")
	end
end

function _scanlib:scan_once()
	if(self.params.mode == "single") then
		return self:scan_single()
	elseif(self.params.mode == "batch") then
		return self:scan_batch()
	else
		return false
	end
end

function _scanlib:scan_batch()
	if(self:get_idle_cntr() <= 0) then
		return false
	end
	--ִ�����ݿ�
	local paras = self:translate(self.params.batch.vars)
	local out   = self:execute_non_query(self.params.batch.command,paras)
	--������
	if(#out < self.params.batch.count_index) then
		error("���ز���̫��")
	end

	--��ȡ��������
	local nCntr = tonumber(out[self.params.batch.count_index])
	if(nCntr <= 0) then
		return false
	end
	print(string.format("ȡ��%d������",nCntr))

	if(self.params.batch.count_index + nCntr > #out) then
		error("���ز�������:����������")
	end

	--���ݻ�ȡ�����������
	for i=1,nCntr do
		local splitParas = utils.split(out[i + self.params.batch.count_index],"@@@",false)
		if(self.params.batch.script_Index > #splitParas) then
			error("���ز������󣺽ű�λ�ò���ȷ")
		end

		local flowParas = {utils.unescape(splitParas[self.params.batch.script_Index],"/")}
		for j=1,#splitParas do
			if(j ~= self.params.batch.script_Index) then
				flowParas[#flowParas + 1] = utils.unescape(splitParas[j],"/")
			end
		end
		flowlib.start_flow(flowParas)
	end

	return true
end

function _scanlib:scan_single()
	--ִ�����ݿ�
	local paras = self:translate(self.params.single.vars)
	local out   = self:execute_non_query(self.params.single.command,paras)
	--������
	if(#out < self.params.single.error_index) then
		error("���ز���̫��")
	end

	if(out[self.params.single.error_index] ~= self.params.single.suc_code) then
		return false
	end

	if(#our < self.params.single.script_Index) then
		error("���ز���̫��:С�ڽű�����")
	end

	local flowParas = {out[self.params.single.script_Index]}
	for i=self.params.single.error_index+1,#out do
		if(i ~= self.params.single.script_Index) then
			flowParas[#flowParas + 1] = out[i]
		end
	end
	flowlib.start_flow(flowParas)
	return true
end

function _scanlib:translate(vars)
	local paras = {}
	for i=1,#vars do
		if(vars[i] == "{IP}") then
			paras[i] = flowlib.get_local_ip()
		elseif(vars[i] == "{IRC}") then
			paras[i] = tostring(self:get_idle_cntr())
		else
			paras[i] = vars[i]
		end
	end

	return paras
end

function _scanlib:get_idle_cntr()
	local n = flowlib.handlerCntr() - flowlib.flowCntr()
	if(n < 0) then
		n = 0
	end
	return n
end

function _scanlib:execute_non_query(sql,paras)
	local db = dblib(self.params.connectionString)
	local ret=db:execute_sp(sql,paras)
	return ret
end

