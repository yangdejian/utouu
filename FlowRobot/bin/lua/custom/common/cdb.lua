_cdb = {}

--构造函数
function _cdb:new()
	 local o = {}
	setmetatable(o,self)
	self.__index = self
	o._matcher={}
	return o
end

--内部函数
function _cdb:__execute_sql(sql,params,count)
	----执行SQL语句
	local dt = self._adapter:ExecuteQuery(sql,params)
	local cols = dt:GetColumnNames()

	ret={}
	local total=count or dt.Rows
	total=total>dt.Rows and dt.Rows or total
	for i = 1,total do
		ret[i]={}
	    for j = 1,dt.Columns,1 do
			ret[i][string.lower(cols[j])]=dt:Get(i-1,cols[j])
		end
	end

	return count == 1 and ret[total] or ret,cols
end

function _cdb:execute(content,input)
	local sp,params,output_names=self:get_procedure_params(content,input)
	for i,v in pairs(params) do
		print(string.format("i:%s,v:%s",tostring(i),tostring(v)))
	end
	local output=base.StringVector()
	local ec = self._adapter:ExecuteNonQuery(sp,params,output)
	local ret = {}
	for i=1,output:size(),1 do
		local fname=output_names[i] or i
		ret[fname] = output:get(i-1)
	end
	return ret
end

function _cdb:alter(content,input)
	local sql,params=self:get_sql_params(content,input)
	local output = base.StringVector()
	return self._adapter:ExecuteNonQuery(sql,params,output)
end

function _cdb:get_data(content,input,count)
	local sql,params=self:get_sql_params(content,input)
	return self:__execute_sql(sql,params,count)
end

function _cdb:scalar(content,input)
	local sql,params = self:get_sql_params(content,input)
	local data = self:__execute_sql(sql,params,1)
	for i,v in pairs(data) do
		return v
	end
	return nil
end

function _cdb:get_procedure_params(content,input)
	local index=0
	local params={}
	local output={}
	for match in string.gmatch(tostring(content),"{@[^{]+}") do
		index=index+1
		local fname=match:match("{@([^{]+)}")
		local pvalue=tostring(input[fname])
		content=string.gsub(content,match,"",1)
		table.insert(params,pvalue)
	end
	for match in string.gmatch(tostring(content),"{$[^{]+}") do
		index=index+1
		local fname=match:match("{$([^{]+)}")
		content=string.gsub(content,match,"",1)
		table.insert(output,fname)
	end
	return content,params,output
end

function _cdb:get_sql_params(content,input)
	local pattern = "{@[^{]+}"
	local index=0
	local params={}
	for match in string.gmatch(tostring(content),pattern) do
		index=index+1
		local fname=match:match("{@([^{]+)}")
		local pname=":p"..(index)
		local pvalue=tostring(input[fname])
		content=string.gsub(content,match,pname,1)
		table.insert(params,pvalue)
	end
	return content,params
end

--构造函数
function cdb(conn)
	local obj = _cdb:new()
	obj._adapter = db.DbAdapter(conn)
	return obj
end

