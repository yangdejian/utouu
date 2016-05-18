widget = require("custom.widget")
--[[
功能：Lua操作日期函数
作者：游书兵
修改记录：
]]
luadate={}

--[[
功能：获取当前系统毫秒时间
参数：
]]
luadate.micro_time = function()
	return widget.microtime()
end

--[[
功能：获取指定时间偏移天后的日期时间
参数：
	orignTime-原始时间(格式必须是yyyyMMddHHmmss)
	interval-偏移值(必须是整数)
	retFormat - 返回日期格式
]]
luadate.add_day = function(orignTime,interval,retFormat)
	local current_time = luadate.ofsetTime(orignTime,interval,"DAY")
	return os.date(retFormat,current_time)
end

--[[
功能：获取指定时间偏移分钟后的日期时间
参数：
	orignTime-原始时间(格式必须是yyyyMMddHHmmss)
	interval-偏移值(必须是整数)
	retFormat - 返回日期格式
]]
luadate.add_minute = function(orignTime,interval,retFormat)
	local current_time = luadate.ofsetTime(orignTime,interval,"MINUTE")
	return os.date(retFormat,current_time)
end

--[[
功能：获取指定时间偏移秒后的日期时间
参数：
	orignTime-原始时间(格式必须是yyyyMMddHHmmss)
	interval-偏移值(必须是整数)
	retFormat - 返回日期格式
]]
luadate.add_second = function(orignTime,interval,retFormat)
	local current_time = luadate.ofsetTime(orignTime,interval,"SECOND")
	return os.date(retFormat,current_time)
end

--[[
功能：获取指定时间偏移后的日期时间
参数：
	orignTime-原始时间(格式必须是yyyyMMddHHmmss)
	interval-偏移值(必须是整数)
	dateUnit-偏移单位(天:DAY;小时:HOUR;分钟:MINUTE;秒:SECOND)
]]
luadate.ofsetTime = function(orignTime,interval,dateUnit)
	--从日期字符串中截取出年月日时分秒
    local Y = string.sub(orignTime,1,4)
    local M = string.sub(orignTime,5,6)
    local D = string.sub(orignTime,7,8)
    local H = string.sub(orignTime,9,10)
    local MM = string.sub(orignTime,11,12)
    local SS = string.sub(orignTime,13,14)

    --把日期时间字符串转换成对应的日期时间
    local dt1 = os.time{year=Y, month=M, day=D, hour=H,min=MM,sec=SS}

    --根据时间单位和偏移量得到具体的偏移数据
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

    --指定的时间+时间偏移量
    local newTime = os.date("*t", dt1 + tonumber(ofset))
    return newTime
end


