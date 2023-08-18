// Copyright 2023 Stan Grishin <stangri@melmac.ca>
// This code wouldn't have been possible without help from [@vsviridov](https://github.com/vsviridov)

'use strict';
'require form';
'require rpc';
'require uci';
'require view';
'require https-dns-proxy.status as hdp';

var pkg = {
	get Name() { return 'https-dns-proxy'; },
	get URL() { return 'https://docs.openwrt.melmac.net/' + pkg.Name + '/'; },
	templateToRegexp: function (template) {
		return RegExp('^' + template.split(/(\{\w+\})/g).map(part => {
			let placeholder = part.match(/^\{(\w+)\}$/);
			if (placeholder)
				return `(?<${placeholder[1]}>.*?)`;
			else
				return part.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
		}).join('') + '$');
	},
	updateParamOption: function (opt, section_id) {
		;
	},
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
			var status, m, s, o, p;
			var __provider, __paramList, __paramText;
			var text;

			status = new hdp.status();

			m = new form.Map(pkg.Name, _("HTTPS DNS Proxy - Configuration"));

			s = m.section(form.NamedSection, "config", pkg.Name);
			o = s.option(form.ListValue, "dnsmasq_config_update", _("Update DNSMASQ Config on Start/Stop"),
				_("If update option is selected, the %s'DNS forwardings' section of DHCP and DNS%s will be automatically updated to use selected DoH providers (%smore information%s).").format("<a href=\"" + L.url("admin", "network", "dhcp") + "\">", "</a>", "<a href=\"" + pkg.URL + "#default-settings" + "\" target=\"_blank\">", "</a>"));
			o.value("*", _("Update all configs"));
			var sections = uci.sections("dhcp", "dnsmasq");
			sections.forEach(element => {
				var description;
				var key;
				if (element[".name"] === uci.resolveSID("dhcp", element[".name"])) {
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
			o.depends("force_dns", "1");
			o.default = "1";

			o = s.option(form.ListValue, "canary_domains_mozilla", _("Canary Domains Mozilla"),
				_("Blocks access to Mozilla Private Relay resolvers, forcing local devices to use router for DNS resolution (%smore information%s).").format("<a href=\"" + pkg.URL + "#canary_domains_mozilla" + "\" target=\"_blank\">", "</a>"));
			o.value("0", _("Let local devices use Mozilla Private Relay"));
			o.value("1", _("Force Router DNS server to all local devices"));
			o.depends("force_dns", "1");
			o.default = "1";

			text = "";
			if (!reply.platform.http2_support)
				text += _("Please note that %s is not supported on this system (%smore information%s).").format("<i>HTTP/2</i>", "<a href=\"" + pkg.URL + "#http2-support" + "\" target=\"_blank\">", "</a>") + "<br />";
			if (!reply.platform.http3_support)
				text += _("Please note that %s is not supported on this system (%smore information%s).").format("<i>HTTP/3 (QUIC)</i>", "<a href=\"" + pkg.URL + "#http3-quic-support" + "\" target=\"_blank\">", "</a>") + "<br />";

			s = m.section(form.GridSection, 'https-dns-proxy', _('HTTPS DNS Proxy - Instances'), text);
			s.rowcolors = true;
			s.sortable = true;
			s.anonymous = true;
			s.addremove = true;

			s.sectiontitle = (section_id => {
				var provText;
				var found;
				reply.providers.forEach(prov => {
					var option;
					let regexp = pkg.templateToRegexp(prov.template);
					let resolver = uci.get(pkg.Name, section_id, "resolver_url");
					resolver = (resolver === "undefined") ? null : resolver;
					if (!found && resolver && regexp.test(resolver)) {
						found = true;
						provText = _(prov.title);
						let match = resolver.match(regexp);
						if (match[1]) {
							if (prov.params && prov.params.option && prov.params.option.options) {
								prov.params.option.options.forEach(opt => {
									if (opt.value === match[1]) {
										option = _(opt.description);
									}
								})
								provText += " (" + option + ")";
							}
							else {
								provText += " (" + match[1] + ")";
							}
						}
					}
				});
				return provText || _("Unknown");
			});

			__provider = s.option(form.ListValue, "__provider", _("Provider"));
			__provider.modalonly = true;
			__provider.onchange = function() {
				console.log(arguments);
				pkg.updateParamOption(this, section_id);
			}

			__paramList = s.option(form.ListValue, "__paramList", _("Parameter"));
			__paramList.modalonly = true;

			__paramText = s.option(form.Value, "__paramText", _("Parameter"));
			__paramText.modalonly = true;

			reply.providers.forEach(prov => {
				__provider.value(prov.template, _(prov.title));
				if (prov.params && prov.params.option) {
					if (prov.params.option.type && prov.params.option.type === "select") {
						__paramList.depends("__provider", prov.template);
					}
					else if (prov.params.option.type && prov.params.option.type === "text") {
						__paramText.depends("__provider", prov.template);
					}
				}
			});

			o = s.option(form.Value, "bootstrap_dns", _("Bootstrap DNS"));
			o.default = "";
			o.modalonly = true;
			o.optional = true;
			o = s.option(form.Value, "listen_addr", _("Listen Address"));
			o.datatype = "ipaddr";
			o.default = "";
			o.optional = true;
			o.placeholder = "127.0.0.1";
			var n = 0;
			o = s.option(form.Value, "listen_port", _("Listen Port"));
			o.datatype = "port";
			o.default = "";
			o.optional = true;
			o.placeholder = n + 5053;
			o = s.option(form.Value, "user", _("Run As User"));
			o.default = "";
			o.modalonly = true;
			o.optional = true;
			o = s.option(form.Value, "group", _("Run As Group"));
			o.default = "";
			o.modalonly = true;
			o.optional = true;
			o = s.option(form.Value, "dscp_codepoint", _("DSCP Codepoint"));
			o.datatype = "and(uinteger, range(0,63))";
			o.default = "";
			o.modalonly = true;
			o.optional = true;
			o = s.option(form.Value, "verbosity", _("Logging Verbosity"));
			o.datatype = "and(uinteger, range(0,4))";
			o.default = "";
			o.modalonly = true;
			o.optional = true;
			o = s.option(form.Value, "logfile", _("Logging File Path"));
			o.default = "";
			o.modalonly = true;
			o.optional = true;
			o = s.option(form.Value, "polling_interval", _("Polling Interval"));
			o.datatype = "and(uinteger, range(5,3600))";
			o.default = "";
			o.modalonly = true;
			o.optional = true;
			o = s.option(form.Value, "proxy_server", _("Proxy Server"));
			o.default = "";
			o.modalonly = true;
			o.optional = true;
			o = s.option(form.ListValue, "use_http1", _("Use HTTP/1"));
			o.default = "0";
			o.modalonly = true;
			o.optional = true;
			o.value("0", _("Use negotiated HTTP version"));
			o.value("1", _("Force use of HTTP/1"));
			o = s.option(form.ListValue, "use_ipv6_resolvers_only", _("Use IPv6 resolvers"));
			o.default = "0";
			o.modalonly = true;
			o.optional = true;
			o.value("0", _("Use any family DNS resolvers"));
			o.value("1", _("Force use of IPv6 DNS resolvers"));

			s.addModalOptions = (modalSection, section_id, ev) => {
				var provText;
				var found;
				let resolver = uci.get(pkg.Name, section_id, "resolver_url");
				if (resolver === "undefined") {
					let prov = reply.providers[0];
					modalSection.children[0].default = prov.template;
					if (prov.params && prov.params.option) {
						if (prov.params.option.type && prov.params.option.type === "select" && prov.params.option.options) {
							modalSection.children[1].default = prov.params.option.options[0].value;
						}
					}
				}
				else {
					reply.providers.forEach(prov => {
						let regexp = pkg.templateToRegexp(prov.template);
						//					console.log(prov.template, _(prov.title));
						//					__provider.value(prov.template, _(prov.title));
						if (!found && resolver && regexp.test(resolver)) {
							found = true;
							//						console.log(modalSection);
							modalSection.children[0].default = prov.template;
							if (prov.params && prov.params.option) {
								if (prov.params.option.type && prov.params.option.type === "select" && prov.params.option.options) {
									let optName = prov.params.option.description;
									optName = optName ? _(optName) : _("Parameter")
									prov.params.option.options.forEach(opt => {
										let val = opt.value || "";
										let descr = opt.description ? _(opt.description) : "";
										modalSection.children[1].value(val, descr);
										let match = resolver.match(regexp);
										if (match[1])
											modalSection.children[1].default = match[1];
									});
								}
								else if (prov.params.option.type && prov.params.option.type === "text") {
									let optName = prov.params.option.description;
									optName = optName ? _(optName) : _("Parameter")
									prov.params.option.options.forEach(opt => {
										let val = opt.value || "";
										let descr = opt.description ? _(opt.description) : "";
										modalSection.children[2].value(val, descr);
										let match = resolver.match(regexp);
										if (match[1])
											modalSection.children[2].default = match[1];
									});
								}
							}
						}
					});

				}
			};

			// o = s.option(form.ListValue, "__provider", _("Provider"));
			// o.modalonly = true;
			// p = s.option(form.ListValue, "__param", _("Parameter"));
			// p.modalonly = true;
			// p.default = "";
			// p.optional = true;
			// reply.providers.forEach(prov => {
				// if (prov.template && prov.title) {
					// o.value(prov.template, _(prov.title));
					// if (prov.params && prov.params.option) {
						// if (prov.params.option.type && prov.params.option.type === 'select' && prov.params.option.options) {
							// let prefixText = prov.params.option.description ? prov.params.option.description + ": " : "";
							// prov.params.option.options.forEach(opt=> {
								// let val = opt.value || '';
								// let descr = opt.description ? _(opt.description) : '';
								// p.value(val, prefixText + descr);
								// p.depends('__provider', prov.template);
							// });
						// }
					// }
				// }
			// });


			return Promise.all([status.render(), m.render()]);
		})
	}
});
