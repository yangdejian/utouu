require "sys"

--[[
	1.��鶩��֧���������Ƿ���ڡ�״̬�Ƿ�Ϊ�ȴ�������֧��
	2.���ȴ�֧��״̬��Ϊ����֧�� �ȴ�״̬�Ľ���ʱʱ����Ϊ��ǰʱ��������
	3.֧��
	4.֧��ʧ��
		4.1���֧����ʱʱ��
			4.1.1����֧����ʱʱ�� ������״̬�˿����״̬��Ϊ���� ����Ƿ���Ҫ��֪ͨ ����֪ͨ(�ر�������֪ͨ) ����ͳ��
			4.1.2û���� ��������ȴ�������
	5.֧���ɹ� �ı䶩��״̬ ���ͷ��� ����ͳ��
]]
order_pay = {fields = "order_no"}
order_pay.pay_status = {wait = "20",ondo = "30",success = "0",fail = "90"}
order_pay.recharge_status = {wait = "20",ondo = "30",success = "0",fail = "90"}
order_pay.order_status = {onpay = "10",ondelivery = "20"}
order_pay.pay_result = {succ = 0,fail = 1}
order_pay.out_time = 5
order_pay.dbg = xdbg()
order_pay.local_ip = flowlib.get_local_ip()

order_pay.main = function(args)
	print("-----------------���ζ���֧��------------------")
	print("1. ���������")
	local params = xtable.parse(args[2], 1)
	if(xobject.empty(params, order_pay.fields)) then
		print(string.format("ȱ�ٱ������, �贫��:%s, �Ѵ���:%s", order_pay.fields, args[2]))
		return sys.error.param_miss
	end

	print("2. ����������")
	local result,pay_next_steps,payment_info = order_pay.main_flow(params)

	--print("3. ����ͳ����Ϣ")
	--order_pay.send_flow_monitor(result, xobject.clone(payment_info, "name,down_channel_no,count,amount"))

	print("4. ��¼֧����������")
	order_pay.add_order_lifetime({content = '��֧�������'..result.code..'��'..tostring(pay_next_steps)..'��'},params)

	print("------���ζ���֧�����-------")
	return
end

order_pay.main_flow = function(params)
	print("2.1.��鶩��֧��״̬")
	local result, payment_info = order_pay.check_order_pay_status(params)
	if(result.code ~= sys.error.success.code) then
		return result,'',{}
	end

	print("2.2.֧���ۿ�")
	local pay_result,next_step_codes = order_pay.payment(payment_info)
	if((pay_result.code ~= sys.error.success.code and pay_result.code ~= sys.error.balance_low.code) or xstring.empty(next_step_codes)) then
		return pay_result,next_step_codes, payment_info
	end

	print("2.3.��������������")
	order_pay.next_step(next_step_codes,params)

	return pay_result,next_step_codes,payment_info
end

--=============================�������ں���============================
order_pay.add_order_lifetime = function(data,params)
	local dbg_result = order_pay.dbg:execute("order.lifetime.save", {order_no = params.order_no,
																	delivery_id = 0,
																	ip = order_pay.local_ip,
																	content = data.content})
	if(dbg_result.result.code ~= sys.error.success.code) then
		print("ERR �����������ʧ�ܣ�"..xtable.tojson(dbg_result))
	end
	return dbg_result
end

--===============================���̺���===============================
order_pay.check_order_pay_status = function(params)
	local dbg_result = order_pay.dbg:execute("order.pay.get", {order_no = params.order_no,
															robot_code = order_pay.local_ip,
															out_time = order_pay.out_time,
															pay_status = order_pay.pay_status.ondo})
	local content = {content = '��֧����ȡ��'..dbg_result.result.code}
	if(dbg_result.result.code ~= sys.error.success.code) then
		print("ERR ����֧��״̬������֧��")
		content = {content = '��֧����ȡ��'..dbg_result.result.code.."ERR ����֧��״̬������֧��"}
	end

	order_pay.add_order_lifetime(content,params)
	return dbg_result.result, dbg_result.data
end

order_pay.payment = function(payment_info)
	local dbg_result = order_pay.dbg:execute("order.pay.obey", payment_info)
	local pay_result = order_pay.pay_result.succ
	if(dbg_result.result.code == sys.error.balance_low.code) then
		pay_result = order_pay.pay_result.fail
	elseif(dbg_result.result.code ~= sys.error.success.code) then
		print("ERR ����֧����������")
		return dbg_result.result
	end
    local return_result = dbg_result.result

	dbg_result = order_pay.dbg:execute("order.pay.save", {payment_id = payment_info.payment_id,
														pay_result = pay_result,
														pay_msg = dbg_result.result.msg,})
	if(dbg_result.result.code ~= sys.error.success.code) then
		return dbg_result.result
	end

	return return_result,dbg_result.data.next_step_codes
end

order_pay.next_step = function(next_step_codes,params)
	local queues = xmq(next_step_codes)
	local send_result = queues:send({order_no = params.order_no})
	print("֧��mq���ͽ����"..tostring(send_result))  
end

--===============================��غ���===================================
order_pay.send_flow_monitor = function(result, data)
	data = data or {}
	data.name = "down_pay"
	data.count = 1
	data.amount = data.payment_amount
	sys.monitor.save(result, data)
end

order_pay.send_system_monitor = function(msg)
	sys.monitor.system_monitor({title = "���̽ű�ִ���쳣", desc = msg})
end

return order_pay
