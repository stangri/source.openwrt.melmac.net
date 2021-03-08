'use strict';
'require ui';
'require view';
'require uci';
'require rpc';
'require form';
'require vpnbypass.widgets as widgets';

return view.extend({

	load: function () {
		return Promise.all([
			uci.load('vpnbypass'),
			uci.load('dhcp')
		]);
	},

	render: function (data) {

		var m, d, s, o;

		m = new form.Map('vpnbypass', _('VPN Bypass'));

		s = m.section(form.NamedSection, 'config', 'vpnbypass');

		o = s.option(widgets.Status, '', _('Service Status'));

		o = s.option(widgets.Buttons, '', _('Service Control'));

		o = s.option(form.DynamicList, 'localport', _('Local Ports to Bypass'), _('Local ports to trigger VPN Bypass'));
		o.datatype = 'portrange';
		o.addremove = false;
		o.optional = false;

		o = s.option(form.DynamicList, 'remoteport', _('Remote Ports to Bypass'), _('Remote ports to trigger VPN Bypass'));
		o.datatype = 'portrange';
		o.addremove = false;
		o.optional = false;

		o = s.option(form.DynamicList, 'localsubnet', _('Local IP Addresses to Bypass'), _('Local IP addresses or subnets with direct internet access (outside of the VPN tunnel)'));
		o.datatype = 'ip4addr';
		o.addremove = false;
		o.optional = false;

		o = s.option(form.DynamicList, 'remotesubnet', _('Remote IP Addresses to Bypass'), _('Remote IP addresses or subnets which will be accessed directly (outside of the VPN tunnel)'));
		o.datatype = 'ip4addr';
		o.addremove = false;
		o.optional = false;

		d = new form.Map('dhcp');
		s = d.section(form.TypedSection, 'dnsmasq');
		s.anonymous = true;
		o = s.option(form.DynamicList, 'ipset', _('Domains to Bypass'), _('Domains to be accessed directly (outside of the VPN tunnel)'));

		return Promise.all([m.render(), d.render()]);
	}
});
