-- Copyright 2016-2018 Stan Grishin <stangri@melmac.net>
-- Licensed to the public under the Apache License 2.0.

-- local readmeURL = "https://github.com/openwrt/packages/blob/master/net/wireshark-helper/files/README.md"
local readmeURL = "https://github.com/stangri/openwrt_packages/tree/master/wireshark-helper/files/README.md"

local packageName = "wireshark-helper"
local uci = require "luci.model.uci".cursor()
local sys = require "luci.sys"
local util = require "luci.util"
local wa  = require "luci.tools.webadmin"
local fs  = require "nixio.fs"
local monIP = uci:get(packageName, "config", "monitor_ip")
local wsIP = uci:get(packageName, "config", "wireshark_ip")

local packageVersion, statusText = nil, nil 
packageVersion = tostring(util.trim(sys.exec("opkg list-installed " .. packageName .. " | awk '{print $3}'")))
if not packageVersion or packageVersion == "" then
	packageVersion = ""
	statusText = packageName .. " " .. translate("is not installed or not found")
else  
	packageVersion = " [" .. packageName .. " " .. packageVersion .. "]"
end

local serviceRunning, serviceEnabled = false, false
if uci:get(packageName, "config", "enabled") == "1" then
	serviceEnabled = true
end
if sys.call("iptables -t mangle -L | grep -q " .. packageName) == 0 then
	serviceRunning = true
end

if serviceRunning then
	statusText = translate("Running")
else
	statusText = translate("Stopped")
	if not serviceEnabled then
		statusText = statusText .. " (" .. translate("disabled") .. ")"
	end
end

m = Map("wireshark-helper", translate("Wireshark Helper Settings"))
h = m:section(NamedSection, "config", packageName, translate("Service Status") .. packageVersion)
ss = h:option(DummyValue, "_dummy", translate("Service Status"))
ss.template = packageName .. "/status"
ss.value = statusText
if packageVersion ~= "" then
	buttons = h:option(DummyValue, "_dummy")
	buttons.template = packageName .. "/buttons"
end


local hintText, helperText = "", ""
if monIP and wsIP then
	if monIP ~= "" and wsIP ~= "" then
		hintText = "<div>" .. translate("Run a Wireshark app on the") .. " " .. wsIP .. " " .. translate("device and set Wireshark filter to") .. ": " .. "(ip.src == " .. monIP .. ") || (ip.dst == " .. monIP .. ")" .. "</div>"
	end
end

helperText = hintText .. "<div>" .. translate("See the") .. " "
	.. [[<a href="]] .. readmeURL .. [[#strict-enforcement" target="_blank">]]
	.. translate("README") .. [[</a>]] .. " " .. translate("for details") .. "." .. "</div>"

s1 = m:section(NamedSection, "config", "wireshark-helper", translate("Configuration"), helperText)

function is_lan(name)
	return name:sub(1,3) == "lan"
end

function is_vlan(name)
	return name:sub(1,4) == "vlan"
end

iface = s1:option(ListValue, "interface", translate("Interface to Listen on"))
iface.datatype = "network"
iface.rmempty = true
uci:foreach("network", "interface", function(s)
	local name=s['.name']
	if is_lan(name) then
		iface:value("", string.upper(name))
		if not iface.default then iface.default = name end
	elseif is_vlan(name) then
		iface:value(name, string.upper(name))
	end
end)

ws = s1:option(Value, "wireshark_ip", translate("Wireshark IP"))
ws.datatype = "or(ip4addr,'ignore')"
ws.rmempty = false

mon = s1:option(Value, "monitor_ip", translate("IP to Monitor"))
mon.datatype = "or(ip4addr,'ignore')"
mon.rmempty = false

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
