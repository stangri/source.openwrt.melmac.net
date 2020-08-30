module("luci.controller.vpnbypass", package.seeall)
function index()
	if nixio.fs.access("/etc/config/vpnbypass") then
		local e = entry({"admin", "vpn"}, firstchild(), _("VPN"), 60)
		e.dependent = false
		e.acl_depends = { "luci-app-vpnbypass" }
		entry({"admin", "vpn", "vpnbypass"}, cbi("vpnbypass"), _("VPN Bypass"))
		entry({"admin", "vpn", "vpnbypass", "action"}, call("vpnbypass_action"), nil).leaf = true
	end
end

function vpnbypass_action(name)
	local packageName = "vpnbypass"
	if name == "start" then
		luci.sys.init.start(packageName)
	elseif name == "action" then
		luci.util.exec("/etc/init.d/" .. packageName .. " restart >/dev/null 2>&1")
		luci.util.exec("/etc/init.d/dnsmasq restart >/dev/null 2>&1")
	elseif name == "stop" then
		luci.sys.init.stop(packageName)
	elseif name == "enable" then
		luci.sys.init.enable(packageName)
	elseif name == "disable" then
		luci.sys.init.disable(packageName)
	end
	luci.http.prepare_content("text/plain")
	luci.http.write("0")
end
