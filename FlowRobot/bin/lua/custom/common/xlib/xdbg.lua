_xdbg = {}
--构造函数
function _xdbg:new(oo)
	 local obj = oo or {}
	setmetatable(obj,self)
	self.__index=self
	obj._matcher={}
	return obj
end

--构造函数
function xdbg(conn_name)
	conn_name = conn_name or "ross_db"
	local provider_name=tostring(utils.getIniStr("db",conn_name,"","../ini/dbg.ini"))
	local obj = _xdbg:new()
	obj._adapter = db.DbAdapter(provider_name)
	return obj
end

function _xdbg:execute(command, params)
	local output = base.StringVector()
	local ec = self._adapter:ExecuteNonQuery("dal_command", {command, xtable.tojson(params)}, output)
	print("dbg执行结果:"..tostring(output:get(0)))
	return xtable.parse(output:get(0), 1)
end

return _dbg
