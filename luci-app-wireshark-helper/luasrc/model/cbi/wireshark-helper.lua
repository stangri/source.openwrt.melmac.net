-- Copyright 2016-2018 Stan Grishin <stangri@melmac.net>
-- Licensed to the public under the Apache License 2.0.

local packageName = "wireshark-helper"
local readmeURL = "https://docs.openwrt.melmac.net/" .. packageName .. "/"
local uci = require "luci.model.uci".cursor()
local sys = require "luci.sys"
local util = require "luci.util"
local wa  = require "luci.tools.webadmin"
local fs  = require "nixio.fs"
local monIP = uci:get(packageName, "config", "monitor_ip")
local wsIP = uci:get(packageName, "config", "wireshark_ip")

function getPackageVersion()
	local opkgFile = "/usr/lib/opkg/status"
	local line
	local flag = false
	for line in io.lines(opkgFile) do
		if flag then
			return line:match('[%d%.$-]+') or ""
		elseif line:find("Package: " .. packageName:gsub("%-", "%%%-")) then
			flag = true
		end
	end
	return ""
end

local packageVersion = getPackageVersion()
local statusText = nil 
if packageVersion == "" then
	statusText = translatef("%s is not installed or not found", packageName)
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
		statusText = translatef("%s (disabled)", statusText)
	end
end

m = Map("wireshark-helper", translate("Wireshark Helper Settings"))
h = m:section(NamedSection, "config", packageName, translatef("Service Status [%s %s]", packageName, packageVersion))
ss = h:option(DummyValue, "_dummy", translate("Service Status"))
ss.template = packageName .. "/status"
ss.value = statusText
if packageVersion ~= "" then
	buttons = h:option(DummyValue, "_dummy", translate("Service Control"))
	buttons.template = packageName .. "/buttons"
end

local hintText, helperText = "", ""
if serviceRunning and monIP and wsIP and monIP ~= "" and wsIP ~= "" then
	hintText = "<div>" .. translatef("Run a Wireshark app on the %s device and set Wireshark filter to: (ip.src == %s) || (ip.dst == %s)", wsIP, monIP, monIP) .. "</div>"
end

helperText = hintText .. "<div>" .. translatef("See the %sREADME%s for details.", "<a href=\"" .. readmeURL .. "\" target=\"_blank\">", "</a>") .. "</div>"

s1 = m:section(NamedSection, "config", "wireshark-helper", translate("Configuration"), helperText)

function is_lan(name)
	return name:sub(1,3):lower() == "lan"
end

function is_vlan(name)
	return name:sub(1,4):lower() == "vlan"
end

iface = s1:option(ListValue, "interface", translate("Interface to Listen on"))
iface.datatype = "network"
iface.rmempty = true
uci:foreach("network", "interface", function(s)
	local name=s['.name']
	if is_lan(name) then
		iface:value("", name:upper())
		if not iface.default then iface.default = name end
	elseif is_vlan(name) then
		iface:value(name, name:upper())
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
