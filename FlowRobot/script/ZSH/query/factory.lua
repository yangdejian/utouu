
query_factory = {}
query_factory.query_logined_obj = require('ZSH.query.query_logined')
query_factory.query_unlogin_obj = require('ZSH.query.query_unlogin')

--- ����params.ext_acctount�ֶη��ز�ѯ����
query_factory.get_query_object = function(need_ext_account)
	if(tostring(need_ext_account) == '0') then
		return query_factory.query_logined_obj
	else
		return query_factory.query_unlogin_obj
	end
end

return query_factory