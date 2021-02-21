'require ui';

var buttonsWidget = form.Value.extend({
	renderWidget: function (/* ... */) {
		var markup = form.Value.prototype.renderWidget.apply(this, arguments);
		markup.disabled = true;
		markup.style.outline = 'none';
		markup.style.border = 'none';
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

		E('button', {
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

		E('button', {
			'id': 'btn_reload',
			click: function (ev) {
				ui.showModal(null, [
					E('p', { 'class': 'spinning' }, _('Restarting vpnbypass service'))
				]);
				return callInitAction('vpnbypass', 'reload').then(function (reply) {
					ui.hideModal();
				});
			}
		}, _('Restart'))

		E('button', {
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

		E('button', {
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

		E('button', {
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

		callInitList('vpnbypass').then(function (reply) {
			if (reply["vpnbypass"].enabled === 1) {
				document.getElementById("btn_start").disabled = false
				document.getElementById("btn_reload").disabled = false
				document.getElementById("btn_stop").disabled = false
				document.getElementById("btn_enable").disabled = true
				document.getElementById("btn_start").disabled = false
			}
			else {
				document.getElementById("btn_start").disabled = true
				document.getElementById("btn_reload").disabled = true
				document.getElementById("btn_stop").disabled = true
				document.getElementById("btn_enable").disabled = false
				document.getElementById("btn_disable").disabled = true
			}
			if (reply["vpnbypass"].running === 1) {
				document.getElementById("btn_start").disabled = true
				document.getElementById("btn_reload").disabled = false
				document.getElementById("btn_stop").disabled = false
			}
			else {
				document.getElementById("btn_reload").disabled = true
				document.getElementById("btn_stop").disabled = true
			}
		});

		return markup;
	}
});

/* var b1 = s.option('buttons', buttonsWidget, _('Service Control'), _('Service Control Description')); */
