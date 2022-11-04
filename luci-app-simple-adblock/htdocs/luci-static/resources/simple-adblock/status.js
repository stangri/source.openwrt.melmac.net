// Copyright 2022 Stan Grishin <stangri@melmac.ca>
// This code wouldn't have been possible without help from [@vsviridov](https://github.com/vsviridov)

"require ui";
"require rpc";
"require form";
"require baseclass";

var pkg = {
	get Name() { return 'simple-adblock'; },
	get URL() { return 'https://docs.openwrt.melmac.net/' + pkg.Name + '/'; },
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
			var text ="";
			var arrPorts = replyStatus[pkg.Name].force_dns_ports;
			var outputFile = replyStatus[pkg.Name].outputFile;
			var outputCache = replyStatus[pkg.Name].outputCache;
			var outputGzip = replyStatus[pkg.Name].outputGzip;
			var statusTable = [];
			statusTable["statusNoInstall"] = _("%s is not installed or not found").format(pkg.Name);;
			statusTable["statusStopped"] = _("Stopped");
			statusTable["statusStarting"] = _("Starting");
			statusTable["statusRestarting"] = _("Restarting");
			statusTable["statusForceReloading"] = _("Force Reloading");
			statusTable["statusDownloading"] = _("Downloading");
			statusTable["statusError"] = _("Error");
			statusTable["statusWarning"] = _("Warning");
			statusTable["statusFail"] = _("Fail");
			statusTable["statusSuccess"] = _("Active");

			var header = E('h2', {}, _("Simple AdBlock - Status"))
			var statusTitle = E('label', { class: 'cbi-value-title' }, _("Service Status"));
			if (replyStatus[pkg.Name].version) {
				text += _("Version: %s").format(replyStatus[pkg.Name].version) + " - ";
				switch (replyStatus[pkg.Name].status) {
					case 'statusSuccess':
						text += statusTable[replyStatus[pkg.Name].status] + ".";
						text += "<br />" + _("Blocking %s domains (with %s).").format(replyStatus[pkg.Name].entries, replyStatus[pkg.Name].dns);
						if (replyStatus[pkg.Name].outputGzipExists) {
							text += "<br />" + _("Compressed cache file created.");
						}
						if (replyStatus[pkg.Name].force_dns_active) {
							text += "<br />" + _("Force DNS ports:");
							arrPorts.forEach(element => {
								text += " " + element;
							});
							text += ".";
						}
						break;
					case 'statusStopped':
						if (replyStatus[pkg.Name].enabled) {
							text += statusTable[replyStatus[pkg.Name].status] + ".";
						}
						else {
							text += statusTable[replyStatus[pkg.Name].status] + _("disabled") + "."
						}
						if (replyStatus[pkg.Name].outputCacheExists) {
							text += "<br />" + _("Cache file found.");
						}
						else if (replyStatus[pkg.Name].outputGzipExists) {
							text += "<br />" + _("Compressed cache file found.");
						}
						break;
					case 'statusRestarting':
					case 'statusForceReloading':
					case 'statusDownloading':
						text += statusTable[replyStatus[pkg.Name].status] + "...";
						break;
					default:
						text += statusTable[replyStatus[pkg.Name].status] + ".";
						break;
				}
			}
			else {
				text = _("Not installed or not found");
			}
			var statusText = E('div', {}, text);
			var statusField = E('div', { class: 'cbi-value-field' }, statusText);
			var statusDiv = E('div', { class: 'cbi-value' }, [statusTitle, statusField]);

			var warningsDiv = [];
			if (replyStatus[pkg.Name].warnings) {
				var warningsTitle = E('label', { class: 'cbi-value-title' }, _("Service Warnings"));
				var warningsText = E('div', {}, replyStatus[pkg.Name].warnings);
				var warningsField = E('div', { class: 'cbi-value-field' }, warningsText);
				warningsDiv = E('div', { class: 'cbi-value' }, [warningsTitle, warningsField]);
			}

			var errorsDiv = [];
			if ((replyStatus[pkg.Name].errors).length) {
				var errorTable = [];
				errorTable["errorOutputFileCreate"] = _("failed to create '%s' file").format(outputFile);
				errorTable["errorFailDNSReload"] = _("failed to restart/reload DNS resolver");
				errorTable["errorSharedMemory"] = _("failed to access shared memory");
				errorTable["errorSorting"] = _("failed to sort data file");
				errorTable["errorOptimization"] = _("failed to optimize data file");
				errorTable["errorAllowListProcessing"] = _("failed to process allow-list");
				errorTable["errorDataFileFormatting"] = _("failed to format data file");
				errorTable["errorMovingDataFile"] = _("failed to move temporary data file to '%s'").format(outputFile);
				errorTable["errorCreatingCompressedCache"] = _("failed to create compressed cache");
				errorTable["errorRemovingTempFiles"] = _("failed to remove temporary files");
				errorTable["errorRestoreCompressedCache"] = _("failed to unpack compressed cache");
				errorTable["errorRestoreCache"] = _("failed to move '%s' to '%s'").format(outputCache, outputFile);
				errorTable["errorOhSnap"] = _("failed to create block-list or restart DNS resolver");
				errorTable["errorStopping"] = _("failed to stop %s").format(pkg.Name);
				errorTable["errorDNSReload"] = _("failed to reload/restart DNS resolver");
				errorTable["errorDownloadingConfigUpdate"] = _("failed to download Config Update file");
				errorTable["errorDownloadingList"] = _("failed to download");
				errorTable["errorParsingConfigUpdate"] = _("failed to parse Config Update file");
				errorTable["errorParsingList"] = _("failed to parse");
				errorTable["errorNoSSLSupport"] = _("no HTTPS/SSL support on device");
				errorTable["errorCreatingDirectory"] = _("failed to create output/cache/gzip file directory");
				var errorsTitle = E('label', { class: 'cbi-value-title' }, _("Service Errors"));
				var text = "";
				(replyStatus[pkg.Name].errors).forEach(element => {
					text += errorTable[element] + ".<br />";
				});
				var errorsText = E('div', {}, text);
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
						E('p', { 'class': 'spinning' }, _('Force re-downloading %s block lists').format(pkg.Name))
					]);
					return RPC.setInitAction(pkg.Name, 'dl');
				}
			}, _('Force Re-Download'));

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
				switch (replyStatus[pkg.Name].status) {
					case 'statusSuccess':
						btn_start.disabled = true;
						btn_action.disabled = false;
						btn_stop.disabled = false;
						break;
					case 'statusStopped':
						btn_start.disabled = false;
						btn_action.disabled = true;
						btn_stop.disabled = true;
						break;
					default:
						btn_start.disabled = true;
						btn_action.disabled = true;
						btn_stop.disabled = true;
						btn_enable.disabled = true;
						btn_disable.disabled = true;
					break;
				}
			}
			else {
				btn_start.disabled = true;
				btn_action.disabled = true;
				btn_stop.disabled = true;
				btn_enable.disabled = false;
				btn_disable.disabled = true;
			}

			var buttonsDiv = [];
			var buttonsTitle = E('label', { class: 'cbi-value-title' }, _("Service Control"))
			var buttonsText = E('div', {}, [btn_start, btn_gap, btn_action, btn_gap, btn_stop, btn_gap_long, btn_enable, btn_gap, btn_disable]);
			var buttonsField = E('div', { class: 'cbi-value-field' }, buttonsText);
			if (replyStatus[pkg.Name].version) {
				buttonsDiv = E('div', { class: 'cbi-value' }, [buttonsTitle, buttonsField]);
			}

			return E('div', {}, [header, statusDiv, warningsDiv, errorsDiv, buttonsDiv]);
		});
	},
});

RPC.on('setInitAction', function (reply) {
	ui.hideModal();
	location.reload();
});

return L.Class.extend({
	status: status,
	getPlatformSupport: getPlatformSupport
});
