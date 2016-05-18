local bit=require 'bit'
module ("xbit", package.seeall)
cast=function(v)
	return bit.cast(v)
end
band=function(a,b)
	return bit.band(a,b)
end
bor=function(a,b)
	return bit.bor(a,b)
end
bxor=function(a,b)
	return bit.bxor(a,b)
end
bnot=function(a,b)
	return bit.bnot(a,b)
end
bnot=function(a,b)
	return bit.bnot(a,b)
end

rshift=function(a,b)
	return bit.rshift(a,b)
end
