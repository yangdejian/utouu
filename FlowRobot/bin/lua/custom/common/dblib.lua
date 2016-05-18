require "sys"

_dblib = {}
--构造函数
function _dblib:new(oo)
	 local obj = oo or {}
	setmetatable(obj,self)
	self.__index=self
	obj._matcher={}
	return obj
end

--构造函数
function dblib(conn)
	local obj = _dblib:new()
	obj._adapter = db.DbAdapter(conn)
	return obj
end

function _dblib:execute(command, params)
	local output = base.StringVector()
	local ec = self._adapter:ExecuteNonQuery("dal_command", {command, xtable.tojson(params)}, output)
	return xtable.parse(output:get(0), 1)
end
