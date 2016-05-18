require "sys"
require "xqstring"
require "custom.common.xhttp"

--����������
xuanjie_delivery = {fields="delivery_id",encode="UTF-8",pre_code='XUANJIE_D_'}
xuanjie_delivery.config = {result_source=2,robot_code=flowlib.get_local_ip()}
xuanjie_delivery.up_carrier_no = {ZSH=104,ZSY=105}
xuanjie_delivery.response_fmt = {json=1,xml=2,split=3} -- ���������ظ�ʽ:3:Ϊ�ַ���ƴ�ӣ��ɡ�|���ָ���

xuanjie_delivery.dbg = xdbg()
xuanjie_delivery.http = xhttp()


xuanjie_delivery.main = function(args)
	print("-------------- �������Žݡ����η��� ------------")

	print("��������������")
	local params=xtable.parse(args[2], 1)
	if(xobject.empty(params, xuanjie_delivery.fields)) then
		print("ERR�����������")
		return sys.error.param_miss
	end
	local input = xtable.merge(params,xuanjie_delivery.config)

	print("�����η��������̡�")
	local result,data,content = xuanjie_delivery.main_flow(input)

	print("��������ɵ��������ڡ�")
	xuanjie_delivery.create_lifetime(xtable.merge(input,data),content)

	print("���̽���:"..result.code)
end

xuanjie_delivery.main_flow = function(params)

	print("1. ��ȡ������������")
	local result,delivery_info = xuanjie_delivery.get_delivery_info(params)
	if(result.code ~= "success") then
		return result,{},"������������������ȡʧ��:"..result.code
	end
	delivery_info.delivery_id = params.delivery_id

	print("2. �������η���")
	local response_data = xuanjie_delivery.request_order(delivery_info)

	print("3. ���淢�����")
	local result,data = xuanjie_delivery.save_result(delivery_info,response_data)
	if(result.code ~= "success") then
		return result,delivery_info,string.format('������������%s',result.code)
	end

	print("4. �����������")
	if(not xstring.empty(data.next_step)) then
		xuanjie_delivery.next_step(data.next_step,xtable.merge(delivery_info,data))
	end

	return sys.error.success,delivery_info,'������������success,NEXT:'..tostring(data.next_step)
end


--===================================��ȡ��������=============================================
xuanjie_delivery.get_delivery_info = function(params)
	local return_data = {}

	print('��ȡ��������')
	local db_ret = xuanjie_delivery.dbg:execute("order.delivery.get",params)
	if(db_ret.result.code ~= sys.error.success.code) then
		error('DBG-ERR:��ȡ��������ʧ��,parse:'..xtable.tojson(parse))
		return db_ret.result
	end
	return_data = xtable.merge(return_data,db_ret.data)

	print('��ȡ����������Ϣ')
	local db_ret = xuanjie_delivery.dbg:execute("order.delivery.get_delivery_config",db_ret.data)
	if(db_ret.result.code ~= sys.error.success.code) then
		error('DBG-ERR:��ȡ����������Ϣʧ��,db_ret.data:'..xtable.tojson(db_ret.data))
		return db_ret.result
	end
	return_data = xtable.merge(return_data,db_ret.data)

	xuanjie_delivery.create_lifetime(return_data,"��������ȡ���ɹ�")
	return sys.error.success,return_data
end

--===================================��������=============================================
--��������
xuanjie_delivery.request_order = function(params)
	local response = {}
	local q = xqstring:new()
	local real_key = sys.decrypt_pwd(params.up_channel_no,params.token_key)

	print('2.1 ����ǩ����post_data')
	q:add("username",params.account_name)
	q:add("orderno",params.delivery_id)
	q:add("nsorttype",xuanjie_delivery.up_carrier_no[params.carrier_no])
	q:add("nproductclass",1) -- �̶� Ĭ�ϴ� 1
	q:add("nproducttype",1) -- �̶� Ĭ�ϴ� 1
	q:add("productid",'')
	q:add("szpayaccount",params.recharge_account_id)
	q:add("cost",params.product_standard)
	q:add("ncount",params.product_num)
	q:add("sztimestamp",os.date("%Y%m%d%H%M%S", os.time()))
	q:add("rtntype",xuanjie_delivery.response_fmt.json) 
	q:add("key",real_key)

	local raw = q:make({kvc="=",sc="&",req=true,ckey=true,encoding=xuanjie_delivery.encode})
	debug('raw:'..raw)
	local sign = string.lower(xutility.md5.encrypt(raw,xuanjie_delivery.encode))
	debug('sign:'..sign)

	q:remove("key")
	q:add("sznotifyurl",params.notify_url)
	q:add("sign",sign)
	local post_data = q:make({kvc="=",sc="&",req=true,ckey=true,encoding=xuanjie_delivery.encode})
	debug('post_data:'..post_data)

	print('2.2 �����µ��ӿ�')
	local url = params.recharge_url..'?'..post_data
	debug('url:'..url)
	local content = xuanjie_delivery.http:get(url,xuanjie_delivery.encode)
	print("content:"..content)

	print('2.3 �����µ����')
	if(xstring.empty(content)) then
		response.up_error_code = xuanjie_delivery.get_up_error_code(sys.error.response_empty.code)
		response.result_msg = '�µ��ӿڷ��ؿ�'
		error(response.result_msg)
		return response
	end
	if(not xstring.start_with(content,'{') or not xstring.end_with(content,'}')) then
		response.up_error_code = xuanjie_delivery.get_up_error_code(sys.error.response_fmt_error.code)
		response.result_msg = '�µ��ӿ���Ӧ��ʽ����(���ط�Json����)'
		error(response.result_msg)
		return response
	end

	local data = xtable.parse(content)
	response.result_msg = string.format('%s|%s',data.nrtn,data.szrtncode)
	response.up_error_code = xuanjie_delivery.get_up_error_code(data.nrtn)
	response.up_order_no = tostring(data.szinorder)
	print('response:'..xtable.tojson(response))
	return response
end

--===================================���淢�����=============================================
--input:{delivery_id,channel_no,success_standard,result_source,result_msg,
--		query_timespan,up_error_code,robot_code}
xuanjie_delivery.save_result = function(delivery_info,response_data)
	print('���淢�����')
	local input = {
		delivery_id = delivery_info.delivery_id,
		channel_no = delivery_info.channel_no,
		success_standard = xstring.empty(response_data.success_standard) and 0 or response_data.success_standard,
		result_source = xuanjie_delivery.config.result_source,
		result_msg = response_data.result_msg,
		query_timespan = delivery_info.query_timespan,
		up_error_code = response_data.up_error_code,
		robot_code = xuanjie_delivery.config.robot_code,
		up_order_no = xstring.empty(response_data.up_order_no) and 0 or response_data.up_order_no
	}
	local db_ret = xuanjie_delivery.dbg:execute("order.delivery.save",input)
	if(db_ret.result.code ~= sys.error.success.code) then
		error('��������ʧ��:'..db_ret.result.code)
		error('�������:'..xtable.tojson(input))
		return db_ret.result
	end
	return db_ret.result,db_ret.data
end

xuanjie_delivery.get_up_error_code = function(code)
	return xuanjie_delivery.pre_code..code
end

--���������һ������
xuanjie_delivery.next_step = function (next_step,data)
	if(xstring.empty(next_step)) then
		return
	end
	local queues = xmq(next_step)
	local result = queues:send(data)
    print(result and "������гɹ�" or "�������ʧ��")
end

--- ������������������
xuanjie_delivery.create_lifetime = function (data,content)
	if(xstring.empty(data.order_no)) then
		error("������������������ʱû�ж�����")
		return
	end
	local result = xuanjie_delivery.dbg:execute("order.lifetime.save",{order_no = data.order_no,
		ip = xuanjie_delivery.config.robot_code,
		content = content,
		delivery_id = xstring.empty(data.delivery_id) and 0 or data.delivery_id})
	if(result.result.code ~= "success") then
		error("��Ӷ�����������������ʧ��:"..result.result.code)
	end
end

return xuanjie_delivery
