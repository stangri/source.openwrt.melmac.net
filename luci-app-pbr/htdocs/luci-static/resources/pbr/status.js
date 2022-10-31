// Copyright 2022 Stan Grishin <stangri@melmac.ca>
// This code wouldn't have been possible without help from [@vsviridov](https://github.com/vsviridov)

"require ui";
"require rpc";
"require form";
"require baseclass";

var pkg = {
	get Name() {
		return "pbr";
	},
	get URL() {
		return "https://docs.openwrt.melmac.net/" + pkg.Name + "/";
	},
};

var getGateways = rpc.declare({
	object: "luci." + pkg.Name,
	method: "getGateways",
	params: ["name"],
});

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

var getInterfaces = rpc.declare({
	object: "luci." + pkg.Name,
	method: "getInterfaces",
	params: ["name"],
});

var getPlatformSupport = rpc.declare({
	object: "luci." + pkg.Name,
	method: "getPlatformSupport",
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
	getGateways: function getGateways(name) {
		getGateways(name).then(function (result) {
			this.emit('getGateways', result);
		}.bind(this));
	},
	getPlatformSupport: function getPlatformSupport(name) {
		getPlatformSupport(name).then(function (result) {
			this.emit('getPlatformSupport', result);
		}.bind(this));
	},
	getInterfaces: function getInterfaces(name) {
		getInterfaces(name).then(function (result) {
			this.emit('getInterfaces', result);
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
			L.resolveDefault(getInitStatus(), {}),
//			L.resolveDefault(getGateways(), {}),
		]).then(function (data) {
			var replyStatus = data[0];
//			var replyGateways = data[1];
			var text;

			var header = E('h2', {}, _("Policy Based Routing - Status"))
			var statusTitle = E('label', { class: 'cbi-value-title' }, _("Service Status"));
			if (replyStatus[pkg.Name].version) {
				if (replyStatus[pkg.Name].running) {
					if (replyStatus[pkg.Name].running_iptables) {
						text = _("Running (version: %s using iptables)").format(replyStatus[pkg.Name].version);
					}
					else if (replyStatus[pkg.Name].running_nft) {
						text = _("Running (version: %s using nft)").format(replyStatus[pkg.Name].version);
					}
					else {
						text = _("Running (version: %s)").format(replyStatus[pkg.Name].version);
					}
				}
				else {
					if (replyStatus[pkg.Name].enabled) {
						text = _("Stopped (version: %s)").format(replyStatus[pkg.Name].version);
					}
					else {
						text = _("Stopped (Disabled)");
					}
				}
			}
			else {
				text = _("Not installed or not found");
			}
			var statusText = E('div', {}, text);
			var statusField = E('div', { class: 'cbi-value-field' }, statusText);
			var statusDiv = E('div', { class: 'cbi-value' }, [statusTitle, statusField]);

			var gatewaysDiv = [];
			if (replyStatus[pkg.Name].gateways) {
				var gatewaysTitle = E('label', { class: 'cbi-value-title' }, _("Service Gateways"));
				text = _("The %s indicates default gateway. See the %sREADME%s for details.").format("<strong>✓</strong>",
					"<a href=\"" + pkg.URL + "#a-word-about-default-routing \" target=\"_blank\">", "</a>")
				var gatewaysDescr = E('div', { class: 'cbi-value-description' }, text);
				var gatewaysText = E('div', {}, replyStatus[pkg.Name].gateways);
				var gatewaysField = E('div', { class: 'cbi-value-field' }, [gatewaysText, gatewaysDescr]);
				gatewaysDiv = E('div', { class: 'cbi-value' }, [gatewaysTitle, gatewaysField]);
			}

			var warningsDiv = [];
			if (replyStatus[pkg.Name].warnings) {
				var warningsTitle = E('label', { class: 'cbi-value-title' }, _("Service Warnings"));
				var warningsText = E('div', {}, replyStatus[pkg.Name].warnings);
				var warningsField = E('div', { class: 'cbi-value-field' }, warningsText);
				warningsDiv = E('div', { class: 'cbi-value' }, [warningsTitle, warningsField]);
			}

			var errorsDiv = [];
			if (replyStatus[pkg.Name].errors) {
				var errorsTitle = E('label', { class: 'cbi-value-title' }, _("Service Errors"));
				var errorsText = E('div', {}, replyStatus[pkg.Name].errors);
				var errorsField = E('div', { class: 'cbi-value-field' }, errorsText);
				errorsDiv = E('div', { class: 'cbi-value' }, [errorsTitle, errorsField]);
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

			if (replyStatus[pkg.Name].enabled) {
				btn_enable.disabled = true;
				btn_disable.disabled = false;
				if (replyStatus[pkg.Name].running) {
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
			if (replyStatus[pkg.Name].version) {
				var buttonsDiv = E('div', { class: 'cbi-value' }, [buttonsTitle, buttonsField]);
			}
			else {
				var buttonsDiv = [];
			}

			return E('div', {}, [header, statusDiv, gatewaysDiv, warningsDiv, errorsDiv, buttonsDiv]);
		});
	},
});

RPC.on('setInitAction', function (reply) {
	ui.hideModal();
	// refresh the page?
});
 
return L.Class.extend({
	status: status,
	getInterfaces: getInterfaces,
	getPlatformSupport: getPlatformSupport,
	RPC: RPC
});
