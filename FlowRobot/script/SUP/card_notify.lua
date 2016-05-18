require "sys"
require "custom.common.xhttp"
require "xqstring"
require "xxml"

sup_card_notify = {fields = "delivery_id,order_no", encoding = "gbk"}
sup_card_notify.card_use_status = {waiting = "20", useing = "30", used = "0", unuse = "90", exp_card = "40", unkown = "99"}
sup_card_notify.sup_card_error_code = {not_used = "10", --δʹ��
								decryption_error = "40", --����ʧ��
								other_error = "99", --��������
								card_error = "300", --���ܴ���
								partly_success = "91", --���ֳɹ�
								success = "0", --�ɹ�
								stockout = "800" --��治��
}
sup_card_notify.http = xhttp()
sup_card_notify.grs_dbg = xdbg("grs_db")
sup_card_notify.local_ip = flowlib.get_local_ip()


sup_card_notify.main = function(args)
	print("------------------֪ͨ����ϵͳ[����]------------------")
	print("1. ������")
	params = xtable.parse(args[2], 1)
	if(xobject.empty(params, sup_card_notify.fields)) then
		error(string.format("ȱ�ٲ���.�贫��:%s,�Ѵ���:%s", sup_card_notify.fields, args[2]))
		return sys.error.param_miss
	end
	params.robot_code = sup_card_notify.local_ip

	print("2. ��ȡ����ʹ�ü�¼")
	local dbg_result = sup_card_notify.grs_dbg:execute("sup.card.record_get", params)
	sup_card_notify.lifetime_save(params,"��������ȡ��"..dbg_result.result.code)
	if(dbg_result.result.code ~= sys.error.success.code) then
		return dbg_result.result
	end
	local delivery_data = dbg_result.data

	print("3. ��鿨״̬")
	local sup_error_code = sup_card_notify.get_sup_error_code(tostring(delivery_data.status))
	if(sup_error_code == nil) then
		error(string.format("��ʹ��״̬�޷���ȷת��ΪSUPϵͳ״̬,����������.�������:%s", params.delivery_id))
		sup_card_notify.lifetime_save(params, "��������顿"..sys.error.card_status_error.code)
		return sys.error.card_status_error
	end

	print("4. ��ȡ����ϵͳ������Ϣ")
	dbg_result = sup_card_notify.grs_dbg:execute("sup.system.get", delivery_data)
	if(dbg_result.result.code ~= sys.error.success.code) then
		return dbg_result.result
	end
	local sup_config = dbg_result.data

	print("5. ����http����,֪ͨ����ϵͳ��������")
	local result, process_msg = sup_card_notify.request_sup_sup_card_notify(delivery_data, sup_error_code, sup_config)
	local input = {delivery_id = params.delivery_id,
					order_no = delivery_data.order_no,
					process_msg = process_msg,
					robot_code = sup_card_notify.local_ip}

	print("6. �����������")
	local lifetime_msg = "������%s��%s����������%s"
	if(result.code == sys.error.success.code) then
		dbg_result = sup_card_notify.grs_dbg:execute("sup.card.notify_success", input)
	else
		dbg_result = sup_card_notify.grs_dbg:execute("sup.card.notify_failure", input)
	end
	if(dbg_result.result.code ~= sys.error.success.code) then
		error("�����������ʧ��")
	end
	sup_card_notify.lifetime_save(params, string.format(lifetime_msg, result.code == sys.error.success.code and "�ɹ�" or "ʧ��", process_msg, dbg_result.result.code))

	return dbg_result.result
end

sup_card_notify.request_sup_sup_card_notify = function(data, sup_error_code, sup_config)
	local params = {}
	params.errorcode = sup_error_code
	params.errormsg = data.msg
	params.orderno = data.card_delivery_no
	params.partnerno = sup_config.channel_id
	params.playaccount = data.recharge_account_id
	params.state = tonumber(data.succ_face) > 0 and 0 or 1
	params.successface = data.succ_face
	local q = xqstring:new(params)
	q:sort()
	local raw = q:make({kvc = "=", sc = "&", req = true, ckey = true, encoding = sup_card_notify.encoding})..sys.decrypt_pwd(sup_config.channel_id, sup_config.token_key)
	print("SUP����ǩ��ԭ��:"..raw)
	q:add("sign", utils.md5(raw, sup_card_notify.encoding))
	local url = string.format("%s?%s", sup_config.notify_url, q:make({kvc = "=", sc = "&", req = true, ckey = true, encoding = sup_card_notify.encoding}))
	local content = sup_card_notify.http:get(url, sup_card_notify.encoding, 30000)
	print("SUP�������󷵻�����:"..tostring(content))
	if(xstring.empty(content)) then
		error("SUP�������󷵻ؿ�,url:"..url)
		return sys.error.failure, "SUP�������󷵻ؿ�"
	end
	--local result = sup_card_notify.analysis_sup_sup_card_notify_result(content)
	if(content ~= "success") then
		error(string.format("SUP�������󷵻�ʧ��.url:%s,��������:%s", url, content))
		return sys.error.failure, string.format("SUP�������󷵻�����:%s", tostring(content))
	end
	return sys.error.success, "SUP�����ɹ�"
end

sup_card_notify.get_sup_error_code = function(card_status)
	if(card_status == sup_card_notify.card_use_status.used) then
		return sup_card_notify.sup_card_error_code.success
	elseif(card_status == sup_card_notify.card_use_status.unuse) then
		return sup_card_notify.sup_card_error_code.not_used
	elseif(card_status == sup_card_notify.card_use_status.exp_card) then
		return sup_card_notify.sup_card_error_code.card_error
	end
	return nil
end

sup_card_notify.analysis_sup_sup_card_notify_result = function(content)
	local xml = xxml:load(content)
	local data = {}
	data.code = xml:get("//response/result", "innerText")
	data.msg = xml:get("//response/msg", "innerText") or content
	return data
end

--{order_no, delivery_id, content}
sup_card_notify.lifetime_save = function(params, msg)
	local params = {order_no = params.order_no or 0,
					delivery_id = params.delivery_id,
					ip = params.robot_code,
					content = msg}
	local dbg_result = sup_card_notify.grs_dbg:execute("order.lifetime.save", params)
	if(dbg_result.result.code ~= sys.error.success.code) then
		error("�������ڱ���ʧ��:"..xtable.tojson(dbg_result.result))
	end
	return dbg_result.result
end

return sup_card_notify
