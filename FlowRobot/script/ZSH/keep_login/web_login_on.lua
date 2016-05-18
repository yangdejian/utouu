require "sys"
require 'custom.common.wclient'


--���� ���½�
--�������� ��ʯ����վ��¼������cookie
login_on = {fields = "up_channel_no,up_shelf_id,login_id,login_name,login_pwd"}
login_on.con_object = xdbg()
login_on.http = wclient()
login_on.loginlib = require("lib.loginlib")
-- ״̬0-����1-�������2-���η��7-����ά��8-�ȴ���¼9-��¼ʧ����ͣʹ��
login_on.login_status = {normal=0,password_error=1,official_defend=7,retry=8,unknown=9}

login_on.main = function(args)
	print("----------------[��ʼ]��վ��¼������cookie---------------")
	print("1. ���������")
	local input = xtable.parse(args[2], 1)
	if(xobject.empty(input, login_on.fields)) then
		error(string.format("ȱ�ٱ������, �Ѵ���:%s", args[2]))
		return sys.error.param_miss
	end

	print("2. ��¼")
	local result,cookies = login_on.loginlib.login_on(login_on.http,input.login_name,input.login_pwd)
	print('���:'..xtable.tojson(result))

	print("3. �����¼���")
	login_on.save_login_result(input,result,cookies)
end

-- ״̬0-����1-�������2-���η��8-�ȴ���¼9-��¼ʧ����ͣʹ��
login_on.save_login_result = function(params,login_result,cookies)

	local status = login_on.login_status.unknown
	if(login_result.code == sys.error.success.code) then
		status = login_on.login_status.normal
	elseif(login_result.code == sys.error.login.password_error.code) then
		status = login_on.login_status.password_error
	elseif(login_result.code == sys.error.login.official_defend.code) then
		status = login_on.login_status.official_defend
	end

	print('�����¼״̬Ϊ:'..tostring(login_result.code))
	local save_data = {status = status, description = login_result.code,
		login_id = params.login_id,cookies = cookies}
	local dbg_ret = login_on.con_object:execute("web.account.save_login_result",save_data)
	if(dbg_ret.result.code ~= sys.error.success.code) then
		error('�����¼״̬ʧ��:'..dbg_ret.result.code)
	end
	return dbg_ret.result
end

return login_on
