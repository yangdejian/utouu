funs={}

function funs:new(o,obj)
	o=o or {}
	setmetatable(o,self)
	self.__index=self
	funs.obj=obj
	funs.funs={}
	return o
end

function funs:add(fun,params)
   local index=#funs.funs+1
   funs.funs[index]={}
   funs.funs[index].fun=fun
   funs.funs[index].params=params
end

function funs:pcall(xi)
  local xindex=tonumber(xi)
   if(xindex==nil or xi==nil or xindex<=0) then
		xindex=1
   end
   local x,y=true,""
   for i=xindex,#funs.funs,1 do
      x,y=pcall(funs.funs[i].fun,funs.obj,funs.funs[i].params)
	  if(not(x)) then
		return x,y,i
	  end
	  if(not(y)) then
		return x,y,i
	  end
   end
   return x,y,i
end

