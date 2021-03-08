'require ui';
'require rpc';
'require form';

var callInitList = rpc.declare({
	object: 'luci.vpnbypass',
	method: 'getInitList',
	params: ['name']
});

var callInitAction = rpc.declare({
	object: 'luci.vpnbypass',
	method: 'setInitAction',
	params: ['name', 'action'],
	expect: { result: false }
});

var buttonsWidget = form.Value.extend({
	renderWidget: function (/* ... */) {
		var markup = form.Value.prototype.renderWidget.apply(this, arguments);
		markup.disabled = true;
		markup.style.outline = 'none';
		markup.style.border = 'none';

		var btn_start = E('button', {
			'id': 'btn_start',
			click: function (ev) {
				ui.showModal(null, [
					E('p', { 'class': 'spinning' }, _('Starting vpnbypass service'))
				]);
				return callInitAction('vpnbypass', 'start').then(function (reply) {
					ui.hideModal();
				});
			}
		}, _('Start'))

		var btn_action = E('button', {
			'id': 'btn_action',
			click: function (ev) {
				ui.showModal(null, [
					E('p', { 'class': 'spinning' }, _('Restarting vpnbypass service'))
				]);
				return callInitAction('vpnbypass', 'reload').then(function (reply) {
					ui.hideModal();
				});
			}
		}, _('Restart'))

		var btn_stop = E('button', {
			'id': 'btn_stop',
			click: function (ev) {
				ui.showModal(null, [
					E('p', { 'class': 'spinning' }, _('Stopping vpnbypass service'))
				]);
				return callInitAction('vpnbypass', 'stop').then(function (reply) {
					ui.hideModal();
				});
			}
		}, _('Stop'))

		var btn_enable = E('button', {
			'id': 'btn_enable',
			click: function (ev) {
				ui.showModal(null, [
					E('p', { 'class': 'spinning' }, _('Enabling vpnbypass service'))
				]);

				return callInitAction('vpnbypass', 'enable').then(function (reply) {
					ui.hideModal();
				});
			}
		}, _('Enable'))

		var btn_disable = E('button', {
			'id': 'btn_disable',
			click: function (ev) {
				ui.showModal(null, [
					E('p', { 'class': 'spinning' }, _('Disabling vpnbypass service'))
				]);
				return callInitAction('vpnbypass', 'disable').then(function (reply) {
					ui.hideModal();
				});
			}
		}, _('Disable'))

		markup.append(btn_start);
		markup.append(btn_action);
		markup.append(btn_stop);
		markup.append(btn_enable);
		markup.append(btn_disable);

		callInitList('vpnbypass').then(function (reply) {
			if (reply["vpnbypass"].enabled === 1) {
				btn_start.disabled = false;
				btn_action.disabled = false;
				btn_stop.disabled = false;
				btn_enable.disabled = true;
				btn_disable.disabled = false;
			}
			else {
				btn_start.disabled = true;
				btn_action.disabled = true;
				btn_stop.disabled = true;
				btn_enable.disabled = false;
				btn_disable.disabled = true;
			}
			if (reply["vpnbypass"].running === 1) {
				btn_start.disabled = true;
				btn_action.disabled = false;
				btn_stop.disabled = false;
			}
			else {
				btn_action.disabled = true;
				btn_stop.disabled = true;
			}
		});

		return markup;
	}
});
