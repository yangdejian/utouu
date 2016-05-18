require "sys"

up_refund = {fields = "delivery_id"}
up_refund.dbg = xdbg()
up_refund.ip = flowlib.get_local_ip()

up_refund.main = function(args)
	print("----------------------���ζ����˿�--------------------------")
	print("1.������")
	local params = xtable.parse(args[2], 1)
	if(xobject.empty(params, up_refund.fields)) then
		print(string.format("ȱ�ٱ������, �贫��:%s, �Ѵ���:%s", up_refund.fields, args[2]))
		return sys.error.param_miss
	end

	print("2.����������")
	local result,refund_info= up_refund.main_flow(params)

	--print("3.����ͳ����Ϣ")
	--up_refund.send_flow_monitor(result, refund_info)

	print("4.�����˿���������")
	up_refund.add_order_lifetime (refund_info)

	print("-----���ζ����˿����-----")
end

up_refund.main_flow = function(params)
	print("2.1. ��ȡ�����˿���Ϣ")
	local input_params = params
	input_params.robot_code = up_refund.ip
	local result,refund_info = up_refund.get_refund_info(input_params)
	input_params = xtable.merge(refund_info,input_params)
	if(not(xstring.equals(result.code, "success"))) then
		input_params.content = "�������˿�ʧ�ܡ�"..result.code
		return result,input_params
	end

	print("3.2. �����˿��")
	result = up_refund.save_refund(input_params)
	input_params.content = "�������˿�ɹ���"..result.code

	return result,input_params
end
--========================�������ں���=========================
up_refund.add_order_lifetime = function(data)
	if(xstring.empty(data.order_no)) then
		print("ERR �����������ʧ�ܣ������˿�û�д�������")
		return
	end
	local dbg_result = up_refund.dbg:execute("order.lifetime.save", {order_no = data.order_no,
																	delivery_id =not(xstring.empty(data.delivery_id)) and data.delivery_id or 0 ,
																	ip = up_refund.ip,
																	content = data.content})
	if(dbg_result.result.code ~= sys.error.success.code) then
		print("ERR �����������ʧ�ܣ�"..xtable.tojson(dbg_result))
	end

	return dbg_result
end

--=========================���̺���=============================
up_refund.get_refund_info = function(params)
	local dbg_result = up_refund.dbg:execute("up_channel.refund.get", params)
    params.content = "�������˿��ȡ��"..dbg_result.result.code
	if(dbg_result.result.code ~= sys.error.success.code) then
		print(string.format("ERR ��ȡ�˿����Ϣʧ�ܣ�%s", dbg_result.result.msg))
        params.content = "�������˿��ȡ��"..dbg_result.result.code.."��ȡ�����˿���Ϣʧ��"
	end
	up_refund.add_order_lifetime(params)
	return dbg_result.result, dbg_result.data
end

up_refund.save_refund = function(input)
	local dbg_result = up_refund.dbg:execute("up_channel.refund.save", input)
	if(dbg_result.result.code ~= sys.error.success.code) then
		print(string.format("ERR �˿������ʧ�ܣ�%s", dbg_result.result.msg))
	end
	return dbg_result.result
end

--==========================��غ���=============================
up_refund.send_flow_monitor = function(result, data)
	data = data or {}
	data.name = "up_refund"
	data.count = 1
	data.amount = data.refund_amount
	sys.monitor.save(result, data)
end

return up_refund
