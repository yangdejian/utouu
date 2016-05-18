require 'CLRPackage'

import('Lib4Net4.Scripts')
import('Lib4Net.Scripts')
import('Lib4Net.Scripts.Data')
import('Lib4Net.Scripts.DB')
import('Lib4Net.Scripts.IO')
import('Lib4Net.Scripts.Html')
import('Lib4Net.Scripts.Net')
import('Lib4Net.Scripts.Services')
import('Lib4Net.Scripts.Xml')
import('Lib4Net.Scripts.UI')
import('Lib4Net.Scripts.OS')
import('Lib4Net.Scripts.Pool')
import('Lib4Net.Scripts.Web')
import('Lib4Net.Scripts.Words')


local p = [[../bin/clibs]]

 m_package_path = package.path
package.path = string.format('%s;%s/?.lua;%s/?.luac;%s/?.dll',
	m_package_path, p,p,p)

--[[
function to_string(e)
	if(e==nil) then
		return ""
	end
	return tostring(e)
end


__csrobot=true


funs={}

function funs:new(obj,oo)
	local o=oo or {}
	setmetatable(o,self)
	self.__index=funs
	self.obj=obj
	self.funs={}
	return o
end

function funs:add(fun,...)
   local index=#self.funs+1
   self.funs[index]={}
   self.funs[index].fun=fun
   self.funs[index].params=...
end

function funs:call(xi)
  local xindex=tonumber(xi)
   if(xindex==nil or xi==nil or xindex<=0) then
		xindex=1
   end
   local x,y=true,""
   for i=xindex,#self.funs,1 do
      x,y=pcall(self.funs[i].fun,self.obj,self.funs[i].params)
	  if(not(x)) then
		return x,y,i
	  end
	  if(not(y)) then
		return x,y,i
	  end
   end
   return x,y,i
end

function funs:pcall(xi)
  local xindex=tonumber(xi)
   if(xindex==nil or xi==nil or xindex<=0) then
		xindex=1
   end
   local x,y=true,""
   for i=xindex,#self.funs,1 do
      x,y=pcall(self.funs[i].fun,self.funs[i].params)
	  if(not(x)) then
		return x,y,i
	  end
	  if(not(y)) then
		return x,y,i
	  end
   end
   return x,y,i
end


function funs:ccall(xi)
  local xindex=tonumber(xi)
   if(xindex==nil or xi==nil or xindex<=0) then
		xindex=1
   end
   local x,y=true,""
   for i=xindex,#self.funs,1 do
      x,y,m,n=pcall(self.funs[i].fun,self.funs[i].params)
	  if(not(x)) then
		return x,y,i,m,n
	  end
	  if(y) then
		return x,y,i,m,n
	  end
   end
   return x,y,i,m,n
end


function eval(str)
    if type(str) == "string" then
        return loadstring("return " .. str)()
    elseif type(str) == "number" then
        return loadstring("return " .. tostring(str))()
    else
        error("is not a string")
    end
end
]]

--[[

---仅供C++机器人使用＝＝＝＝＝＝＝＝＝＝＝＝＝＝＝

	require("comm/xhttp")
	require("comm/xhtml")
	require("comm/thttp")
	require("comm/xxml")

require("comm/ini")
require("comm/thread")


function debug(msg)
	WriteLog(3,"script",tostring(msg))
end

function fatal(msg)
	WriteLog(0,"script",tostring(msg))
end

function warn(msg)
	WriteLog(1,"script",tostring(msg))
end

function error(msg)
	WriteLog(0,"script",tostring(msg))
end

--===========================================
]]
