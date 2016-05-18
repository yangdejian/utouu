require "sys"
require "xqstring"
require "custom.common.xhttp"
require "CLRPackage"

import('SecurityCore')

--����������
jfyp_delivery = {fields="delivery_id",encode="UTF-8",pre_code='JFYP_D_'}
jfyp_delivery.config = {result_source=2,robot_code=flowlib.get_local_ip()}
jfyp_delivery.up_result_code = {success = '000000'}

jfyp_delivery.dbg = xdbg()
jfyp_delivery.http = xhttp()


jfyp_delivery.main = function(args)
	print("-------------- ��������Ʒ�����η��� ------------")

	print("��������������")
	local params=xtable.parse(args[2], 1)
	if(xobject.empty(params, jfyp_delivery.fields)) then
		print("ERR�����������")
		return sys.error.param_miss
	end
	local input = xtable.merge(params,jfyp_delivery.config)

	print("�����η��������̡�")
	local result,data,content = jfyp_delivery.main_flow(input)

	print("��������ɵ��������ڡ�")
	jfyp_delivery.create_lifetime(xtable.merge(input,data),content)

	print("���̽���:"..result.code)
end

jfyp_delivery.main_flow = function(params)

	print("1. ��ȡ������������")
	local result,delivery_info = jfyp_delivery.get_delivery_info(params)
	if(result.code ~= "success") then
		return result,{},"������������������ȡʧ��:"..result.code
	end
	delivery_info.delivery_id = params.delivery_id

	print("2. �������η���")
	local response_data = jfyp_delivery.request_order(delivery_info)

	print("3. ���淢�����")
	local result,data = jfyp_delivery.save_result(delivery_info,response_data)
	if(result.code ~= "success") then
		return result,delivery_info,string.format('������������%s',result.code)
	end

	print("4. �����������")
	if(not xstring.empty(data.next_step)) then
		jfyp_delivery.next_step(data.next_step,xtable.merge(delivery_info,data))
	end

	return sys.error.success,delivery_info,'������������success,NEXT:'..tostring(data.next_step)
end


--===================================��ȡ��������=============================================
jfyp_delivery.get_delivery_info = function(params)
	local return_data = {}

	print('��ȡ��������')
	local db_ret = jfyp_delivery.dbg:execute("order.delivery.get",params)
	if(db_ret.result.code ~= sys.error.success.code) then
		error('DBG-ERR:��ȡ��������ʧ��,params:'..xtable.tojson(params))
		return db_ret.result
	end
	return_data = xtable.merge(return_data,db_ret.data)

	print('��ȡ����������Ϣ')
	local db_ret = jfyp_delivery.dbg:execute("order.delivery.get_delivery_config",db_ret.data)
	if(db_ret.result.code ~= sys.error.success.code) then
		error('DBG-ERR:��ȡ����������Ϣʧ��,input:'..xtable.tojson(db_ret.data))
		return db_ret.result
	end
	return_data = xtable.merge(return_data,db_ret.data)

	jfyp_delivery.create_lifetime(return_data,"��������ȡ���ɹ�")
	return sys.error.success,return_data
end

--===================================��������=============================================
--��������
jfyp_delivery.request_order = function(params)
	local response = {}
	local q = xqstring:new()

	print('2.1 ����ǩ����post_data')
	q:add("P0_biztype",'mobiletopup')
	q:add("P1_agentcode",params.account_name)
	q:add("P2_mobile",params.recharge_account_id)
	q:add("P3_parvalue",params.total_standard)
	q:add("P4_productcode",params.carrier_no)
	q:add("P5_requestid",params.delivery_id)
	q:add("P6_callbackurl",params.notify_url)
	q:add("P7_extendinfo",'')

	local raw = q:make({kvc="",sc="",req=true,ckey=false,encoding=jfyp_delivery.encode})
	debug('raw:'..raw)
	local real_key = sys.decrypt_pwd(params.up_channel_no,params.token_key)
	local ret,sign = pcall(Security.Jinfeng_Hmac,raw,real_key)
	if(not ret) then
		error('����Security.Jinfeng_Hmac����ǩ��ʧ��,sign:'..tostring(sign))
		return sys.error.build_sign_failure
	end
	q:add("hmac",sign)
	local post_data = q:make({kvc="=",sc="&",req=true,ckey=true,encoding=jfyp_delivery.encode})
	print('post_data:'..post_data)

	print('2.2 �����µ��ӿ�')
	local url = params.recharge_url..'?'..post_data
	debug('url:'..url)
	local content = jfyp_delivery.http:get(url,jfyp_delivery.encode)
	print("content:"..content)

	print('2.3 �����µ����')
	if(xstring.empty(content)) then
		response.up_error_code = jfyp_delivery.get_up_error_code(sys.error.response_empty.code)
		response.result_msg = '�µ��ӿڷ��ؿ�'
		error(response.result_msg)
		return response
	end
	local s,e = string.find(content, "<html>")
	if(s ~= nil) then
		response.up_error_code = jfyp_delivery.get_up_error_code(sys.error.response_html.code)
		response.result_msg = '�µ��ӿڷ���HTML'
		error(response.result_msg)
		return response
	end

	response.up_error_code = jfyp_delivery.get_up_error_code(content)
	print('response:'..xtable.tojson(response))
	return response
end

--===================================���淢�����=============================================
--input:{delivery_id,channel_no,success_standard,result_source,result_msg,
--		query_timespan,up_error_code,robot_code}
jfyp_delivery.save_result = function(delivery_info,response_data)
	print('���淢�����')
	local input = {
		delivery_id = delivery_info.delivery_id,
		channel_no = delivery_info.channel_no,
		success_standard = xstring.empty(response_data.success_standard) and 0 or response_data.success_standard,
		result_source = jfyp_delivery.config.result_source,
		result_msg = response_data.result_msg,
		query_timespan = delivery_info.query_timespan,
		up_error_code = response_data.up_error_code,
		robot_code = jfyp_delivery.config.robot_code,
		up_order_no = xstring.empty(response_data.up_order_no) and 0 or response_data.up_order_no
	}
	local db_ret = jfyp_delivery.dbg:execute("order.delivery.save",input)
	if(db_ret.result.code ~= sys.error.success.code) then
		error('��������ʧ��:'..db_ret.result.code)
		error('�������:'..xtable.tojson(input))
		return db_ret.result
	end
	return db_ret.result,db_ret.data
end

jfyp_delivery.get_up_error_code = function(code)
	return jfyp_delivery.pre_code..code
end

--���������һ������
jfyp_delivery.next_step = function (next_step,data)
	if(xstring.empty(next_step)) then
		return
	end
	local queues = xmq(next_step)
	local result = queues:send(data)
    print(result and "������гɹ�" or "�������ʧ��")
end

--- ������������������
jfyp_delivery.create_lifetime = function (data,content)
	if(xstring.empty(data.order_no)) then
		error("������������������ʱû�ж�����")
		return
	end
	local result = jfyp_delivery.dbg:execute("order.lifetime.save",{order_no = data.order_no,
		ip = jfyp_delivery.config.robot_code,
		content = content,
		delivery_id = xstring.empty(data.delivery_id) and 0 or data.delivery_id})
	if(result.result.code ~= "success") then
		error("��Ӷ�����������������ʧ��:"..result.result.code)
	end
end

return jfyp_delivery
