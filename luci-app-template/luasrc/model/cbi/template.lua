readmeURL = "https://docs.openwrt.melmac.net/template/"

m = Map("template", translate("Template Settings"))
s = m:section(NamedSection, "config", "template")

-- General options
e = s:option(Flag, "enabled", translate("Start Template service"))
e.rmempty = false
function e.write(self, section, value)
	if value ~= "1" then
		luci.sys.init.stop("template")
	end
	return Flag.write(self, section, value)
end

-- DynamicList
dl1 = s:option(DynamicList, "setting", translate("Setting"), translate("Setting of Template"))
dl1.datatype    = "portrange"
dl1.placeholder = "0-65535"
dl1.addremove = false
dl1.optional = false

return m
