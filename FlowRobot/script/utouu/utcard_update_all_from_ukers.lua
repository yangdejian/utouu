require 'sys'
require 'custom.common.wclient'

all_update_inukers = {}

all_update_inukers = {fields="command"}
all_update_inukers.CONFIG = {timeout=3000,utcard_data=[[..\UTCardData.txt]]}
all_update_inukers.card_data_nodes = {summary='FileState',data='UTCardDatas'}
all_update_inukers.enums = {
	update_status = {wait='20',doing='30',success='0',failure='90'},
	read_status = {wait='20',doing='30',success='0',failure='90'}
}
all_update_inukers.http = wclient()

all_update_inukers.main = function(args)
	print("----------------�������еĸ���Ϣ(ukers)----------------")

	print("I. ���������")
	local params = xtable.parse(args[2], 1)
	if(xobject.empty(params, all_update_inukers.fields)) then
   		print("ȱ�ٲ���")
		return
	end

	print('II. ������״̬')
	local ret,err = all_update_inukers.check_update_status()
	if(not ret) then
		error('��ʱ�޷�����,'..tostring(err))
		return
	end

	print('III. ��ȡ���еĸ�')
	local ret,all_govs = all_update_inukers.get_all_utcard_list()
	

	print('IV. ���¸���Ϣ')
	all_update_inukers.save_update_result(ret,all_govs)

	print('����ִ�����')



	--[[print("3. ɸѡ������������ĸ�")
	local ft_govs = {}
	for i,v in pairs(govs) do
		print(string.format('������:%s(����:%s,id:%s_tid:%s)',
			tostring(v.name),
			tostring(v.code)
			tostring(v.id),
			tostring(v.this_id)))

		--- ������ǵĸ����Ҵ�����С�ֺ�
		if(tostring(v.ft_date) == os.date('%Y-%m-%d',os.time())
			and tonumber(v.stock_avg_bonus) >= tonumber(params.min_bonus)) then
			v.min_bonus = params.min_bonus
			table.insert(ft_govs,v)
		end
	end

	print(string.format('4�����͸���������(%s����)',tostring(#ft_govs)))
	local queues=xmq(all_update_inukers.CONFIG.analyze_group_code)
	local res=queues:send(ft_govs)
	print(res and '���з��ͳɹ�!' or '���з���ʧ��!')]]
end

--- ���״̬�Ƿ�Ϊ�ȴ�����+��ȡ״̬Ϊ����
all_update_inukers.check_update_status = function()
	print('��鵱ǰ�Ƿ���Ը��¸�����(�����ظ�д����߶�ȡ�����ݹ���)')
	local node_summary = all_update_inukers.card_data_nodes.summary
	local node_datas = all_update_inukers.card_data_nodes.data
	local file = all_update_inukers.CONFIG.utcard_data

	local update_status = base.ReadString(node_summary, 'UpdateStatus', '', file)
	if(xstring.empty(update_status)) then
		print('д���ʼ����')
		base.WriteString(node_summary, 'LastUpdateTime', os.date('%Y%-m-%d %H:%M:%S',os.time()), file)
		base.WriteString(node_summary, 'UpdateStatus', all_update_inukers.enums.update_status.doing, file)
		base.WriteString(node_summary, 'ReadStatus', all_update_inukers.enums.read_status.success, file)
		return true
	end
	if(update_status ~= all_update_inukers.enums.update_status.wait) then
		return false,'����״̬�����ǵȴ�,��ǰΪ:'..tostring(update_status)
	end
	local read_status = base.ReadString(node_summary, 'ReadStatus', '', file)
	if(read_status == all_update_inukers.enums.read_status.wait 
		or read_status == all_update_inukers.enums.read_status.doing) then
		return false,'�ļ����ڻ�׼������ȡ'
	end

	base.WriteString(node_summary, 'LastUpdateTime', os.date('%Y%-m-%d %H:%M:%S',os.time()), file)
	base.WriteString(node_summary, 'UpdateStatus', all_update_inukers.enums.update_status.doing, file)
	return true
end

all_update_inukers.save_update_result = function(ret,all_govs)
	print("������½��")
	local node_summary = all_update_inukers.card_data_nodes.summary
	local node_datas = all_update_inukers.card_data_nodes.data
	local file = all_update_inukers.CONFIG.utcard_data

	local update_status = (ret and all_update_inukers.enums.update_status.success or all_update_inukers.enums.update_status.failure)
	local update_msg = (ret and '���³ɹ���' or tostring(all_govs))
	base.WriteString(node_summary, 'LastUpdateTime', os.date('%Y%-m-%d %H:%M:%S',os.time()), file)
	base.WriteString(node_summary, 'UpdateStatus', update_status, file)
	base.WriteString(node_summary, 'ResultMsg', update_msg, file)
	base.WriteString(node_summary, 'DataFormat', 'ID|����|����|����|���¼�|�ɽ���|����|������|������', file)
	if(ret) then
		for i,v in pairs(all_govs) do
			print(string.format('...... �� �� �� %s ҳ �� �� �� .......',tostring(i)))
			for j,gov in pairs(v) do
				local content = string.format('%s|%s|%s|%s|%s|%s|%s|%s|%s',
					tostring(gov.id),
					tostring(gov.name),
					tostring(gov.code),
					tostring(gov.stock_avg_bonus),
					tostring(gov.price),
					tostring(gov.trade_amount),
					tostring(gov.pop_number),
					tostring(gov.ft_date),
					tostring(gov.date))
				base.WriteString(node_datas, gov.id, content, file)
			end
		end
	end
end

all_update_inukers.get_all_utcard_list = function()
	print('��ȡ���е��ǿ��б�')
	local govs = {}
	local i = 1
	local err = nil
	while true do
		local ret,arr = all_update_inukers.query_page_x(i)
		if(not ret) then
			err = tostring(arr)
			error('��ѯʧ��:'..err)
			break
		end
		if(xtable.empty(arr)) then
			print('�Ѿ�û��������!')
			break
		end
		table.insert(govs["page"..tostring(i)],arr)
		i = i + 1
	end
	if(err) then
		return false,err
	end
	return true,govs
end

all_update_inukers.query_page_x = function(page_index)
	print(string.format('..... �� �� �� %s ҳ �� �� �� .....',page_index))
	local post_data = string.format("page=%s&f_name=&dtk=",page_index)
	local request_input = all_update_inukers.get_all_update_inukers_params(post_data)
	print('input:'..xtable.tojson(request_input))
	local content = all_update_inukers.http:query(request_input, {}, all_update_inukers.CONFIG.timeout)
	print('content:'..tostring(content))

	if(xstring.empty(content)) then
		return false,'���󷵻ؿ�'
	end
	if(not xstring.start_with(content,'{')) then
		return false,'���صĸ�ʽ��json'
	end

	local obj = xtable.parse(content)
	if(not obj.success) then
		return false,'��ѯʧ��:'..xtable.tojson(obj)
	end

	return true,obj.data

end

all_update_inukers.get_all_update_inukers_params = function(post_data)
    return {
		method = "get",
		encoding = "UTF-8",
		content = "text",
		gzip = true,
		data = post_data,
		url = 'http://www.sinopecsales.com/gas/webjsp/netRechargeAction_queryCardOrderOfCzk.json',
		header = [[Accept:application/json, text/javascript, */*; q=0.01
Accept-Encoding:gzip, deflate, sdch
Accept-Language:zh-CN,zh;q=0.8
Cache-Control:max-age=0
Connection:keep-alive
Host:www.ukers.cn
Referer:http://www.ukers.cn/home/Ukers
User-Agent:Mozilla/5.0 (Windows NT 6.1) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/45.0.2454.101 Safari/537.36
X-Requested-With:XMLHttpRequest]]
	}
end

return all_update_inukers