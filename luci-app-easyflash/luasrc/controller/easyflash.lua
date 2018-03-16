module("luci.controller.easyflash", package.seeall)
function index()
	entry({"admin", "services", "easyflash"}, template("easyflash"), _("Easy Flash"), 1)
end
