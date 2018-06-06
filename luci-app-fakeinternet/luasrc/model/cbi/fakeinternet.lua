readmeURL = "https://github.com/openwrt/packages/blob/master/net/fakeinternet/files/README.md"

m = Map("fakeinternet", translate("Fakeinternet Settings"))
s1 = m:section(NamedSection, "config", "fakeinternet")

-- General options
e = s1:option(Flag, "enabled", translate("Start Fakeinternet service"))
e.rmempty = false
function e.write(self, section, value)
	if value ~= "1" then
		luci.sys.init.stop("fakeinternet")
	end
	return Flag.write(self, section, value)
end

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
