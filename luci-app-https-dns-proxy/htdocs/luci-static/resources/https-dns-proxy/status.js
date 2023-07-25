// Copyright 2023 Stan Grishin <stangri@melmac.ca>
// This code wouldn't have been possible without help from [@vsviridov](https://github.com/vsviridov)

"require ui";
"require rpc";
"require uci";
"require form";
"require baseclass";

var pkg = {
	get Name() { return 'https-dns-proxy'; },
	get URL() { return 'https://docs.openwrt.melmac.net/' + pkg.Name + '/'; }
};

var getInitList = rpc.declare({
	object: "luci." + pkg.Name,
	method: "getInitList",
	params: ["name"],
});

var getInitStatus = rpc.declare({
	object: "luci." + pkg.Name,
	method: "getInitStatus",
	params: ["name"],
});

var getPlatformSupport = rpc.declare({
	object: "luci." + pkg.Name,
	method: "getPlatformSupport",
	params: ["name"],
});

var getProviders = rpc.declare({
	object: "luci." + pkg.Name,
	method: "getProviders",
	params: ["name"],
});

var getRuntime = rpc.declare({
	object: "luci." + pkg.Name,
	method: "getRuntime",
	params: ["name"],
});

var _setInitAction = rpc.declare({
	object: "luci." + pkg.Name,
	method: "setInitAction",
	params: ["name", "action"],
	expect: { result: false },
});

var RPC = {
	listeners: [],
	on: function on(event, callback) {
		var pair = { event: event, callback: callback }
		this.listeners.push(pair);
		return function unsubscribe() {
			this.listeners = this.listeners.filter(function (listener) {
				return listener !== pair;
			});
		}.bind(this);
	},
	emit: function emit(event, data) {
		this.listeners.forEach(function (listener) {
			if (listener.event === event) {
				listener.callback(data);
			}
		});
	},
	getInitList: function getInitList(name) {
		getInitList(name).then(function (result) {
			this.emit('getInitList', result);
		}.bind(this));
	},
	getInitStatus: function getInitStatus(name) {
		getInitStatus(name).then(function (result) {
			this.emit('getInitStatus', result);
		}.bind(this));
	},
	getPlatformSupport: function getPlatformSupport(name) {
		getPlatformSupport(name).then(function (result) {
			this.emit('getPlatformSupport', result);
		}.bind(this));
	},
	getProviders: function getProviders(name) {
		getProviders(name).then(function (result) {
			this.emit('getProviders', result);
		}.bind(this));
	},
	getRuntime: function getRuntime(name) {
		getRuntime(name).then(function (result) {
			this.emit('getRuntime', result);
		}.bind(this));
	},
	setInitAction: function setInitAction(name, action) {
		_setInitAction(name, action).then(function (result) {
			this.emit('setInitAction', result);
		}.bind(this));
	},
}

var status = baseclass.extend({
	render: function () {
		return Promise.all([
			L.resolveDefault(getInitStatus(pkg.Name), {}),
			L.resolveDefault(getProviders(pkg.Name), {}),
			L.resolveDefault(getRuntime(pkg.Name), {}),
		]).then(function (data) {
			var text;

			var reply = {
				status: data[0] && data[0][pkg.Name] || {
					enabled: null,
					running: null,
					force_dns_active: null,
					version: null,
				},
				providers: data[1] && data[1][pkg.Name] || { providers: [] },
				runtime: data[2] && data[2][pkg.Name] || { instances: [] },
			}

			var header = E('h2', {}, _("HTTPS DNS Proxy - Status"));
			var statusTitle = E('label', { class: 'cbi-value-title' }, _("Service Status"));
			if (reply.status.version) {
				if (reply.status.running) {
					text = _("Version %s - Running.").format(reply.status.version);
					if (reply.status.force_dns_active) {
						text += "<br />" + _("Force DNS ports:");
						reply.status.force_dns_ports.forEach(element => {
							text += " " + element;
						});
						text += ".";
					}
				}
				else {
					if (reply.status.enabled) {
						text = _("Version %s - Stopped.").format(reply.status.version);
					}
					else {
						text = _("Version %s - Stopped (Disabled).").format(reply.status.version);
					}
				}
			}
			else {
				text = _("Not installed or not found");
			}
			var statusText = E('div', {}, text);
			var statusField = E('div', { class: 'cbi-value-field' }, statusText);
			var statusDiv = E('div', { class: 'cbi-value' }, [statusTitle, statusField]);

			var instancesDiv = [];
			if (reply.runtime.instances) {
				var instancesTitle = E('label', { class: 'cbi-value-title' }, _("Service Instances"));
				text = _("See the %sREADME%s for details.").format(
					"<a href=\"" + pkg.URL + "#a-word-about-default-routing \" target=\"_blank\">", "</a>")
				var instancesDescr = E('div', { class: 'cbi-value-description' }, "");

				text=""
				Object.values(reply.runtime.instances).forEach(element => {
					var rFlag
					var aFlag
					var pFlag
					var r
					var a
					var p
					var name
					var option
					element.command.forEach(param => {
						if (rFlag) {
							r = param
							rFlag = null
						}
						if (aFlag) {
							a = param
							aFlag = null
						}
						if (pFlag) {
							p = param
							pFlag = null
						}
						if (param === "-r") rFlag = true;
						if (param === "-a") aFlag = true;
						if (param === "-p") pFlag = true;
					});

					function templateToRegexp(template) {
						return RegExp('^' + template.split(/(\{\w+\})/g).map(part => {
							let placeholder = part.match(/^\{(\w+)\}$/);
							if (placeholder)
								return `(?<${placeholder[1]}>.*?)`;
							else
								return part.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
						}).join('') + '$');
					}

					reply.providers.forEach(prov => {
						let regexp = templateToRegexp(prov.template);
						if (regexp.test(r)) {
							name = _(prov.title);
							let match = r.match(regexp);
							if (match[1]) {
								if (prov.params.option.options) {
									prov.params.option.options.forEach(opt => {
										if (opt.value === match[1]){
											option = _(opt.description);
										}
									})
									name += " (" + option + ")" 
								}
								else {
									name += " (" + match[1] + ")" 
								}
							}
						}
					});

					if ( a === "127.0.0.1" ) {
						text += _("%s%s%s proxy on port %s.%s").format("<strong>", name, "</strong>", p, "<br />");
					}
					else {
						text += _("%s%s%s proxy at %s on port %s.%s").format("<strong>", name, "</strong>", a, p, "<br />");
					}
				});

				var instancesText = E('div', {}, text);
				var instancesField = E('div', { class: 'cbi-value-field' }, [instancesText, instancesDescr]);
				instancesDiv = E('div', { class: 'cbi-value' }, [instancesTitle, instancesField]);
			}

			var btn_gap = E('span', {}, '&#160;&#160;');
			var btn_gap_long = E('span', {}, '&#160;&#160;&#160;&#160;&#160;&#160;&#160;&#160;');
			var btn_start = E('button', {
				'class': 'btn cbi-button cbi-button-apply',
				disabled: true,
				click: function (ev) {
					ui.showModal(null, [
						E('p', { 'class': 'spinning' }, _('Starting %s service').format(pkg.Name))
					]);
					return RPC.setInitAction(pkg.Name, 'start');
				}
			}, _('Start'));

			var btn_action = E('button', {
				'class': 'btn cbi-button cbi-button-apply',
				disabled: true,
				click: function (ev) {
					ui.showModal(null, [
						E('p', { 'class': 'spinning' }, _('Restarting %s service').format(pkg.Name))
					]);
					return RPC.setInitAction(pkg.Name, 'restart');
				}
			}, _('Restart'));

			var btn_stop = E('button', {
				'class': 'btn cbi-button cbi-button-reset',
				disabled: true,
				click: function (ev) {
					ui.showModal(null, [
						E('p', { 'class': 'spinning' }, _('Stopping %s service').format(pkg.Name))
					]);
					return RPC.setInitAction(pkg.Name, 'stop');
				}
			}, _('Stop'));

			var btn_enable = E('button', {
				'class': 'btn cbi-button cbi-button-apply',
				disabled: true,
				click: function (ev) {
					ui.showModal(null, [
						E('p', { 'class': 'spinning' }, _('Enabling %s service').format(pkg.Name))
					]);
					return RPC.setInitAction(pkg.Name, 'enable');
				}
			}, _('Enable'));

			var btn_disable = E('button', {
				'class': 'btn cbi-button cbi-button-reset',
				disabled: true,
				click: function (ev) {
					ui.showModal(null, [
						E('p', { 'class': 'spinning' }, _('Disabling %s service').format(pkg.Name))
					]);
					return RPC.setInitAction(pkg.Name, 'disable');
				}
			}, _('Disable'));

			if (reply.status.enabled) {
				btn_enable.disabled = true;
				btn_disable.disabled = false;
				if (reply.status.running) {
					btn_start.disabled = true;
					btn_action.disabled = false;
					btn_stop.disabled = false;
				}
				else {
					btn_start.disabled = false;
					btn_action.disabled = true;
					btn_stop.disabled = true;
				}
			}
			else {
				btn_start.disabled = true;
				btn_action.disabled = true;
				btn_stop.disabled = true;
				btn_enable.disabled = false;
				btn_disable.disabled = true;
			}

			var buttonsTitle = E('label', { class: 'cbi-value-title' }, _("Service Control"))
			var buttonsText = E('div', {}, [btn_start, btn_gap, btn_action, btn_gap, btn_stop, btn_gap_long, btn_enable, btn_gap, btn_disable]);
			var buttonsField = E('div', { class: 'cbi-value-field' }, buttonsText);
			if (reply.status.version) {
				var buttonsDiv = E('div', { class: 'cbi-value' }, [buttonsTitle, buttonsField]);
			}
			else {
				var buttonsDiv = [];
			}

			return E('div', {}, [header, statusDiv, instancesDiv, buttonsDiv]);
		});
	},
});

RPC.on('setInitAction', function (reply) {
	ui.hideModal();
	location.reload();
});

return L.Class.extend({
	status: status,
	getPlatformSupport: getPlatformSupport,
	getProviders: getProviders,
	getRuntime: getRuntime,
});
