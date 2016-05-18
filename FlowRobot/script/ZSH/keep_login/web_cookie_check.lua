require "sys"

-- ���� ���½�
-- ��������:��ʱ���ֵ�¼�ļ������
-- ��Ҫ��¼,�ַ�����¼����;��Ҫά��,�ַ���ά������
cookie_check = {}
cookie_check.con_object = xdbg()
cookie_check.loginlib = require("lib.loginlib")
cookie_check.CONFIG = {
	group_name = flowlib.get_local_ip(),
	delay_secs = 3 * 60
}
cookie_check.status_flow_map = {['0'] = 'zsh_website_keep_cookie',['8'] = 'zsh_website_login_on'}


cookie_check.main = function(args)
	print("----------------[��ʼ]���ֵ�¼�Ķ�ʱ�������---------------")

	print("1. ��ȡ��¼�˻��б�")
	local result,list = cookie_check.get_login_accounts(cookie_check.CONFIG)
	if(result.code ~= sys.error.success.code) then
		return result
	end
	if(#list <= 0) then
		print('û����Ҫ������˺�')
		return sys.error.success
	end

	print("2. ��״̬ɸѡ����")
	local messages = {}
	for i,v in pairs(list) do
		print("�����������ݣ�"..xtable.tojson(v))
		local flow = cookie_check.status_flow_map[tostring(v.status)]
		messages[flow] = messages[flow] or {}
		table.insert(messages[flow], v)
	end

	print("3. ����Ϣ���ͳ�ȥ")
	local send_faild_count = 0
	for i,v in pairs(messages) do
		local queues = xmq(i)
		local res = queues:send(v)
		if(not(res)) then
			send_faild_count = send_faild_count + table.getn(v)	
		end
	end
	return sys.error.success,{fail_count = send_faild_count}

end

cookie_check.get_login_accounts = function(params)
	local dbg_ret = cookie_check.con_object:execute("web.account.get_account_list_wait_keep_or_login",params)
	if(dbg_ret.result.code ~= sys.error.success.code) then
		return dbg_ret.result
	end
	return dbg_ret.result,dbg_ret.data.items
end

return cookie_check
