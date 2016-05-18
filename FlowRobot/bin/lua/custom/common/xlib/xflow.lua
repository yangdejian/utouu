
require 'xtable'
module ("xflow", package.seeall)
function xflow:new(o)
	 o = o or {}
     setmetatable(o,self)
     self.__index = self
     o.flows={}
     return o
end

function xflow:add(f,arg,jump)
	table.insert(self.flows,xtable.merge({max=3},{f=f,arg=(arg or {}),jump=jump}))
end

function xflow:call(i)
	local index=i or 1
	local n=#self.flows
	while(index<=n) do
		local flow=self.flows[index]
		if(flow.exec==nil or flow.max==nil
			or flow.exec<flow.max) then
			--print("ִ��:"..index)
			local s,r=pcall(flow.f,unpack(flow.arg))
			flow.exec=flow.exec==nil and 1 or flow.exec+1
			if(not(s)) then
				return false,index,r
			end
			if(r==nil) then
				return false,index,string.format("����[%s]δָ������ֵ",index)
			end
			if(not(r)) then
				if(flow.jump==nil) then
					return false,index,string.format("����[%s]ִ��ʧ��",index)
				end
				print(string.format("����[%s]ִ��ʧ��,ת��������[%s]",index,tostring(flow.jump)))
				index=flow.jump
			end
		else
			return false,index,string.format("����[%s]ִ�г���ָ���Ĵ�������[%s]��",
				tostring(index),tostring(flow.max))
		end
	end
	return true,"����ִ�����"
end







