require "custom.ui.windowPathTokenStream"
require "custom.ui.windowPathMatcher"
require "custom.ui.windowPath"

windowlib={}
--��ȡ���̵����ж��㴰��
windowlib.getProcessTop = function(pid)
	local vecTemp = ui.TWindowVector()
	local vec = ui.TWindowVector()
	ui.TWindow.GetTopWindows(vecTemp)

	for i=0,vecTemp:size()-1 do
		local w = vecTemp:get(i)
		if(w == nil) then
			logerr.warn("�����˿մ���")
		else
			--[[local proc = w.process
			if(proc ~= nil and proc.id == pid) then
				vec:add(w)
			end]]
			if(pid == w.processId) then
				vec:add(w)
			end
		end
	end
	return vec
end

--��ȡ���̵����д���
windowlib.getProcessAll = function(pid)
	local vecTemp = windowlib.getProcessTop(pid)
	local vec = ui.TWindowVector()
	vec:append(vecTemp)

	for i=0,vecTemp:size()-1 do
		local w = vecTemp:get(i)
		w:GetDescendants(vec)
	end
	return vec
end

--��ȡһ��ָ�����̵����������Ĵ���
windowlib.selectOne = function(pid,path)
	local matcher = windowPath(path)
	local vec = nil
	if(matcher._isroot) then
		vec = windowlib.getProcessTop(pid)
	else
		vec = windowlib.getProcessAll(pid)
	end
	return matcher:selectOne(vec)
end

--��ȡһ��ָ�����̵����������Ĵ���
windowlib.selectAll = function(pid,path)
	local matcher = windowPath(path)
	local vec = nil
	if(matcher._isroot) then
		vec = windowlib.getProcessTop(pid)
	else
		vec = windowlib.getProcessAll(pid)
	end
	return matcher:selectAll(vec)
end

--[[
����:�ȴ������¼�
����
	pid:����ID
	path:����·��
	timeout:��ʱ
����ֵ:
	true/false
]]
windowlib.waitSingleObject = function(pid,path,timeout)
	local start = flowlib.microTime()
	while(flowlib.microTime() - start < timeout) do
		if(windowlib.selectOne(pid,path) ~= nil) then
			return true
		end
		flowlib.sleep_sync(100)
	end
	return false
end


--[[
����:�ȴ�����¼�
����
	pid:����ID
	paths:����·��(table)
	waitAll:�Ƿ�ȴ����ж���
	timeout:��ʱ
����ֵ:
	true/false
]]
windowlib.waitMultiObject = function(pid,paths,waitAll,timeout)
	local start = flowlib.microTime()
	while(flowlib.microTime() - start < timeout) do
		local bOver = true
		for i=1,#paths do
			local w = windowlib.selectOne(pid,paths[i])
			if(not waitAll) then
				if(w ~= nil) then
					return true
				end
			else
				if(w == nil) then
					bOver = false
					break
				end
			end
		end

		if(bOver) then
			return true
		end
		flowlib.sleep_sync(500)
	end
	return false
end

