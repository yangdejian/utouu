widget = require("custom.widget")
--[[
���ܣ�Lua�������ں���
���ߣ������
�޸ļ�¼��
]]
luadate={}

--[[
���ܣ���ȡ��ǰϵͳ����ʱ��
������
]]
luadate.micro_time = function()
	return widget.microtime()
end

--[[
���ܣ���ȡָ��ʱ��ƫ����������ʱ��
������
	orignTime-ԭʼʱ��(��ʽ������yyyyMMddHHmmss)
	interval-ƫ��ֵ(����������)
	retFormat - �������ڸ�ʽ
]]
luadate.add_day = function(orignTime,interval,retFormat)
	local current_time = luadate.ofsetTime(orignTime,interval,"DAY")
	return os.date(retFormat,current_time)
end

--[[
���ܣ���ȡָ��ʱ��ƫ�Ʒ��Ӻ������ʱ��
������
	orignTime-ԭʼʱ��(��ʽ������yyyyMMddHHmmss)
	interval-ƫ��ֵ(����������)
	retFormat - �������ڸ�ʽ
]]
luadate.add_minute = function(orignTime,interval,retFormat)
	local current_time = luadate.ofsetTime(orignTime,interval,"MINUTE")
	return os.date(retFormat,current_time)
end

--[[
���ܣ���ȡָ��ʱ��ƫ����������ʱ��
������
	orignTime-ԭʼʱ��(��ʽ������yyyyMMddHHmmss)
	interval-ƫ��ֵ(����������)
	retFormat - �������ڸ�ʽ
]]
luadate.add_second = function(orignTime,interval,retFormat)
	local current_time = luadate.ofsetTime(orignTime,interval,"SECOND")
	return os.date(retFormat,current_time)
end

--[[
���ܣ���ȡָ��ʱ��ƫ�ƺ������ʱ��
������
	orignTime-ԭʼʱ��(��ʽ������yyyyMMddHHmmss)
	interval-ƫ��ֵ(����������)
	dateUnit-ƫ�Ƶ�λ(��:DAY;Сʱ:HOUR;����:MINUTE;��:SECOND)
]]
luadate.ofsetTime = function(orignTime,interval,dateUnit)
	--�������ַ����н�ȡ��������ʱ����
    local Y = string.sub(orignTime,1,4)
    local M = string.sub(orignTime,5,6)
    local D = string.sub(orignTime,7,8)
    local H = string.sub(orignTime,9,10)
    local MM = string.sub(orignTime,11,12)
    local SS = string.sub(orignTime,13,14)

    --������ʱ���ַ���ת���ɶ�Ӧ������ʱ��
    local dt1 = os.time{year=Y, month=M, day=D, hour=H,min=MM,sec=SS}

    --����ʱ�䵥λ��ƫ�����õ������ƫ������
    local ofset=0

    if dateUnit =='DAY' then
        ofset = 60 *60 * 24 * interval

    elseif dateUnit == 'HOUR' then
        ofset = 60 *60 * interval

 elseif dateUnit == 'MINUTE' then
        ofset = 60 * interval

    elseif dateUnit == 'SECOND' then
        ofset = interval
    end

    --ָ����ʱ��+ʱ��ƫ����
    local newTime = os.date("*t", dt1 + tonumber(ofset))
    return newTime
end


