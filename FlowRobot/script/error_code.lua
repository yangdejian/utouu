error_code = {}

error_code.success = {code = "success", msg = "�����ɹ�"}
error_code.failure = {code = "failure", msg = "����ʧ��"}
error_code.unkown = {code = "unkown", msg = "δ֪"}
error_code.param_miss = {code = "param_miss", msg = "ȱ�ٱ���Ĳ���"}
error_code.param_error = {code = "param_error", msg = "��������"}
error_code.not_exists={code="not_exists",msg="���ݲ�����"}
error_code.data_miss = {code = "data_miss", msg = "���ݲ����ڻ��ѱ�ɾ��"}
error_code.data_exists = {code = "data_exists", msg = "�����Ѵ���"}
error_code.data_not_exists = {code = "data_not_exists", msg = "���ݲ�����"}
error_code.system_busy = {code = "system_busy", msg = "ϵͳ��æ,�Ժ�����"}
error_code.data_repeat = {code = "data_repeat", msg = "�����ظ�"}
error_code.data_time_out = {code = "data_time_out", msg = "�����ѹ���"}
error_code.balance_low = {code = "balance_low",msg = "�˻�����"}
error_code.amount_error = {code = "amount_error", msg = "������"}
error_code.not_allow = {code = "not_allow", msg = "������ִ�д˲���"}
error_code.num_error = {code = "num_error", msg = "��������"}
error_code.has_refunded = {code = "has_refunded", msg = "�Ѵ����˿�"}
error_code.valid_code_error = {code = "valid_code_error", msg = "��֤�����"}
error_code.card_status_error = {code = "card_status_error", msg = "��״̬����"}
error_code.response_empty = {code = "response_empty", msg = "���󷵻ؿ�"}
error_code.response_html = {code = "response_html", msg = "���󷵻�HTML����"}
error_code.response_fmt_error = {code = "response_fmt_error", msg = "���󷵻ظ�ʽ����"}
error_code.xml_load_failure = {code = "xml_load_failure", msg = "XML���ݼ���ʧ��"}
error_code.build_sign_failure = {code = "build_sign_failure", msg = "����ǩ��ʧ��"}
error_code.sign_error = {code = "sign_error", msg = "ǩ������"}

error_code.command = {}
error_code.command.require_error = {code = "command.require_error", msg = "ִ��ָ��ʱ,�������ݲ�ű�����"}
error_code.command.execute_error = {code = "command.execute_error", msg = "ִ��ָ��ʱ,���ݲ㷽������"}

error_code.delivery = {}
error_code.delivery.payment_status_error = {code = "delivery.payment_status_error", msg = "֧��״̬����"}
error_code.delivery.refund_status_error = {code = "delivery.refund_status_error", msg = "�˿�״̬����"}
error_code.delivery.verify_card_error = {code = "delivery.verify_card_error", msg = "�鿨ʧ��"}
error_code.delivery.recharge_card_normal = {code = "delivery.card_normal", msg = "��ֵ������"}
error_code.delivery.recharge_card_has_been_used = {code = "delivery.recharge_card_has_been_used", msg = "��ֵ���ѱ�ʹ��"}
error_code.delivery.recharge_card_status_exp = {code = "delivery.recharge_card_status_exp", msg = "��ֵ��״̬�쳣"}
error_code.delivery.verify_card_result_unkown = {code = "delivery.verify_card_result_unkown", msg = "�鿨����ѷ���,����δ��������.�����鿨ҳ���Ƿ�����"}
error_code.delivery.sms_code_error = {code = "delivery.sms_code_error", msg = "������֤�����"}
error_code.delivery.number_code_error = {code = "delivery.number_code_error", msg = "������֤�����"}
error_code.delivery.query_result_unkown = {code = "delivery.query_result_unkown", msg = "�����ɹ�,��ѯ���δ֪"}
error_code.delivery.rechargeing = {code = "delivery.rechargeing", msg = "�����ɹ�,���ڳ�ֵ"}
error_code.delivery.recharge_success = {code = "delivery.recharge_success", msg = "�����ɹ�,��ֵ�ɹ�"}
error_code.delivery.get_card_info_failure = {code = "delivery.get_card_info_failure", msg = "��ȡ���Ϳ���Ϣʧ��"}
error_code.delivery.recharge_account_id_not_exists = {code = "delivery.recharge_account_id_not_exists", msg = "���Ϳ����Ų�����"}
error_code.delivery.user_card_cannot_recharge = {code = "delivery.user_card_cannot_recharge", msg = "���Ϳ������Գ�ֵ"}
error_code.delivery.login_failure = {code = "delivery.login_failure", msg = "������¼ʧ��"}

error_code.delivery.recharge = {}
error_code.delivery.recharge.submit = {}
error_code.delivery.recharge.submit.failure = {code = "delivery.recharge.submit.failure", msg = "��ֵ�ύʧ��"}
error_code.delivery.recharge.submit.unkown = {code = "delivery.recharge.submit.unkown", msg = "��ֵ�ύ���δ֪"}
error_code.delivery.recharge.submit.sms_code_error = {code = "delivery.recharge.submit.sms_code_error", msg = "������֤�����"}
error_code.delivery.recharge.submit.number_code_error = {code = "delivery.recharge.submit.number_code_error", msg = "������֤�����"}
error_code.delivery.recharge.submit.card_pwd_error = {code = "delivery.recharge.submit.card_pwd_error", msg = "��ֵ���������"}

error_code.delivery.recharge.query = {}
error_code.delivery.recharge.query.unkown = {code = "delivery.recharge.query.unkown", msg = "�����ύ�ɹ�,��ѯ���δ֪"}

error_code.delivery.query = {}
error_code.delivery.query.list_response_empty = {code = "delivery.query.list_response_empty", msg = "��ѯ�����б����󷵻ؿ�"}
error_code.delivery.query.list_response_html = {code = "delivery.query.list_response_html", msg = "��ѯ�����б���html"}
error_code.delivery.query.card_response_empty = {code = "delivery.query.card_response_empty", msg = "�鿨���󷵻ؿ�"}
error_code.delivery.query.card_response_html = {code = "delivery.query.card_response_html", msg = "�鿨���󷵻�html"}
error_code.delivery.query.get_cookies_failed = {code = "delivery.query.get_cookies_failed", msg = "��ȡcookieʧ��"}
error_code.delivery.query.single_response_empty = {code = "delivery.query.single_response_empty", msg = "ֱ�Ӳ�ѯ�������󷵻ؿ�"}
error_code.delivery.query.single_response_html = {code = "delivery.query.single_response_html", msg = "ֱ�Ӳ�ѯ��������html"}
error_code.delivery.query.order_not_exists = {code = "delivery.query.order_not_exists", msg = "��ѯ���ض���������"}
error_code.delivery.query.order_success = {code = "delivery.query.order_success", msg = "��ѯ���س�ֵ�ɹ�"}



error_code.channel = {}
error_code.channel.not_exists = {code = "channel.not_exists", msg = "����������"}
error_code.channel.settle_type_error = {code = "channel.settle_type_error", msg = "�����������ʹ���"}

error_code.up_channel = {}
error_code.up_channel.not_exists = {code = "up_channel.not_exists", msg = "����������"}
error_code.up_channel.settle_type_error = {code = "up_channel.settle_type_error", msg = "�����������ʹ���"}

error_code.down_channel = {}
error_code.down_channel.order_notify_exists = {code = "down_channel.order_notify_exists", msg = "������������֪ͨ�����Ѵ���"}

error_code.order = {}
error_code.order.order_status_error = {code = "order.order_status_error", msg = "����״̬����ȷ"}
error_code.order.no_need_bind={code = "order.no_need_bind", msg = "���������"}
error_code.order.no_need_delivery={code = "order.no_need_delivery", msg = "�������跢��"}
error_code.order.not_fund_delivery_channel={code = "order.not_fund_delviery_channel", msg = "δ�ҵ�����������Ϣ"}

error_code.order.bind_failed={code = "order.bind_failed", msg = "������ʧ��"}
error_code.order.no_match_product={code = "order.no_match_product", msg = "����δ�ҵ�ƥ��Ĳ�Ʒ"}
error_code.order.no_match_error_code={code = "order.no_match_error_code", msg = "δ�ҵ�ƥ��Ĵ�����"}
error_code.order.delivery_save_error={code = "order.delivery_save_error", msg = "���������������ʧ��"}

error_code.order.no_need_notify ={code = "order.no_need_notify", msg = "��������֪ͨ"}
error_code.order.amount_error={code = "order.amount_error",msg = "�����������"}
error_code.order.status_error={code="order_status_error",msg="����״̬����"}
error_code.order.data_error={code="order_data_error",msg="������������"}
error_code.order.no_need_deal={code="order_no_need_deal",msg="�������账��"}

error_code.order.pay_delay_process={code="order.pay_delay_process",msg="�ӳٴ���"}
error_code.order.not_allow_pay={code="order.not_allow_pay",msg="����������֧��"}
error_code.order.notify_not_save={code="order.notify_not_save",msg="����֪ͨ��¼δ����"}

error_code.sms = {}
error_code.sms.send_failure = {code = "sms.send_failure", msg = "���ŷ���ʧ��"}
error_code.sms.content_card_no_match_failure = {code = "sms.content_card_no_match_failure", msg = "���������г�ֵ�����뷢�Ϳ��Ų�ƥ��"}
error_code.sms.content_analysis_failure = {code = "sms.content_analysis_failure", msg = "�������ݽ���ʧ��"}
error_code.sms.get_sms_content_failure = {code = "sms.get_sms_content_failure", msg = "����smsϵͳ,��ȡ��������ʧ��"}

error_code.bind = {}
error_code.bind.no_useful_mobile = {code = "bind.no_useful_mobile", msg = "û�п��õ��ֻ���"}

error_code.login = {}
error_code.login.cookie_timeout = {code = "login.cookie_timeout", msg = "cookie�ѹ���"}
error_code.login.get_cookie_failure = {code = "login.get_cookie_failure", msg = "��ȡ��¼cookieʧ��"}
error_code.login.valid_code_error = {code = "login.valid_code_error", msg = "��¼��֤�����"}
error_code.login.valid_code_recognize_failure = {code = "login.valid_code_recognize_failure", msg = "��¼��֤��ʶ��ʧ��"}
error_code.login.valid_code_calc_failure = {code = "login.valid_code_calc_failure", msg = "��֤�����ʧ��"}
error_code.login.password_error = {code = "login.password_error", msg = "��¼�������"}
error_code.login.official_defend = {code="login.official_defend", msg = "����ά��,�޷���¼"}
error_code.login.repeat_login = {code="login.repeat_login", msg = "�ظ��ĵ�¼"}
error_code.login.response_empty = {code="login.response_empty", msg = "���󷵻ؿ�"}
error_code.login.response_html = {code="login.response_html", msg = "���󷵻�HTML"}
error_code.login.cookies_timeout = {code="login.cookies_timeout", msg = "cookie�ѹ���"}
error_code.login.unkown_result = {code="login.unkown_result", msg = "��¼���δ֪"}
error_code.login.refresh_response_empty = {code="login.refresh_response_empty", msg = "��¼ά�����󷵻ؿ�"}
error_code.login.refresh_response_html = {code="login.refresh_response_html", msg = "��¼ά�����󷵻�HTML"}


function eval(str)
	if(not(str)) then
		return nil
	end
    if type(str) == "string" then
        return loadstring("return " .. str)()
    elseif type(str) == "number" then
        return loadstring("return " .. tostring(str))()
    else
        print("is not a string")
    end
end


error_code.get = function(code)
	local result = eval("error_code."..tostring(code))
	if(result == nil) then
		print("�Ҳ�����Ӧ�Ĵ�����:"..tostring(code))
		result = error_code.system_busy
	end
	return result
end


return error_code
