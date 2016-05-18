require "custom.nbsp.dbgateway"
require "custom.nbsp.module"
require "custom.common.utils"
_tcplib={}

function _tcplib:new(oo)
	 local o = oo or {}
	setmetatable(o,self)
	self.__index=self
	return o
end


function tcplib()
	return _tcplib:new()
end

--创建TCP服务器(固定长度字符串)
--(1)端口
--(2)用于确定报文长度的字节数
--(3)报文的额外长度
--(5)接收队列长度
--(6)发送队列长度
--(7)接收线程个数
--(8)发送线程个数
--(4)字符串编码方式

function _tcplib:init_str_server(port,area_len,extra_len,recvQueueSize,sendQueueSize,recvThreadNum,sendThreadNum,encoding)
	if(encoding==nil) then
		encoding="gb2312"
	end
	self.tcpserver = tcp.TcpServer.CreateInstance(port,area_len,extra_len,encoding,recvQueueSize,sendQueueSize,recvThreadNum,sendThreadNum)
	if(self.tcpserver == nil) then
		return false
	end
	return true
end

--创建TCP服务器(基于结束符的字符串)
--(1)端口
--(2)线束符
--(4)接收队列长度
--(5)发送队列长度
--(6)接收线程个数
--(7)发送线程个数
--(3)字符串编码方式

function _tcplib:init_fixend_server(port,end_mark,recvQueueSize,sendQueueSize,recvThreadNum,sendThreadNum,encoding)
	if(encoding==nil) then
		encoding="gb2312"
	end
	self.tcpserver = tcp.TcpServer.CreateInstance(port,end_mark,encoding,recvQueueSize,sendQueueSize,recvThreadNum,sendThreadNum)
	if(self.tcpserver == nil) then
		return false
	end
	return true
end

--创建TCP服务器(pdu)
--(1)端口
--(2)接收队列长度
--(3)发送队列长度
--(4)接收线程个数
--(5)发送线程个数
--(6)是否排除相同的session

function _tcplib:init_pdu_server(port,recvQueueSize,sendQueueSize,recvThreadNum,sendThreadNum)
	self.tcpserver = tcp.TcpServer.CreateInstance(port,recvQueueSize,sendQueueSize,recvThreadNum,sendThreadNum,true)
	if(self.tcpserver == nil) then
		return false
	end
	return true
end

--获取一个报文
function _tcplib:try_get_pdu(timeout)
	if(self.tcpserver == nil) then
		return nil
	end
	local pdu = nbsp.Pdu()
	local ret = self.tcpserver:ReceivevRequest(pdu,timeout)
	logger.debug("Receiveret="..tostring(ret))
	if(ret == EC_OK) then
		return pdu
	else
		return nil
	end
end

--获取返回值(以固定字符串长度形式)
function _tcplib:format_string_ret(params,need_sign,key,encoding)
	local body=params:make("","",false,false)
	if(need_sign) then
		encoding = encoding==nil and "gb2312" or encoding
		local sign=utils.md5(body..key,encoding)
		body=body..sign
	end
	local head=utils.pad_left(tostring(string.len(body)+4),4,"0")
	return string.format("%s%s",head,body)
end

--获取返回值(以json字符串形式,包以\r\n结束)
function _tcplib:format_json_ret(params,need_sign,key,encoding)
	local body=params:make("","",false,false)
	if(need_sign) then
		encoding = encoding==nil and "gb2312" or encoding
		local sign=utils.md5(string:trimall(body)..key,encoding)
		params:append("sign",sign,false)
	end
	local ret=params:make("\":\"","\",\"",false,true)
	ret="{\""..string:trimall(ret).."\"}".."\r\n\r\n"
	return ret
end

--创建响应pdu报文(返回字符串形式)
 function _tcplib:create_response_pdu(pdu,ret_val)
	local resp = nbsp.Pdu()
	resp.senderStation = pdu.receiverStation
	resp.receiverStation = pdu.senderStation
	resp.session = pdu.session
	resp.senderObj = pdu.receiverObj
	resp.receiverObj = pdu.senderObj
	resp:InsertString(NBSP_BASE_DATA_KEY,ret_val)
	return resp
end

--发送响应报文
function _tcplib:response(resp)

	if(self.tcpserver == nil) then
		return false
	end

	return self.tcpserver:Response(resp)
end

---*********PDU对象相关操作***********--
--获取PDU中的字符串
function _tcplib:get_pdu_string(pdu)
	return pdu:GetString(NBSP_BASE_DATA_KEY)
end

--将pdu转换为base64字符串
function _tcplib:pdu_to_base64(pdu)
	return nbsp.Pdu.ToBase64(pdu)
end

--将ase64字符串转换为pdu
function _tcplib:pdu_from_base64(strval)
	local pdu=nbsp.Pdu()
	nbsp.Pdu.FromBase64(strval,pdu)
	return pdu
end


--***********公共方法***********--
function string:trimall(s)
  return (string.gsub(s, "%s*(.-)%s*", "%1"))
end
