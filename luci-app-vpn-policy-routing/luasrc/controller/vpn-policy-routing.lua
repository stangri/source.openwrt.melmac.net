module("luci.controller.vpn-policy-routing", package.seeall)
function index()
	if nixio.fs.access("/etc/config/vpn-policy-routing") then
		if luci.dispatcher.lookup and luci.dispatcher.lookup("admin/vpn") then
			entry({"admin", "vpn", "vpn-policy-routing"}, cbi("vpn-policy-routing"), _("VPN Policy Routing"))
		else
			entry({"admin", "services", "vpn-policy-routing"}, cbi("vpn-policy-routing"), _("VPN Policy Routing"))
		end
	entry({"admin", "services", "vpn-policy-routing-action"}, post("action_vpn_policy_routing")).leaf = true
	end
end

function action_vpn_policy_routing()
	local packageName = "vpn-policy-routing"
	if luci.http.formvalue("start") then
		luci.sys.init.start(packageName)
	elseif luci.http.formvalue("stop") then
		luci.sys.init.stop(packageName)
	elseif luci.http.formvalue("enable") then
		luci.util.exec("uci set " .. packageName .. ".config.enabled=1; uci commit " .. packageName)
	elseif luci.http.formvalue("disable") then
		luci.util.exec("uci set " .. packageName .. ".config.enabled=0; uci commit " .. packageName)
	elseif luci.http.formvalue("reload") then
		luci.util.exec("/etc/init.d/" .. packageName .. " reload")
	end
end
