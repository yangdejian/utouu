require "sys"

order_refund = {}
order_refund_config ={ fields = "order_no"}
order_refund.xdbg =  xdbg()
order_refund.ip = flowlib.get_local_ip()
order_refund.main = function(args)

	print("----------------���ζ����˿����̿�ʼ---------------")
	print("1.���ش�����")
	params =xtable.parse(args[2], 1)
	if(xobject.empty(params, order_refund_config.fields)) then
		print("ERR�����������")
		return sys.error.param_error
	end
	print("2.�����˿�������")
	local result,order,sys_result =order_refund.main_flow(params)

    --print("3.���ζ����˿�����ͳ��")
    --order_refund.send_monitor(order,result,sys_result)

	print("4.�����˿���ɵ���������")
	order_refund.add_order_lifetime(order)

	print("-----���ζ����˿��������-----")
end

order_refund.main_flow = function(params)
	local input_params=params
	print("2.1. ��ȡ�����˿�����(ȡһ��)")
	local dbg_result = order_refund.get_refund_info(input_params)
	if(not(xstring.equals(dbg_result.result.code, "success"))) then
		print("û����Ҫ�˿������orderno:"..params.order_no)
		input_params.content="���˿�ʧ�ܡ�"..dbg_result.result.code
		return dbg_result.result,input_params
    end

	print("2.2. �����˿�")
	input_params = xtable.merge(input_params,dbg_result.data)
	local refund_result = order_refund.refund_request(input_params)
	if(not(xstring.equals(refund_result.result.code, "success"))) then
		print("�˿��쳣�������"..xtable.tojson(refund_result))
		input_params.content = '���˿�ʧ�ܡ�'..refund_result.result.code
		return refund_result.result,input_params
    end

	print("2.3. �����˿���")
	local save_result =order_refund.refund_save(input_params)
	if(not(xstring.equals(save_result.result.code, "success"))) then
		print("�����˿�ʧ�ܣ������"..xtable.tojson(save_result))
		input_params.content = '���˿�ɹ���'..refund_result.result.code.."������ʧ�ܡ�"..save_result.result.code
		return refund_result.result,input_params,save_result.result
    end

    input_params.content = '���˿�ɹ���'..refund_result.result.code
	return refund_result.result,input_params
end

--===================================�������ں���===========================================
order_refund.add_order_lifetime = function(data)
	local dbg_result= order_refund.xdbg:execute("order.lifetime.save", {order_no = data.order_no,
																		delivery_id = 0,
																		ip = order_refund.ip,
																		content = data.content })
	if(dbg_result.result.code ~= sys.error.success.code) then
		print("ERR �����������ʧ�ܣ�"..xtable.tojson(dbg_result))
	end
end

--========================================���̺���================================================
order_refund.get_refund_info = function (params )
	local dbg_result = order_refund.xdbg:execute("order.refund.get_info", {order_no = params.order_no,refund_robot_code = order_refund.ip})
	order_refund.add_order_lifetime(xtable.merge(params,{content='���˿��ȡ��'..dbg_result.result.code}))
	return dbg_result
end

order_refund.refund_request = function (data )
	local dbg_result = order_refund.xdbg:execute("order.refund.refund_request", data)
	return dbg_result
end

order_refund.refund_save = function (data)
	local save_input = { refund_id = data.refund_id,refund_msg = 'success',refund_result = 0}
	local dbg_result =order_refund.xdbg:execute("order.refund.result_save", save_input)
	return dbg_result
end

--========================================��غ���================================================
--���ͼ��ͳ��
order_refund.send_monitor =function(params,result,sys_result)
	params.count = 1
	local input = xobject.clone(params,"down_channel_no>channel_no,name,count,refund_amount>amount")
    order_refund.normal_monitor(input,result)

	if(sys_result and (sys_result.code ~= sys.error.success.code)) then
		print("ϵͳ���󱣴�,������"..xtable.tojson(input))
		order_refund.sys_monitor(input,sys_result)
	end
end

--һ����
order_refund.normal_monitor=function (input,result)
	input.name = 'down_refund'
	input.desc = input.result_msg or result.msg
	sys.monitor.save(result,input)
end

--ϵͳ���
order_refund.sys_monitor=function (input ,sys_result)
	input.title="�˿�ɹ�������ʧ��"
	input.desc = sys_result.msg
	sys.monitor.system_monitor(input)
end

return order_refund
