require "json"
require "custom.nbsp.tcplib"
require "custom.common.qparam"

__balance_lib = {}
__balance_lib.methods = {}
__balance_lib.tcphelp = tcplib()
__balance_lib.responseParams = qparam()
__balance_lib.encoding = 'gb2312'


-- ���������ݵĴ������ж�ǩ��
__balance_lib.methods.process = function(args)
	__balance_lib.sign_key=base.ReadString("server","signKey","","../ini/mobilebalance.ini")
	if(utils.stringIsEmpty(__balance_lib.sign_key)) then
		__balance_lib.methods.response_by_error('001','�����ļ���signKey������')
		return false
	end

	__balance_lib.x,__balance_lib.r,__balance_lib.y = __balance_lib.methods.receive_data(args)
	if(not(__balance_lib.x)) then
		__balance_lib.methods.response_by_error('001','���ݸ�ʽ����')
		return false
	end

	--�ж�ǩ���Ƿ�һ��
	if(not(__balance_lib.methods.verify_sign_key())) then
		return false
	end
	return true,__balance_lib.r
end


-- �������ݵĴ���
__balance_lib.methods.receive_data = function(args)
	local g_port = base.ReadInt("server","port",8015,"../ini/mobilebalance.ini")
	__balance_lib.tcphelp:init_fixend_server(g_port,"\r\n\r\n",4096,4096,4,4)
	__balance_lib.pdu = __balance_lib.tcphelp:pdu_from_base64(args[2])
	local recv_data = __balance_lib.tcphelp:get_pdu_string(__balance_lib.pdu)
	print("���յ�������:"..tostring(recv_data))
	return pcall(json.decode,recv_data)
end


-- �ж�ǩ���Ƿ�һ��
__balance_lib.methods.verify_sign_key = function()
	local inputs = qparam()
	inputs:append("request_no",__balance_lib.r.request_no,true)
	inputs:append("request_time",__balance_lib.r.request_time,true)
	inputs:append("carrier",__balance_lib.r.carrier,true)
	inputs:append("province",__balance_lib.r.province,true)
	inputs:append("city",__balance_lib.r.city,true)
	inputs:append("phone",__balance_lib.r.phone,true)
	inputs:append("partner",__balance_lib.r.partner,true)
	local original=inputs:make("","",false,false)..__balance_lib.sign_key
	local current_sign=utils.md5(original,__balance_lib.encoding)
	if(string.upper(current_sign)~=string.upper(__balance_lib.r.sign)) then
		logger.warn(string.format("ǩ����һ��,ϵͳ:%s,����:%s",current_sign,__balance_lib.r.sign))
		__balance_lib.methods.response_by_error('001','ǩ������')
		return false, params
	end
	return true
end


-- ��ѯ�ɹ���response
__balance_lib.methods.response_by_success = function(balance,msg,user,product,need_pay)
	print("�����Ϣ:"..tostring(msg))
	__balance_lib.methods.init_response_params()
	__balance_lib.responseParams:append("user",user,true)
	__balance_lib.responseParams:append("product",product,true)
	__balance_lib.responseParams:append("need_pay",need_pay,true)
	__balance_lib.responseParams:append("code","000",true)
	__balance_lib.responseParams:append("msg",msg,true)
	__balance_lib.responseParams:append("balance",balance,true)
	__balance_lib.methods.response()
end


-- ��ѯʧ��,�����response
__balance_lib.methods.response_by_error = function(code,msg)
	print("�����Ϣ:"..tostring(msg))
	__balance_lib.methods.init_response_params()
	__balance_lib.responseParams:append("code",code,true)
	__balance_lib.responseParams:append("msg",msg,true)
	__balance_lib.methods.response()
end


-- ��ʼ��response��������
__balance_lib.methods.init_response_params = function()
	__balance_lib.responseParams:append("flowid", utils.pad_right(__balance_lib.r.request_no,16," ") ,true)
	__balance_lib.responseParams:append("phone",utils.pad_right(__balance_lib.r.phone,12," "),true)
	__balance_lib.responseParams:append("partner",utils.pad_right(__balance_lib.r.partner,11," "),true)
end


-- response
__balance_lib.methods.response = function()
	local str_ret = __balance_lib.tcphelp:format_json_ret(__balance_lib.responseParams,true,__balance_lib.sign_key,__balance_lib.encoding)
	local resp = __balance_lib.tcphelp:create_response_pdu(__balance_lib.pdu,str_ret)
	__balance_lib.tcphelp:response(resp)
end


return __balance_lib

