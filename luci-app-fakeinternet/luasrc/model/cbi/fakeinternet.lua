-- Copyright 2016-2018 Stan Grishin <stangri@melmac.net>
-- Licensed to the public under the Apache License 2.0.

local readmeURL = "https://github.com/openwrt/packages/blob/master/net/fakeinternet/files/README.md"

m = Map("fakeinternet", translate("Fakeinternet Settings"))
h = m:section(NamedSection, "config", "fakeinternet", translate("Service Status"))

local serviceName = "fakeinternet"
local uci = require("luci.model.uci").cursor()
local enabledFlag = uci:get(serviceName, "config", "enabled")
en = h:option(Button, "__toggle")
if enabledFlag ~= "1" then
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

s1 = m:section(NamedSection, "config", "fakeinternet", translate("Configuration"))

-- General options
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
