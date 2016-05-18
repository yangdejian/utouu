require 'sys'
require "xqstring"
require "custom.common.xhttp"

xuanjie_query = {}
xuanjie_query = {fields="query_id,order_no",encode="UTF-8",pre_code='XUANJIE_Q_'}
xuanjie_query.CONFIG = {ip=flowlib.get_local_ip(),next_query_wait_minutes=5,result_source=3}
xuanjie_query.response_fmt = {json=1,xml=2,split=3} -- ���������ظ�ʽ:3:Ϊ�ַ���ƴ�ӣ��ɡ�|���ָ���

xuanjie_query.dbg 	= xdbg()
xuanjie_query.http = xhttp()

xuanjie_query.main = function(args)
	print("----------------�������Žݡ�������ѯ ----------------")
	print("�������������")
	local input = xtable.parse(args[2], 1)
	if(xobject.empty(input, xuanjie_query.fields)) then
		error("ȱ�ٱ������:"..xuanjie_query.fields)
		return sys.error.param_miss
	end

	print("�����η��������̡�")
	local result,data,content = xuanjie_query.main_flow(input)

	print("��������ɵ��������ڡ�")
	xuanjie_query.create_order_life(xtable.merge(input,data),content)

	print("���̽���:"..result.code)
end

xuanjie_query.main_flow = function(params)
	print("1����ȡ��������")
	local result,query_params = xuanjie_query.get_query_data(params) 
	if(result.code ~= sys.error.success.code) then
		return result,{},'����ѯ��ȡ��ʧ��:'..result.code
	end

	print("2����ʼ��ѯ")
	local query_result = xuanjie_query.get_query_result(query_params)

	print("3�������ѯ��������ݿ�")
	local result,dbg_data = xuanjie_query.save_query_result(query_result,query_params)
	if(result.code ~= sys.error.success.code) then
		return result,query_params,'����ѯ���桿ʧ��:'..result.code
	end

	print("4����������������") 
	if(not xstring.empty(dbg_data.next_step_codes)) then
		xuanjie_query.notify_next_flow(dbg_data.next_step_codes,query_params)
	end

	return result,query_params,string.format('����ѯ���桿�ɹ�(%s),NEXT:%s',
		query_result.result_msg,tostring(dbg_data.next_step_codes))
end

--- return errcode,data
xuanjie_query.get_query_data = function(params)
	local return_data = {}

	print('��ȡ��������Ϣ')
	local input = {query_id = params.query_id,
		wait_time = xuanjie_query.CONFIG.next_query_wait_minutes,
		robot_code = xuanjie_query.CONFIG.ip
	}
	local dbg_ret = xuanjie_query.dbg:execute("order.delivery_query.get",input)
	if(dbg_ret.result.code ~= sys.error.success.code) then
		error('DBG-ERR:��ȡ������Ϣʧ��,input:'..xtable.tojson(input))
		return dbg_ret.result
	end
	return_data = xtable.merge(return_data,dbg_ret.data)

	print('��ȡ��ѯ��ַ����Ϣ')
	local db_ret = xuanjie_query.dbg:execute("order.delivery_query.get_query_config",dbg_ret.data)
	if(db_ret.result.code ~= sys.error.success.code) then
		error('DBG-ERR:��ȡ��ѯ��ַ��Ϣʧ��,params:'..xtable.tojson(dbg_ret.data))
		return db_ret.result
	end
	return_data = xtable.merge(return_data,db_ret.data)

	xuanjie_query.create_order_life(return_data,string.format('����ѯ��ȡ��qid:%s,ret:%s',params.query_id,dbg_ret.result.code))
	return dbg_ret.result,return_data
end

xuanjie_query.get_query_result = function(params)
	local response = {}
	local q = xqstring:new()
	local real_key = sys.decrypt_pwd(params.up_channel_no,params.token_key)

	print('2.1 ����ǩ����post_data')
	q:add("orderno",params.delivery_id)
	q:add("username",params.account_name)
	q:add("rtntype",xuanjie_query.response_fmt.json)
	q:add("key",real_key)

	local raw = q:make({kvc="=",sc="&",req=true,ckey=true,encoding=xuanjie_query.encode})
	debug('raw:'..raw)
	local sign = string.lower(xutility.md5.encrypt(raw,xuanjie_query.encode))
	debug('sign:'..sign)

	q:remove("key")
	q:add("sign",sign)
	local post_data = q:make({kvc="=",sc="&",req=true,ckey=true,encoding=xuanjie_query.encode})
	print('post_data:'..post_data)

	print('2.1 �����ѯ�ӿ�')
	local url = params.query_url..'?'..post_data
	print('url:'..url)
	local content = xuanjie_query.http:get(url,xuanjie_query.encode)
	print("content:"..content)

	print('2.2 ������ѯ���')
	if(xstring.empty(content)) then
		response.up_error_code = xuanjie_query.get_up_error_code(sys.error.response_empty.code)
		error('��ѯ�ӿڷ��ؿ�')
		return response
	end
	if(not xstring.start_with(content,'{') or not xstring.end_with(content,'}')) then
		response.up_error_code = xuanjie_query.get_up_error_code(sys.error.response_fmt_error.code)
		error('�µ��ӿ���Ӧ��ʽ����(���ط�Json����)')
		return response
	end

	local data = xtable.parse(content)
	local up_error_code = string.format('%s_%s',tostring(data.nrtn),tostring(data.flag))
	
	response.up_error_code = xuanjie_query.get_up_error_code(up_error_code)
	print('response:'..xtable.tojson(response))
	return response
end

--- query_result:{up_error_code,card_use_status,success_standard,up_order_no,order_msg,card_msg}
xuanjie_query.save_query_result = function(query_result,query_params)
	print('�����ѯ���')
	local input = {
		up_error_code = query_result.up_error_code,
		success_standard = xstring.empty(query_result.success_standard) and 0 or query_result.success_standard,
		delivery_id = query_params.delivery_id,
		up_order_no = xstring.empty(query_result.up_order_no) and 0 or query_result.up_order_no,
		up_channel_no = query_params.up_channel_no,
		result_source = xuanjie_query.CONFIG.result_source,
		result_msg = query_result.result_msg
	}
	local dbg_ret = xuanjie_query.dbg:execute("order.delivery_query.save", input)
	if(dbg_ret.result.code ~= sys.error.success.code) then
		error('��ѯ����ʧ��,code:'..dbg_ret.result.code)
		error('input:'..xtable.tojson(input))
		return dbg_ret.result
	end
	return dbg_ret.result, dbg_ret.data
end

xuanjie_query.create_order_life = function (params, content)
	print('������������')
	local input = {order_no = params.order_no,
		delivery_id = xstring.empty(params.delivery_id) and 0 or params.delivery_id,
		ip = xuanjie_query.CONFIG.ip,
		content = content}
	local dbg_result = xuanjie_query.dbg:execute("order.lifetime.save", input)
	if(dbg_result.result.code ~= sys.error.success.code) then
		error('DBG_ERR�������ڱ���ʧ��')
		error("input:"..xtable.tojson(input))
	end
end

xuanjie_query.notify_next_flow = function(next_step_codes, query_info)
	if(xstring.empty(next_step_codes)) then
		error('û����һ��!')
		return true
	end
	local queues = xmq(next_step_codes)
	local ret = queues:send(query_info)
	print(ret and '������гɹ�' or '�������ʧ��')
end

xuanjie_query.get_up_error_code = function(code)
	return xuanjie_query.pre_code..code
end

return xuanjie_query