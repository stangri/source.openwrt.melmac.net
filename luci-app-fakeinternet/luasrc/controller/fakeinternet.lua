module("luci.controller.fakeinternet", package.seeall)
function index()
	if not nixio.fs.access("/etc/config/fakeinternet") then
		return
	end
	entry({"admin", "services", "fakeinternet"}, cbi("fakeinternet"), _("Fakeinternet"))
end
