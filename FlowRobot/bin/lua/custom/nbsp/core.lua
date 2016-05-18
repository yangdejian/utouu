require "custom.common.bit"
--命令字组成:命令类型(4字节)+模块编号(12bit)+消息编号(16bit)
NBSP_REQUEST_COMMAND_TYPE  = 0x0
NBSP_RESPONSE_COMMAND_TYPE = 0x1


function NBSP_MAKE_REQUEST_COMMAND(module,msg)
 return bit:_lshift(NBSP_REQUEST_COMMAND_TYPE,28) + bit:_lshift(module,16)+msg
end

function NBSP_MAKE_RESPONSE_COMMAND(module,msg)
   return bit:_lshift(NBSP_RESPONSE_COMMAND_TYPE,28) + bit:_lshift(module,16)+msg
end

function NBSP_COMMAND_TYPE(cmd)
	return bit:_and(bit:_rshift(cmd,28),0xF)
end

function NBSP_MAKE_KEY(module,v)
	return bit:_lshift(module,20)+v
end

function NBSP_MAKE_ERROR_CODE(module,v)
	return bit:_lshift(module,20)+v
end

--系统模块,其它模块在public文件夹定义
NBSP_SYSTEM_MODULE  = 0x000

--用户自定义模块
NBSP_MODULE_BASE  = 0x100

--通用的心跳命令
NBSP_COMMON_HEART_COMMAND 	= NBSP_MAKE_REQUEST_COMMAND(NBSP_SYSTEM_MODULE,0)
--分包的数据键值
NBSP_FRAGMENT_DATA_KEY 		= NBSP_MAKE_KEY(NBSP_SYSTEM_MODULE,0)
--数据键
NBSP_BASE_DATA_KEY 		= NBSP_MAKE_KEY(NBSP_SYSTEM_MODULE,1)
--长度
NBSP_BASE_LENGTH_KEY 		= NBSP_MAKE_KEY(NBSP_SYSTEM_MODULE,2)
--时间
NBSP_BASE_TIME_KEY 		= NBSP_MAKE_KEY(NBSP_SYSTEM_MODULE,3)

--系统内置错误码
EC_OK = NBSP_MAKE_ERROR_CODE(NBSP_SYSTEM_MODULE,0)--成功
EC_INVALID_DATA = NBSP_MAKE_ERROR_CODE(NBSP_SYSTEM_MODULE,1)--数据不正确
EC_NODATA = NBSP_MAKE_ERROR_CODE(NBSP_SYSTEM_MODULE,2)--没有数据
EC_IMCOMPATIBLE = NBSP_MAKE_ERROR_CODE(NBSP_SYSTEM_MODULE,3)--数据不兼容
EC_NOMEM = NBSP_MAKE_ERROR_CODE(NBSP_SYSTEM_MODULE,4)--内存不足
EC_NETWORK = NBSP_MAKE_ERROR_CODE(NBSP_SYSTEM_MODULE,5)--网络错误
