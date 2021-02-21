'require ui';

var callInitList = rpc.declare({
	object: 'luci.template',
	method: 'getInitList',
	params: ['name']
});

var callInitAction = rpc.declare({
	object: 'luci.template',
	method: 'setInitAction',
	params: ['name', 'action'],
	expect: { result: false }
});

E('button', {
	'id': 'btn_start',
	click: function (ev) {
		ui.showModal(null, [
			E('p', { 'class': 'spinning' }, _('Starting template service'))
		]);
		return callInitAction('template', 'start').then(function (reply) {
			ui.hideModal();
		});
	}
}, _('Start'))

E('button', {
	'id': 'btn_restart',
	click: function (ev) {
		ui.showModal(null, [
			E('p', { 'class': 'spinning' }, _('Restarting template service'))
		]);
		return callInitAction('template', 'restart').then(function (reply) {
			ui.hideModal();
		});
	}
}, _('Restart'))

E('button', {
	'id': 'btn_stop',
	click: function (ev) {
		ui.showModal(null, [
			E('p', { 'class': 'spinning' }, _('Stopping template service'))
		]);
		return callInitAction('template', 'stop').then(function (reply) {
			ui.hideModal();
		});
	}
}, _('Stop'))

E('button', {
	'id': 'btn_enable',
	click: function (ev) {
		ui.showModal(null, [
			E('p', { 'class': 'spinning' }, _('Enabling template service'))
		]);

		return callInitAction('template', 'enable').then(function (reply) {
			ui.hideModal();
		});
	}
}, _('Enable'))

E('button', {
	'id': 'btn_disable',
	click: function (ev) {
		ui.showModal(null, [
			E('p', { 'class': 'spinning' }, _('Disabling template service'))
		]);
		return callInitAction('template', 'disable').then(function (reply) {
			ui.hideModal();
		});
	}
}, _('Disable'))

callInitList('template').then(function (reply) {
	if (reply["template"].enabled === 1) {
		document.getElementById("btn_start").disabled = false
		document.getElementById("btn_restart").disabled = false
		document.getElementById("btn_stop").disabled = false
		document.getElementById("btn_enable").disabled = true
		document.getElementById("btn_start").disabled = false
	}
	else {
		document.getElementById("btn_start").disabled = true
		document.getElementById("btn_restart").disabled = true
		document.getElementById("btn_stop").disabled = true
		document.getElementById("btn_enable").disabled = false
		document.getElementById("btn_disable").disabled = true
	}
	if (reply["template"].running === 1) {
		document.getElementById("btn_start").disabled = true
		document.getElementById("btn_restart").disabled = false
		document.getElementById("btn_stop").disabled = false
	}
	else {
		document.getElementById("btn_restart").disabled = true
		document.getElementById("btn_stop").disabled = true
	}
});
