// Copyright 2022 Stan Grishin (stangri@melmac.ca)

'use strict';
'require form';
'require uci';
'require view';
'require pbr.widgets as widgets';

var pkg = {
	get Name() { return 'pbr'; },
	get URL() { return 'https://docs.openwrt.melmac.net/' + pkg.Name + '/'; }
};

return view.extend({
	load: function () {
		return Promise.all([
			uci.load(pkg.Name)
		]);
	},

	render: function (data) {

		var m, s, o;

		m = new form.Map(pkg.Name, _('Policy Based Routing'));

		s = m.section(form.NamedSection, 'config', pkg.Name);

		o = s.option(widgets.Status, '', _('Service Status'));

		o = s.option(widgets.Buttons, '', _('Service Control'));

		s.tab("tab_basic", _("Basic Configurations"));
		s.tab("tab_advanced", _("Advanced Configuration"), 
			_("%sWARNING:%s Please make sure to check the %sREADME%s before changing anything in this section! " +
			"Change any of the settings below with extreme caution!%s").format(
			"<br/>&#160;&#160;&#160;&#160;<b>", "</b>", 
			"<a href=\"" + pkg.URL + "#service-configuration-settings \" target=\"_blank\">", "</a>", "<br/><br/>"));
		s.tab("tab_webui", _("Web UI Configuration"))

		o = s.taboption("tab_basic", form.ListValue, "verbosity", _("Output verbosity"), 
			_("Controls both system log and console output verbosity."));
		o.value("0", _("Suppress/No output"));
		o.value("1", _("Condensed output"));
		o.value("2", _("Verbose output"));
		o.default = "2";

		o = s.taboption("tab_basic", form.ListValue, "strict_enforcement", _("Strict enforcement"),
			_("See the %sREADME%s for details.").format(
			"<a href=\"" + pkg.URL + "#strict-enforcement\" target=\"_blank\">", "</a>"));
		o.value("0", _("Do not enforce policies when their gateway is down"));
		o.value("1", _("Strictly enforce policies when their gateway is down"));
		o.default = "1";

// TODO: add resolver_set to tab_basic
		var resolver_set_descr = "description";
		var resolver_set_descr_readme = _("Please check the %sREADME%s before changing this option.").format(
		"<a href=\"" + pkg.URL + "#service-configuration-settings\" target=\"_blank\">", "</a>");

// if not checkDnsmasq() then
// 		resolver_set_descr = _f("Please note that %s is not supported on this system.", "<i>dnsmasq.ipset</i>")
// 		resolver_set_descr = resolver_set_descr.. "<br />".._f("Please note that %s is not supported on this system.", "<i>dnsmasq.nftset</i>")
// else
// 	if not checkDnsmasqIpset() then 
// 		resolver_set_descr = _f("Please note that %s is not supported on this system.", "<i>dnsmasq.ipset</i>")
// 	end
// 	if not checkDnsmasqNftset() then 
// 		resolver_set_descr = _f("Please note that %s is not supported on this system.", "<i>dnsmasq.nftset</i>")
// 	end
// end
// if resolver_set_descr then
// 	resolver_set_descr = resolver_set_descr.. "<br />" ..resolver_set_descr_readme
// else
// 	resolver_set_descr = resolver_set_descr_readme
// end
		o = s.taboption("tab_basic", form.ListValue, "resolver_set", _("Use resolver set support for domains"), resolver_set_descr);
		o.value("none", _("Disabled"));
// if checkDnsmasq() then
// if checkDnsmasqIpset() then
// resolver_set: value("dnsmasq.ipset", _("DNSMASQ Ipset"))
// resolver_set.default = "dnsmasq.ipset"
// end
// if checkDnsmasqNftset() then
// resolver_set: value("dnsmasq.nftset", _("DNSMASQ Nft Set"))
// resolver_set.default = "dnsmasq.nftset"
// end
// else
// resolver_set.default = "none"
// end

		o = s.taboption("tab_basic", form.ListValue, "ipv6_enabled", _("IPv6 Support"));
		o.value("0", _("Disabled"));
		o.value("1", _("Enabled"));

		o = s.taboption("tab_advanced", form.DynamicList, "supported_interface", _("Supported Interfaces"),
			_("Allows to specify the list of interface names (in lower case) to be explicitly supported by the service. " + 
			"Can be useful if your OpenVPN tunnels have dev option other than tun* or tap*."));
		o.optional = false;

		o = s.taboption("tab_advanced", form.DynamicList, "ignored_interface", _("Ignored Interfaces"),
			_("Allows to specify the list of interface names (in lower case) to be ignored by the service. " +
			"Can be useful if running both VPN server and VPN client on the router."));
		o.optional = false;

		o = s.taboption("tab_advanced", form.ListValue, "rule_create_option", _("Rule Create option"),
			_("Select Add for -A/add and Insert for -I/Insert."));
		o.value("add", _("Add"));
		o.value("insert", _("Insert"));
		o.default = "add";

		o = s.taboption("tab_advanced", form.ListValue, "icmp_interface", _("Default ICMP Interface"),
			_("Force the ICMP protocol interface."));
		o.value("", _("No Change"));
		o.value("wan", _("WAN"));
// TODO: populate interfaces from GetSupportedInterfaces call
		o.rmempty = true;

		o = s.taboption("tab_advanced", form.Value, "wan_tid", _("WAN Table ID"),
			_("Starting (WAN) Table ID number for tables created by the service."));
		o.rmempty = true;
		o.placeholder = "201";
		o.datatype = "and(uinteger, min(201))";

		o = s.taboption("tab_advanced", form.Value, "wan_mark", _("WAN Table FW Mark"), 
			_("Starting (WAN) FW Mark for marks used by the service. High starting mark is " +
			"used to avoid conflict with SQM/QoS. Change with caution together with") + 
			" " + _("Service FW Mask") + ".");
		o.rmempty = true;
		o.placeholder = "0x010000";
		o.datatype = "hex(8)";

		o = s.taboption("tab_advanced", form.Value, "fw_mask", _("Service FW Mask"),
			_("FW Mask used by the service. High mask is used to avoid conflict with SQM/QoS. " +
			"Change with caution together with") + " " + _("WAN Table FW Mark") + ".");
		o.rmempty = true;
		o.placeholder = "0xff0000";
		o.datatype = "hex(8)";

		o = s.taboption("tab_webui", form.DynamicList, "webui_supported_protocol", _("Supported Protocols"),
			_("Display these protocols in protocol column in Web UI."));
		o.optional = false;

		o = s.taboption("tab_webui", form.ListValue, "webui_show_ignore_target", _("Add IGNORE Target"),
		_("Adds `IGNORE` to the list of interfaces for policies, allowing you to skip " +
		"further processing by VPN Policy Routing."));
		o.value("0", _("Disabled"));
		o.value("1", _("Enabled"));

		s = m.section(form.GridSection, 'policy', _('Policies'),
			_("Name, interface and at least one other field are required. Multiple local and remote " +
			"addresses/devices/domains and ports can be space separated. Placeholders below represent just " +
			"the format/syntax and will not be used if fields are left blank."));
		s.sortable = true;
		s.anonymous = true;
		s.addremove = true;

		o = s.option(form.Flag, "enabled", _("Enabled"));
		o.default = "1";

		o = s.option(form.Value, "name", _("Name"));

		o = s.option(form.Value, "src_addr", _("Local addresses / devices"));
		o.rmempty = true;
		o.datatype = "list(neg(or(host,network,macaddr)))";

		o = s.option(form.Value, "src_port", _("Local ports"));
		o.datatype = "list(neg(or(portrange,port)))";
		o.placeholder = "0-65535";
		o.rmempty = true;

		o = s.option(form.Value, "dest_addr", _("Remote addresses / domains"));
		o.datatype = "list(neg(or(host,network,macaddr)))";
		o.placeholder = "0.0.0.0/0";
		o.rmempty = true;

		o = s.option(form.Value, "dest_port", _("Remote ports"));
		o.datatype = "list(neg(or(portrange,port)))";
		o.placeholder = "0-65535";
		o.rmempty = true;

		o = s.option(form.ListValue, "proto", _("Protocol"));
		o.value("", _("all"));
		o.default = ("", _("all"));
		o.rmempty = true;
// TODO:		enc = uci:get_list("pbr", "config", "webui_supported_protocol")
//		if next(enc) == nil then
//		enc = { "all", "tcp", "udp", "tcp udp", "icmp" }
//		end
//		for key, value in pairs(enc) do
//			proto: value(value: lower(), value: gsub(" ", "/"): upper())

		o = s.option(form.ListValue, "chain", _("Chain"));
		o.value("", "PREROUTING");
		o.value("FORWARD", "FORWARD");
		o.value("INPUT", "INPUT");
		o.value("OUTPUT", "OUTPUT");
		o.value("POSTROUTING", "POSTROUTING");
		o.default = ("", "PREROUTING");
		o.rmempty = true;

		o = s.option(form.ListValue, "interface", _("Interface"));
		o.datatype = "network";
		o.rmempty = false;
// TODO: populate interfaces from GetSupportedInterfaces call
		o.value("wan", "WAN");
		o.value("ignore", "IGNORE");

		s = m.section(form.NamedSection, 'config', pkg.Name, _("DSCP Tagging"),
			_("Set DSCP tags (in range between 1 and 63) for specific interfaces. See the %sREADME%s for details.").format(
			"<a href=\"" + pkg.URL +  "#dscp-tag-based-policies" +  "\" target=\"_blank\">", "</a>"));
// TODO x = dscp:option(Value, name.. "_dscp", name: upper().. " ".._("DSCP Tag"))
		o = s.option(form.Value, "wan_dscp", "WAN" + " " + _("DSCP Tag"));

		s = m.section(form.GridSection, 'include',_("Custom User File Includes"),
			_("Run the following user files after setting up but before restarting DNSMASQ. " +
			"See the %sREADME%s for details.").format(
			"<a href=\"" + pkg.URL +  "#custom-user-files\" target=\"_blank\">", "</a>"));
		s.sortable = true;
		s.anonymous = true;
		s.addremove = true;

		s.option(form.Flag, "enabled", _("Enabled")).optional = false;
		s.option(form.Value, "path", _("Path")).optional = false;

		return m.render();
	}
});
