module("luci.controller.vpn-policy-routing", package.seeall)
function index()
	if nixio.fs.access("/etc/config/vpn-policy-routing") then
		if luci.dispatcher.lookup and luci.dispatcher.lookup("admin/vpn") then
			entry({"admin", "vpn", "vpn-policy-routing"}, cbi("vpn-policy-routing"), _("VPN Policy Routing"))
		else
			entry({"admin", "services", "vpn-policy-routing"}, cbi("vpn-policy-routing"), _("VPN Policy Routing"))
		end
		entry({"admin", "services", "vpn-policy-routing", "action"}, call("vpn_policy_routing_action"), nil).leaf = true
	end
end

function vpn_policy_routing_action(name)
	local packageName = "vpn-policy-routing"
	if name == "start" then
		luci.sys.init.start(packageName)
	elseif name == "action" then
		luci.util.exec("/etc/init.d/" .. packageName .. " reload >/dev/null 2>&1")
	elseif name == "stop" then
		luci.sys.init.stop(packageName)
	elseif name == "enable" then
		luci.util.exec("uci set " .. packageName .. ".config.enabled=1; uci commit " .. packageName)
	elseif name == "disable" then
		luci.util.exec("uci set " .. packageName .. ".config.enabled=0; uci commit " .. packageName)
	end
	luci.http.prepare_content("text/plain")
	luci.http.write("0")
end
