require "sys"

zsh_recharge_order = {encoding = "gbk"}
zsh_recharge_order.commonlib = require "zsh.website_recharge.commonlib"
zsh_recharge_order.encryptlib = require "zsh.website_recharge.encryptlib"

--������ѯ
--{zsh_order_no}
zsh_recharge_order.query = function(http, params)
	local input = {}
	input.encoding = zsh_recharge_order.encoding
	input.content = "json"
	input.method = "post"
	input.url = "http://www.sinopecsales.com/gas/html/netRechargeAction_selectCardOrder.json"
	input.data = string.format("orderId=%s", params.zsh_order_info.order_id)
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
	print("������ѯ��������:"..content)
	if(xstring.empty(content)) then
		error(string.format("��ѯ�������󷵻ؿ�.url:%s,post_data:%s,header:%s", input.url, input,data, input.header))
		return sys.error.delivery.recharge.query.unkown
	end
	if(zsh_recharge_order.commonlib.is_html(content)) then
		error("������ѯ���ش���.����:"..content)
		return sys.error.delivery.recharge.query.unkown
	end
	local data = xtable.parse(content, 1)
	return zsh_recharge_order.analysis_query_result(data)
end

--{recharge_account_id,card_pwd,validcode_mobile,number_code,sms_code}
zsh_recharge_order.submit = function(http, params)
	local input = {}
	input.encoding = zsh_recharge_card.encoding
	input.content = "json"
	input.method = "post"
	input.url = "http://www.sinopecsales.com/gas/html/netRechargeAction_czkCharge.json"
	input.data = string.format([=[rechargeCardNo=%s&rechargeCzkCardPwd=["%s"]&rechargeCardPhone=%s&yzm=%s&addCyCardNoTiXing=false&smsYzm=%s]=],
								params.recharge_account_id,
								zsh_recharge_order.encryptlib.recharge_card_pwd_encrypt(params.card_pwd),
								params.validcode_mobile,
								params.img_code,
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
	params.has_submit_recharge = true
	local content = http:query(input, {}, 30000)
	if(xstring.empty(content)) then
		error(string.format("���ܳ�ֵ���󷵻ؿ�.url:%s,post_data:%s,header:%s", input.url, input.data, input.header))
		return sys.error.delivery.recharge.submit.unkown
	end
	if(zsh_recharge_order.commonlib.is_html(content)) then
		error("��ֵ���ش���.����:"..content)
		return sys.error.delivery.recharge.submit.failure
	end
	local data = xtable.parse(content, 1)
	if(data.error ~= nil and string.find(data.error, "������֤�벻��ȷ") ~= nil) then
		error("������֤�벻��ȷ,�����»�ȡ")
		return sys.error.delivery.recharge.submit.sms_code_error
	elseif(data.yzmresult == "1") then
		error("�����»�ȡ������֤��")
		return sys.error.delivery.recharge.submit.number_code_error
	elseif(data.yzmresult == "2") then
		error("������֤��������,�����»�ȡ")
		return sys.error.delivery.recharge.submit.number_code_error
	elseif(data.list == nil or data.list[1] == nil or data.list[1][1] == nil) then
		error(string.format("��ֵ���󷵻����ݲ�����������.url:%s,post_data:%s,header:%s,response_data:%s", input.url, input.data, input.header, content))
		return {code = sys.error.delivery.recharge.submit.unkown.code,
				msg = "����ʧ��,δ�ҵ�������"}
	end
	return sys.error.success, {order_id = data.list[1][1]}
end


zsh_recharge_order.analysis_query_result = function(data)
	--data.ordersuccess:����֧��״̬
	--data.success:������ֵ״̬
	--data.respCode:������ʾ
	if(tostring(data.ordersuccess) == "1" and tostring(data.success) == "2" and tonumber(data.orderMoney) > 0) then
		print("��ֵ�ɹ�")
		return sys.error.delivery.recharge_success
	end
	local code = nil
	if(string.find(data.respCode or "", "��ֵ���������") ~= nil) then
		code = sys.error.delivery.recharge.submit.card_pwd_error.code
	elseif(tostring(data.ordersuccess) == "1") then
		code = string.format("payStatus:%s&rechargeStatus:%s", data.ordersuccess or "!", data.success or "!")
	else
		code = string.format("payStatus:%s", data.ordersuccess or "!")
	end
	return {code = code, msg = data.respCode or "��ѯ����:"..xtable.tojson(data)}
end




return zsh_recharge_order
