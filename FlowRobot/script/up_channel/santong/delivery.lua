require "sys"
require "custom.common.xhttp"

santong_delivery = {fields = "delivery_id,order_no",
					encoding = "utf-8",
					pre_code = "SANTONG_D_",
					result_source = 2,
					local_ip = flowlib.get_local_ip(),
					up_succ_code = "00000"}
santong_delivery.grs_dbg = xdbg("grs_db")
santong_delivery.http = xhttp()

santong_delivery.main = function(args)
	print("------------------���η���(��ͨ)------------------")
	print("1. ������")
	local params = xtable.parse(args[2], 1)
	if(xobject.empty(params, santong_delivery.fields)) then
		error(string.format("ȱ�ٲ���.�贫��:%s,�Ѵ���:%s", santong_delivery.fields, args[2]))
		return sys.error.param_miss
	end
	params.robot_code = santong_delivery.local_ip

	print("2. ��ȡ��������")
	local result, delivery_data = santong_delivery.get_delivery_data(params)
	santong_delivery.lifetime_save(params, "��������ȡ��"..tostring(result.code))
	if(result.code ~= sys.error.success.code) then
		return result
	end
	params = xtable.merge(params, delivery_data)

	print("3. �ύ���η�������")
	result = santong_delivery.request_up_delivery(params)
	santong_delivery.lifetime_save(params, string.format("�����������%s|%s", result.code, result.msg))

	print("4. ���淢�����")
	result, params.next_step_data = santong_delivery.delivery_save(result, params)
	santong_delivery.lifetime_save(params, string.format("���������桿%s��%s��", result.code, tostring(params.next_step_data and params.next_step_data.next_step)))
	if(result.code ~= sys.error.success.code) then
		return result
	end

	print("5. �����������")
	santong_delivery.next_step(params)

	return sys.error.success
end

santong_delivery.get_delivery_data = function(params)
	local dbg_result = santong_delivery.grs_dbg:execute("order.delivery.get", params)
	if(dbg_result.result.code ~= sys.error.success.code) then
		return dbg_result.result
	end
	local delivery_data = dbg_result.data

	local dbg_result = santong_delivery.grs_dbg:execute("order.delivery.get_delivery_config", delivery_data)
	if(dbg_result.result.code ~= sys.error.success.code) then
		return dbg_result.result
	end
	delivery_data = xtable.merge(delivery_data, dbg_result.data)

	return sys.error.success, delivery_data
end

santong_delivery.request_up_delivery = function(params)
	print("3.1 ��������url")
	local url = santong_delivery.builder_url(params)

	print("3.2 �ύ����")
	local content = santong_delivery.http:get(url, santong_delivery.encoding)
	print("url:"..url)
	print("content:"..tostring(content))

	print("3.3 �������ؽ��")
	if(xstring.empty(content)) then
		error("�������󷵻ؿ�.url:"..url)
		return sys.error.response_empty
	end
	local data = xtable.parse(content, 1)
	if(tostring(data.errorCode) ~= santong_delivery.up_succ_code) then
		return {code = data.errorCode, msg = data.errorDesc}
	end
	params.up_order_no = data.hfOrderNo

	return sys.error.success
end

santong_delivery.delivery_save = function(recharge_result, params)
	local input = {delivery_id = params.delivery_id,
				channel_no = params.up_channel_no,
				success_standard = 0,
				up_order_no = params.up_order_no or "",
				result_source = santong_delivery.result_source,
				result_msg = recharge_result.msg,
				query_timespan = params.query_timespan,
				robot_code = santong_delivery.local_ip}

	if(recharge_result.code == sys.error.success.code) then
		input.up_error_code = santong_delivery.get_up_error_code(santong_delivery.up_succ_code)
	elseif(recharge_result.code == sys.error.response_empty.code) then
		input.up_error_code = santong_delivery.get_up_error_code(sys.error.response_empty.code)
	else
		input.up_error_code = santong_delivery.get_up_error_code(recharge_result.code)
	end

	local dbg_result = santong_delivery.grs_dbg:execute("order.delivery.save", input)
	return dbg_result.result, dbg_result.data
end

santong_delivery.get_up_error_code = function(code)
	return santong_delivery.pre_code..string.upper(code)
end

--{order_no, delivery_id, content}
santong_delivery.lifetime_save = function(params, msg)
	local input = {order_no = params.order_no,
					delivery_id = params.delivery_id,
					ip = santong_delivery.local_ip,
					content = msg}
	local dbg_result = santong_delivery.grs_dbg:execute("order.lifetime.save", input)
	if(dbg_result.result.code ~= sys.error.success.code) then
		error("�������ڱ���ʧ��:"..xtable.tojson(dbg_result.result))
	end
	return dbg_result.result
end

santong_delivery.builder_url = function(params)
	return string.format("%s?coopId=%s&merchantOrderNo=%s&chargeNumber=%s&chargeMoney=%s&notifyUrl=%s&sign=%s",
						params.recharge_url,
						params.account_name,
						params.delivery_id,
						params.recharge_account_id,
						params.total_face,
						params.notify_url,
						santong_delivery.builder_sign(params))
end

santong_delivery.builder_sign = function(params)
	--coopId+merchantOrderNo+chargeNumber+chargeMoney+notifyUrl+secretKey
	local raw = params.account_name
				..params.delivery_id
				..params.recharge_account_id
				..params.total_face
				..params.notify_url
				..sys.decrypt_pwd(params.up_channel_no, params.token_key)
	print("ǩ��ԭ��:"..raw)
	return string.lower(xutility.md5.encrypt(raw))
end

santong_delivery.next_step = function(params)
	if(xstring.empty(params.next_step_data.next_step)) then
		return true
	end
	local queues = xmq(params.next_step_data.next_step)
	queues:send({delivery_id = params.delivery_id, order_no = params.next_step_data.order_no, query_id = params.next_step_data.query_id})
	return true
end

return santong_delivery
