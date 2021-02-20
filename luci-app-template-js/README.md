# luci-app-template-js README

```sh
mkdir luci-app-template-js/
cd luci-app-template-js/
touch Makefile
touch README.md
mkdir -p htdocs/luci-static/resources/view/services/
touch htdocs/luci-static/resources/view/services/template.js
mkdir -p root/etc/uci-defaults
touch root/etc/uci-defaults/40_luci-template
mkdir -p root/usr/libexec/rpcd
touch root/usr/libexec/rpcd/luci.template
mkdir -p root/usr/share/luci/menu.d
touch root/usr/share/luci/menu.d/template.json
mkdir -p root/usr/share/rpcd/acl.d
touch root/usr/share/rpcd/acl.d/template.json
```
