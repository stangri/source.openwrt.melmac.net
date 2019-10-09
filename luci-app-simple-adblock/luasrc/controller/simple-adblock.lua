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
		luci.util.exec("uci set " .. packageName .. ".config.enabled=1; uci commit " .. packageName)
	elseif luci.http.formvalue("disable") then
		luci.util.exec("uci set " .. packageName .. ".config.enabled=0; uci commit " .. packageName)
	elseif luci.http.formvalue("dl") then
		luci.util.exec("/etc/init.d/" .. packageName .. " dl")
	end
end
