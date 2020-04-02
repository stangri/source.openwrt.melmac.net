module("luci.controller.wireshark-helper", package.seeall)
function index()
	if nixio.fs.access("/etc/config/wireshark-helper") then
		entry({"admin", "services", "wireshark-helper"}, cbi("wireshark-helper"), _("Wireshark Helper"))
		entry({"admin", "services", "wireshark-helper", "action"}, call("wireshark_helper_action"), nil).leaf = true
	end
end

function wireshark_helper_action(name)
	local packageName = "wireshark-helper"
	if name == "start" then
		luci.sys.init.start(packageName)
	elseif name == "action" then
		luci.util.exec("/etc/init.d/" .. packageName .. " restart >/dev/null 2>&1")
	elseif name == "stop" then
		luci.sys.init.stop(packageName)
	elseif name == "enable" then
		luci.util.exec("uci set " .. packageName .. ".config.enabled=1; uci commit " .. packageName)
	elseif name == "disable" then
		luci.util.exec("uci set " .. packageName .. ".config.enabled=0; uci commit " .. packageName)
	end
	luci.http.prepare_content("text/plain")
	luci.http.write("0")
end
