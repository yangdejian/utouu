
--- ���˺Ų�ѯ
--- �����ڴ��˺ų�ֵ�Ķ���,ͨ����¼�󶩵��б��ж϶�����δ���

require 'sys'

query_logined = {}
query_logined.CONFIG = {timeout = 6000}
query_logined.comm = require('ZSH.query.comm')
query_logined.pkg = require('lib.package')
query_logined.loginlib = require('lib.loginlib')
query_logined.orderStatus = {no_paid='0',pay_succeed='1',pay_failed='2'} -- =ordersuccess
query_logined.gcaStatus = {no_start='0',under_way='1',success='2',failure='3',order_not_exists='4'} --=success
query_logined.order_result = {success='PAY1_GCA2',failure='PAY2_GCA0',nodata='NODATA',unkown='UNKOWN'}
query_logined.card_use_status = {used='0',unuse='90',error='40',unkown='99'}
query_logined.card_use_msg = {['0']='USED',['90']='UNUSE',['40']='ERR',['99']='UNKOWN'}
query_logined.query_way = {by_O_C_J = 'Q_O_C_J', by_O_J = 'Q_O_J', by_C_J = 'Q_C_J'}
query_logined.prefix = 'Q1'

local function debugger(str)
	print('[QueyLogind]'..tostring(str))
end

--- return errcode,{up_error_code,success_standard,card_use_status[,up_order_no]}
query_logined.start_query = function(http,params)
	print('a. ����ֶ�')
	local require_fileds = 'delivery_time,account_id,up_shelf_id,login_name'
	if(xobject.empty(params,require_fileds)) then
		error('ȱ�ٲ���,����:%s'..xtable.tojson(params))
		return sys.error.param_miss
	end

	print('b. ��ʼ��http����')
	local result, cookies = query_logined.loginlib.get_cookies(params.up_channel_no,params.up_shelf_id,params.login_name)
	if(result.code ~= sys.error.success.code) then
		error('��ȡcookieʧ��')
		return sys.error.delivery.query.get_cookies_failed
	end
	query_logined.loginlib.clear_web_cookies(http)
	query_logined.loginlib.set_web_cookies(http, cookies)

	print('c. ��ȡ��ѯ���')
	if(tostring(params.delivery_type) == tostring(query_logined.pkg.delivery_type.kami)) then
		return query_logined.get_kami_query_result(http,params)
	end
	return query_logined.get_bank_query_result(http,params)
end

query_logined.get_kami_query_result = function (http,params)
	local query_way = ''
	local order_ret = nil
	local order_info = nil

	print('���ݲ���������в�ѯ')
	if(not xstring.empty(params.up_order_no)) then
		order_ret,query_way,order_info = query_logined.get_order_info_by_O_C_J(http,params)
		if(order_ret.code == sys.error.success.code and order_info == nil) then
			order_ret,query_way,order_info = query_logined.get_query_result_by_O_J(http,params)
		end
	else
		order_ret,query_way,order_info = query_logined.get_query_result_by_C_J(http,params)
	end


	print('���ݲ�ͬ�����,���ز�ѯ���')
	if(order_ret.code ~= sys.error.success.code) then
		return query_logined.build_query_fail_data(order_ret,http,params)
	end

	if(order_info == nil) then
		return query_logined.build_query_none_data(query_way,http,params)
	end

	return query_logined.build_query_ok_data(query_way,order_info,http,params)
end

query_logined.get_bank_query_result = function(http,params)
	local order_ret,query_way,order_info = query_logined.query_bank_order_list(http,params)
	if(order_ret.code ~= sys.error.success.code or xtable.empty(order_info)) then
		return query_logined.build_bank_query_fail_data(order_ret)
	end
	return query_logined.build_bank_query_ok_data(order_info)
end

query_logined.build_bank_query_ok_data = function(order_info)
	print('��ѯ�ɹ�,��ϴ�����')
	local deal_code = string.format("%s_PAY%sGCA%s", query_logined.prefix,tostring(order_info.orderStatus),tostring(order_info.gcaStatus))
	local return_data = {
		up_error_code = deal_code,
		success_standard = tonumber(order_info.orderMoney)/100,
		up_order_no = order_info.orderId,
		card_use_status = ""
	}
	return sys.error.success,return_data
end

query_logined.build_bank_query_fail_data = function(query_ret)
	print('��ѯʧ��,��ϴ�����')
	local deal_code = nil
	if(query_ret.code == sys.error.delivery.query.list_response_empty.code) then
		deal_code = string.format("%s_RESPONSE_EMPTY", query_logined.prefix)
	elseif(query_ret.code == sys.error.delivery.query.list_response_html.code) then
		deal_code = string.format("%s_RESPONSE_HTML", query_logined.prefix)
	else
		deal_code = string.format("%s_QUERY_OTHER_ERR", query_logined.prefix)
	end
	local return_data = {
		up_error_code = deal_code,
		success_standard = 0,
		card_use_status = ""
	}
	return query_ret,return_data
end

query_logined.build_query_ok_data = function(query_way,order_info,http,params)
	print('��ѯ�ɹ�,�ж�������,��ϴ�����')
	local is_need,card_use_status = query_logined.is_need_check_card(order_info)
	if(is_need) then
		card_use_status = query_logined.check_card(http,params.card_no)
	end
	local deal_code = string.format('%s_PAY%sGCA%s_CARD:%s',
		query_logined.prefix,tostring(order_info.orderStatus),tostring(order_info.gcaStatus),
		query_logined.card_use_msg[card_use_status])
	local return_data = {
		up_error_code = deal_code,
		success_standard = tonumber(order_info.orderMoney)/100,
		card_use_status = card_use_status,
		up_order_no = order_info.orderId
	}
	return sys.error.success,return_data
end

query_logined.build_query_none_data = function(query_way,http,params)
	print('��ѯ�ɹ�,�Ҳ�������,����������')
	local card_use_status = query_logined.check_card(http,params.card_no)
	local deal_code = string.format('%s_NODATA_CARD:%s',
		query_logined.prefix,query_logined.card_use_msg[card_use_status])
	local return_data = {
		up_error_code = deal_code,
		success_standard = 0,
		card_use_status = card_use_status
	}
	return sys.error.delivery.query.order_not_exists,return_data
end

query_logined.build_query_fail_data = function(query_ret,http,params)
	print('��ѯʧ��,�����鿨�������������')
	local deal_code = nil
	local card_use_status = query_logined.check_card(http,params.card_no)
	if(query_ret.code == sys.error.delivery.query.list_response_empty.code) then
		deal_code = string.format('%s_RESPONSE_EMPTY_CARD:%s',
			query_logined.prefix,query_logined.card_use_msg[card_use_status])
	end
	if(query_ret.code == sys.error.delivery.query.list_response_html.code) then
		deal_code = string.format('%s_RESPONSE_HTML_CARD:%s',
			query_logined.prefix,query_logined.card_use_msg[card_use_status])
	end
	if(xstring.empty(deal_code)) then
		deal_code = string.format('%s_QUERY_OTHER_ERR_CARD:%s',
			query_logined.prefix,query_logined.card_use_msg[card_use_status])
	end
	local return_data = {
		up_error_code = deal_code,
		success_standard = 0,
		card_use_status = card_use_status
	}
	return query_ret,return_data
end

query_logined.get_order_info_by_O_C_J = function(http,params)
	print('ͨ���˺�+������+��ֵ����ѯ...')
	local query_way = query_logined.query_way.by_O_C_J
	local request_input = query_logined.get_request_header_J_O_C(params)
	print('header:'..xtable.tojson(request_input))
	local content = http:query(request_input, {}, query_logined.CONFIG.timeout)
	debugger('���󷵻�:'..tostring(content))
	local result = query_logined.check_response_content(content)
	if(result.code ~= sys.error.success.code) then
		return result,query_way
	end
	local response_obj = xtable.parse(content)
	return sys.error.success,query_way,response_obj.czkOrderList[1]
end

query_logined.get_query_result_by_O_J = function(http,params)
	print('ͨ��������+�˺Ų�ѯ...')
	local query_way = query_logined.query_way.by_O_J
	local request_input = query_logined.get_request_header_O_J(params)
	print('header:'..xtable.tojson(request_input))
	local content = http:query(request_input, {}, query_logined.CONFIG.timeout)
	debugger('���󷵻�:'..tostring(content))
	local result = query_logined.check_response_content(content)
	if(result.code ~= sys.error.success.code) then
		return result,query_way
	end
	local response_obj = xtable.parse(content)
	return sys.error.success,query_way,response_obj.czkOrderList[1]
end

query_logined.query_bank_order_list = function(http,params)
	print('ͨ��������+�˺Ų�ѯ...')
	local query_way = query_logined.query_way.by_O_J
	local request_input = query_logined.get_request_header_O_J(params)
	print('header:'..xtable.tojson(request_input))
	local content = http:query(request_input, {}, query_logined.CONFIG.timeout)
	debugger('���󷵻�:'..tostring(content))
	local result = query_logined.check_response_content(content)
	if(result.code ~= sys.error.success.code) then
		return result,query_way
	end
	local response_obj = xtable.parse(content)
	return sys.error.success,query_way,response_obj.unionOrderList[1]
end

query_logined.get_query_result_by_C_J = function(http,params)
	print('ͨ���˺�+��ֵ����ѯ...')
	local query_way = query_logined.query_way.by_C_J
	local request_input = query_logined.get_request_header_C_J(params)
	print('header:'..xtable.tojson(request_input))
	local content = http:query(request_input, {}, query_logined.CONFIG.timeout)
	debugger('���󷵻�:'..tostring(content))
	local result = query_logined.check_response_content(content)
	if(result.code ~= sys.error.success.code) then
		return result,query_way
	end
	local response_obj = xtable.parse(content)
	return sys.error.success,query_way,response_obj.czkOrderList[1]
end

query_logined.check_response_content = function (content)
	if(xstring.empty(content)) then
		error("��ѯʧ��,���󷵻ؿ�")
		return sys.error.delivery.query.list_response_empty
	end
	if(query_logined.comm.is_html(content)) then
		error("��ѯʧ��,����html:"..tostring(content))
		return sys.error.delivery.query.list_response_html
	end
	return sys.error.success
end

query_logined.check_card = function (http, card_no)
	print('��ѯ�鿨�ӿ�')
	local request_input = query_logined.comm.get_card_query_header('czkNo='..card_no)
	local content = http:query(request_input, {}, query_logined.CONFIG.timeout)
	debugger('���󷵻�:'..tostring(content))
	if(xstring.empty(content) or query_logined.comm.is_html(content)) then
		error('�鿨ʧ��,����:'..tostring(content))
		return query_logined.card_use_status.unkown
	end

	local obj = xtable.parse(content)
	print('�����鿨������')
	if(obj.czkUseStatus == "��ʹ��") then
		return query_logined.card_use_status.used
	end
	if(obj.czkUseStatus == "δʹ��") then
		return query_logined.card_use_status.unuse
	end
	if(obj.czkUseStatus == "error") then
		return query_logined.card_use_status.error
	end
	print("�����µĿ�״̬,czkUseStatus:"..tostring(obj.czkUseStatus))
	return query_logined.card_use_status.unkown
end

query_logined.is_need_check_card = function(order_info)
	print('����Ƿ���Ҫ�鿨')
	if(query_logined.is_sure_success(order_info)) then
		return false, query_logined.card_use_status.used
	end
  	return true
end

--- �ж϶����Ƿ�ɹ�
--- order_info="phoneNo":"15828680877","cardNo":"1000115100001625079","orderSource":1,"gcaStatus":2,"compName":"������","province":"�Ĵ�","orderTime":"2016-02-18 17:41:04","orderMoney":10000,"gcaTime":"2016-02-18 17:41:06","orderStatus":1,"orderId":"2116021817413225","bankAccount":"2510440002369251"
query_logined.is_sure_success = function(order_info)
	if(tostring(order_info.orderStatus) == query_logined.orderStatus.pay_succeed
		and tostring(order_info.gcaStatus) == query_logined.gcaStatus.success) then
		return true
	end
	return false
end

--- �ж϶����Ƿ�ʧ��
--- order_info="phoneNo":"15828680877","cardNo":"1000115100001625079","orderSource":1,"gcaStatus":0,"compName":"������","province":"�Ĵ�","orderTime":"2016-02-24 10:30:18","orderMoney":0,"orderStatus":2,"orderId":"2116022410308561"
query_logined.is_sure_failure = function(order_info)
	if(tostring(order_info.orderStatus) == query_logined.orderStatus.pay_failed
		and tostring(order_info.gcaStatus) == query_logined.gcaStatus.no_start) then
		return true
	end
	return false
end

query_logined.get_request_header_C_J = function(params)
	return query_logined.get_request_header_J_O_C(params)
end

query_logined.get_request_header_O_J = function(params)
	return query_logined.get_request_header_J_O_C(params)
end

query_logined.get_request_header_J_O_C = function(params)
	local date = xdate:new(params.delivery_time,'yyyyMMddHHmmss')
	local s_date = date:adddays(-1):format('yyyy-MM-dd')
	local e_date = date:adddays(2):format('yyyy-MM-dd')
	local post_data = 'startDate='..s_date
		..'&endDate='..e_date
		..'&orderSource='..'' -- ������Դ:��վ/�ֻ�
		..'&orderCardNo='..(params.account_id or '') -- ���Ϳ�����
		..'&queryOrderId='..(params.up_order_no or '') -- ������
		..'&page.pageNo=1'

	if(tostring(params.delivery_type) == tostring(query_logined.pkg.delivery_type.kami)) then
		post_data = post_data..'&czkCardNo='..(params.card_no or '') -- ��ֵ������
		debug('post_data:'..post_data)
		return query_logined.comm.get_kami_order_list_query_header(post_data)
	end
	post_data = post_data..'&isPref=false'
	debug('post_data:'..post_data)
	return query_logined.comm.get_bank_order_list_query_header(post_data)
end

return query_logined
