require "sys"
require "custom.common.xhttp"
require "xqstring"
require "xxml"

gasoline_card_save = {fields = "card_no,carrier_no,status,is_complete", encoding = "gbk"}
gasoline_card_save.grs_dbg = xdbg("grs_db")

gasoline_card_save.main = function(args)
	print("------------------������Ϳ���Ϣ------------------")
	print("1. ������")
	gasoline_card_save.params = xtable.parse(args[2], 1)
	if(xobject.empty(gasoline_card_save.params, gasoline_card_save.fields)) then
		error(string.format("ȱ�ٲ���.�贫��:%s,�Ѵ���:%s", gasoline_card_save.fields, args[2]))
		return sys.error.param_miss
	end

	print("2. ��ȡ���Ϳ�ʡ�ݱ���")
	local result = gasoline_card_save.get_card_province_no()

	print("3. ��������")
	gasoline_card_save.params.expire_date = tostring(gasoline_card_save.params.is_complete) == "0" and 100 or 10
	local dbg_result = gasoline_card_save.grs_dbg:execute("gasoline_card.archive.save", gasoline_card_save.params)
	if(dbg_result.result.code ~= sys.error.success.code) then
		error("��������ʧ��,�������:"..xtable.tojson(gasoline_card_save.params))
	end
	return dbg_result.result
end

gasoline_card_save.get_card_province_no = function()
	gasoline_card_save.params.province_no = string.sub(gasoline_card_save.params.card_no, 7, 8)
	if(gasoline_card_save.params.province_no == "86") then
		gasoline_card_save.params.province_no = string.sub(gasoline_card_save.params.card_no, 9, 10)
	end
	gasoline_card_save.params.province_name = gasoline_card_save.province_no_list[tostring(gasoline_card_save.params.province_no)] or ""
	return true
end


gasoline_card_save.province_no_list = {}
gasoline_card_save.province_no_list["11"] = "������"
gasoline_card_save.province_no_list["12"] = "�����"
gasoline_card_save.province_no_list["13"] = "�ӱ�ʡ"
gasoline_card_save.province_no_list["14"] = "ɽ��ʡ"
gasoline_card_save.province_no_list["15"] = "���ɹ�������"
gasoline_card_save.province_no_list["21"] = "����ʡ"
gasoline_card_save.province_no_list["22"] = "����ʡ"
gasoline_card_save.province_no_list["23"] = "������ʡ"
gasoline_card_save.province_no_list["31"] = "�Ϻ���"
gasoline_card_save.province_no_list["32"] = "����ʡ"
gasoline_card_save.province_no_list["33"] = "�㽭ʡ"
gasoline_card_save.province_no_list["34"] = "����ʡ"
gasoline_card_save.province_no_list["35"] = "����ʡ"
gasoline_card_save.province_no_list["36"] = "����ʡ"
gasoline_card_save.province_no_list["37"] = "ɽ��ʡ"
gasoline_card_save.province_no_list["41"] = "����ʡ"
gasoline_card_save.province_no_list["42"] = "����ʡ"
gasoline_card_save.province_no_list["43"] = "����ʡ"
gasoline_card_save.province_no_list["44"] = "�㶫ʡ"
gasoline_card_save.province_no_list["45"] = "����ʡ"
gasoline_card_save.province_no_list["46"] = "����ʡ"
gasoline_card_save.province_no_list["50"] = "������"
gasoline_card_save.province_no_list["51"] = "�Ĵ�ʡ"
gasoline_card_save.province_no_list["52"] = "����ʡ"
gasoline_card_save.province_no_list["53"] = "����ʡ"
gasoline_card_save.province_no_list["54"] = "����������"
gasoline_card_save.province_no_list["61"] = "����ʡ"
gasoline_card_save.province_no_list["62"] = "����ʡ"
gasoline_card_save.province_no_list["63"] = "�ຣʡ"
gasoline_card_save.province_no_list["64"] = "����������"
gasoline_card_save.province_no_list["65"] = "�½�������"
gasoline_card_save.province_no_list["90"] = "������"
gasoline_card_save.province_no_list["91"] = "��������"

return gasoline_card_save
