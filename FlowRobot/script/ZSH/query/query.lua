require 'sys'
require 'custom.common.wclient'

delivery_query = {}

delivery_query = {fields = "query_id,order_no"}
delivery_query.CONFIG = {ip=flowlib.get_local_ip(),next_query_wait_minutes=5}
delivery_query.dbg = xdbg()
delivery_query.http = wclient()
delivery_query.query_factory = require("ZSH.query.factory")
delivery_query.card_use_status = {used='0',unuse='90',error='40',unkown='99'}
delivery_query.card_use_msg = {['0']='��ʹ��',['90']='δʹ��',['40']='������',['99']='δ֪'}

delivery_query.main = function(args)
	print("----------------������ѯ----------------")
	print("1. ���������")
	local input = xtable.parse(args[2], 1)
	if(xobject.empty(input, delivery_query.fields)) then
		print(string.format("ȱ�ٱ������, �贫��:%s, �Ѵ���:%s", delivery_query.fields, args[2]))
		return sys.error.param_miss
	end

	print("2����ȡ��������")
	local result,query_params = delivery_query.get_query_data(input) 
	if(result.code ~= sys.error.success.code) then
		return result
	end

	print("2����ʼ��ѯ")
	local result, query_result = delivery_query.get_query_result(query_params)

	print("3�������ѯ��������ݿ�")
	local result, dbg_data = delivery_query.save_query_result(query_result,result,query_params)
	if(result.code ~= sys.error.success.code) then
		return result
	end

	print("4����������������") 
	delivery_query.notify_next_flow(dbg_data.next_step_codes,query_params)
end

--- return errcode,data
delivery_query.get_query_data = function(params)
	print('�����ݿ��ȡ��ѯ����')
	local input = {query_id = params.query_id,
		wait_time = delivery_query.CONFIG.next_query_wait_minutes,
		robot_code = delivery_query.CONFIG.ip
	}
	print('input:'..xtable.tojson(input))
	local dbg_ret = delivery_query.dbg:execute("order.delivery_query.get",input)
	if(dbg_ret.result.code ~= sys.error.success.code) then
		error('��ȡʧ��:'..dbg_ret.result.code)
		delivery_query.create_order_life(params,'����ѯ��ȡ��ȡ������������')
		return dbg_ret.result
	end
	delivery_query.create_order_life(params,string.format('����ѯ��ȡ��qid:%s,ret:%s',params.query_id,dbg_ret.result.code))
	return sys.error.success, xtable.merge(dbg_ret.data, {cookies = cookies})
end

delivery_query.get_query_result = function(query_params)
	print('ȡ��ͬ�Ĳ�ѯ��ʽ(���������˺�)')
	local query_obj = delivery_query.query_factory.get_query_object(query_params.need_ext_account)

	print('���ò�ѯ��ʽ��ѯ���')
	local ret,query_result = query_obj.start_query(delivery_query.http,query_params)
	if(ret.code ~= sys.error.success.code) then
		delivery_query.create_order_life(query_params,string.format("����ѯʧ�ܡ�ret:%s,msg:%s",ret.code,ret.msg))
	end
	return ret,query_result
end

--- query_result:{up_error_code,card_use_status,success_standard,up_order_no,order_msg,card_msg}
delivery_query.save_query_result = function(query_result,result,query_params)
	print('�����ѯ���')
	local query_data = query_result
	if(query_data == nil) then
		print('Ϊ��ѯʧ��,������������')
		query_data = {up_error_code = result.code,card_use_status = delivery_query.card_use_status.unkown}
	end
	local input = {
		up_error_code = query_data.up_error_code,
		card_use_status = query_data.card_use_status,
		success_standard = query_data.success_standard or 0,

		delivery_id = query_params.delivery_id,
		up_order_no = query_data.up_order_no or '',
		up_channel_no = query_params.up_channel_no,

		query_timespan = 0, -- û��,��0
		result_source = 3,
		card_msg = delivery_query.card_use_msg[query_data.card_use_status]
	}
	print("�������:"..xtable.tojson(input))
	local dbg_ret = delivery_query.dbg:execute("order.delivery_query.save", input)
	if(dbg_ret.result.code ~= sys.error.success.code) then
		error('��ѯ����ʧ��,code:'..dbg_ret.result.code)
		delivery_query.create_order_life(query_params,
			string.format('����ѯ���桿ʧ��,ret:%s',xtable.tojson(dbg_ret.result)))
		return dbg_ret.result
	end
	delivery_query.create_order_life(query_params,
		string.format('����ѯ���桿%s,NEXT:%s',dbg_ret.result.code,tostring(dbg_ret.data.next_step_codes)))
	return dbg_ret.result, dbg_ret.data
end

delivery_query.create_order_life = function (params, content)
	print('������������')
	local input = {
		order_no = params.order_no,
		delivery_id = xstring.empty(params.delivery_id) and 0 or params.delivery_id,
		ip = delivery_query.CONFIG.ip,
		content = content
	}
	print("�������:"..xtable.tojson(input))
	local dbg_result = delivery_query.dbg:execute("order.lifetime.save", input)
	if(dbg_result.result.code ~= sys.error.success.code) then
		error('DBG_ERR�������ڱ���ʧ��')
	end
end

delivery_query.notify_next_flow = function(next_step_codes, query_info)
	if(xstring.empty(next_step_codes)) then
		print('û����һ��!')
		return true
	end
	local queues = xmq(next_step_codes)
	return queues:send({order_no = query_info.order_no,query_id = query_info.query_id,
		delivery_id = query_info.delivery_id})
end

return delivery_query