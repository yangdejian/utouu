require 'sys'
require 'custom.common.wclient'

distrb_task = {fields = "min_bonus,min_profit_rate,ft_date,analyze_group_code"} --ft_date:'08'

distrb_task.datafile = require 'utouu.datafile'
distrb_task.CONFIG = {errlog=[[..\FlowError.txt]]} 
distrb_task.http = wclient()

distrb_task.main = function(args)
	print("----------------ɸѡ��Ҫ�����ĸ�----------------")
	print("I. ���������")
	local params=xtable.parse(args[2], 1)
	if(xobject.empty(params, distrb_task.fields)) then
		error("ȱ�ٱ������")
		return
	end

	print("II. ����������")
	local ret,msg,succ_count = distrb_task.main_flow(params)
	if(not ret) then
		error('������ִ��ʧ��:'..tostring(msg))
	end

	print('III. ��ȡ���')
	local ret,err = distrb_task.datafile.read_over({
		is_succ = ret,msg = msg,total_count = succ_count
	})
	if(not ret) then
		error('�����ȡ״̬ʧ��,'..tostring(err))
	end

	print('����ִ�����,is_ok:'..tostring(ret))
end

distrb_task.main_flow = function(params)
	print('1. ��ʼ��ȡ')
	local ret,err = distrb_task.datafile.start_read()
	if(not ret) then
		error('��ʼ��ȡ״̬����,'..tostring(err))
		return false,tostring(err)
	end

	print('2. װ�����еĸ�')
	local govs = distrb_task.datafile.DATAS_Items()
	if(xtable.empty(govs)) then
		print('û���κθ�����')
		return false,'û���κθ����ݿɹ�����!'
	end

	print('3. ɸѡ��:�ֺ����NԪ��,�ֺ���=������')
	local send_datas = {}
	for i,v in pairs(govs) do
		if(not xstring.empty(v.stock_avg_bonus) and tonumber(v.stock_avg_bonus) >= tonumber(params.min_bonus)) then
			if(xstring.empty(v.ft_date) or tostring(v.ft_date) == params.ft_date) then
				table.insert(send_datas,{
					name = v.name,
					code = v.code,
					id = v.id,
					min_bonus = params.min_bonus,
					ft_date = params.ft_date,
					min_profit_rate = params.min_profit_rate
				})
			end
		end
	end

	print('4. �����������̶���,����:'..tostring(#send_datas))
	local queues=xmq(params.analyze_group_code)
	local res=queues:send(send_datas)
	print(res and '���з��ͳɹ�!' or '���з���ʧ��!')

	return true,'ɸѡ���!',#send_datas
end

return distrb_task