readmeURL = "https://github.com/openwrt/packages/tree/master/net/wlanblinker/files/README.md"
readmeURL = "https://github.com/stangri/openwrt_packages/tree/master/wlanblinker/files/README.md"

uci = require "luci.model.uci".cursor()

m = Map("wlanblinker", translate("WLAN Blinker Settings"))
s = m:section(NamedSection, "config", "wlanblinker")

-- General options
e = s:option(Flag, "enabled", translate("Start VPNBypass service"))
e.rmempty = false
function e.write(self, section, value)
	if value ~= "1" then
		luci.sys.init.stop("wlanblinker")
	end
	return Flag.write(self, section, value)
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
disp = mode:option(ListValue, "display", translate("Indication"))
disp:value("","none")
disp:value("channel")
disp:value("link_quality")

return m
