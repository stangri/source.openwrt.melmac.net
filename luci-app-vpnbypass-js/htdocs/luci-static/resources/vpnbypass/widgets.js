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

var callInitStatus = rpc.declare({
	object: 'luci.vpnbypass',
	method: 'getInitStatus',
	params: ['name']
});

var statusCBI = form.DummyValue.extend({
	renderWidget: function (section) {
		var status = E('span', {}, _("Quering") + "...");
		var refreshStatus = function () {
			callInitStatus('vpnbypass').then(function (reply) {
				status.innerText = _("Running");
				if (reply["vpnbypass"].running) {
					status.innerText = _("Running") + "(" + _("version: ") + reply["vpnbypass"].version + ")";
				}
				else {
					if (reply["vpnbypass"].enabled) {
						status.innerText = _("Stopped");
					}
					else {
						status.innerText = _("Stopped") + " (" + _("Disabled") + ")";
					}
				}
			});
		}
		refreshStatus();
		return E('div', {}, [status]);
	}
});

var buttonsCBI = form.DummyValue.extend({
	renderWidget: function (section) {

		var btn_separator = E('span', {}, '&nbsp;&nbsp;&nbsp;&nbsp;');

		var btn_start = E('button', {
			'class': 'btn cbi-button cbi-button-apply',
			click: function (ev) {
				ui.showModal(null, [
					E('p', { 'class': 'spinning' }, _('Starting vpnbypass service'))
				]);
				return callInitAction('vpnbypass', 'start').then(function (reply) {
					ui.hideModal();
					refreshButtons();
				});
			}
		}, _('Start'))

		var btn_action = E('button', {
			'class': 'btn cbi-button cbi-button-apply',
			click: function (ev) {
				ui.showModal(null, [
					E('p', { 'class': 'spinning' }, _('Restarting vpnbypass service'))
				]);
				return callInitAction('vpnbypass', 'reload').then(function (reply) {
					ui.hideModal();
					refreshButtons();
				});
			}
		}, _('Restart'))

		var btn_stop = E('button', {
			'class': 'btn cbi-button cbi-button-reset',
			click: function (ev) {
				ui.showModal(null, [
					E('p', { 'class': 'spinning' }, _('Stopping vpnbypass service'))
				]);
				return callInitAction('vpnbypass', 'stop').then(function (reply) {
					ui.hideModal();
					refreshButtons();
				});
			}
		}, _('Stop'))

		var btn_enable = E('button', {
			'class': 'btn cbi-button cbi-button-apply',
			click: function (ev) {
				console.log('Button Enable Click', arguments, this);
				ui.showModal(null, [
					E('p', { 'class': 'spinning' }, _('Enabling vpnbypass service'))
				]);

				return callInitAction('vpnbypass', 'enable').then(function (reply) {
					ui.hideModal();
					refreshButtons();
				});
			}
		}, _('Enable'))

		var btn_disable = E('button', {
			'class': 'btn cbi-button cbi-button-reset',
			click: function (ev) {
				ui.showModal(null, [
					E('p', { 'class': 'spinning' }, _('Disabling vpnbypass service'))
				]);
				return callInitAction('vpnbypass', 'disable').then(function (reply) {
					ui.hideModal();
					refreshButtons();
				});
			}
		}, _('Disable'))

		var refreshButtons = function () {
			callInitList('vpnbypass').then(function (reply) {
				//				console.log('callInitList', reply);
				if (reply["vpnbypass"].enabled) {
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
				if (reply["vpnbypass"].running) {
					btn_start.disabled = true;
					btn_action.disabled = false;
					btn_stop.disabled = false;
				}
				else {
					btn_action.disabled = true;
					btn_stop.disabled = true;
				}
			});
		}

		refreshButtons();

		return E('div', {}, [btn_start, btn_action, btn_stop, btn_separator, btn_enable, btn_disable]);
	}
});

return L.Class.extend({
	Status: statusCBI,
	Buttons: buttonsCBI
});
