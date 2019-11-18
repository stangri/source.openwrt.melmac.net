module("luci.controller.vpnbypass", package.seeall)
function index()
	if nixio.fs.access("/etc/config/vpnbypass") then
		local node, pkgVersion = "services", tonumber(luci.util.trim(luci.sys.exec("opkg list-installed luci-app-openvpn | awk '{print $3}' | awk -F'[-.]' '{print $2}'")))
		if pkgVersion and pkgVersion >= 19 then node = "vpn" end
		entry({"admin", node, "vpnbypass"}, cbi("vpnbypass"), _("VPN Bypass"))
		entry({"admin", node, "vpnbypass", "action"}, call("vpnbypass_action"), nil).leaf = true
	end
end

function vpnbypass_action(name)
	local packageName = "vpnbypass"
	if name == "start" then
		luci.sys.init.start(packageName)
	elseif name == "action" then
		luci.util.exec("/etc/init.d/" .. packageName .. " reload >/dev/null 2>&1")
		luci.util.exec("/etc/init.d/dnsmasq restart >/dev/null 2>&1")
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
