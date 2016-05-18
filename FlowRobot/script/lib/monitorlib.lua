monitorlib = {__data = {}, __last_time = 0}

--result:{
--������:code
--��Ϣ:msg
--}
--params:{
--����������:name���ݲ㷽������(�ش�) ��-down_request
--���ʱ��:time
--�������:channel_no,down_channel_no,up_channel_no
--ʡ�ݱ��:province_no
--���:product_standard,standard
--�澯����:warning_type(�澯��رش�)
--������:total_count,count
--�ܽ��:total_amount,amount
--ʧ������:fail_count
--ʧ�ܽ��:fail_amount
--δ֪����:unkown_count
--����:title
--����:desc(ʧ����δ֪ʱ������Ϊresult.msg)
--}
monitorlib.save = function(result, params)
	pcall(monitorlib.__save, result, params)
end

monitorlib.system_monitor = function(params)
	params.name = "system"
	pcall(monitorlib.__save, nil, params)
end

monitorlib.__save = function(result,params)
	--������
	if(not(sys.open_monitor)) then
		return
	end
	if(xstring.empty(params.name)) then
		print("ERR monitorlib.saveȱ�ٱ������name")
		return
	end

	--��������
	local input = {}
	input.monitor_time = tonumber(params.time) or tonumber(xdate:now():format("yyyyMMddhhmmss"))
	input.channel_no = params.channel_no or params.down_channel_no or params.up_channel_no or "-"
	input.province_no = params.province_no or 0
	input.product_standard = params.product_standard or params.standard or 0
	input.warning_type = params.warning_type or 0
	input.total_count = params.total_count or params.count or 0
	input.total_amount = params.total_amount or params.amount or 0
	input.robot_code = flowlib.get_local_ip()
	if(result ~= nil) then
		if(result.code == sys.error.success.code) then
			--params.name = params.name.."_success"
			input.total_count = input.total_count == 0 and 1 or input.total_count
		elseif(result.code == sys.error.system_busy.code) then
			--params.name = params.name.."_unknown"
			input.unkown_count = params.unkown_count or input.total_count
			input.desc = params.desc or result.msg
		else
			--params.name = params.name.."_fail"
			input.fail_count = params.fail_count or input.total_count
			input.fail_amount = params.fail_amount or input.total_amount
			input.desc = params.desc or result.msg
		end
	end

	--��������������ݼ���
	table.insert(monitorlib.__data, xtable.merge(params, input))

	--����Ƿ���Ҫ����������
	if(not(monitorlib.__can_send())) then
		return
	end

	--���Ͷ���
	monitorlib.__send()
end

monitorlib.__can_send = function()
	return (#monitorlib.__data >= sys.monitor_store_number) or ((monitorlib.__last_time + sys.monitor_store_time) <= os.time())
end

monitorlib.__send = function()
	monitorlib.__last_time = os.time()
	local mq_adapter = xmq("monitor")
	local data = monitorlib.__get_send_data()
	print("��������ض����е���������:"..tostring(#data))
	mq_adapter:send(xtable.tojson(data))
end

monitorlib.__get_send_data = function()
	local data = {}
	for i=1,sys.monitor_store_number,1 do
		data[i] = monitorlib.__data[1]
		table.remove(monitorlib.__data, 1)
	end
	return data
end

return monitorlib
