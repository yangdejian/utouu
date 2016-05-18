require "custom.common.bit"
--���������:��������(4�ֽ�)+ģ����(12bit)+��Ϣ���(16bit)
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

--ϵͳģ��,����ģ����public�ļ��ж���
NBSP_SYSTEM_MODULE  = 0x000

--�û��Զ���ģ��
NBSP_MODULE_BASE  = 0x100

--ͨ�õ���������
NBSP_COMMON_HEART_COMMAND 	= NBSP_MAKE_REQUEST_COMMAND(NBSP_SYSTEM_MODULE,0)
--�ְ������ݼ�ֵ
NBSP_FRAGMENT_DATA_KEY 		= NBSP_MAKE_KEY(NBSP_SYSTEM_MODULE,0)
--���ݼ�
NBSP_BASE_DATA_KEY 		= NBSP_MAKE_KEY(NBSP_SYSTEM_MODULE,1)
--����
NBSP_BASE_LENGTH_KEY 		= NBSP_MAKE_KEY(NBSP_SYSTEM_MODULE,2)
--ʱ��
NBSP_BASE_TIME_KEY 		= NBSP_MAKE_KEY(NBSP_SYSTEM_MODULE,3)

--ϵͳ���ô�����
EC_OK = NBSP_MAKE_ERROR_CODE(NBSP_SYSTEM_MODULE,0)--�ɹ�
EC_INVALID_DATA = NBSP_MAKE_ERROR_CODE(NBSP_SYSTEM_MODULE,1)--���ݲ���ȷ
EC_NODATA = NBSP_MAKE_ERROR_CODE(NBSP_SYSTEM_MODULE,2)--û������
EC_IMCOMPATIBLE = NBSP_MAKE_ERROR_CODE(NBSP_SYSTEM_MODULE,3)--���ݲ�����
EC_NOMEM = NBSP_MAKE_ERROR_CODE(NBSP_SYSTEM_MODULE,4)--�ڴ治��
EC_NETWORK = NBSP_MAKE_ERROR_CODE(NBSP_SYSTEM_MODULE,5)--�������
