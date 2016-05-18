require "bit"
require "sys"
require "custom.common.wclient"
require "custom.common.recognizelib"
require "lib.loginlib"

order_delivery = {fields = "delivery_id",
				encoding = "gbk",
				domain = "http://www.sinopecsales.com",
				send_sms_code_limit = 2,
				wait_smsras_code_limit = 3,
				download_number_code_limit = 3}
order_delivery.deal_code = {success = "000", failure = "100", unkown = "900"}
order_delivery.card_use_status = {waiting = 20, useing = 30, used = 0, unuse = 90, exp_card = 40, unkown = 99}
order_delivery.gasoline_card_archive_status = {normal = 0, --����
											sub            = 1, --����,
											lose           = 2, --��ʧ
											damage         = 3, --��
											discard        = 4, --����
											card_exception = 5, --���쳣
											expire         = 6, --������
											not_exists     = 9  --���Ų�����
											}
order_delivery.http = wclient()
order_delivery.recognize = recognize()
order_delivery.grs_dbg = xdbg("grs_db")
order_delivery.sms_dbg = xdbg("sms_db")


order_delivery.main = function(args)
	print("------------------���η���------------------")
	print("1. ������")
	order_delivery.params = xtable.parse(args[2], 1)
	if(xobject.empty(order_delivery.params, order_delivery.fields)) then
		error(string.format("ȱ�ٲ���.�贫��:%s,�Ѵ���:%s", order_delivery.fields, args[2]))
		return sys.error.param_miss
	end
	order_delivery.params.robot_code = flowlib.get_local_ip()
	order_delivery.params.__send_sms_code_times = 0

	print("2. ��ʼ����")
	local recharge_result, up_order_info, query_result, up_order_query_info = order_delivery.delivery_flow()
	if(recharge_result.code == sys.error.order.no_need_delivery.code) then
		error("�������跢��,���̽���")
		return recharge_result
	end

	print("3. ���淢�����")
	local result, next_step_data = order_delivery.delivery_save(recharge_result, up_order_info, query_result, up_order_query_info)
	if(result.code ~= sys.error.success.code) then
		error("���淢�����ʧ��")
		return result
	end

	print("4. �����������")
	order_delivery.next_step(next_step_data)

	return sys.error.success
end

order_delivery.delivery_flow = function()
	print("��ȡ��������")
	local result = order_delivery.get_delivery_data()
	if(result.code ~= sys.error.success.code) then
		return result
	end

	print("��ȡ��վ��¼Cookie")
	result = order_delivery.get_web_login_data()
	if(result.code ~= sys.error.success.code) then
		error("��ȡ��վ��¼Cookieʧ��.�޷����к�����������")
		return result
	end

	print("����Ƿ���Ҫ�鿨")
	if(tostring(order_delivery.delivery_data.need_check_card) == "0") then
		result = order_delivery.verify_card({card_no = order_delivery.delivery_data.card_no})
		if(result.code ~= sys.error.delivery.recharge_card_normal.code) then
			return result
		end
	end

	::send_sms_code::
	print("��ȡ������֤��")
	local sms_code, number_code, user_card_staus, user_card_info = nil
	order_delivery.params.__send_sms_code_times = order_delivery.params.__send_sms_code_times + 1
	order_delivery.params.__download_number_code_times = 0
	result, user_card_status, sms_code = order_delivery.get_sms_code({recharge_account_id = order_delivery.delivery_data.recharge_account_id,
													validcode_mobile = order_delivery.delivery_data.validcode_mobile,
													up_shelf_id = order_delivery.delivery_data.up_shelf_id})
	if(result.code == sys.error.delivery.user_card_cannot_recharge.code) then
		print("�����Ϳ���Ϣ������������Ϳ���ϢMQ��")
		result = order_delivery.join_to_card_info_save_mq(user_card_status, user_card_info)
		return result
	elseif(result.code ~= sys.error.success.code) then
		return result
	end

	print("������ʯ����ѯ���Ϳ���Ϣ����")
	result, user_card_status, user_card_info = order_delivery.request_query_card_info({recharge_account_id = order_delivery.delivery_data.recharge_account_id,
																					validcode_mobile = order_delivery.delivery_data.validcode_mobile,
																					sms_code = sms_code})
	if(result.code == sys.error.delivery.sms_code_error.code) then
		if(order_delivery.params.__send_sms_code_times < order_delivery.send_sms_code_limit) then
			goto send_sms_code
		else
			return result
		end
	elseif(result.code == sys.error.success.code) then
		print("�����Ϳ���Ϣ������������Ϳ���ϢMQ��")
		result = order_delivery.join_to_card_info_save_mq(user_card_status, user_card_info)
	else
		return result
	end

	::get_number_code::
	print("��ȡ������֤��")
	order_delivery.params.__download_number_code_times = order_delivery.params.__download_number_code_times + 1
	result, number_code = order_delivery.get_number_code()
	if(result.code ~= sys.error.success.code) then
		if(order_delivery.params.__download_number_code_times < order_delivery.download_number_code_limit) then
			goto get_number_code
		else
			return result
		end
	end

	print("������ʯ����ֵ����")
	local recharge_result, up_order_info = order_delivery.request_recharge({recharge_account_id = order_delivery.delivery_data.recharge_account_id,
															card_pwd = order_delivery.delivery_data.card_pwd,
															validcode_mobile = order_delivery.delivery_data.validcode_mobile,
															number_code = number_code,
															sms_code = sms_code})
	if(recharge_result.code == sys.error.delivery.sms_code_error.code) then
		if(order_delivery.params.__send_sms_code_times < order_delivery.send_sms_code_limit) then
			goto send_sms_code
		else
			return recharge_result
		end
	elseif(recharge_result.code == sys.error.delivery.number_code_error.code) then
		if(order_delivery.params.__download_number_code_times < order_delivery.download_number_code_limit) then
			goto get_number_code
		else
			return recharge_result
		end
	elseif(recharge_result.code ~= sys.error.success.code) then
		return recharge_result
	end

	print("������ʯ��������ѯ����")
	local query_result, up_order_query_info = order_delivery.request_order_query({order_id = up_order_info.order_id})
	return recharge_result, up_order_info, query_result, up_order_query_info
end


order_delivery.get_web_login_data = function(up_shelf_id, login_name)
	local result, cookie = loginlib.get_cookies(order_delivery.delivery_data.up_shelf_id, order_delivery.delivery_data.third_login_name)
	if(result.code ~= sys.error.success.code) then
		return sys.error.login.get_cookie_failure
	end
	loginlib.clear_web_cookies(order_delivery.http)
	loginlib.set_web_cookies(order_delivery.http, cookie)
	return sys.error.success
end

order_delivery.get_delivery_data = function()
	local dbg_result = order_delivery.grs_dbg:execute("order.delivery.get", order_delivery.params)
	order_delivery.delivery_data = dbg_result.data
	return dbg_result.result
end

--{card_no}
order_delivery.verify_card = function(params)
	local input = {}
	input.encoding = order_delivery.encoding
	input.content = "json"
	input.method = "post"
	input.url = "http://www.sinopecsales.com/gas/webjsp/memberOilCardAction_searchCzkStatus.json"
	input.data = string.format("czkNo=%s", params.card_no)
	input.header= [[Accept:application/json, text/javascript, */*; q=0.01
Accept-Encoding:gzip, deflate
Accept-Language:zh-CN,zh;q=0.8
Connection:keep-alive
Content-Type:application/x-www-form-urlencoded; charset=UTF-8
Host:www.sinopecsales.com
Origin:http://www.sinopecsales.com
Referer:http://www.sinopecsales.com/gas/webjsp/myoil/myOilCard_v1.jsp
User-Agent:Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/48.0.2564.97 Safari/537.36
X-Requested-With:XMLHttpRequest]]
	local content = order_delivery.http:query(input, {}, 30000)
	if(xstring.empty(content)) then
		error(string.format("�鿨���󷵻ؿ�.url:%s,data:%s,header:%s", input.url, input.data, input.header))
		return {code = sys.error.delivery.verify_card_error.code, msg = "�鿨���󷵻ؿ�"}
	end
	if(order_delivery.is_html(content)) then
		error("�鿨���ش���.����:"..content)
		return {code = sys.error.delivery.verify_card_error.code, msg = "�鿨���󷵻���Ҫ��¼"}
	end
	local result = xtable.parse(content, 1)
	if(result.czkUseStatus == nil) then
		error("�鿨���󷵻����ݲ�������״̬.��������:"..content)
		return {code = sys.error.delivery.verify_card_error.code, msg = "�鿨���󷵻����ݲ�������״̬"}
	elseif(result.czkUseStatus == "��ʹ��") then
		error("����ʹ��.�������:"..order_delivery.params.delivery_id)
		return sys.error.delivery.recharge_card_has_been_used
	elseif(result.czkUseStatus == "δʹ��") then
		print("��δʹ��.������������")
		return sys.error.delivery.recharge_card_normal
	elseif(result.czkUseStatus == "error") then
		return sys.error.delivery.recharge_card_status_exp
	end
	error("�鿨����״̬δ֪,response data:"..content)
	return sys.error.delivery.verify_card_result_unkown
end

order_delivery.send_sms_code = function(params)
	local input = {}
	input.encoding = order_delivery.encoding
	input.content = "json"
	input.method = "post"
	input.url = "http://www.sinopecsales.com/gas/html/netRechargeAction_getSmsYzm.json"
	input.data = string.format("cardNo=%s&phoneNo=%s", params.recharge_account_id, params.validcode_mobile)
	input.header = [[Accept:application/json, text/javascript, */*; q=0.01
Accept-Encoding:gzip, deflate
Accept-Language:zh-CN,zh;q=0.8
Connection:keep-alive
Content-Type:application/x-www-form-urlencoded; charset=UTF-8
Host:www.sinopecsales.com
Origin:http://www.sinopecsales.com
Referer:http://www.sinopecsales.com/gas/html/billQueryAction_goChangeCard.action
User-Agent:Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/48.0.2564.97 Safari/537.36
X-Requested-With:XMLHttpRequest]]
	local content = order_delivery.http:query(input, {}, 30000)
	if(xstring.empty(content)) then
		error(string.format("���Ͷ�����֤�����󷵻ؿ�.url:%s,post_data:%s,header:%s", input.url, input.data, input.header))
		return {code = sys.error.failure.code, msg = "���Ͷ�����֤�뷵�ؿ�"}
	end
	if(order_delivery.is_html(content)) then
		error("���Ͷ�����֤�뷵�ش���.����:"..content)
		return {code = sys.error.failure.code, msg = "���Ͷ�����֤�뷵����Ҫ��¼"}
	end
	local data = xtable.parse(content, 1)
	local success_code = tostring(data.success)
	if(success_code == "0") then
		return sys.error.success
	elseif(success_code == "3") then
		error("���Ϳ�������")
		return {code = sys.error.delivery.user_card_cannot_recharge.code, msg = "���Ϳ�������"}, order_delivery.gasoline_card_archive_status.not_exists
	elseif(success_code == "4") then
		error("�������ܽ��г�ֵ")
		return {code = sys.error.delivery.user_card_cannot_recharge.code, msg = "�������ܽ��г�ֵ"}, order_delivery.gasoline_card_archive_status.sub
	elseif(success_code == "5") then
		error("���Ϳ��ѹ�ʧ,���ܽ��г�ֵ")
		return {code = sys.error.delivery.user_card_cannot_recharge.code, msg = "���Ϳ��ѹ�ʧ,���ܽ��г�ֵ"}, order_delivery.gasoline_card_archive_status.lose
	elseif(success_code == "6") then
		error("���Ϳ��ѹ���,���ܽ��г�ֵ")
		return {code = sys.error.delivery.user_card_cannot_recharge.code, msg = "���Ϳ��ѹ���,���ܽ��г�?"}, order_delivery.gasoline_card_archive_status.expire
	elseif(success_code == "7") then
		error("���Ϳ���ʧЧ,���ܽ��г�ֵ")
		return {code = sys.error.delivery.user_card_cannot_recharge.code, msg = "���Ϳ���ʧЧ,���ܽ��г�ֵ"}, order_delivery.gasoline_card_archive_status.expire
	elseif(success_code == "9") then
		error("���Ϳ�����,���ܽ��г�ֵ")
		return {code = sys.error.delivery.user_card_cannot_recharge.code, msg = "���Ϳ�����,���ܽ��г�?"}, order_delivery.gasoline_card_archive_status.damage
	elseif(success_code == "10") then
		error("���Ϳ�������,���ܽ��г�ֵ")
		return {code = sys.error.delivery.user_card_cannot_recharge.code, msg = "���Ϳ�������,���ܽ��г�ֵ"}, order_delivery.gasoline_card_archive_status.discard
	elseif(success_code == "11") then
		error("���Ϳ�״̬�쳣,���ܽ��г�ֵ")
		return {code = sys.error.delivery.user_card_cannot_recharge.code, msg = "���Ϳ�״̬�쳣,���ܽ��г�ֵ"}, order_delivery.gasoline_card_archive_status.card_exception
	end

	if(tostring(success_code) ~= "0") then
		local err_msg = order_delivery.get_card_error_info(tostring(data.success))
		error(string.format("���Ͷ�����֤��ʧ��,��������:%s.������Ϣ:%s", content, err_msg))
		return {code = sys.error.failure.code, msg = err_msg}
	end
	return sys.error.success
end

--{recharge_account_id,validcode_mobile}
order_delivery.get_sms_code = function(params)
	local result, user_card_status = order_delivery.send_sms_code(params)
	if(result.code ~= sys.error.success.code) then
		return result, user_card_status
	end
	--��ȴ����ŷ������ֻ�����
	local card_tail_no = string.sub(params.recharge_account_id, -4)
	result, content = order_delivery.get_smsras_sms(params.validcode_mobile, card_tail_no, 4000, 0)
	if(result.code == sys.error.sms.get_sms_content_failure.code) then
		print("��֤�����ʧ��,�ۼ�ʧ�ܴ���")
		order_delivery.grs_dbg:execute("up_channel.phone_card.receive_sms_failure", params)
		return result
	end
	print("��֤����ճɹ�,���ʧ�ܴ���")
	order_delivery.grs_dbg:execute("up_channel.phone_card.receive_sms_success", params)
	local sms_data = order_delivery.analysis_recharge_sms(tostring(content))
	if(sms_data.code == nil) then
		error(string.format("�������ݽ���ʧ��.����������ݽ��������Ƿ���Ҫ����.��������:%s", content))
		return sys.error.sms.content_analysis_failure
	elseif(tostring(sms_data.card_tail_no) ~= card_tail_no) then
		error(string.format("���������м��Ϳ�β�����û����Ϳ��Ų�ƥ��.������β��:%s,�û����Ϳ���:%s", sms_data.card_tail_no, params.recharge_account_id))
		return sys.error.sms.content_card_no_match_failure
	end


	return sys.error.success, user_card_status, sms_data.code
end

order_delivery.get_number_code = function()
	local input = {}
	input.url = "http://www.sinopecsales.com/gas/YanZhengMaServlet?"..os.time()
	input.net = "zhongshihua.net"
	input.value = 0.5
	input.len = 5
	input.result = ""
	local result, msg = order_delivery.recognize:net_recognize(order_delivery.http, input)
	print("������֤��ʶ����:"..tostring(input.result))
	if(not(result)) then
		error(msg)
		return sys.error.failure
	end
	--ʶ������жϵ�һ���͵������Ƿ����ַ����ڶ����Ǻ��������+��x,���ĸ���=�ţ���5����w
	local a = tonumber(string.sub(input.result, 1, 1))
	local b = tonumber(string.sub(input.result, 3, 3))
	local d = string.sub(input.result, 2, 2)
	if(a == nil or b == nil) then
		error("������֤��ʶ�����,�����»�ȡ������֤��")
		return sys.error.failure
	end
	if(d == "+") then
		return sys.error.success, a + b
	end
	return sys.error.success, a * b
end

order_delivery.request_query_card_info = function(params)
	local input = {}
	input.encoding = order_delivery.encoding
	input.content = "json"
	input.method = "post"
	input.url = "http://www.sinopecsales.com/gas/html/netRechargeAction_queryCardInfo.json"
	input.data = string.format([=[cardNo=%s&smsYzm=%s&chargePhoneNo=%s]=],
								params.recharge_account_id,
								params.sms_code,
								params.validcode_mobile)
	input.header= [[Accept:application/json, text/javascript, */*; q=0.01
Accept-Encoding:gzip, deflate
Accept-Language:zh-CN,zh;q=0.8
Connection:keep-alive
Content-Type:application/x-www-form-urlencoded; charset=UTF-8
Host:www.sinopecsales.com
Origin:http://www.sinopecsales.com
Referer:http://www.sinopecsales.com/gas/html/billQueryAction_goChangeCard.action
User-Agent:Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/48.0.2564.97 Safari/537.36
X-Requested-With:XMLHttpRequest]]
	local content = order_delivery.http:query(input, {}, 30000)
	print("��ѯ���Ϳ���Ϣ���󷵻�����:"..tostring(content))
	if(xstring.empty(content)) then
		error(string.format("��ѯ���Ϳ���Ϣ���󷵻ؿ�.url:%s,post_data:%s,header:%s", input.url, input.data, input.header))
		return sys.error.delivery.get_card_info_failure
	end
	if(order_delivery.is_html(content)) then
		error("��ѯ���Ϳ���Ϣ���ش���.����:"..content)
		return sys.error.delivery.get_card_info_failure
	end
	local data = xtable.parse(content, 1)
	if(tostring(data.smsyzmresult) == "3" or tostring(data.smsyzmresult) == "4") then
		error("������֤�����,�����»�ȡ")
		return sys.error.delivery.sms_code_error
	end
	if(data.cardInfo ~= nil) then
		if(tostring(data.cardInfo) == "error") then
			error("���Ϳ�������")
			return {code = sys.error.delivery.user_card_cannot_recharge.code, msg = "���Ϳ�������"}, order_delivery.gasoline_card_archive_status.not_exists
		elseif(tostring(data.cardInfo.priCard) == "0") then
			error("���ܸ��������г�ֵ")
			return {code = sys.error.delivery.user_card_cannot_recharge.code, msg = "���ܸ��������г�ֵ"}, order_delivery.gasoline_card_archive_status.sub
		elseif(tostring(data.cardInfo.cardStatus) == "04") then
			print("���Ϳ�����,���Խ��г�ֵ")
		elseif(tostring(data.cardInfo.cardStatus) == "07") then
			error("���Ϳ��ѹ�ʧ�����ܽ��г�ֵ")
			return {code = sys.error.delivery.user_card_cannot_recharge.code, msg = "���Ϳ��ѹ�ʧ�����ܽ��г�ֵ"}, order_delivery.gasoline_card_archive_status.lose
		elseif(tostring(data.cardInfo.cardStatus) == "09") then
			error("���Ϳ����𻵣����ܽ��г�ֵ")
			return {code = sys.error.delivery.user_card_cannot_recharge.code, msg = "���Ϳ����𻵣����ܽ��г�ֵ"}, order_delivery.gasoline_card_archive_status.damage
		elseif(tostring(data.cardInfo.cardStatus) == "10") then
			error("���Ϳ������ϣ����ܽ��г�ֵ")
			return {code = sys.error.delivery.user_card_cannot_recharge.code, msg = "���Ϳ������ϣ����ܽ��г�ֵ"}, order_delivery.gasoline_card_archive_status.discard
		elseif(data.cardInfo.cardStatus ~= nil and tostring(data.cardInfo.cardStatus) ~= "" and tostring(data.cardInfo.cardStatus) ~= "null") then
			error("���Ϳ�״̬�쳣�����ܽ��г�ֵ")
			return {code = sys.error.delivery.user_card_cannot_recharge.code, msg = "���Ϳ�״̬�쳣�����ܽ��г�ֵ"}, order_delivery.gasoline_card_archive_status.card_exception
		elseif(tostring(data.cardInfo.validDate) == "1") then
			error("���Ϳ��ѳ�����Ч�ڣ����ܽ��г�ֵ")
			return {code = sys.error.delivery.user_card_cannot_recharge.code, msg = "���Ϳ��ѳ�����Ч�ڣ����ܽ��г�ֵ"}, order_delivery.gasoline_card_archive_status.expire
		end
	end
	--��������Ϣ
	local user_card_info = order_delivery.analysis_user_card_info(data.cardInfo)
	return sys.error.success, order_delivery.gasoline_card_archive_status.normal, user_card_info
end

--{recharge_account_id,card_pwd,validcode_mobile,number_code,sms_code}
order_delivery.request_recharge = function(params)
	local input = {}
	input.encoding = order_delivery.encoding
	input.content = "json"
	input.method = "post"
	input.url = "http://www.sinopecsales.com/gas/html/netRechargeAction_czkCharge.json"
	input.data = string.format([=[rechargeCardNo=%s&rechargeCzkCardPwd=["%s"]&rechargeCardPhone=%s&yzm=%s&addCyCardNoTiXing=false&smsYzm=%s]=],
								params.recharge_account_id,
								order_delivery.card_pwd_encrypt(params.card_pwd),
								params.validcode_mobile,
								params.number_code,
								params.sms_code)
	input.header= [[Accept:application/json, text/javascript, */*; q=0.01
Accept-Encoding:gzip, deflate
Accept-Language:zh-CN,zh;q=0.8
Connection:keep-alive
Content-Type:application/x-www-form-urlencoded; charset=UTF-8
Host:www.sinopecsales.com
Origin:http://www.sinopecsales.com
Referer:http://www.sinopecsales.com/gas/html/billQueryAction_goChangeCard.action
User-Agent:Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/48.0.2564.97 Safari/537.36
X-Requested-With:XMLHttpRequest]]
	local content = order_delivery.http:query(input, {}, 30000)
	print("��ֵ���󷵻�����:"..tostring(content))
	if(xstring.empty(content)) then
		error(string.format("��ֵ���󷵻ؿ�.url:%s,post_data:%s,header:%s", input.url, input.data, input.header))
		return sys.error.unkown
	end
	if(order_delivery.is_html(content)) then
		error("��ֵ���ش���.����:"..content)
		return sys.error.failure
	end
	local data = xtable.parse(content, 1)
	if(data.error ~= nil and string.find(data.error, "������֤�벻��ȷ") ~= nil) then
		print("������֤�벻��ȷ,�����»�ȡ")
		return sys.error.delivery.sms_code_error
	elseif(data.yzmresult == "1") then
		error("�����»�ȡ������֤��")
		return sys.error.delivery.number_code_error
	elseif(data.yzmresult == "2") then
		error("������֤��������,�����»�ȡ")
		return sys.error.delivery.number_code_error
	elseif(data.list == nil or data.list[1] == nil or data.list[1][1] == nil) then
		error(string.format("��ֵ���󷵻����ݲ�����������.url:%s,post_data:%s,header:%s,response_data:%s", input.url, input.data, input.header, content))
		return sys.error.unkown
	end
	return sys.error.success, {order_id = data.list[1][1]}
end

--{order_id}
order_delivery.request_order_query = function(params)
	local input = {}
	input.encoding = order_delivery.encoding
	input.content = "json"
	input.method = "post"
	input.url = "http://www.sinopecsales.com/gas/html/netRechargeAction_selectCardOrder.json"
	input.data = string.format("orderId=%s", params.order_id)
	input.header = [[Accept:application/json, text/javascript, */*; q=0.01
Accept-Encoding:gzip, deflate
Accept-Language:zh-CN,zh;q=0.8
Connection:keep-alive
Content-Type:application/x-www-form-urlencoded; charset=UTF-8
Host:www.sinopecsales.com
Origin:http://www.sinopecsales.com
Referer:http://www.sinopecsales.com/gas/html/billQueryAction_goChangeCard.action
User-Agent:Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/48.0.2564.97 Safari/537.36
X-Requested-With:XMLHttpRequest]]
	local content = order_delivery.http:query(input, {}, 30000)
	print("������ѯ��������:"..content)
	if(xstring.empty(content)) then
		error(string.format("��ѯ�������󷵻ؿ�.url:%s,post_data:%s,header:%s", input.url, input,data, input.header))
		return sys.error.delivery.query_result_unkown
	end
	if(order_delivery.is_html(content)) then
		error("������ѯ���ش���.����:"..content)
		return sys.error.delivery.query_result_unkown
	end
	local data = xtable.parse(content, 1)
	if(tostring(data.ordersuccess) == "1" and tostring(data.success) == "2" and tonumber(data.orderMoney) > 0) then
		print("��ֵ�ɹ�")
		return sys.error.delivery.recharge_success
	end
	return sys.error.delivery.query_result_unkown, data
end

order_delivery.delivery_save = function(recharge_result, up_order_info, query_result, up_order_query_info)
	local params = {}
	params.delivery_id = order_delivery.params.delivery_id
	params.channel_no = order_delivery.delivery_data.up_channel_no
	params.success_standard = 0
	params.result_source = 2
	params.result_msg = recharge_result.msg
	params.up_order_no = (up_order_info == nil or up_order_info.order_id == nil) and "" or up_order_info.order_id
	params.query_timespan = order_delivery.delivery_data.query_timespan
	params.up_error_code = order_delivery.deal_code.unkown
	params.card_use_status = order_delivery.card_use_status.unkown
	params.robot_code = order_delivery.params.robot_code
	if(recharge_result.code == sys.error.login.get_cookie_failure.code) then
		params.card_msg = "��ȡ��¼cookieʧ��,��δʹ��"
		params.card_use_status = order_delivery.card_use_status.unuse
		params.up_error_code = order_delivery.deal_code.failure

	elseif(recharge_result.code == sys.error.delivery.recharge_card_has_been_used.code
		or recharge_result.code == sys.error.delivery.recharge_card_status_exp.code) then
		params.card_msg = "�鿨���ؿ��ѱ�ʹ��"
		params.card_use_status = order_delivery.card_use_status.exp_card
		params.up_error_code = order_delivery.deal_code.failure

	elseif(recharge_result.code == sys.error.unkown.code) then
		params.card_msg = "�ύ��ֵ���󷵻ؽ��δ֪,��ʹ�ý��δ֪"

	elseif(recharge_result.code == sys.error.delivery.verify_card_result_unkown.code) then
		params.card_msg = sys.error.delivery.verify_card_result_unkown.msg
		params.card_use_status = order_delivery.card_use_status.unuse
		params.up_error_code = order_delivery.deal_code.failure

	elseif(recharge_result.code == sys.error.delivery.verify_card_error.code) then
		params.card_msg = "�鿨ʧ��,��ʹ��״̬δ֪"
		params.card_use_status = order_delivery.card_use_status.unuse
		params.up_error_code = order_delivery.deal_code.failure

	elseif(recharge_result.code ~= sys.error.success.code) then
		params.card_msg = "�ύ��ֵ����ʧ��,��δʹ��"
		params.up_error_code = order_delivery.deal_code.failure
		params.card_use_status = order_delivery.card_use_status.unuse

	elseif(query_result.code == sys.error.delivery.query_result_unkown.code) then
		params.card_msg = "�ύ��ֵ����ɹ�,��ѯʧ��.��״̬δ֪"
		params.result_msg = query_result.msg

	else
		params.card_msg = "�ύ��ֵ����ɹ�,����ʹ��"
		params.up_error_code = order_delivery.deal_code.success
		params.up_order_no = up_order_info.order_id
		params.card_use_status = order_delivery.card_use_status.useing
	end
	local dbg_result = order_delivery.grs_dbg:execute("order.delivery.save", params)
	return dbg_result.result, dbg_result.data

end

order_delivery.next_step = function(data)
	if(xstring.empty(data.next_step)) then
		return
	end
	local queues = xmq(data.next_step)
	queues:send({delivery_id = order_delivery.params.delivery_id, order_no = data.order_no, query_id = data.query_id})
end

order_delivery.join_to_card_info_save_mq = function(card_status, card_info)
	local send_data = {card_no = order_delivery.delivery_data.recharge_account_id,
					card_holder = card_info.card_holder or "",
					carrier_no = "ZSH",
					status = card_status,
					is_complete = 0}
	local queues = xmq("gasoline_card_save")
	queues:send(send_data)
end

order_delivery.get_smsras_sms = function(mobile, card_tail_no, sleep_time, wait_times)
	flowlib.sleep_sync(sleep_time)
	local dbg_result = order_delivery.sms_dbg:execute_sp("sp_get_grs_sms", {mobile, card_tail_no, 60})
	if(tostring(dbg_result:get(0)) == "100") then
		return sys.error.success, dbg_result:get(1)
	elseif(tostring(dbg_result:get(0)) ~= "100" and wait_times <= order_delivery.wait_smsras_code_limit) then
		return order_delivery.get_smsras_sms(mobile, card_tail_no, 1000, wait_times + 1)
	else
		return sys.error.sms.get_sms_content_failure
	end
end

order_delivery.card_pwd_encrypt = function(card_pwd)
	local str = ""
	for i=1,#card_pwd,1 do
		local b = string.byte(string.sub(card_pwd, i, i))
		local s = string.format("%02x",bit.bxor(b,158))
		if(#s == 1) then
			str = str.."0"
		end
		str = str..s
	end
	return str
end


order_delivery.is_html = function(content)
	local s,e = string.find(content, "<html>")
	if(s ~= nil) then
		return true
	end
	return false
end

order_delivery.get_card_error_info = function(status)
	local msg = nil
	if(status == "1") then
		msg = "�ֻ����벻��ȷ"
	elseif(status == "2") then
		msg = "���Ϳ����벻��ȷ"
	elseif(status == "3") then
		msg = "���Ϳ�������"
	elseif(status == "4") then
		msg = "�������ܽ��г�ֵ"
	elseif(status == "5") then
		msg = "���Ϳ��ѹ�ʧ,���ܽ��г�ֵ"
	elseif(status == "6") then
		msg = "���Ϳ��ѳ�����Ч��,���ܽ��г�ֵ"
	elseif(status == "7") then
		msg = "���Ϳ���ʧЧ,���ܽ��г�ֵ"
	elseif(status == "9") then
		msg = "���Ϳ�����,���ܽ��г�ֵ"
	elseif(status == "10") then
		msg = "���Ϳ�������,���ܽ��г�ֵ"
	elseif(status == "11") then
		msg = "���Ϳ�״̬�쳣,���ܽ��г�ֵ"
	else
		msg = "δ֪״̬,ֵ:"..status
	end
	return msg
end

order_delivery.analysis_recharge_sms = function(content)
	local codes, data = {}, {}
	for item in string.gmatch(content, "[%d]+") do
		table.insert(codes, item)
	end
	data.card_tail_no = codes[1]
	data.code = codes[2]
	return data
end

order_delivery.analysis_user_card_info = function(data)
	local card_info = data
	card_info.card_no = data.cardNo
	card_info.card_holder = data.cardHolder


	--�����û�����
	--�����û�����
	--�����û�����
	--�����û�����


	return card_info
end




return order_delivery
