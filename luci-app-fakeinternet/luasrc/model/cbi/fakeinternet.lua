-- Copyright 2016-2018 Stan Grishin <stangri@melmac.net>
-- Licensed to the public under the Apache License 2.0.

local packageName = "fakeinternet"
local readmeURL = "https://docs.openwrt.melmac.net/" .. packageName .. "/"
local uci = require("luci.model.uci").cursor()
local enabledFlag = uci:get(packageName, "config", "enabled")

m = Map("fakeinternet", translate("Fakeinternet Settings"))
h = m:section(NamedSection, "config", "fakeinternet", translate("Service Status"))

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
	uci:set(packageName, "config", "enabled", enabledFlag)
	uci:save(packageName)
	uci:commit(packageName)
	if enabledFlag == "0" then
		luci.sys.init.stop(packageName)
	else
		luci.sys.init.enable(packageName)
		luci.sys.init.start(packageName)
	end
	luci.http.redirect(luci.dispatcher.build_url("admin/services/" .. packageName))
end

s1 = m:section(NamedSection, "config", "fakeinternet", translate("Configuration"))

-- General options
icmp = s1:option(ListValue, "icmp_redirect", translate("ICMP Redirect"), translate("Redirect ICMP (ping) traffic to router."))
icmp:value("0", translate("Do not redirect ICMP traffic to router"))
icmp:value("1", translate("Redirect ICMP traffic to router"))
icmp.default = 0

dl1 = s1:option(DynamicList, "address", translate("Addresses"), translate("Addresses to fake."))
dl1.datatype = "string"

s2 = m:section(TypedSection, "policy", translate("Policies"), translate("Advanced policies. Use # as the domain name for all domains. Put blocked domains at the top."))
s2.template  = "cbi/tblsection"
s2.sortable  = true
s2.anonymous = true
s2.addremove = true

la = s2:option(Value, "address", translate("Domain Name"))
la.datatype = "string"
la.rmempty  = true

ac = s2:option(ListValue, "action", translate("Action"))
ac.rmempty = true
ac.default = "fake"
ac:value("fake","Fake")
ac:value("block","Block")

return m
