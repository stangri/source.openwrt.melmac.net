module("luci.controller.wireshark-helper", package.seeall)
function index()
	if not nixio.fs.access("/etc/config/wireshark-helper") then
		return
	end
	entry({"admin", "services", "wireshark-helper"}, cbi("wireshark-helper"), _("Wireshark Helper"))
end
