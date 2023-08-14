// Copyright 2022 Stan Grishin <stangri@melmac.ca>
// This code wouldn't have been possible without help from [@vsviridov](https://github.com/vsviridov)

"use strict";
"require form";
"require uci";
"require view";
"require adblock-fast.status as adb";

var pkg = {
  get Name() {
    return "adblock-fast";
  },
  get URL() {
    return "https://docs.openwrt.melmac.net/" + pkg.Name + "/";
  },
  // https://stackoverflow.com/a/14919494
  humanFileSize: function (bytes, si = false, dp = 1) {
    const thresh = si ? 1000 : 1024;

    if (Math.abs(bytes) < thresh) {
      return bytes + " B";
    }

    const units = si
      ? ["kB", "MB", "GB", "TB", "PB", "EB", "ZB", "YB"]
      : ["KiB", "MiB", "GiB", "TiB", "PiB", "EiB", "ZiB", "YiB"];
    let u = -1;
    const r = 10 ** dp;

    do {
      bytes /= thresh;
      ++u;
    } while (
      Math.round(Math.abs(bytes) * r) / r >= thresh &&
      u < units.length - 1
    );

    return bytes.toFixed(dp) + " " + units[u];
  },
};

return view.extend({
  load: function () {
    return Promise.all([uci.load(pkg.Name)]);
  },

  render: function () {
    return Promise.all([
      L.resolveDefault(adb.getFileSizes(pkg.Name), {}),
      L.resolveDefault(adb.getPlatformSupport(pkg.Name), {}),
    ]).then(function (data) {
      var reply = {
        sizes:
          (data[0] && data[0][pkg.Name] && data[0][pkg.Name]["sizes"]) || [],
        platform: (data[1] && data[1][pkg.Name]) || {
          ipset_installed: false,
          nft_installed: false,
          dnsmasq_installed: fasle,
          unbound_installed: false,
          dnsmasq_ipset_support: false,
          dnsmasq_nftset_support: false,
          leds: [],
        },
      };
      var status, m, s, o;

      status = new adb.status();
      m = new form.Map(pkg.Name, _("AdBlock-Fast: Configuration"));
      s = m.section(form.NamedSection, "config", pkg.Name);
      s.tab("tab_basic", _("Basic Configuration"));
      s.tab("tab_advanced", _("Advanced Configuration"));

      o = s.taboption(
        "tab_basic",
        form.ListValue,
        "config_update_enabled",
        _("Automatic Config Update"),
        _("Perform config update before downloading the block/allow-lists.")
      );
      o.value("0", _("Disable"));
      o.value("1", _("Enable"));
      o.default = ("0", _("Disable"));

      o = s.taboption(
        "tab_basic",
        form.ListValue,
        "verbosity",
        _("Output Verbosity Setting"),
        _("Controls system log and console output verbosity.")
      );
      o.value("0", _("Suppress output"));
      o.value("1", _("Some output"));
      o.value("2", _("Verbose output"));
      o.default = ("2", _("Verbose output"));

      o = s.taboption(
        "tab_basic",
        form.ListValue,
        "force_dns",
        _("Force Router DNS"),
        _(
          "Forces Router DNS use on local devices, also known as DNS Hijacking."
        )
      );
      o.value("0", _("Let local devices use their own DNS servers if set"));
      o.value("1", _("Force Router DNS server to all local devices"));
      o.default = ("1", _("Force Router DNS server to all local devices"));

      if (reply.platform.leds.length) {
        o = s.taboption(
          "tab_basic",
          form.ListValue,
          "led",
          _("LED to indicate status"),
          _(
            "Pick the LED not already used in %sSystem LED Configuration%s."
          ).format(
            '<a href="' + L.url("admin", "system", "leds") + '">',
            "</a>"
          )
        );
        o.value("", _("none"));
        reply.platform.leds.forEach((element) => {
          o.value(element);
        });
      }
      var text = _(
        "DNS resolution option, see the %sREADME%s for details."
      ).format(
        '<a href="' + pkg.URL + '#dns-resolution-option" target="_blank">',
        "</a>"
      );
      if (!reply.platform.dnsmasq_installed) {
        text +=
          "<br />" +
          _("Please note that %s is not supported on this system.").format(
            "<i>dnsmasq.addnhosts</i>"
          );
        text +=
          "<br />" +
          _("Please note that %s is not supported on this system.").format(
            "<i>dnsmasq.conf</i>"
          );
        text +=
          "<br />" +
          _("Please note that %s is not supported on this system.").format(
            "<i>dnsmasq.ipset</i>"
          );
        text +=
          "<br />" +
          _("Please note that %s is not supported on this system.").format(
            "<i>dnsmasq.servers</i>"
          );
      } else {
        if (!reply.platform.dnsmasq_ipset_support) {
          text +=
            "<br />" +
            _("Please note that %s is not supported on this system.").format(
              "<i>dnsmasq.ipset</i>"
            );
        }
        if (!reply.platform.dnsmasq_nftset_support) {
          text +=
            "<br />" +
            _("Please note that %s is not supported on this system.").format(
              "<i>dnsmasq.nftset</i>"
            );
        }
      }
      if (!reply.platform.unbound_installed) {
        text =
          text +
          "<br />" +
          _("Please note that %s is not supported on this system.").format(
            "<i>unbound.adb_list</i>"
          );
      }

      o = s.taboption(
        "tab_advanced",
        form.ListValue,
        "dns",
        _("DNS Service"),
        text
      );
      if (reply.platform.dnsmasq_installed) {
        o.value("dnsmasq.addnhosts", _("dnsmasq additional hosts"));
        o.value("dnsmasq.conf", _("dnsmasq config"));
        if (reply.platform.dnsmasq_ipset_support) {
          o.value("dnsmasq.ipset", _("dnsmasq ipset"));
        }
        if (reply.platform.dnsmasq_nftset_support) {
          o.value("dnsmasq.nftset", _("dnsmasq nft set"));
        }
        o.value("dnsmasq.servers", _("dnsmasq servers file"));
      }
      if (reply.platform.unbound_installed) {
        o.value("unbound.adb_list", _("unbound adblock list"));
      }
      o.default = ("dnsmasq.servers", _("dnsmasq servers file"));

      o = s.taboption(
        "tab_advanced",
        form.ListValue,
        "ipv6_enabled",
        _("IPv6 Support"),
        _("Add IPv6 entries to block-list.")
      );
      o.value("", _("Do not add IPv6 entries"));
      o.value("1", _("Add IPv6 entries"));
      o.depends("dns", "dnsmasq.addnhosts");
      o.depends("dns", "dnsmasq.nftset");
      o.default = ("", _("Do not add IPv6 entries"));
      o.rmempty = true;

      o = s.taboption(
        "tab_advanced",
        form.Value,
        "download_timeout",
        _("Download time-out (in seconds)"),
        _("Stop the download if it is stalled for set number of seconds.")
      );
      o.default = "20";
      o.datatype = "range(1,60)";

      o = s.taboption(
        "tab_advanced",
        form.Value,
        "curl_max_file_size",
        _("Curl maximum file size (in bytes)"),
        _(
          "If curl is installed and detected, it would not download files bigger than this."
        )
      );
      o.default = "";
      o.datatype = "uinteger";
      o.rmempty = true;

      o = s.taboption(
        "tab_advanced",
        form.Value,
        "curl_retry",
        _("Curl download retry"),
        _(
          "If curl is installed and detected, it would retry download this many times on timeout/fail."
        )
      );
      o.default = "3";
      o.datatype = "range(0,30)";

      o = s.taboption(
        "tab_advanced",
        form.ListValue,
        "parallel_downloads",
        _("Simultaneous processing"),
        _(
          "Launch all lists downloads and processing simultaneously, reducing service start time."
        )
      );
      o.value("0", _("Do not use simultaneous processing"));
      o.value("1", _("Use simultaneous processing"));
      o.default = ("1", _("Use simultaneous processing"));

      o = s.taboption(
        "tab_advanced",
        form.ListValue,
        "compressed_cache",
        _("Store compressed cache file on router"),
        _(
          "Attempt to create a compressed cache of block-list in the persistent memory."
        )
      );
      o.value("0", _("Do not store compressed cache"));
      o.value("1", _("Store compressed cache"));
      o.default = ("0", _("Do not store compressed cache"));

      o = s.taboption(
        "tab_advanced",
        form.Value,
        "compressed_cache_dir",
        _("Directory for compressed cache file"),
        _(
          "Directory for compressed cache file of block-list in the persistent memory."
        )
      );
      o.datatype = "string";
      o.rmempty = true;
      o.default = "/etc";
      o.depends("compressed_cache", "1");

      o = s.taboption(
        "tab_advanced",
        form.ListValue,
        "debug",
        _("Enable Debugging"),
        _("Enables debug output to /tmp/adblock-fast.log.")
      );
      o.value("0", _("Disable Debugging"));
      o.value("1", _("Enable Debugging"));
      o.default = ("0", _("Disable Debugging"));

      s = m.section(
        form.NamedSection,
        "config",
        "adblock-fast",
        _("AdBlock-Fast: Allowed and Blocked Lists Management")
      );
      o = s.option(
        form.Value,
        "dnsmasq_config_file_url",
        _("Dnsmasq Config File URL"),
        _(
          "URL to the external dnsmasq config file, see the %sREADME%s for details."
        ).format(
          '<a href="' + pkg.URL + '#dnsmasq_config_file_url" target="_blank">',
          "</a>"
        )
      );
      o.addremove = true;
      o.rmempty = true;
      o = s.option(
        form.DynamicList,
        "allowed_domain",
        _("Allowed Domains"),
        _("Individual domains to be allowed.")
      );
      o.depends("dnsmasq_config_file_url", "");
      o.addremove = true;
      o = s.option(
        form.DynamicList,
        "blocked_domain",
        _("Blocked Domains"),
        _("Individual domains to be blocked.")
      );
      o.depends("dnsmasq_config_file_url", "");
      o.addremove = true;

      s = m.section(
        form.GridSection,
        "allowed_file",
        _("Allowed Lists File URLs"),
        _("URLs to file(s) containing lists to be allowed.")
      );
      s.sectiontitle = function (section_id) {
        let url = uci.get(pkg.Name, section_id, "url");
        let ret = _("Unknown");
        reply.sizes.forEach((element) => {
          if (element.url === url) {
            ret = (element.size === 0) ? ret : pkg.humanFileSize(element.size);
          }
        });
        return _("Size: %s").format(ret);
      };
      s.rowcolors = true;
      s.sortable = true;
      s.anonymous = true;
      s.addremove = true;
      o = s.option(form.Flag, "enabled");
      o.default = "1";
      o.editable = true;
      o = s.option(form.Value, "url");
      o.editable = true;
      s = m.section(
        form.GridSection,
        "blocked_file",
        _("Blocked Lists File URLs"),
        _("URLs to file(s) containing lists to be blocked.")
      );
      s.sectiontitle = function (section_id) {
        let url = uci.get(pkg.Name, section_id, "url");
        let ret = _("Unknown");
        reply.sizes.forEach((element) => {
          if (element.url === url) {
            ret = (element.size === 0) ? ret : pkg.humanFileSize(element.size);
          }
        });
        return _("Size: %s").format(ret);
      };
      s.rowcolors = true;
      s.sortable = true;
      s.anonymous = true;
      s.addremove = true;
      o = s.option(form.Flag, "enabled");
      o.default = "1";
      o.editable = true;
      o = s.option(form.Value, "url");
      o.editable = true;

			return Promise.all([status.render(), m.render()]);
    });
  },
});
