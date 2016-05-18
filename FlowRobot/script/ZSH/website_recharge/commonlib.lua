zsh_commonlib = {}


zsh_commonlib.recharge_card_status = {waiting = 20,
								useing = 30,
								used = 0,
								unuse = 90,
								exp_card = 40,
								unkown = 99
								}
zsh_commonlib.gasoline_card_status = {normal = 0, --����
								sub            = 1, --����,
								lose           = 2, --��ʧ
								damage         = 3, --��
								discard        = 4, --����
								card_exception = 5, --���쳣
								expire         = 6, --������
								not_exists     = 9  --���Ų�����
								}

zsh_commonlib.delivery_deal_code = {}
zsh_commonlib.delivery_deal_code["failure"] = "DFAILURE"
zsh_commonlib.delivery_deal_code["delivery.login_failure"] = "DRCHG_LOGIN_FAILURE"--��¼ʧ��
zsh_commonlib.delivery_deal_code["delivery.verify_card_error"] = "DRCHG_VERIFY_CARD_ERROR"--�鿨�쳣
zsh_commonlib.delivery_deal_code["delivery.recharge_card_has_been_used"] = "DRCHG_CARD_HAS_BEEN_USED"--���ѱ�ʹ��
zsh_commonlib.delivery_deal_code["delivery.recharge_card_status_exp"] = "DRCHG_CARD_STATUS_EXP"--��״̬�쳣
zsh_commonlib.delivery_deal_code["delivery.user_card_cannot_recharge"] = "DUSER_CARD_CANNOT_RECHARGE"--���Ϳ��޷���ֵ
zsh_commonlib.delivery_deal_code["sms.send_failure"] = "DSMS_SEND_FAILURE"--���ŷ���ʧ��
zsh_commonlib.delivery_deal_code["sms.get_sms_content_failure"] = "DGET_SMS_CONTENT_FAILURE"--�������ݻ�ȡʧ��
zsh_commonlib.delivery_deal_code["delivery.get_card_info_failure"] = "DGET_CARD_INFO_FAILURE"--���Ϳ���Ϣ��ȡʧ��
zsh_commonlib.delivery_deal_code["delivery.sms_code_error"] = "DRCHG_SMS_CODE_ERROR"--������֤�����
zsh_commonlib.delivery_deal_code["delivery.number_code_error"] = "DRCHG_IMG_CODE_ERROR"--������֤�����
zsh_commonlib.delivery_deal_code["delivery.recharge.submit.unkown"] = "DRCHG_SUBMIT_UNKOWN"--��ֵ�ύ���δ֪
zsh_commonlib.delivery_deal_code["delivery.recharge.submit.failure"] = "DRCHG_SUBMIT_FAILURE"--��ֵ�ύʧ��
zsh_commonlib.delivery_deal_code["delivery.recharge.submit.sms_code_error"] = "DRCHG_SUBMIT_SMS_CODE_ERROR"--��ֵ�ύ���ض�����֤�����
zsh_commonlib.delivery_deal_code["delivery.recharge.submit.number_code_error"] = "DRCHG_SUBMIT_IMG_CODE_ERROR"--��ֵ�ύ����������֤�����
zsh_commonlib.delivery_deal_code["delivery.recharge.submit.card_pwd_error"] = "DRCHG_SUBMIT_CARD_PWD_ERROR"--��ֵ���������
zsh_commonlib.delivery_deal_code["delivery.recharge.query.unkown"] = "DRCHG_QUERY_UNKOWN"--��ֵ��ѯ���δ֪
zsh_commonlib.delivery_deal_code["delivery.recharge_success"] = "DRCHG_SUCCESS"--��ֵ�ɹ�
zsh_commonlib.delivery_deal_code["payStatus:!"] = "DPAYSTATUS:!"--��ѯ����ʧ��
zsh_commonlib.delivery_deal_code["payStatus:0"] = "DPAYSTATUS:0"--��ѯ����ʧ��
zsh_commonlib.delivery_deal_code["payStatus:1&rechargeStatus:!"] = "DPAYSTATUS:1&RECHARGESTATUS:!"--֧���ɹ�,��ֵ״̬δ֪
zsh_commonlib.delivery_deal_code["payStatus:1&rechargeStatus:0"] = "DPAYSTATUS:1$RECHARGESTATUS:0"--֧���ɹ�,δ��ֵ
zsh_commonlib.delivery_deal_code["payStatus:1&rechargeStatus:1"] = "DPAYSTATUS:1$RECHARGESTATUS:1"--֧���ɹ�,�ȴ���ֵ
zsh_commonlib.delivery_deal_code["payStatus:1&rechargeStatus:2"] = "DPAYSTATUS:1$RECHARGESTATUS:2"--֧���ɹ�,��ֵ�ɹ�
zsh_commonlib.delivery_deal_code["payStatus:1&rechargeStatus:3"] = "DPAYSTATUS:1$RECHARGESTATUS:3"--֧���ɹ�,��ֵʧ��
zsh_commonlib.delivery_deal_code["payStatus:1&rechargeStatus:4"] = "DPAYSTATUS:1$RECHARGESTATUS:4"--֧���ɹ�,�޴˶���
zsh_commonlib.delivery_deal_code["payStatus:1&rechargeStatus:5"] = "DPAYSTATUS:1$RECHARGESTATUS:5"--֧���ɹ�,���ڳ�ֵ
zsh_commonlib.delivery_deal_code["payStatus:2"] = "DPAYSTATUS:2"--��ѯ����ʧ��
zsh_commonlib.delivery_deal_code["manual_audit"] = "MANUAL_AUDIT"--�˹����

zsh_commonlib.get_deal_code = function(code)
	if(zsh_commonlib.delivery_deal_code[code] == nil) then
		error("δ�ҵ���Ӧ�Ĵ�����:"..code)
		return zsh_commonlib.delivery_deal_code["manual_audit"]
	end
	return zsh_commonlib.delivery_deal_code[code]
end

zsh_commonlib.is_html = function(content)
	local s,e = string.find(content, "<html>")
	if(s ~= nil) then
		return true
	end
	return false
end









return zsh_commonlib
