module("luci.controller.wlanblinker", package.seeall)
function index()
	if nixio.fs.access("/etc/config/wlanblinker") then
		entry({"admin", "services", "wlanblinker"}, cbi("wlanblinker"), _("WLAN Blinker")).acl_depends = { "luci-app-wlanblinker" }
	end
end
