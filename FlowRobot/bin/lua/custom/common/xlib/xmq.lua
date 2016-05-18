require "xtable"
require "xstring"

_xmq = {time_out = 300000}
_xmq_multi = {time_out = 300000}

function _xmq:new(oo, settings)
	local o = oo or {}
	setmetatable(o,self)
	self.__index=self
	if(xtable.empty(settings))then
		print("ERR 请输入正确的mq配置信息")
		return
	end
	--消息队列名称[必须]暂时只设置前缀,发送者会根据不同情况去取不同的队列名称
	o.sender_queue_name_pre = settings.sender_name
	o.sender_queue_name = settings.sender_name
	--在队列中超时时间(毫秒)
	o.sender_time_out = settings.sender_time_out or _xmq.time_out
	--接收者队列名称
	o.receiver_queue_name_pre = settings.receiver_name
	o.receiver_queue_name = settings.receiver_name
	--一次取多少条数据
	o.receiver_once_count = settings.receiver_once_count or 1

	self.default_adapter = mq.MQAdapter("server0")
	self.monitor_adapter = mq.MQAdapter("server1")

	return o
end

--发送消息
function _xmq:send(data)
	if(data == nil)then
		print("ERR 消息内容不能为空")
		return false
	end
	local send_datas =  __get_send_data(data)
	--print("发送的队列:"..self.sender_queue_name)
	local result, adapter = nil
	if(__is_monitor_queue(self.sender_queue_name)) then
		adapter = self.monitor_adapter
	else
		adapter = self.default_adapter
	end
	local res = nil
	if(type(send_datas[1]) == "string") then
		res = adapter:SaveData(self.sender_queue_name, send_datas, self.sender_time_out, false)
		--if(tostring(res) ~= "0") then
			print(string.format("加入至队列结果,队列名称:%s, 消息内容:%s,超时时间:%s,结果:%s", tostring(self.sender_queue_name), xtable.tojson(send_datas),tostring(self.sender_time_out),tostring(res)))
		--end
		return true
	end
	for i,v in pairs(send_datas) do
		res = adapter:SaveData(self.sender_queue_name, v, self.sender_time_out, false)
		--if(tostring(res) ~= "0") then
			print(string.format("加入至队列结果,队列名称:%s, 消息内容:%s,超时时间:%s,结果:%s", tostring(self.sender_queue_name), xtable.tojson(v),tostring(self.sender_time_out),tostring(res)))
		--end
	end
	return true
end

--接收消息,返回lua的table类型
function _xmq:rev()
	local vec = base.StringVector()
	--print("接收的队列:"..self.receiver_queue_name)
	local ret = nil
	if(__is_monitor_queue(self.receiver_queue_name)) then
		ret = self.monitor_adapter:GetData(self.receiver_queue_name,self.receiver_once_count,vec)
	else
		ret = self.default_adapter:GetData(self.receiver_queue_name,self.receiver_once_count,vec)
	end
	if(not ret)then
		return {}
	end
	local result = {}
	for i=0,vec:size()-1,1 do
		result[#result + 1] = vec:get(i)
	end
	return result
end

function _xmq_multi:new(oo, settings)
	local o = oo or {}
	setmetatable(o, self)
	self.__index = self
	o.queues = {}
	if(not(xstring.empty(settings))) then
		settings = xstring.split(settings or "", ",")
		for i,v in pairs(settings) do
			local s = xstring.split(v, ":")
			local status, config = pcall(require, string.format("config.%s", s[1]))
			if(not(status)) then
				print(string.format("ERR mq配置文件:%s,加载失败:%s", v, config))
			elseif(config.mq == nil) then
				print(string.format("ERR mq配置文件:%s,不存在节点mq", v))
			else
				if(tonumber(s[2]) ~= nil) then
					config.mq.sender_time_out = tonumber(s[2]) * 1000
				end
				o.queues[v] = config.mq
			end
		end
	end
	self.adapter = mq.MQAdapter("server0")
	return o
end

function _xmq_multi:send(data)
	if(data == nil)then
		print("ERR 消息内容不能为空")
		return false
	end
	local send_datas = __get_send_data(data)
	local res = nil
	for i,v in pairs(self.queues) do
		if(type(send_datas[1]) == "string") then
			res = self.adapter:SaveData(v.sender_name,
										send_datas,
										v.sender_time_out or _xmq_multi.time_out,
										false)
			--if(tostring(res) ~= "0") then
				print(string.format("加入至队列结果,队列名称:%s, 消息内容:%s,超时时间:%s,结果:%s", tostring(v.sender_name), xtable.tojson(send_datas),tostring(v.sender_time_out),tostring(res)))
			--end
		else
			for a,b in pairs(send_datas) do
				res = self.adapter:SaveData(v.sender_name,
											b,
											v.sender_time_out or _xmq_multi.time_out,
											false)
				--if(tostring(res) ~= "0") then
					print(string.format("加入至队列结果,队列名称:%s, 消息内容:%s,超时时间:%s,结果:%s", tostring(v.sender_name), xtable.tojson(b),tostring(v.sender_time_out),tostring(res)))
				--end
			end
		end
	end
	return true
end

--{sender_name,sender_time_out,receiver_name,receiver_once_count}
function xmq(settings)
	if(type(settings) ~= "string" and type(settings) ~= "table") then
		print("ERR setting类型错误")
		return nil
	end
	if(type(settings) == "table") then
		return _xmq:new(nil, settings)
	end
	if(not(xstring.empty(settings)) and  string.find(settings, ",") == nil) then
		local s = xstring.split(settings,":")
		local status, config = pcall(require, string.format("config.%s", s[1]))
		if(not(status)) then
			print(string.format("mq配置文件:%s,加载失败:%s", s[1], config))
			return nil
		end
		if(tonumber(s[2]) ~= nil) then
			config.mq.sender_time_out = tonumber(s[2]) * 1000
		end
		return _xmq:new(nil, config.mq)
	end
	return _xmq_multi:new(nil, settings)
end


function __get_send_data(data)
	if(type(data) ~= "table") then
		return {data}
	end
	if(not(xtable.isarray(data))) then
		return {xtable.tojson(data)}
	end
	local send_data = {}
	local _index, _length = 0, 1000
	for i,v in pairs(data) do
		if(_length >= 1000) then
			_index = _index + 1
			send_data[_index] = {}
		end
		local s = xtable.tojson(v)
		_length = _length + #s
		table.insert(send_data[_index], s)
	end
	return send_data
end

function __is_monitor_queue(queue_name)
	return string.match(queue_name, "^monitor.+") == queue_name
end
