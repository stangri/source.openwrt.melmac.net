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

for i in https-dns-proxy simple-adblock vpn-policy-routing vpnbypass; do
mkdir -p "luci-app-${i}-js"/htdocs/luci-static/resources/view/services/"${i}"
mkdir -p "luci-app-${i}-js"/root/etc/uci-defaults
mkdir -p "luci-app-${i}-js"/root/usr/libexec/rpcd
mkdir -p "luci-app-${i}-js"/root/usr/share/luci/menu.d
mkdir -p "luci-app-${i}-js"/root/usr/share/rpcd/acl.d
sed "s/+luci-compat //g" "luci-app-${i}"/Makefile > "luci-app-${i}-js"/Makefile
cp "luci-app-${i}"/README.md "luci-app-${i}-js"/
sed "s/template/${i}/g" "luci-app-template-js"/htdocs/luci-static/resources/view/services/template.js > "luci-app-${i}-js"/htdocs/luci-static/resources/view/services/${i}.js
cp "luci-app-template-js"/root/etc/uci-defaults/40_luci-template "luci-app-${i}-js"/root/etc/uci-defaults/40_luci-"${i}"
sed "s/template/${i}/g" "luci-app-template-js"/root/usr/libexec/rpcd/luci.template > "luci-app-${i}-js"/root/usr/libexec/rpcd/luci.${i}
rm -f "luci-app-${i}-js"/root/usr/libexec/rpcd/luci.template
chmod +x "luci-app-${i}-js"/root/usr/libexec/rpcd/luci.${i}
sed "s/template/${i}/g" "luci-app-template-js"/root/usr/share/luci/menu.d/template.json > "luci-app-${i}-js"/root/usr/share/luci/menu.d/${i}.json
sed "s/template/${i}/g" "luci-app-template-js"/root/usr/share/rpcd/acl.d/template.json > "luci-app-${i}-js"/root/usr/share/rpcd/acl.d/${i}.json
done


for i in https-dns-proxy simple-adblock vpn-policy-routing vpnbypass; do
done

```

## FAQ

<https://github.com/openwrt/luci/issues/4813>
