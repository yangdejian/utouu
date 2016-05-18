require "custom.ui.windowPathTokenStream"
require "custom.ui.windowPathMatcher"
require "custom.ui.remoteWindowPath"

remoteWindowlib={}
remoteWindowlib.selectOne = function(vec,path)
	local matcher = remoteWindowPath(path)
	return matcher:selectOne(vec)
end

remoteWindowlib.selectAll = function(vec,path)
	local matcher = remoteWindowPath(path)
	return matcher:selectAll(vec)
end


return remoteWindowlib

