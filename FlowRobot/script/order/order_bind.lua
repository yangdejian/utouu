require "sys"
require "xutility"
require "custom.common.xlib.xqstring"
require "custom.common.xxml"
require "custom.common.xhttp"

--��������
order_bind = {encoding = 'gb2312',method = {},fields ='order_no'}
order_bind.enum={delivery_type={kami="1",zhichong="2",bank="3"},business_type = {jyk="11"},sup_business_type={jyk="10"}}
order_bind.xdbg = xdbg()
order_bind.ip = flowlib.get_local_ip()

order_bind.main = function(args)
	print("---------------------���������̿�ʼ--------------------")
	print("1. �����󶨼��ش�����")
	local params=xtable.parse(args[2], 1)
	local check_result = order_bind.method.check_params(params)
   	if(check_result.code ~=sys.error.success.code) then
   		print("ERR�����������")
   		return
   	end
	params = {order_no = params.order_no}
	print("2. ������������")
	local result,order =order_bind.main_flow(params)

	print("3. �����������")
	order_bind.method.send_mq(order)

    --print("4. ����������ͳ��")
    --order_bind.send_monitor(order,result)

	print("4. ��������ɵ���������")
	order_bind.create_lifetime(order)

	print("5. �������������")
end


order_bind.main_flow = function(params)
    print("2.1 ��ȡ��Ʒ�б���������Ϣ")
    local get_result,product_info = order_bind.method.get_bind_info(params)
    local input_params = xtable.merge(params,product_info)
    if(get_result.code ~=sys.error.success.code) then
    	input_params.content = "����ʧ�ܡ�"..get_result.code
   		return get_result,input_params
   	end

    print("2.2 ��ȡ���ܻ����е���Ϣ")
    local kami_result,card_info,product,save_result,save_data = order_bind.method.get_ext_info(input_params)
    if(kami_result.code ~=sys.error.success.code) then
    	input_params.content = "����ʧ�ܡ�"..kami_result.msg
    	input_params = xtable.merge(input_params,save_data)
        if(save_result.code~=sys.error.success.code) then
        	input_params.content = input_params.content.."������ʧ��pro��"..save_result.code
        end
   		return kami_result,input_params
   	end

	print("2.3 ������")
	input_params = xtable.merge(input_params,card_info)
	input_params = xtable.merge(input_params,product)
	local create_result,order = order_bind.method.create_bind(input_params)
	input_params = xtable.merge(input_params,order)
	input_params.content = "���󶨽�����"..create_result.code

   	return  create_result,input_params
end

--- ������
order_bind.method.check_params=function (params)
	if(xobject.empty(params, order_bind.fields)) then
		return sys.error.param_miss
	end
	return sys.error.success
end

--- ��ȡ������������Ϣ
order_bind.method.get_bind_info = function(params)
	local info=order_bind.xdbg:execute("order.bind.get_product_info",{order_no=params.order_no})
	order_bind.create_lifetime(xtable.merge({content = "���󶨻�ȡ��"..info.result.code},params))
    return info.result,xobject.empty(info,"data")and {} or info.data

end

--- �ӿڻ�ȡext��Ϣ,����ǿ����򷵻ؿ��ܣ����п��򷵻ذ��˻���ֱ�䲻����ֵ
order_bind.method.get_ext_info = function (pro)
	local ext_result = sys.error.failure
	local ext_info={}

	print(xtable.tojson(pro.products))
	for i, item in pairs(pro.products) do
		if(item.delivery_type == order_bind.enum.delivery_type.kami) then
			print("���ýӿڻ�ȡ����")
			ext_result,ext_info = order_bind.method.get_card_info(xtable.merge(item,pro))
			if(ext_result.code == sys.error.success.code) then
				return ext_result,ext_info,item
			end	
		elseif(item.delivery_type == order_bind.enum.delivery_type.bank) then
			print("��ȡ���п��˻���Ϣ")
			ext_result,ext_info = order_bind.method.get_pay_account_info(xtable.merge(item,pro))
			if(ext_result.code == sys.error.success.code) then
				return ext_result,ext_info,item
			end	
		elseif(item.delivery_type == order_bind.enum.delivery_type.zhichong) then
			print("ֱ��")
			return sys.error.success,ext_info,item	
		end
	end

	local res,data = order_bind.method.get_ext_error(xtable.merge(pro,{msg = ext_result.msg}))
	return ext_result,{},{},res,data
end

--ȡ����ʧ�ܵ������ݿ�洢������Ϊʧ��
order_bind.method.get_ext_error = function (pro) 
	local res =  order_bind.xdbg:execute("order.bind.get_ext_error",pro)
	return res.result,xobject.empty(res,"data") and {} or res.data
end

--- ������������
order_bind.method.create_bind = function (info)
	local order=order_bind.xdbg:execute("order.bind.create",info)
	return order.result,not(xobject.empty(order,'data')) and  order.data or {}
end

--==================================��ȡ��ֵ����=============================================
order_bind.method.get_card_info = function (data)
	local url  = order_bind.method.card_make(data)
	print("url=:"..url)
	return order_bind.method.card_request(url)
end
order_bind.method.get_pay_account_info =function (data)
	local account=order_bind.xdbg:execute("order.bind.get_bank_account",data)
	return account.result,not(xobject.empty(account,'data')) and  account.data or {}
end
--����ǩ����URL���տ�ϵͳȡ���ӿڡ�
order_bind.method.card_make=function(params)
	local param=xqstring:new()
	param:add("businesstype",order_bind.enum.sup_business_type.jyk)
	param:add("carrierno",params.carrier_no)
	param:add("cityno",params.city_no)
	param:add("discount",params.down_real_discount)
	param:add("face",params.bind_standard)
	param:add("orderno",params.delivery_id)
	param:add("partnerno",params.sup_up_channel)
	param:add("provinceno",params.province_sup)
	local token=sys.decrypt_pwd(params.sup_up_channel,params.token_key)

	local q = xqstring:new(param)
	local raw = q:make({kvc = "=", sc = "&", req = true, ckey = true, encoding = order_bind.encoding})..token
	print(raw)
	q:add("sign", string.lower(utils.md5(raw, order_bind.encoding)))

	return  string.format("%s?%s", params.get_card_url, q:make({kvc = "=", sc = "&", req = true, ckey = true, encoding = order_bind.encoding}))
end

---SUPϵͳȡ��
order_bind.method.card_request=function(url)
	local xml =xxml()
	local http = xhttp()
	local msg=""
	local cardinfo={}
	for i=1,3,1 do
		print("ȡ������:"..tostring(i))
		local content=http:get(url,order_bind.encoding)

		if(xml:load(content)) then
			local ret=xml:get("//response/result","innerText")
			msg=xml:get("//response/msg","innerText")
			if(ret=="0") then
				print("ȡ���ɹ�")
				cardinfo.card_delivery_no=xml:get("//response/deliveryid","innerText")
				cardinfo.batch_no=xml:get("//response/batchno","innerText")
				cardinfo.card_no=xml:get("//response/cardno","innerText")
				local card_pwd=xml:get("//response/pwd","innerText")
				cardinfo.card_pwd=sys.encrypt_pwd(cardinfo.card_no,card_pwd)
				cardinfo.real_discount=xml:get("//response/discount","innerText")
				cardinfo.need_face_confirm=xml:get("//response/faceconfirm","innerText")
				cardinfo.card_type=xml:get("//response/cardtype","innerText")
				print("ȡ�����"..xtable.tojson(cardinfo))
				return sys.error.success,cardinfo
			end
			print("content:"..tostring(content))
		else
			print("content:"..tostring(content))
			msg ="�������ݲ�����ȷ��xml��ʽ"
		end
	end
	print("ȡ��ʧ��,"..tostring(msg))
	return {code = 'failure',msg ="ȡ��ʧ��,"..tostring(msg) }
end
--- ��ʧ�ܻ�ɹ������������
order_bind.method.send_mq=function (data)
	print("��һ����"..tostring(data.next_step))
	if(xstring.empty(data.next_step)) then
		return
	end
	local mqinput={order_no=data.order_no,delivery_id=data.delivery_id,recharge_account_id = data.recharge_account_id}
	local queues = xmq(data.next_step)
	print(xtable.tojson(mqinput))
	local result = queues:send(mqinput)
	print("����mq���"..tostring(result))
end
--- grsϵͳ��business_typeת����sup��
order_bind.method.to_sup_businesstype = function (businesstype)
	if(businesstype ==order_bind.enum.business_type.jyk) then
		return order_bind.enum.sup_business_typeorder_bind
	end
end
--- ������������������
order_bind.create_lifetime = function (order)
	local next_string=''
	if(not(xstring.empty(order.next_step))) then
		next_string ="��"..order.next_step.."��"
	end
	local result = order_bind.xdbg:execute("order.lifetime.save",{ 
		order_no = order.order_no,
		ip = order_bind.ip,
		content = order.content..next_string,
		delivery_id = 0
		})
	if(result.result.code~=sys.error.success.code) then
		print("��Ӷ����󶨵���������ʧ��"..result.result.code.."order_no"..order.order_no)
	end
end
return order_bind
