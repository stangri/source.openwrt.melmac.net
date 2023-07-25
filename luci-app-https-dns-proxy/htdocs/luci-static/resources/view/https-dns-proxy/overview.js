// Copyright 2022 Stan Grishin <stangri@melmac.ca>
// This code wouldn't have been possible without help from [@vsviridov](https://github.com/vsviridov)

'use strict';
'require form';
'require rpc';
'require uci';
'require view';
'require https-dns-proxy.status as hdp';

var pkg = {
	get Name() { return 'https-dns-proxy'; },
	get URL() { return 'https://docs.openwrt.melmac.net/' + pkg.Name + '/'; }
};

return view.extend({
	load: function () {
		return Promise.all([
			uci.load(pkg.Name),
			uci.load('dhcp')
		]);
	},

	render: function () {
		return Promise.all([
			L.resolveDefault(hdp.getPlatformSupport(pkg.Name), {}),
			L.resolveDefault(hdp.getProviders(pkg.Name), {}),
		]).then(function (data) {
			var reply = {
				platform: data[0] && data[0][pkg.Name] || {
					http2_support: null,
					http3_support: null,
				},
				providers: data[1] && data[1][pkg.Name] || { providers: [] },
			};
			var status, m, s, o;

			status = new hdp.status();

			m = new form.Map(pkg.Name, _("HTTPS DNS Proxy - Configuration"));

			s = m.section(form.NamedSection, 'config', pkg.Name);
			o = s.option(form.ListValue, "dnsmasq_config_update", _("Update DNSMASQ Config on Start/Stop"),
				_("If update option is selected, the %s'DNS forwardings' section of DHCP and DNS%s will be automatically updated to use selected DoH providers (%smore information%s).").format("<a href=\"" + L.url("admin", "network", "dhcp") + "\">", "</a>", "<a href=\"" + pkg.URL + "#default-settings" + "\" target=\"_blank\">", "</a>"));
			o.value('*', _("Update all configs"));
			var sections = uci.sections('dhcp', 'dnsmasq');
			sections.forEach(element => {
				var description;
				var key;
				if (element[".name"] === uci.resolveSID('dhcp', element[".name"])) {
					key = element[".index"];
					description = "dnsmasq[" + element[".index"] + "]";
				}
				else {
					key = element[".name"];
					description = element[".name"];
				}
				o.value(key, _("Update %s only").format(description));
			});
			o.value('-', _("Do not update configs"));
			o.default = "*";

			o = s.option(form.ListValue, "force_dns", _("Force Router DNS"),
				_("Forces Router DNS use on local devices, also known as DNS Hijacking."));
			o.value("0", _("Let local devices use their own DNS servers if set"));
			o.value("1", _("Force Router DNS server to all local devices"));
			o.default = "1";

			o = s.option(form.ListValue, "canary_domains_icloud", _("Canary Domains iCloud"),
				_("Blocks access to iCloud Private Relay resolvers, forcing local devices to use router for DNS resolution (%smore information%s).").format("<a href=\"" + pkg.URL + "#canary_domains_icloud" + "\" target=\"_blank\">", "</a>"));
			o.value("0", _("Let local devices use iCloud Private Relay"));
			o.value("1", _("Force Router DNS server to all local devices"));
			o.depends('force_dns', '1');
			o.default = "1";

			o = s.option(form.ListValue, "canary_domains_mozilla", _("Canary Domains Mozilla"),
				_("Blocks access to Mozilla Private Relay resolvers, forcing local devices to use router for DNS resolution (%smore information%s).").format("<a href=\"" + pkg.URL + "#canary_domains_mozilla" + "\" target=\"_blank\">", "</a>"));
			o.value("0", _("Let local devices use Mozilla Private Relay"));
			o.value("1", _("Force Router DNS server to all local devices"));
			o.depends('force_dns', '1');
			o.default = "1";

			s = m.section(form.GridSection, 'https-dns-proxy', _('Instances Grid'));
			s.rowcolors = true;
			s.sortable = true;
			s.anonymous = true;
			s.addremove = true;

			o = s.option(form.Value, "resolver_url", _("Resolver"));
			o = s.option(form.Value, "param", _("Option"));
			o = s.option(form.Value, "listen_addr", _("Listen Address"));
			o = s.option(form.Value, "listen_addr", _("Listen Port"));

			return Promise.all([status.render(), m.render()]);
		})
	}
});
