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

--����TCP������(�̶������ַ���)
--(1)�˿�
--(2)����ȷ�����ĳ��ȵ��ֽ���
--(3)���ĵĶ��ⳤ��
--(5)���ն��г���
--(6)���Ͷ��г���
--(7)�����̸߳���
--(8)�����̸߳���
--(4)�ַ������뷽ʽ

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

--����TCP������(���ڽ��������ַ���)
--(1)�˿�
--(2)������
--(4)���ն��г���
--(5)���Ͷ��г���
--(6)�����̸߳���
--(7)�����̸߳���
--(3)�ַ������뷽ʽ

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

--����TCP������(pdu)
--(1)�˿�
--(2)���ն��г���
--(3)���Ͷ��г���
--(4)�����̸߳���
--(5)�����̸߳���
--(6)�Ƿ��ų���ͬ��session

function _tcplib:init_pdu_server(port,recvQueueSize,sendQueueSize,recvThreadNum,sendThreadNum)
	self.tcpserver = tcp.TcpServer.CreateInstance(port,recvQueueSize,sendQueueSize,recvThreadNum,sendThreadNum,true)
	if(self.tcpserver == nil) then
		return false
	end
	return true
end

--��ȡһ������
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

--��ȡ����ֵ(�Թ̶��ַ���������ʽ)
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

--��ȡ����ֵ(��json�ַ�����ʽ,����\r\n����)
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

--������Ӧpdu����(�����ַ�����ʽ)
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

--������Ӧ����
function _tcplib:response(resp)

	if(self.tcpserver == nil) then
		return false
	end

	return self.tcpserver:Response(resp)
end

---*********PDU������ز���***********--
--��ȡPDU�е��ַ���
function _tcplib:get_pdu_string(pdu)
	return pdu:GetString(NBSP_BASE_DATA_KEY)
end

--��pduת��Ϊbase64�ַ���
function _tcplib:pdu_to_base64(pdu)
	return nbsp.Pdu.ToBase64(pdu)
end

--��ase64�ַ���ת��Ϊpdu
function _tcplib:pdu_from_base64(strval)
	local pdu=nbsp.Pdu()
	nbsp.Pdu.FromBase64(strval,pdu)
	return pdu
end


--***********��������***********--
function string:trimall(s)
  return (string.gsub(s, "%s*(.-)%s*", "%1"))
end
