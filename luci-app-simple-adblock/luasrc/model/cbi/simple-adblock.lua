-- Copyright 2016-2018 Stan Grishin <stangri@melmac.net>
-- Licensed to the public under the Apache License 2.0.

m = Map("simple-adblock", translate("Simple AdBlock Settings"))
s = m:section(NamedSection, "config", "simple-adblock")

-- General options
local serviceName = "simple-adblock"
local uci = require "luci.model.uci".cursor()
local util = require "luci.util"
local enabledFlag = uci:get(serviceName, "config", "enabled")
local status = util.ubus('service', 'list', { name = serviceName })[serviceName]['instances']['status']['data']['status'] or "Stopped"
if status:match("Reloading") then
	ds = s:option(DummyValue, "_dummy", translate("Service Status"))
	ds.template = "simple-adblock/status"
	ds.value = status
else
	en = s:option(Button, "__toggle")
	if enabledFlag ~= "1" or status:match("Stopped") then
		en.title      = translate("Service is disabled/stopped")
		en.inputtitle = translate("Enable/Start")
		en.inputstyle = "apply"
	else
		en.title      = translate("Service is enabled/started")
		en.inputtitle = translate("Stop/Disable")
		en.inputstyle = "reset"
		ds = s:option(DummyValue, "_dummy", translate("Service Status"))
		ds.template = "simple-adblock/status"
		ds.value = status
		if not status:match("Success") then
			reload = s:option(Button, "__toggle")
			reload.title      = translate("Service started with error")
			reload.inputtitle = translate("Reload")
			reload.inputstyle = "apply"
			function reload.write()
				luci.sys.exec("/etc/init.d/simple-adblock reload")
				luci.http.redirect(luci.dispatcher.build_url("admin/services/" .. serviceName))
			end
		end
	end
	function en.write()
		enabledFlag = enabledFlag == "1" and "0" or "1"
		uci:set(serviceName, "config", "enabled", enabledFlag)
		uci:save(serviceName)
		uci:commit(serviceName)
		if enabledFlag == "0" then
			luci.sys.init.stop(serviceName)
			luci.sys.exec("/etc/init.d/simple-adblock killcache")
		else
			luci.sys.init.enable(serviceName)
			luci.sys.init.start(serviceName)
		end
		luci.http.redirect(luci.dispatcher.build_url("admin/services/" .. serviceName))
	end
end

o2 = s:option(ListValue, "verbosity", translate("Output Verbosity Setting"),translate("Controls system log and console output verbosity"))
o2:value("0", translate("Suppress output"))
o2:value("1", translate("Some output"))
o2:value("2", translate("Verbose output"))
o2.rmempty = false
o2.default = 2

o3 = s:option(ListValue, "force_dns", translate("Force Router DNS"), translate("Forces Router DNS use on local devices, also known as DNS Hijacking"))
o3:value("0", translate("Let local devices use their own DNS servers if set"))
o3:value("1", translate("Force Router DNS server to all local devices"))
o3.rmempty = false
o3.default = 1

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

s2 = m:section(NamedSection, "config", serviceName)
-- Whitelisted Domains
d1 = s2:option(DynamicList, "whitelist_domain", translate("Whitelisted Domains"), translate("Individual domains to be whitelisted"))
d1.addremove = false
d1.optional = false

-- Blacklisted Domains
d3 = s2:option(DynamicList, "blacklist_domain", translate("Blacklisted Domains"), translate("Individual domains to be blacklisted"))
d3.addremove = false
d3.optional = false

-- Whitelisted Domains URLs
d2 = s2:option(DynamicList, "whitelist_domains_url", translate("Whitelisted Domain URLs"), translate("URLs to lists of domains to be whitelisted"))
d2.addremove = false
d2.optional = false

-- Blacklisted Domains URLs
d4 = s2:option(DynamicList, "blacklist_domains_url", translate("Blacklisted Domain URLs"), translate("URLs to lists of domains to be blacklisted"))
d4.addremove = false
d4.optional = false

-- Blacklisted Hosts URLs
d5 = s2:option(DynamicList, "blacklist_hosts_url", translate("Blacklisted Hosts URLs"), translate("URLs to lists of hosts to be blacklisted"))
d5.addremove = false
d5.optional = false

return m
