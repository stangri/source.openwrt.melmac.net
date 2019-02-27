-- Copyright 2016-2018 Stan Grishin <stangri@melmac.net>
-- Licensed to the public under the Apache License 2.0.

-- local readmeURL = "https://github.com/openwrt/packages/blob/master/net/wireshark-helper/files/README.md"
local readmeURL = "https://github.com/stangri/openwrt_packages/tree/master/wireshark-helper/files/README.md"

local serviceName = "wireshark-helper"

local uci = require "luci.model.uci".cursor()
local sys = require "luci.sys"
local wa  = require "luci.tools.webadmin"
local fs  = require "nixio.fs"
local enabledFlag = uci:get(serviceName, "config", "enabled")
local monIP = uci:get(serviceName, "config", "monitor_ip")
local wsIP = uci:get(serviceName, "config", "wireshark_ip")

m = Map("wireshark-helper", translate("Wireshark Helper Settings"))
h = m:section(NamedSection, "config", "wireshark-helper", translate("Service Status"))

en = h:option(Button, "__toggle")
if enabledFlag ~= "1" then
	en.title      = translate("Service is disabled/stopped")
	en.inputtitle = translate("Enable/Start")
	en.inputstyle = "apply important"
else
	en.title      = translate("Service is enabled/started")
	en.inputtitle = translate("Stop/Disable")
	en.inputstyle = "reset important"
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

if monIP and wsIP then
	if monIP ~= "" and wsIP ~= "" then
		hintText = translate("Run a Wireshark app on the") .. " " .. wsIP .. " " .. translate("device and set Wireshark filter to") .. ": " .. "(ip.src == " .. monIP .. ") || (ip.dst == " .. monIP .. ")"
	end
end

helperText = ( hintText and hintText .. "</br>" or "" ) .. translate("See the") .. " "
  .. [[<a href="]] .. readmeURL .. [[#strict-enforcement" target="_blank">]]
	.. translate("README") .. [[</a>]] .. " " .. translate("for details") .. "."

s1 = m:section(NamedSection, "config", "wireshark-helper", translate("Configuration"), helperText)

ws = s1:option(Value, "wireshark_ip", translate("Wireshark IP"))
ws.datatype = "or(ip4addr,'ignore')"
ws.rmempty = false

mon = s1:option(Value, "monitor_ip", translate("IP to Monitor"))
mon.datatype = "or(ip4addr,'ignore')"
mon.rmempty = false

-- hint = m:section(TypedSection, "_dummy", translate("Hint"), hintText)
-- hints = hint:option(DummyValue, "_dummy", nil, hintText)

local routerip = uci:get("network", "lan", "ipaddr")
sys.net.host_hints(function(m, v4, v6, name)
	if v4 and v4 ~= routerip then
		if name then
			ws:value(v4, v4 .. " (" .. name .. ")")
			mon:value(v4, v4 .. " (" .. name .. ")")
		else
			ws:value(v4)
			mon:value(v4)
		end
	end
end)

return m
