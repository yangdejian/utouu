require "custom.ui.windowPathTokenStream"
require "custom.ui.windowPathMatcher"

_remoteWindowPath={_isroot = false}
function _remoteWindowPath:new(oo)
	 local obj = oo or {}
	setmetatable(obj,self)
	self.__index=self
	obj._matcher={}
	return obj
end

--构造函数
function remoteWindowPath(path)
	local obj = _remoteWindowPath:new()

	--解析语法
	local stream = windowPathTokenStream(path)
	local ch = stream:pregetBoundary()
	if(ch == "/") then
		obj._isroot = true
		stream:getBoundary()
	end

	while(not stream:empty()) do
		local matcher = windowPathMatcher(stream)
		obj._matcher[#obj._matcher + 1] = matcher

		local sep = stream:getBoundary()
		if(sep == "") then
			break
		elseif(sep ~= "/") then
			print(sep)
			error("syntax error:separator is error")
		end
	end

	return obj
end

--从集合获取一个满足条件的窗口
function _remoteWindowPath:selectOne(vec)
    local v = self:selectAll(vec)
	if(v:size() >0) then
		return v:get(0)
	else
		return nil
	end
end

--从集合中获取所有满足条件的窗口
function _remoteWindowPath:selectAll(vec)
	local vecRet = vec
	for i=1,#self._matcher do
		local v = vecRet
		local vecTemp = ui.TRemoteWindowVector()
		for j = 0,v:size() - 1 do
			local w = v:get(j)
			if(self._matcher[i]:match(w)) then
				vecTemp:add(w)
			end
		end

		--检查是否还需要进行处理
		if(i >= #self._matcher) then
			vecRet = vecTemp
		else
			--获取子窗口
			vecRet = ui.TWindowVector()
			for j = 0,vecTemp:size() - 1 do
				vecTemp:get(j):GetChilds(vecRet)
			end
		end
	end
	return vecRet
end


function _remoteWindowPath:print()
	print(string.format("root=%s",tostring(self._isroot)))
	for i = 1,#self._matcher do
		self._matcher[i]:print()
	end

end
