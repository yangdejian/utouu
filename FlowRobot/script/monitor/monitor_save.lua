require "sys"

monitor_save = {}
monitor_save.dbg = xdbg()

monitor_save.main = function(args)
	print("-------------������ݱ���-------------")
	print("1. ��ȡ����")
	local params = xtable.parse(args[2], 1)
	local queue_name = args[3]

	print("2. �������ݲ㱣������")
	local dbg_result = monitor_save.dbg:execute("monitor."..tostring(queue_name), params)
	if(dbg_result.result.code ~= sys.error.success.code) then
		print(string.format("����������ʧ��,��������:%s,������:%s", queue_name, dbg_result.result.code))
	end

	print("------ִ�����------")
end

return monitor_save
