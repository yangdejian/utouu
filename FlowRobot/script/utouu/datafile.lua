--[[
  filedata.txt �ļ���ʽ:
  [UpdateSummary]
  Status = 30
  LastStartTime = 2016-05-07 08:19:00
  LastOverTime = 2016-05-07 08:22:00
  Result = '���ڸ���'
  TotalCount = 2065

  [ReadSummary]
  Status = 30
  LastStartTime = 2016-05-07 08:19:00
  LastOverTime = 2016-05-07 08:22:00
  Result = '���ڶ�ȡ'
  TotalCount = 5

  [Datas]
  ID = ID|����|����|����|�¸�������|���¼�|�ϼ�ʱ��|�ɽ���|����|������
  2038 = 2038|�ζ�|18454|1.65|2016-05-07|30.00|2014-05-07 11:12:00|50|428|2016-08-01
  ...

]]
-- os.date("%Y-%m-%d %H:%M:%S",1422979200000/1000)
require "xqstring"


datafile = {
	fields = 'ft_date,people,'
		..'id,name,code,stock_avg_bonus,price,trade_amount,ipo_time,change,change_ratio,first_tradingday,highest,lowest,trade_price,zombie',
	path = '../UTCardData.txt',
	node_UpdateSummary = 'UpdateSummary',
	attr_UpdateSummary_Status = 'Status',
	attr_UpdateSummary_LastStartTime = 'LastStartTime',
	attr_UpdateSummary_LastEndTime = 'LastOverTime',
	attr_UpdateSummary_Result = 'Result',
	attr_UpdateSummary_TotalCount = 'TotalCount',

	node_ReadSummary = 'ReadSummary',
	attr_ReadSummary_Status = 'Status',
	attr_ReadSummary_LastStartTime = 'LastStartTime',
	attr_ReadSummary_LastEndTime = 'LastOverTime',
	attr_ReadSummary_Result = 'Result',
	attr_ReadSummary_TotalCount = 'TotalCount',

	node_Datas = 'Datas',
	attr_Datas_ID = 'utCardID',

	UPD_Status = function(data)
		if(xstring.empty(data)) then
			return base.ReadString(datafile.node_UpdateSummary,datafile.attr_UpdateSummary_Status,nil,datafile.path)
		else
			base.WriteString(datafile.node_UpdateSummary,datafile.attr_UpdateSummary_Status,data,datafile.path)
			return true
		end
	end,

	UPD_LastStartTime = function(data)
		if(xstring.empty(data)) then
			return base.ReadString(datafile.node_UpdateSummary,datafile.attr_UpdateSummary_LastStartTime,nil,datafile.path)
		else
			base.WriteString(datafile.node_UpdateSummary,datafile.attr_UpdateSummary_LastStartTime,data,datafile.path)
			return true
		end
	end,

	UPD_LastEndTime = function(data)
		if(xstring.empty(data)) then
			return base.ReadString(datafile.node_UpdateSummary,datafile.attr_UpdateSummary_LastEndTime,nil,datafile.path)
		else
			base.WriteString(datafile.node_UpdateSummary,datafile.attr_UpdateSummary_LastEndTime,data,datafile.path)
			return true
		end
	end,

	UPD_Result = function(data)
		if(xstring.empty(data)) then
			return base.ReadString(datafile.node_UpdateSummary,datafile.attr_UpdateSummary_Result,nil,datafile.path)
		else
			base.WriteString(datafile.node_UpdateSummary,datafile.attr_UpdateSummary_Result,data,datafile.path)
			return true
		end
	end,

	UPD_TotalCount = function(data)
		if(xstring.empty(data)) then
			return base.ReadString(datafile.node_UpdateSummary,datafile.attr_UpdateSummary_TotalCount,nil,datafile.path)
		else
			base.WriteString(datafile.node_UpdateSummary,datafile.attr_UpdateSummary_TotalCount,data,datafile.path)
			return true
		end
	end,

	RED_Status = function(data)
		if(xstring.empty(data)) then
			return base.ReadString(datafile.node_ReadSummary,datafile.attr_ReadSummary_Status,nil,datafile.path)
		else
			base.WriteString(datafile.node_ReadSummary,datafile.attr_ReadSummary_Status,data,datafile.path)
			return true
		end
	end,

	RED_LastStartTime = function(data)
		if(xstring.empty(data)) then
			return base.ReadString(datafile.node_ReadSummary,datafile.attr_ReadSummary_LastStartTime,nil,datafile.path)
		else
			base.WriteString(datafile.node_ReadSummary,datafile.attr_ReadSummary_LastStartTime,data,datafile.path)
			return true
		end
	end,

	RED_LastEndTime = function(data)
		if(xstring.empty(data)) then
			return base.ReadString(datafile.node_ReadSummary,datafile.attr_ReadSummary_LastEndTime,nil,datafile.path)
		else
			base.WriteString(datafile.node_ReadSummary,datafile.attr_ReadSummary_LastEndTime,data,datafile.path)
			return true
		end
	end,

	RED_Result = function(data)
		if(xstring.empty(data)) then
			return base.ReadString(datafile.node_ReadSummary,datafile.attr_ReadSummary_Result,nil,datafile.path)
		else
			base.WriteString(datafile.node_ReadSummary,datafile.attr_ReadSummary_Result,data,datafile.path)
			return true
		end
	end,

	RED_TotalCount = function(data)
		if(xstring.empty(data)) then
			return base.ReadString(datafile.node_ReadSummary,datafile.attr_ReadSummary_TotalCount,nil,datafile.path)
		else
			base.WriteString(datafile.node_ReadSummary,datafile.attr_ReadSummary_TotalCount,data,datafile.path)
			return true
		end
	end,

	DATAS_Title = function(data)
		if(xstring.empty(data)) then
			return base.ReadString(datafile.node_Datas,datafile.attr_Datas_ID,nil,datafile.path)
		else
			base.WriteString(datafile.node_Datas,datafile.attr_Datas_ID,data,datafile.path)
			return true
		end
	end,

    --- data=objʱ,Ϊ����id=data.id����
    --- ����,��Ϊ��ȡid=data�ĵ�������
	DATAS_Item = function(data)
		--- ������
		if(type(data) == 'table') then
			if(xstring.empty(data.id)) then 
				return false 
			end
			local content = datafile.transfer_data_fmt(data)
			local old_data = base.ReadString(datafile.node_Datas, tostring(data.id), '', datafile.path)

			if(string.sub(old_data,1,-21) == content) then
				print('����û�仯,���ø���')
				return true
			end
			content = content..'|'..os.date('%Y-%m-%d %H:%M:%S',os.time()) -- ׷��������ʱ��
			base.WriteString(datafile.node_Datas, tostring(data.id), content, datafile.path)
			return true
		end

		--- ȡ����
		if(xstring.empty(data)) then
			return {}
		end
		local utcard_str = base.ReadString(datafile.node_Datas, tostring(data), '', datafile.path)
		return datafile.transfer_data_fmt(utcard_str)
	end,

    --- ��ȡȫ����
	DATAS_Items = function()
		datafile.init()
		local return_data = {}
		local file = io.open(datafile.path,"r")
		local flag = false
		for l in file:lines() do
			if(flag and not xstring.empty(l)) then
				local a,b = string.gsub(l, "^(%d+=)", "") -- ȥ��ǰ���id=
				table.insert(return_data,datafile.transfer_data_fmt(a))
			end
			local a,b = string.find(tostring(l),'utCardID=')
			if(a ~= nil and b~= nil) then
				flag = true
			end
		end
		file:close()
		print('return_data:'..tostring(#return_data))
		return return_data
	end
}

datafile.comm = require "utouu.comm"



--- �����ļ���ʼ��
datafile.init = function()
	local is_exists = datafile.comm.file_exists(datafile.path)
	if(not is_exists) then
		datafile.UPD_Status(datafile.comm.update_status.not_start)
		datafile.UPD_LastStartTime('-1')
		datafile.UPD_LastEndTime('-1')
		datafile.UPD_Result('��ʼ��')
		datafile.UPD_TotalCount('0')

		datafile.RED_Status(datafile.comm.read_status.not_start)
		datafile.RED_LastStartTime('-1')
		datafile.RED_LastEndTime('-1')
		datafile.RED_Result('��ʼ��')
		datafile.RED_TotalCount('0')

		local fields_tab = xstring.split(datafile.fields,',')
		table.sort(fields_tab)
		local data_fmt = xstring.join(fields_tab)
		datafile.DATAS_Title(data_fmt)
	end
end
datafile.init()

--- ��ʼ����
datafile.start_update = function()
	local update_status = datafile.UPD_Status()
	if(update_status ~= datafile.comm.update_status.wait) then
		return false,'����״̬����'
	end
	local read_status = datafile.RED_Status()
	if(read_status ~= datafile.comm.read_status.success and read_status ~= datafile.comm.read_status.failure) then
		return false,'��ȡ״̬����'
	end
	datafile.UPD_Status(datafile.comm.update_status.doing)
	datafile.UPD_LastStartTime(datafile.get_now('-'))
	datafile.UPD_Result('���ڸ���...')
	return true
end

--- ���Ƿ����
--- id:utcard_id
--- return boolean
datafile.is_exists = function(id)
	return (not xtable.empty(datafile.DATAS_Item(id)))
end

--- ��ȡ������
--- id:utcard_id
--- return {id,name,code,avg_bonus,price,trade_amount,people,ft_date}
datafile.get_utcard = function(id)
	local utcard_info = datafile.DATAS_Item(id)
	if(xtable.empty(utcard_info)) then
		print(string.format('δ�ҵ���ID=%s',tostring(id)))
	end
	return utcard_info
end

--- ���¿�����
datafile.update_utcard = function(data)
	local old_utcard = datafile.get_utcard(data.id)
	local new_utcard = xtable.merge(old_utcard,data)
	local ret = datafile.DATAS_Item(new_utcard)
	if(not ret) then
		error('���¸�ʧ��,new_utcard:'..xtable.tojson(new_utcard))
	end
	return ret
end

--- �������
--- data:{is_succ,msg,total_count}
datafile.update_over = function(data)
	local update_status = datafile.UPD_Status()
	if(update_status ~= datafile.comm.update_status.doing) then
		return false,'���½���ʱ,��鵽����״̬����'
	end
	local update_status = data.is_succ and datafile.comm.update_status.success or datafile.comm.update_status.failure
	datafile.UPD_Status(update_status)
	datafile.UPD_LastEndTime(datafile.get_now('-'))
	datafile.UPD_Result(tostring(data.msg))
	datafile.UPD_TotalCount(tostring(data.total_count))
	return true
end

--- ��ʼ��ȡ
datafile.start_read = function()
	local read_status = datafile.RED_Status()
	if(read_status ~= datafile.comm.read_status.wait) then
		return false,'��ȡ״̬����'
	end
	local update_status = datafile.UPD_Status()
	if(update_status ~= datafile.comm.update_status.success and update_status ~= datafile.comm.update_status.failure) then
		return false,'����״̬����'
	end
	datafile.RED_Status(datafile.comm.read_status.doing)
	datafile.RED_LastStartTime(datafile.get_now('-'))
	datafile.RED_Result('���ڶ�ȡ...')
	return true
end

--- ��ȡ���
--- data:{is_succ,msg,total_count}
datafile.read_over = function(data)
	local read_status = datafile.RED_Status()
	if(read_status ~= datafile.comm.read_status.doing) then
		return false,'��ȡ����ʱ,��鵽��ȡ״̬����'
	end
	local read_status = data.is_succ and datafile.comm.read_status.success or datafile.comm.read_status.failure
	datafile.RED_Status(read_status)
	datafile.RED_LastEndTime(datafile.get_now('-'))
	datafile.RED_Result(tostring(data.msg))
	datafile.RED_TotalCount(tostring(data.total_count))
	return true
end

datafile.get_now = function(fmt)
	if(fmt == '-') then
		return os.date('%Y-%m-%d %H:%M:%S',os.time())
	end
	return os.date('%Y%m%d%H%M%S',os.time())
end

--- �����ݻ�ת
--- data=string,return obj
--- data=obj,return string
datafile.transfer_data_fmt = function(data)
	local fields_str = datafile.fields
	local fields_tab = xstring.split(fields_str,',')
	table.sort(fields_tab)

	if(type(data) == 'string') then
		if(xstring.empty(data)) then
			print('ת��ʱ,�ṩ��dataΪ��')
			return {}
		else
			local return_data = {}
			local arr = xstring.split(data,'|')
			for i,v in ipairs(arr) do
				local key = fields_tab[i]
				if(key == nil) then break end
				return_data[key] = xstring.empty(v) and nil or tostring(v)
			end
			return return_data
		end
	end
	if(type(data) == 'table') then
		if(xtable.empty(data)) then
			print('ת������ʱ,dataΪ��')
			return ''
		else
			local content = ''
			for i,v in ipairs(fields_tab) do
				content = content..(xstring.empty(data[v]) and '' or tostring(data[v]))..'|'
			end
			return xstring.rtrim(content,'|')
		end
	end
	return nil
end

return datafile