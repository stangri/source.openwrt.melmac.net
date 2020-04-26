module("luci.controller.template", package.seeall)
function index()
	if nixio.fs.access("/etc/config/template") then
		entry({"admin", "services", "template"}, cbi("template"), _("Template")).acl_depends = { "luci-app-template" }
	end
end
