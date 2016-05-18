require 'custom.common.utils'
require "custom.common.dblib"
function main()
	--Delete()
	get_list()
end

function send()
	local adapter = mq.MQAdapter("server0")
	local ret = adapter:SaveData("FR.OrderWaitBind",{"F2015081409532833425"},180000,true) --��������
	print("������:" .. tostring(ret))
end

function rev()
	local adapter = mq.MQAdapter("server0")
	local vec = base.StringVector()
	local ret = adapter:GetData("FR.WaitBindOrder",5,vec)  --��ȡ����
	print("�������ݿ�ʼ")
	if(ret)then
		print("size:".. tostring(vec:size()))
		for i=0,vec:size()-1,1 do
			print("i:" .. ":" .. tostring(vec:get(i)))
		end
	else
		print("û������")
	end
	print("�������")
end


function get_list()
	print("ȡ���ж��г���")
	local adapter = mq.MQAdapter("server0")
	local vec = base.StringVector()
	local status = adapter:All(vec)
	if(not status)then
		print("��ȡ���������б�ʧ��")
	end
	print("==========================�����б�============================")
	for i=0,vec:size()-1,1 do
		local name = vec:get(i)
		local count = adapter:Count(name)
		print(string.format("[%2s]%-40s����:%s",i,tostring(name),tostring(count)))
	end
	print("============================���==============================")
end
--ɾ��
function Delete()
	local adapter = mq.MQAdapter("server0")
	local status = adapter:Delete("FR.OrderWaitNotify.b")
	print("ɾ�����:" .. tostring(status))
end

