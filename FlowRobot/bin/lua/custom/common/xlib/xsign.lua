require 'xstring'
require 'xtable'
require 'xqstring'
require 'xutility'

module ("xsign", package.seeall)

require_fields="sign,method,timestamp,v"



empty=function(q,req,p)
	local qstring=type(q)=="userdata" and xqstring:new(q) or q
	local fields=p or require_fields
	local nreq=xstring.trim(req,",")
	if(not(xstring.empty(fields))) then
		nreq = nreq..","..fields
	end
	local lst=xstring.split(nreq,",")
	local max=xtable.size(lst)

	for i=1,max,1 do
		if(xstring.empty(qstring:get(lst[i]))) then
			return true
		end
	end
	return false
end


check=function(q,key)
	local qstring=type(q)=="userdata" and xqstring:new(q) or q
	local nqstring=xtable.clone(qstring)
	local charset=nqstring:get("charset") or "gbk"
	--nqstring:decode(charset)

	local xmethod=nqstring:get("method")
	local methods=xstring.split(xmethod,"/")
	local method=methods[#methods]
	local sign=nqstring:get("sign")
	local sign_method = nqstring:get("sign_method") or "md5"
	nqstring:remove("sign")
	nqstring:remove("method")
	nqstring:add("method",method)
	nqstring:sort()
	local raw=key..nqstring:make({kvc="",sc="",req=true,ckey=true,encoding=charset})..key
	local csign=string.upper(xutility.md5.encrypt(raw,charset))
	return csign==string.upper(sign),raw
end

make=function(input,charset,key)
	local qstring = xqstring:new(input)
	qstring:remove("signature")
	qstring:sort()
	local raw= key..qstring:make({kvc="",sc=""})..key
print(xtable.tojson(input))
	print("raw:"..raw)
	return string.upper(xutility.md5.encrypt(raw,charset))
end



--print(make({params={{k='id',v='1'},{k='aname',v='colin'}}},'gbk',"2222"))
--print(make({id=1,aname='colin'},'gbk',"2222"))





