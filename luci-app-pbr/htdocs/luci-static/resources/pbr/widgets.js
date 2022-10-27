// Copyright 2022 Stan Grishin <stangri@melmac.ca>
// This code wouldn't have been possible without help from [@vsviridov](https://github.com/vsviridov)

"require rpc";
"require ui";

var pkg = {
	get Name() {
		return "pbr";
	},
	get URL() {
		return "https://docs.openwrt.melmac.net/" + pkg.Name + "/";
	},
};

var _getGateways = rpc.declare({
	object: "luci." + pkg.Name,
	method: "getGateways",
	params: ["name"],
});

var _getInitList = rpc.declare({
	object: "luci." + pkg.Name,
	method: "getInitList",
	params: ["name"],
});

var _getInitStatus = rpc.declare({
	object: "luci." + pkg.Name,
	method: "getInitStatus",
	params: ["name"],
});

var _getInterfaces = rpc.declare({
	object: "luci." + pkg.Name,
	method: "getInterfaces",
	params: ["name"],
});

var _getPlatformSupport = rpc.declare({
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
		_getInitList(name).then(function (result) {
			this.emit('getInitList', result);
		}.bind(this));
	},
	getInitStatus: function getInitStatus(name) {
		_getInitStatus(name).then(function (result) {
			this.emit('getInitStatus', result);
		}.bind(this));
	},
	getGateways: function getGateways(name) {
		_getGateways(name).then(function (result) {
			this.emit('getGateways', result);
		}.bind(this));
	},
	getPlatformSupport: function getPlatformSupport(name) {
		_getPlatformSupport(name).then(function (result) {
			this.emit('getPlatformSupport', result);
		}.bind(this));
	},
	getInterfaces: function getInterfaces(name) {
		_getInterfaces(name).then(function (result) {
			this.emit('getInterfaces', result);
		}.bind(this));
	},
	setInitAction: function setInitAction(name, action) {
		_setInitAction(name, action).then(function (result) {
			this.emit('setInitAction', result);
		}.bind(this));
	},
}

RPC.on('setInitAction', function (reply) {
	ui.hideModal();
	RPC.getInitStatus(pkg.Name);
});

return L.Class.extend({
	RPC: RPC
});
