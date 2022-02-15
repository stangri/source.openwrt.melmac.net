module("luci.controller.pbr", package.seeall)
function index()
	if nixio.fs.access("/etc/config/pbr") then
		entry({"admin", "services", "pbr"}, cbi("pbr"), _("Policy Based Routing")).acl_depends = { "luci-app-pbr" }
		entry({"admin", "services", "pbr", "action"}, call("pbr_action"), nil).leaf = true
	end
end

function pbr_action(name)
	local packageName = "pbr"
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
