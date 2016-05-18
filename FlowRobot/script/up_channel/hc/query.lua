require 'sys'
require "xqstring"
require "custom.common.xhttp"
require "custom.common.xxml"

hc_query = {}
hc_query = {fields="query_id,order_no",encode="GB2312",pre_code='HC_Q_'}
hc_query.CONFIG = {ip=flowlib.get_local_ip(),next_query_wait_minutes=5,result_source=3}

hc_query.dbg = xdbg()
hc_query.http = xhttp()
hc_query.xml = xxml()

hc_query.main = function(args)
	print("----------------���ó䡿������ѯ ----------------")
	print("�������������")
	local input = xtable.parse(args[2], 1)
	if(xobject.empty(input, hc_query.fields)) then
		error("ȱ�ٱ������:"..hc_query.fields)
		return sys.error.param_miss
	end

	print("�����η��������̡�")
	local result,data,content = hc_query.main_flow(input)

	print("��������ɵ��������ڡ�")
	hc_query.create_order_life(xtable.merge(input,data),content)

	print("���̽���:"..result.code)
end

hc_query.main_flow = function(params)
	print("1����ȡ��������")
	local result,query_params = hc_query.get_query_data(params) 
	if(result.code ~= sys.error.success.code) then
		return result,{},'����ѯ��ȡ��ʧ��:'..result.code
	end

	print("2����ʼ��ѯ")
	local query_result = hc_query.get_query_result(query_params)

	print("3�������ѯ��������ݿ�")
	local result,dbg_data = hc_query.save_query_result(query_result,query_params)
	if(result.code ~= sys.error.success.code) then
		return result,query_params,'����ѯ���桿ʧ��:'..result.code
	end

	print("4����������������") 
	if(not xstring.empty(dbg_data.next_step_codes)) then
		hc_query.notify_next_flow(dbg_data.next_step_codes,query_params)
	end

	return result,query_params,'����ѯ���桿�ɹ�,NEXT:'..tostring(dbg_data.next_step_codes)
end

--- return errcode,data
hc_query.get_query_data = function(params)
	local return_data = {}

	print('��ȡ��������Ϣ')
	local input = {query_id = params.query_id,
		wait_time = hc_query.CONFIG.next_query_wait_minutes,
		robot_code = hc_query.CONFIG.ip}
	local dbg_ret = hc_query.dbg:execute("order.delivery_query.get",input)
	if(dbg_ret.result.code ~= sys.error.success.code) then
		error('DBG-ERR:��ȡ������Ϣʧ��,input:'..xtable.tojson(input))
		return dbg_ret.result
	end
	return_data = xtable.merge(return_data,dbg_ret.data)

	print('��ȡ��ѯ��ַ����Ϣ')
	local db_ret = hc_query.dbg:execute("order.delivery_query.get_query_config",dbg_ret.data)
	if(db_ret.result.code ~= sys.error.success.code) then
		error('DBG-ERR:��ȡ��ѯ��ַ��Ϣʧ��,params:'..xtable.tojson(dbg_ret.data))
		return db_ret.result
	end
	return_data = xtable.merge(return_data,db_ret.data)
	debug('return_data:'..xtable.tojson(return_data))

	hc_query.create_order_life(return_data,string.format('����ѯ��ȡ��qid:%s,ret:%s',params.query_id,dbg_ret.result.code))
	return dbg_ret.result,return_data
end

hc_query.get_query_result = function(params)
	local response = {}
	local q = xqstring:new()
	local xml = hc_query.xml
	local real_key = sys.decrypt_pwd(params.up_channel_no,params.token_key)

	print('2.1 ����ǩ����post_data')
	q:add("userid",params.account_name)
	q:add("sporderid",params.delivery_id)
	q:add("key",real_key)

	local raw = q:make({kvc="=",sc="&",req=true,ckey=true,encoding=hc_query.encode})
	debug('raw:'..raw)
	local sign = xutility.md5.encrypt(raw,hc_query.encode)
	debug('sign:'..sign)

	q:remove("key")
	q:add("sign",sign)
	q:add("ver","2.0")
	local post_data = q:make({kvc="=",sc="&",req=true,ckey=true,encoding=hc_query.encode})
	print('post_data:'..post_data)

	print('2.2 �����ѯ�ӿ�')
	local url = string.format('%s?%s',params.query_url,post_data)
	debug('url:'..url)
	local content = hc_query.http:get(url,hc_query.encode)
	print("content:"..content)

	print('2.3 ������ѯ���')
	if(xstring.empty(content)) then
		response.up_error_code = hc_query.get_up_error_code(sys.error.response_empty.code)
		error('��ѯ�ӿڷ��ؿ�')
		return response
	end
	if(not xml:load(content)) then
		response.up_error_code = hc_query.get_up_error_code(sys.error.xml_load_failure.code)
		error('��ѯ�������ʧ��')
		return response
	end

	local resultno = xml:get("//order/resultno","innerText")
	local up_order_no = xml:get("//order/orderid","innerText")

	response.up_order_no = up_order_no
	response.up_error_code = hc_query.get_up_error_code(resultno)

	print('response:'..xtable.tojson(response))
	return response
end

--- query_result:{up_error_code,card_use_status,success_standard,up_order_no,order_msg,card_msg}
hc_query.save_query_result = function(query_result,query_params)
	print('�����ѯ���')
	local input = {
		up_error_code = query_result.up_error_code,
		success_standard = xstring.empty(query_result.success_standard) and 0 or query_result.success_standard,
		delivery_id = query_params.delivery_id,
		up_order_no = query_result.up_order_no,
		up_channel_no = query_params.up_channel_no,
		result_source = hc_query.CONFIG.result_source,
		result_msg = query_result.result_msg
	}
	local dbg_ret = hc_query.dbg:execute("order.delivery_query.save", input)
	if(dbg_ret.result.code ~= sys.error.success.code) then
		error('��ѯ����ʧ��,code:'..dbg_ret.result.code)
		error('input:'..xtable.tojson(input))
		return dbg_ret.result
	end
	return dbg_ret.result, dbg_ret.data
end

hc_query.create_order_life = function (params, content)
	print('������������')
	local input = {order_no = params.order_no,
		delivery_id = xstring.empty(params.delivery_id) and 0 or params.delivery_id,
		ip = hc_query.CONFIG.ip,
		content = content}
	local dbg_result = hc_query.dbg:execute("order.lifetime.save", input)
	if(dbg_result.result.code ~= sys.error.success.code) then
		error('DBG_ERR�������ڱ���ʧ��')
		error("input:"..xtable.tojson(input))
	end
end

hc_query.notify_next_flow = function(next_step_codes, query_info)
	if(xstring.empty(next_step_codes)) then
		error('û����һ��!')
		return true
	end
	local queues = xmq(next_step_codes)
	local ret = queues:send(query_info)
	print(ret and '������гɹ�' or '�������ʧ��')
end

hc_query.get_up_error_code = function(code)
	return hc_query.pre_code..code
end

return hc_query