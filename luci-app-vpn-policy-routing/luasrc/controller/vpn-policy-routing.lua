module("luci.controller.vpn-policy-routing", package.seeall)
function index()
	if nixio.fs.access("/etc/config/vpn-policy-routing") then
		local node, pkgVersion = "services", tonumber(luci.util.trim(luci.sys.exec("opkg list-installed luci-app-openvpn | awk '{print $3}' | awk -F'[-.]' '{print $2}'")))
		if pkgVersion and pkgVersion >= 19 then node = "vpn" end
		entry({"admin", node, "vpn-policy-routing"}, cbi("vpn-policy-routing"), _("VPN Policy Routing"))
		entry({"admin", node, "vpn-policy-routing", "action"}, call("vpn_policy_routing_action"), nil).leaf = true
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
