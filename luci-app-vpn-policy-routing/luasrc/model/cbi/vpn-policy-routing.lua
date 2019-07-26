-- local readmeURL = "https://github.com/openwrt/packages/tree/master/net/vpn-policy-routing/files/README.md"
local readmeURL = "https://github.com/stangri/openwrt_packages/tree/master/vpn-policy-routing/files/README.md"

-- function log(obj)
-- 	if obj ~= nil then if type(obj) == "table" then luci.util.dumptable(obj) else luci.util.perror(obj) end else luci.util.perror("Empty object") end
-- end

local packageName = "vpn-policy-routing"
local uci = require "luci.model.uci".cursor()
local sys = require "luci.sys"
local util = require "luci.util"
local ip = require "luci.ip"
local fs = require "nixio.fs"
local jsonc = require "luci.jsonc"
local http = require "luci.http"
local dispatcher = require "luci.dispatcher"
local enc

local t = uci:get("vpn-policy-routing", "config", "supported_interface")
if not t then
	supportedIfaces = ""
elseif type(t) == "table" then
	for key,value in pairs(t) do supportedIfaces = supportedIfaces and supportedIfaces .. ' ' .. value or value end
elseif type(t) == "string" then
	supportedIfaces = t
end

t = uci:get("vpn-policy-routing", "config", "ignored_interface")
if not t then
	ignoredIfaces = ""
elseif type(t) == "table" then
	for key,value in pairs(t) do ignoredIfaces = ignoredIfaces and ignoredIfaces .. ' ' .. value or value end
elseif type(t) == "string" then
	ignoredIfaces = t
end

local lanIPAddr = uci:get("network", "lan", "ipaddr")
local lanNetmask = uci:get("network", "lan", "netmask")
-- if multiple ip addresses on lan interface, will be return as table of CIDR notations i.e. {"10.0.0.1/24","10.0.0.2/24"}
if (type(lanIPAddr) == "table") then                                                                                   
        first = true                                                                                             
        for i,line in ipairs(lanIPAddr) do                                                                  
                lanIPAddr = lanIPAddr[i]                                                                    
                break                                           
        end                                                     
        lanIPAddr = string.match(lanIPAddr,"[0-9.]+")                                                            
end          
if lanIPAddr and lanNetmask then
	laPlaceholder = ip.new(lanIPAddr .. "/" .. lanNetmask )
end

function is_supported_interface(arg)
	local name=arg['.name']
	local proto=arg['proto']
	local ifname=arg['ifname']

	if name and supportedIfaces:match('%f[%w]' .. name .. '%f[%W]') then return true end
	if name and not ignoredIfaces:match('%f[%w]' .. name .. '%f[%W]') then
		if type(ifname) == "table" then
			for key,value in pairs(ifname) do
				if value and value:sub(1,3) == "tun" then return true end
				if value and value:sub(1,3) == "tap" then return true end
				if value and value:sub(1,3) == "tor" then return true end
				if value and fs.access("/sys/devices/virtual/net/" .. value .. "/tun_flags") then return true end
			end
		elseif type(ifname) == "string" then
			if ifname and ifname:sub(1,3) == "tun" then return true end
			if ifname and ifname:sub(1,3) == "tap" then return true end
			if ifname and ifname:sub(1,3) == "tor" then return true end
			if ifname and fs.access("/sys/devices/virtual/net/" .. ifname .. "/tun_flags") then return true end
		end
		if proto and proto:sub(1,11) == "openconnect" then return true end
		if proto and proto:sub(1,4) == "pptp" then return true end
		if proto and proto:sub(1,4) == "l2tp" then return true end
		if proto and proto:sub(1,9) == "wireguard" then return true end
	end
end

local tmpfs
if fs.access("/var/run/" .. packageName .. ".json") then
	tmpfs = jsonc.parse(util.trim(sys.exec("cat /var/run/" .. packageName .. ".json")))
end

local tmpfsVersion, tmpfsStatus = "", "Stopped"
if tmpfs and tmpfs['data'] then
	if tmpfs['data']['status'] and tmpfs['data']['status'] ~= "" then
		tmpfsStatus = tmpfs['data']['status']
	end
	if tmpfs['data']['version'] and tmpfs['data']['version'] ~= "" then
		tmpfsVersion = " (" .. packageName .. " " .. tmpfs['data']['version'] .. ")"
	end
end

m = Map("vpn-policy-routing", translate("Openconnect, OpenVPN, PPTP, Wireguard and WAN Policy-Based Routing"))
st = m:section(NamedSection, "config", "vpn-policy-routing", translate("Service Status") .. tmpfsVersion)
local packageName = "vpn-policy-routing"
local enabledFlag = uci:get(packageName, "config", "enabled")
en = st:option(Button, "__toggle")
if enabledFlag ~= "1" or tmpfsStatus:match("Stopped") then
	en.title      = translate("Service is disabled/stopped")
	en.inputtitle = translate("Enable/Start")
	en.inputstyle = "apply important"
else
	en.title      = translate("Service is enabled/started")
	en.inputtitle = translate("Stop/Disable")
	en.inputstyle = "reset important"
	ds = st:option(DummyValue, "_dummy", translate("Service Status"))
	ds.template = "vpn-policy-routing/status"
	ds.value = tmpfsStatus
	if not tmpfsStatus:match("Success") then
		reload = st:option(Button, "__reload")
		reload.title      = translate("Service started with error(s)")
		reload.inputtitle = translate("Reload")
		reload.inputstyle = "apply important"
		function reload.write()
			sys.exec("/etc/init.d/vpn-policy-routing reload")
			http.redirect(dispatcher.build_url("admin/services/" .. packageName))
		end
	end
end
function en.write()
	enabledFlag = enabledFlag == "1" and "0" or "1"
	uci:set(packageName, "config", "enabled", enabledFlag)
	uci:save(packageName)
	uci:commit(packageName)
	if enabledFlag == "0" then
		sys.init.stop(packageName)
	else
		sys.init.enable(packageName)
		sys.init.start(packageName)
	end
	http.redirect(dispatcher.build_url("admin/services/" .. packageName))
end

-- General options
config = m:section(NamedSection, "config", "vpn-policy-routing", translate("Configuration"))
config.override_values = true
config.override_depends = true
config:tab("basic", translate("Basic Configuration"))

verb = config:taboption("basic", ListValue, "verbosity", translate("Output verbosity"),translate("Controls both system log and console output verbosity"))
verb:value("0", translate("Suppress/No output"))
verb:value("1", translate("Condensed output"))
verb:value("2", translate("Verbose output"))
verb.default = 2

se = config:taboption("basic", ListValue, "strict_enforcement", translate("Strict enforcement"),translate("See the") .. " "
  .. [[<a href="]] .. readmeURL .. [[#strict-enforcement" target="_blank">]]
  .. translate("README") .. [[</a>]] .. " " .. translate("for details"))
se:value("0", translate("Do not enforce policies when their gateway is down"))
se:value("1", translate("Strictly enforce policies when their gateway is down"))
se.default = 1

dnsmasq = config:taboption("basic", ListValue, "dnsmasq_enabled", translate("Use DNSMASQ for domain policies"),
	translate("Please check the" .. " "
  .. [[<a href="]] .. readmeURL .. [[#use-dnsmasq" target="_blank">]]
  .. translate("README") .. [[</a>]] .. " " .. translate("before enabling this option.")))
dnsmasq:value("0", translate("Disabled"))
dnsmasq:value("1", translate("Enabled"))

ipset = config:taboption("basic", ListValue, "ipset_enabled", translate("Use ipsets"),
	translate("Please check the") .. " "
  .. [[<a href="]] .. readmeURL .. [[#additional-settings" target="_blank">]]
  .. translate("README") .. [[</a>]] .. " " .. translate("before changing this option."))
ipset:depends({dnsmasq_enabled="0"})
ipset:value("", translate("Disabled"))
ipset:value("1", translate("Enabled"))

ipv6 = config:taboption("basic", ListValue, "ipv6_enabled", translate("IPv6 Support"))
ipv6:value("0", translate("Disabled"))
ipv6:value("1", translate("Enabled"))

config:tab("advanced", translate("Advanced Configuration"),
	"<br/>&nbsp;&nbsp;&nbsp;&nbsp;<b>" .. translate("WARNING:") .. "</b>" .. " " .. translate("Please make sure to check the") .. " "
	.. [[<a href="]] .. readmeURL .. [[#additional-settings" target="_blank">]] .. translate("README") .. [[</a>]] .. " "
	.. translate("before changing anything in this section! Change any of the settings below with extreme caution!") .. "<br/><br/>")

supported = config:taboption("advanced", DynamicList, "supported_interface", translate("Supported Interfaces"), translate("Allows to specify the list of interface names (in lower case) to be explicitly supported by the service. Can be useful if your OpenVPN tunnels have dev option other than tun* or tap*."))
supported.optional = false
supported.rmempty = true

ignored = config:taboption("advanced", DynamicList, "ignored_interface", translate("Ignored Interfaces"), translate("Allows to specify the list of interface names (in lower case) to be ignored by the service. Can be useful if running both VPN server and VPN client on the router."))
ignored.optional = false
ignored.rmempty = true

timeout = config:taboption("advanced", Value, "boot_timeout", translate("Boot Time-out"), translate("Time (in seconds) for service to wait for WAN gateway discovery on boot."))
timeout.optional = false
timeout.rmempty = true

insert = config:taboption("advanced", ListValue, "iptables_rule_option", translate("IPTables rule option"), translate("Select Append for -A and Insert for -I."))
insert:value("", translate("Append"))
insert:value("insert", translate("Insert"))
insert.default = ""
insert.rmempty = true

iprule = config:taboption("advanced", ListValue, "iprule_enabled", translate("IP Rules Support"), translate("Add an ip rule, not an iptables entry for policies with just the local address. Use with caution to manipulte policies priorities."))
iprule:value("", translate("Disabled"))
iprule:value("1", translate("Enabled"))
iprule.rmempty = true

enable_control = config:taboption("advanced", ListValue, "enable_control", translate("Show Enable Column"), translate("Shows the enable checkbox column for policies, allowing you to quickly enable/disable specific policy without deleting it."))
enable_control:value("", translate("Disabled"))
enable_control:value("1", translate("Enabled"))
enable_control.rmempty = true

proto_control = config:taboption("advanced", ListValue, "proto_control", translate("Show Protocol Column"), translate("Shows the protocol column for policies, allowing you to assign a TCP, UDP or TCP/UDP protocol to a policy."))
proto_control:value("", translate("Disabled"))
proto_control:value("1", translate("Enabled"))
proto_control.rmempty = true

chain_control = config:taboption("advanced", ListValue, "chain_control", translate("Show Chain Column"), translate("Shows the chain column for policies, allowing you to assign a TCP, UDP or TCP/UDP protocol to a policy."))
chain_control:value("", translate("Disabled"))
chain_control:value("1", translate("Enabled"))
chain_control.rmempty = true

icmp = config:taboption("advanced", ListValue, "icmp_interface", translate("Default ICMP Interface"), translate("Force the ICMP protocol interface."))
icmp:value("", translate("No Change"))
icmp:value("wan", translate("WAN"))
uci:foreach("network", "interface", function(s)
	local name=s['.name']
	if is_supported_interface(s) then icmp:value(name, string.upper(name)) end
end)
icmp.rmempty = true

append_local = config:taboption("advanced", Value, "append_local_rules", translate("Append local IP Tables rules"), translate("Special instructions to append iptables rules for local IPs/netmasks/devices."))
append_local.rmempty = true

append_remote = config:taboption("advanced", Value, "append_remote_rules", translate("Append remote IP Tables rules"), translate("Special instructions to append iptables rules for remote IPs/netmasks."))
append_remote.rmempty = true

wantid = config:taboption("advanced", Value, "wan_tid", translate("WAN Table ID"), translate("Starting (WAN) Table ID number for tables created by the service."))
wantid.rmempty = true
wantid.placeholder = "201"

wanmark = config:taboption("advanced", Value, "wan_mark", translate("WAN Table FW Mark"), translate("Starting (WAN) FW Mark for marks used by the service. High starting mark is used to avoid conflict with SQM/QoS. Change with caution together with") .. " " .. translate("Service FW Mask") .. ".")
wanmark.rmempty = true
wanmark.placeholder = "0x010000"

fwmask = config:taboption("advanced", Value, "fw_mask", translate("Service FW Mask"), translate("FW Mask used by the service. High mask is used to avoid conflict with SQM/QoS. Change with caution together with") .. " " .. translate("WAN Table FW Mark") .. ".")
fwmask.rmempty = true
fwmask.placeholder = "0xff0000"

-- Policies
p = m:section(TypedSection, "policy", translate("Policies"), translate("Comment, interface and at least one other field are required. Multiple local and remote addresses/devices/domains and ports can be space separated. Placeholders below represent just the format/syntax and will not be used if fields are left blank."))
p.template = "cbi/tblsection"
p.sortable  = true
p.anonymous = true
p.addremove = true

enc = uci:get("vpn-policy-routing", "config", "enable_control")
if enc and enc ~= 0 then
	le = p:option(Flag, "enabled", translate("Enabled"))
	le.default = "1"
end

local comment = uci:get_first("vpn-policy-routing", "policy", "comment")
if comment then
	p:option(Value, "comment", translate("Comment"))
else
	p:option(Value, "name", translate("Name"))
end

la = p:option(Value, "local_address", translate("Local addresses/devices"))
if laPlaceholder then
	la.placeholder = laPlaceholder
end
la.rmempty = true

lp = p:option(Value, "local_port", translate("Local ports"))
lp.datatype    = "list(neg(portrange))"
lp.placeholder = "0-65535"
lp.rmempty = true

ra = p:option(Value, "remote_address", translate("Remote addresses/domains"))
ra.placeholder = "0.0.0.0/0"
ra.rmempty = true

rp = p:option(Value, "remote_port", translate("Remote ports"))
rp.datatype    = "list(neg(portrange))"
rp.placeholder = "0-65535"
rp.rmempty = true

enc = uci:get("vpn-policy-routing", "config", "proto_control")
if enc and enc ~= 0 then
	proto = p:option(ListValue, "proto", translate("Protocol"))
	proto.rmempty = true
	proto.default = "tcp"
	proto:value("tcp","TCP")
	proto:value("udp","UDP")
	proto:value("tcp udp","TCP/UDP")
end

enc = uci:get("vpn-policy-routing", "config", "chain_control")
if enc and enc ~= 0 then
	chain = p:option(ListValue, "chain", translate("Chain"))
	chain.rmempty = true
	chain.default = "PREROUTING"
	chain:value("PREROUTING")
	chain:value("FORWARD")
	chain:value("INPUT")
	chain:value("OUTPUT")
end

gw = p:option(ListValue, "interface", translate("Interface"))
-- gw.datatype = "network"
gw.rmempty = false
gw.default = "wan"
gw:value("wan","WAN")
uci:foreach("network", "interface", function(s)
	local name=s['.name']
	if is_supported_interface(s) then gw:value(name, string.upper(name)) end
end)

dscp = m:section(NamedSection, "config", "vpn-policy-routing", translate("DSCP Tagging"), translate("Set DSCP tags (in range between 1 and 63) for specific interfaces."))
wan = dscp:option(Value, "wan_dscp", translate("WAN DSCP Tag"))
wan.datatype = "range(1,63)"
wan.rmempty = true
uci:foreach("network", "interface", function(s)
	local name=s['.name']
	if is_supported_interface(s) then dscp:option(Value, name .. "_dscp", string.upper(name) .. " " .. translate("DSCP Tag")).rmempty = true end
end)

-- Includes
inc = m:section(TypedSection, "include", translate("Custom User File Includes"), translate("Run the following user files after setting up but before restarting DNSMASQ. See the") .. " "
  .. [[<a href="]] .. readmeURL .. [[#custom-user-files" target="_blank">]]
  .. translate("README") .. [[</a>]] .. " " .. translate("for details."))
inc.template = "cbi/tblsection"
inc.sortable  = true
inc.anonymous = true
inc.addremove = true

finc = inc:option(Flag, "enabled", translate("Enabled"))
finc.optional = false
finc.default = "1"
inc:option(Value, "path", translate("Path")).optional = false

return m
