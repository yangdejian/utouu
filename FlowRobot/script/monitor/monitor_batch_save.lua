require "sys"

monitor_batch_save = {}
monitor_batch_save.dbg = xdbg()

monitor_batch_save.main = function(args)
	print("-------------���������������-------------")
	print("1. ��ȡ����")
	local params = xtable.parse(args[2])
	if(not(xtable.isarray(params))) then
		print("ERR �����������lua����")
		return false
	end

	print("��������:"..tostring(#params))

	for i,v in pairs(params) do
		print("name:::"..tostring(v.name))
	end


	print("2. �������ݲ㱣������")
	local dbg_result = monitor_batch_save.dbg:execute("monitor.monitor.batch_save", params)
	if(dbg_result.result.code ~= sys.error.success.code) then
		print(string.format("����������ʧ��,�ű�����:%s,������:%s", "monitor_batch_save", dbg_result.result.code))
	end

	print("------ִ�����------")
end

return monitor_batch_save
