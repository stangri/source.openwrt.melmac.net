module("luci.controller.fakeinternet", package.seeall)
function index()
	if nixio.fs.access("/etc/config/fakeinternet") then
		entry({"admin", "services", "fakeinternet"}, cbi("fakeinternet"), _("Fakeinternet")).acl_depends = { "luci-app-fakeinternet" }
	end
end
