require 'sys'
require 'custom.common.wclient'

all_update_from_TC = {fields="start_page_index"}

all_update_from_TC.comm = require 'utouu.comm'
all_update_from_TC.datafile = require 'utouu.datafile'

all_update_from_TC.CONFIG = {timeout=3000}
all_update_from_TC.http = wclient()

all_update_from_TC.main = function(args)
	print("----------------�������еĸ���Ϣ(��������)----------------")

	print("I. ���������")
	local params = xtable.parse(args[2], 1)
	if(xobject.empty(params, all_update_from_TC.fields)) then
   		print("ȱ�ٲ���")
		return
	end

	print('II. ����������')
	local ret,err,succ_count = all_update_from_TC.main_flow(params)

	print('IV. ������½��')
	local ret,err = all_update_from_TC.datafile.update_over({
		is_succ = ret,
		msg = tostring(err),
		total_count = succ_count
	})
	if(not ret) then error('���½������ʧ��,err:'..err) end

	print('����ִ�����,is_ok:'..tostring(ret))
end

all_update_from_TC.main_flow = function(params)
	print('1. ��ʼ����')
	local ret,err = all_update_from_TC.datafile.start_update()
	if(not ret) then
		error('��ʼ����ʧ��,'..tostring(err))
		return false,err
	end

	print('2. ��ȡ������')
	local ret,datas = all_update_from_TC.get_all_utcard_list(params)
	if(not ret) then
		error('��ȡ�����ݴ���,'..tostring(datas))
		return false,datas
	end

	print('3. ���¸�����')
	local succ_count = 0
	for i,v in pairs(datas) do
		local ret = all_update_from_TC.datafile.update_utcard(v)
		if(ret) then succ_count = succ_count + 1 end
	end
	return true,(succ_count==#datas and '����ȫ�����!' or '���²������!'),succ_count
end

all_update_from_TC.get_all_utcard_list = function(params)
	print('��ȡ���е��ǿ��б�')
	local govs = {}
	local i = params.start_page_index
	local err = nil
	while true do
		local ret,arr = all_update_from_TC.query_page_x(i)
		if(not ret) then
			err = tostring(arr)
			error('��ѯʧ��:'..err)
			break
		end
		if(xtable.empty(arr)) then
			error('�Ѿ�û��������!')
			break
		end
		table.insert(govs,arr)
		i = i + 1
	end
	if(err) then
		return false,err
	end

	print('�����������')
	local return_data = {}
	for i,v in pairs(govs) do
		for j,gov in pairs(v) do

			--- ��һ����ӽ����ĸ�����Ҫ��ȡ�ֺ����ںͲ�������(��ȡ����������TODO)
			if(not all_update_from_TC.datafile.is_exists(gov.id)) then
				print('��ȡ�ֺ�����,ID:'..tostring(gov.id))
				local ret,bonus_date = all_update_from_TC.comm.get_bonus_date(all_update_from_TC.http,gov.id)
				if(not ret or xstring.empty(bonus_date)) then
					error("�޷���ȡ�ֺ�����,"..tostring(bonus_date))
					break
				end
				gov.ft_date = string.sub(bonus_date,-2)
			end

			--- ת���ϼ�ʱ��
			gov.ipo_time = xstring.empty(gov.ipo_time) and '' or os.date("%Y-%m-%d",tonumber(gov.ipo_time)/1000)
			table.insert(return_data,gov)
		end
	end

	print('return_data:'..xtable.tojson(return_data))
	return true,return_data
end

all_update_from_TC.query_page_x = function(page_index)
	print(string.format('..... �� �� �� %s ҳ �� �� �� .....',page_index))

	local request_input = all_update_from_TC.header.utcard_list(page_index)
	print('input:'..xtable.tojson(request_input))
	local content = all_update_from_TC.http:query(request_input, {}, all_update_from_TC.CONFIG.timeout)
	--print('content:'..tostring(content))

	if(xstring.empty(content)) then
		return false,'���󷵻ؿ�'
	end

	local obj = xtable.parse(content)
	if(not obj.success) then
		return false,'��ѯʧ��:'..xtable.tojson(obj)
	end

	print('total:'..tostring(obj.data.total))
	return true,obj.data.rows

end

all_update_from_TC.header = {}
all_update_from_TC.header.utcard_list = function(page_index)
    return {
		method = "post",
		encoding = "UTF-8",
		content = "text",
		gzip = true,
		data = 'ipo_time=1&sort=stock_trade_price&order=DESC&page='..tostring(page_index)..'&limit=20',
		url = 'http://www.utcard.cn/utcard/listpage',
		header = [[Host: www.utcard.cn
Connection: keep-alive
Accept: application/json, text/javascript, */*; q=0.01
Origin: http://www.utcard.cn
X-Requested-With: XMLHttpRequest
User-Agent: Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/45.0.2454.101 Safari/537.36
Content-Type: application/x-www-form-urlencoded; charset=UTF-8
Referer: http://www.utcard.cn/trade-center
Accept-Encoding: gzip, deflate
Accept-Language: zh-CN,zh;q=0.8]]
	}
end


return all_update_from_TC