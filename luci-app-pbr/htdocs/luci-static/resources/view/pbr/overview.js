// Copyright 2022 Stan Grishin <stangri@melmac.ca>
// This code wouldn't have been possible without help from [@vsviridov](https://github.com/vsviridov)

'use strict';
'require form';
'require uci';
'require view';
'require pbr.widgets as widgets';
'require pbr.status as statusWidget';

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

		m = new form.Map(pkg.Name, _("Policy Based Routing - Configuration"));

		s = m.section(form.NamedSection, 'config', pkg.Name);
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

		var resolver;
		var r_descr = "";
		widgets.RPC.on('getPlatformSupport', function (reply) {
			if (! (reply[pkg.Name].dnsmasq_ipset_support)) {
				r_descr += _("Please note that %s is not supported on this system.").format("<i>dnsmasq.ipset</i>") + "<br />"
			}
			if (! (reply[pkg.Name].dnsmasq_nftset_support)) {
				r_descr += _("Please note that %s is not supported on this system.").format("<i>dnsmasq.nftset</i>") + "<br />"
			}
			});
		r_descr += _("Please check the %sREADME%s before changing this option.").format(
			"<a href=\"" + pkg.URL + "#service-configuration-settings\" target=\"_blank\">", "</a>");
		resolver = s.taboption("tab_basic", form.ListValue, "resolver_set", _("Use resolver set support for domains"), r_descr);
		resolver.value("none", _("Disabled"));
		widgets.RPC.on('getPlatformSupport', function (reply) {
			if (reply[pkg.Name].dnsmasq_ipset_support) {
				resolver.value("dnsmasq.ipset", _("DNSMASQ Ipset"));
				resolver.default = ("dnsmasq.ipset", _("DNSMASQ Ipset"));
			}
			if (reply[pkg.Name].dnsmasq_nftset_support) {
				resolver.value("dnsmasq.nftset", _("DNSMASQ Nft Set"));
				resolver.default = ("dnsmasq.nftset", _("DNSMASQ Nft Set"));
			}
		});
		widgets.RPC.getPlatformSupport(pkg.Name);

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

		var icmp;
		icmp = s.taboption("tab_advanced", form.ListValue, "icmp_interface", _("Default ICMP Interface"),
			_("Force the ICMP protocol interface."));
		icmp.value("", _("No Change"));
		widgets.RPC.on('getInterfaces', function (reply) {
			var arr=reply[pkg.Name].interfaces;
			arr.forEach(element => {
				if ( element.name_lower !== "ignore" ) {
					icmp.value(element.name_lower, element.name_upper);
				}
			});
		});
		icmp.rmempty = true;

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

		s = m.section(form.GridSection, 'policy', _('Policies'),
			_("Name, interface and at least one other field are required. Multiple local and remote " +
			"addresses/devices/domains and ports can be space separated. Placeholders below represent just " +
			"the format/syntax and will not be used if fields are left blank."));
		s.sortable = true;
		s.anonymous = true;
		s.addremove = true;

		o = s.option(form.Flag, "enabled", _("Enabled"));
		o.default = "1";
		o.editable = true;

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
		var proto = L.toArray(uci.get(pkg.Name, "config", "webui_supported_protocol"));
		if (!proto.length) {
			proto = [ "all", "tcp", "udp", "tcp udp", "icmp" ]
		}
		proto.forEach(element => {
			if ( element === "all" ) {
				o.value("", _("all"));
				o.default = ("", _("all"));
			}
			else {
				o.value(element.toLowerCase());
			}
		});
		o.rmempty = true;

		o = s.option(form.ListValue, "chain", _("Chain"));
		o.value("", "prerouting");
		o.value("forward", "forward");
		o.value("input", "input");
		o.value("output", "output");
		o.value("postrouting", "postrouting");
		o.default = ("", "prerouting");
		o.rmempty = true;

		var iface
		iface = s.option(form.ListValue, "interface", _("Interface"));
		iface.datatype = "network";
		iface.rmempty = false;
		widgets.RPC.on('getInterfaces', function (reply) {
			var arr = reply[pkg.Name].interfaces;
			arr.forEach(element => {
				iface.value(element.name_lower);
			});
		});

		var dscp_s;
		var dscp_o;
		dscp_s = m.section(form.NamedSection, 'config', pkg.Name, _("DSCP Tagging"),
			_("Set DSCP tags (in range between 1 and 63) for specific interfaces. See the %sREADME%s for details.").format(
			"<a href=\"" + pkg.URL +  "#dscp-tag-based-policies" +  "\" target=\"_blank\">", "</a>"));
		widgets.RPC.on('getInterfaces', function (reply) {
			var arr = reply[pkg.Name].interfaces;
			arr.forEach(element => {
				if (element.name_lower !== "ignore") {
					dscp_o = dscp_s.option(form.Value, element.name_lower + "_dscp", element.name_upper + " " + _("DSCP Tag"));
				}
			});
		});
		widgets.RPC.getInterfaces(pkg.Name);

		s = m.section(form.GridSection, 'include',_("Custom User File Includes"),
			_("Run the following user files after setting up but before restarting DNSMASQ. " +
			"See the %sREADME%s for details.").format(
			"<a href=\"" + pkg.URL +  "#custom-user-files\" target=\"_blank\">", "</a>"));
		s.sortable = true;
		s.anonymous = true;
		s.addremove = true;

		s.option(form.Flag, "enabled", _("Enabled")).optional = false;
		s.option(form.Value, "path", _("Path")).optional = false;

		return Promise.all([statusWidget.render(), m.render()]);
	}
});
