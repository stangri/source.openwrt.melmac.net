module("luci.controller.simple-adblock", package.seeall)
function index()
	if not nixio.fs.access("/etc/config/simple-adblock") then
		return
	end
	entry({"admin", "services", "simple-adblock"}, cbi("simple-adblock"), _("Simple AdBlock"))
	entry({"admin", "services", "simple-adblock-action"}, post("action_simple_adblock")).leaf = true
end

function action_simple_adblock()
	local packageName = "simple-adblock"
	if luci.http.formvalue("start") then
		luci.sys.init.start(packageName)
	elseif luci.http.formvalue("stop") then
		luci.sys.init.stop(packageName)
	elseif luci.http.formvalue("enable") then
		luci.sys.init.enable(packageName)
	elseif luci.http.formvalue("disable") then
		luci.sys.init.disable(packageName)
	elseif luci.http.formvalue("dl") then
		luci.util.exec("/etc/init.d/simple-adblock dl")
	end
	luci.http.redirect(luci.dispatcher.build_url("admin", "services", packageName))
end


