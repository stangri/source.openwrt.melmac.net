module("luci.controller.wlanblinker", package.seeall)
function index()
	if not nixio.fs.access("/etc/config/wlanblinker") then
		return
	end
	entry({"admin", "services", "wlanblinker"}, cbi("wlanblinker"), _("WLAN Blinker"))
end
