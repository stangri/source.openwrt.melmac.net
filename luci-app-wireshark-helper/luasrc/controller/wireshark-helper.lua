module("luci.controller.wireshark-helper", package.seeall)
function index()
	if nixio.fs.access("/etc/config/wireshark-helper") then
		entry({"admin", "services", "wireshark-helper"}, cbi("wireshark-helper"), _("Wireshark Helper")).acl_depends = { "luci-app-wireshark-helper" }
		entry({"admin", "services", "wireshark-helper", "action"}, call("wireshark_helper_action"), nil).leaf = true
	end
end

function wireshark_helper_action(name)
	local packageName = "wireshark-helper"
	local http = require "luci.http"
	local sys = require "luci.sys"
	local uci = require "luci.model.uci".cursor()
	local util = require "luci.util"
	if name == "start" then
		sys.init.start(packageName)
	elseif name == "action" then
		util.exec("/etc/init.d/" .. packageName .. " restart >/dev/null 2>&1")
	elseif name == "stop" then
		sys.init.stop(packageName)
	elseif name == "enable" then
		uci:set(packageName, "config", "enabled", "1")
		uci:commit(packageName)
	elseif name == "disable" then
		uci:set(packageName, "config", "enabled", "0")
		uci:commit(packageName)
	end
	http.prepare_content("text/plain")
	http.write("0")
end
