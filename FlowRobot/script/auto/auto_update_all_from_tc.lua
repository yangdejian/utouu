require "sys"
require "auto_mq_receiver"

function main(args)
	local script_name = args[1]
	print("�����ű�:"..tostring(script_name))

	auto_mq_receiver.main(script_name:match("/auto_(.-).lua"))
end
