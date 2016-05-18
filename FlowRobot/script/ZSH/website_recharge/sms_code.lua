require "sys"

zsh_sms_code = {encoding = "gbk",
				first_receive_sms_sleep_time = 10000,
				max_receive_sms_sleep_number = 10,
				receive_sms_time_limit = 10}
zsh_sms_code.commonlib = require "zsh.website_recharge.commonlib"
zsh_sms_code.sms_dbg = xdbg("sms_db")

--���Ͷ�����֤��
--{recharge_account_id,validcode_mobile}
zsh_sms_code.send = function(http, params)
	local input = {}
	input.encoding = zsh_sms_code.encoding
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
	debug(string.format("url:%s, post_data:%s", input.url, input.data))
	local content = http:query(input, {}, 30000)
	if(xstring.empty(content)) then
		error(string.format("���Ͷ�����֤�����󷵻ؿ�.url:%s,post_data:%s,header:%s", input.url, input.data, input.header))
		return {code = sys.error.sms.send_failure.code, msg = "���Ͷ�����֤�뷵�ؿ�"}
	end
	if(zsh_sms_code.commonlib.is_html(content)) then
		error("���Ͷ�����֤�뷵�ش���.����:"..content)
		return {code = sys.error.sms.send_failure.code, msg = "���Ͷ�����֤�뷵����Ҫ��¼"}
	end
	local data = xtable.parse(content, 1)
	local success_code = tostring(data.success)
	if(success_code == "0") then
		return sys.error.success
	elseif(success_code == "1") then
		return {code = sys.error.sms.send_failure.code, msg = "�ֻ����벻��ȷ"}
	elseif(success_code == "2") then
		return {code = sys.error.sms.send_failure.code, msg = "���Ϳ����벻��ȷ"}
	elseif(success_code == "3") then
		error("���Ϳ�������")
		return {code = sys.error.delivery.user_card_cannot_recharge.code, msg = "���Ϳ�������"}, zsh_sms_code.commonlib.gasoline_card_status.not_exists
	elseif(success_code == "4") then
		error("�������ܽ��г�ֵ")
		return {code = sys.error.delivery.user_card_cannot_recharge.code, msg = "�������ܽ��г�ֵ"}, zsh_sms_code.commonlib.gasoline_card_status.sub
	elseif(success_code == "5") then
		error("���Ϳ��ѹ�ʧ,���ܽ��г�ֵ")
		return {code = sys.error.delivery.user_card_cannot_recharge.code, msg = "���Ϳ��ѹ�ʧ,���ܽ��г�ֵ"}, zsh_sms_code.commonlib.gasoline_card_status.lose
	elseif(success_code == "6") then
		error("���Ϳ��ѹ���,���ܽ��г�ֵ")
		return {code = sys.error.delivery.user_card_cannot_recharge.code, msg = "���Ϳ��ѹ���,���ܽ��г�?"}, zsh_sms_code.commonlib.gasoline_card_status.expire
	elseif(success_code == "7") then
		error("���Ϳ���ʧЧ,���ܽ��г�ֵ")
		return {code = sys.error.delivery.user_card_cannot_recharge.code, msg = "���Ϳ���ʧЧ,���ܽ��г�ֵ"}, zsh_sms_code.commonlib.gasoline_card_status.expire
	elseif(success_code == "9") then
		error("���Ϳ�����,���ܽ��г�ֵ")
		return {code = sys.error.delivery.user_card_cannot_recharge.code, msg = "���Ϳ�����,���ܽ��г�ֵ"}, zsh_sms_code.commonlib.gasoline_card_status.damage
	elseif(success_code == "10") then
		error("���Ϳ�������,���ܽ��г�ֵ")
		return {code = sys.error.delivery.user_card_cannot_recharge.code, msg = "���Ϳ�������,���ܽ��г�ֵ"}, zsh_sms_code.commonlib.gasoline_card_status.discard
	elseif(success_code == "11") then
		error("���Ϳ�״̬�쳣,���ܽ��г�ֵ")
		return {code = sys.error.delivery.user_card_cannot_recharge.code, msg = "���Ϳ�״̬�쳣,���ܽ��г�ֵ"}, zsh_sms_code.commonlib.gasoline_card_status.card_exception
	end

	return sys.error.sms.send_failure
end


--���ն�����֤��
--{validcode_mobile, recharge_account_id}
zsh_sms_code.receive = function(dbg, params, sleep_time, sleep_number)
	sleep_time = sleep_time or zsh_sms_code.first_receive_sms_sleep_time
	sleep_number = sleep_number or 0
	flowlib.sleep_sync(sleep_time)
	local dbg_result = zsh_sms_code.sms_dbg:execute_sp("sp_get_grs_sms", {params.validcode_mobile,
																		string.sub(params.recharge_account_id, -4),
																		zsh_sms_code.receive_sms_time_limit})
	print("����èDBG���ؽ��:"..tostring(dbg_result:get(0)))
	if(tostring(dbg_result:get(0)) ~= "100") then
		if(sleep_number < zsh_sms_code.max_receive_sms_sleep_number) then
			print("���½��մ���:"..tostring(sleep_number + 1))
			return zsh_sms_code.receive(dbg, params, 2000, sleep_number + 1)
		end
		return sys.error.sms.get_sms_content_failure
	end
	local data = zsh_sms_code.__analysis(dbg_result:get(1))
	if(string.sub(params.recharge_account_id, -4) ~= data.card_tail_no or xstring.empty(data.code)) then
		return sys.error.sms.get_sms_content_failure
	end
	return sys.error.success, data.code
end

zsh_sms_code.__analysis = function(content)
	local codes, data = {}, {}
	for item in string.gmatch(content, "[%d]+") do
		table.insert(codes, item)
	end
	data.card_tail_no = codes[1]
	data.code = codes[2]
	return data
end








return zsh_sms_code
