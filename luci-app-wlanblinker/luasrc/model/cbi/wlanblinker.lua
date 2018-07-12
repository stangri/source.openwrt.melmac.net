-- local readmeURL = "https://github.com/openwrt/packages/tree/master/net/wlanblinker/files/README.md"
local readmeURL = "https://github.com/stangri/openwrt_packages/tree/master/wlanblinker/files/README.md"

m = Map("wlanblinker", translate("WLAN Blinker Settings"))
h = m:section(NamedSection, "config", "wlanblinker", translate("Service Status"))

local serviceName = "wlanblinker"
local uci = require("luci.model.uci").cursor()
local enabledFlag = uci:get(serviceName, "config", "enabled")
en = h:option(Button, "__toggle")
if enabledFlag == "0" then
	en.title      = translate("Service is disabled/stopped")
	en.inputtitle = translate("Enable/Start")
	en.inputstyle = "apply"
else
	en.title      = translate("Service is enabled/started")
	en.inputtitle = translate("Stop/Disable")
	en.inputstyle = "reset"
end
function en.write()
	enabledFlag = enabledFlag == "1" and "0" or "1"
	uci:set(serviceName, "config", "enabled", enabledFlag)
	uci:save(serviceName)
	uci:commit(serviceName)
	if enabledFlag == "0" then
		luci.sys.init.stop(serviceName)
	else
		luci.sys.init.enable(serviceName)
		luci.sys.init.start(serviceName)
	end
	luci.http.redirect(luci.dispatcher.build_url("admin/services/" .. serviceName))
end

s = m:section(NamedSection, "config", "wlanblinker", translate("Configuration"))
-- General options
local sysfs_path = "/sys/class/leds/"
local leds = {}
if nixio.fs.access(sysfs_path) then
	leds = nixio.util.consume((nixio.fs.dir(sysfs_path)))
end
if #leds ~= 0 then
	o3 = s:option(Value, "led", translate("LED to indicate status"), translate("Pick the LED not already used in")
		.. [[ <a href="]] .. luci.dispatcher.build_url("admin/system/leds") .. [[">]]
		.. translate("System LED Configuration") .. [[</a>]])
	o3.rmempty = true
	o3:value("", translate("none"))
	for k, v in ipairs(leds) do
		o3:value(v)
	end
end

cm = s:option(ListValue, "mode", translate("Current Mode"))
cm.rmempty = false
cm.default = uci:get("wlanblinker", "config", "mode")
uci:foreach("wlanblinker", "mode", function(s)
	local name=s['.name']
	cm:value(name)
end)

mode = m:section(TypedSection, "mode", translate("Modes"), translate("User-defined modes of operation"))
mode.template = "cbi/tblsection"
mode.addremove = true

on = mode:option(Value, "on_time", translate("LED on time (in sec)"))
on.rmempty = false
on.datatype = "range(1,60)"
off = mode:option(Value, "off_time", translate("LED off time (in sec)"))
off.rmempty = false
off.datatype = "range(1,60)"
sleep = mode:option(Value, "sleep_time", translate("LED sleep time (in sec)"))
sleep.rmempty = false
sleep.datatype = "range(1,60)"
disp = mode:option(ListValue, "display", translate("LED indication"))
disp:value("", translate("none"))
disp:value("channel", translate("channel"))
disp:value("link_quality", translate("link quality"))

return m
