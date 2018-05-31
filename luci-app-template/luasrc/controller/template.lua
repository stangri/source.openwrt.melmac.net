module("luci.controller.template", package.seeall)
function index()
	if not nixio.fs.access("/etc/config/template") then
		return
	end
	entry({"admin", "services", "template"}, cbi("template"), _("Template"))
end
