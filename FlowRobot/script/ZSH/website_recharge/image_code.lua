require "sys"
require "custom.common.recognizelib"

zsh_image_code = {net_file_name = "zhongshihua.net",
				net_recognize_value = 0.5,
				image_code_length = 5,
				download_image_code_limit = 3}
zsh_image_code.recognize = recognize()

--����ͼƬ��֤�벢��ʶ��
zsh_image_code.download = function(http, current_times)
	current_times = current_times or 0
	local input = {}
	input.url = "http://www.sinopecsales.com/gas/YanZhengMaServlet?"..os.time()
	input.net = zsh_image_code.net_file_name
	input.value = zsh_image_code.net_recognize_value
	input.len = zsh_image_code.image_code_length
	input.result = ""
	local result, msg = zsh_image_code.recognize:net_recognize(http, input)
	print("������֤��ʶ����:"..tostring(input.result))
	if(not(result) or input.result == nil) then
		error(msg)
		if(current_times < zsh_image_code.download_image_code_limit) then
			error(string.format("������֤��ʶ��ʧ��,��%s������", current_times + 1))
			return zsh_image_code.download(http, current_times + 1)
		end
		return sys.error.delivery.number_code_error
	end
	--ʶ������жϵ�һ���͵������Ƿ����ַ����ڶ����Ǻ��������+��x,���ĸ���=�ţ���5����w
	local a = tonumber(string.sub(input.result, 1, 1))
	local b = tonumber(string.sub(input.result, 3, 3))
	local d = string.sub(input.result, 2, 2)
	if(a == nil or b == nil) then
		error("������֤��ʶ�����,�����»�ȡ������֤��")
		return sys.error.delivery.number_code_error
	end
	if(d == "+") then
		print("��֤�������:"..tostring(a + b))
		return sys.error.success, a + b
	elseif(d == "x") then
		print("��֤�������:"..tostring(a * b))
		return sys.error.success, a * b
	end
	return sys.error.delivery.number_code_error
end


return zsh_image_code
