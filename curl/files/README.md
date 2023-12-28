# curl

## Building libcurl with HTTP/3 and QUIC support

I was only able to successfully build the libcurl with HTTP/3 and QUIC support inside the musl-based Alpine Linux VM. Instructions below are for the Alpine Linux VM, however you may also be able to create an [Alpine Linix-based docker image](https://openwrt.org/docs/guide-user/virtualization/obtain.firmware.docker) and use that.

After you Alpine Linux VM is booted and you non-root user is set up, log in to your Alpine Linux VM as the non-root user and run:

```sh
doas sed -i 's|#http://|http://|' /etc/apk/repositories
doas apk update
doas apk add argp-standalone asciidoc bash bc binutils bzip2 coreutils diffutils findutils libxslt flex g++ gawk gettext git grep gzip linux-headers musl-libintl
doas apk add musl-obstack-dev ncurses-dev openssl-dev patch perl python3-dev rsync unzip zlib-dev curl build-base wget gnupg tar perl-utils nano expat cunit autoconf
doas apk add automake libtool xz elfutils-dev util-linux cmake shadow musl-fts-dev cdrkit intltool
doas chsh "$(whoami)"
```

Swtich shell to bash by typing `/bin/bash`.

After that log out of SSH session and log back int and run the following commands:

```sh
rm -rf source.openwrt.melmac.net
git clone --depth 1 https://github.com/stangri/source.openwrt.melmac.net.git
rm -rf openwrt
git clone --depth 1 --branch v23.05.2 https://git.openwrt.org/openwrt/openwrt.git
cd openwrt
./scripts/feeds update -a
./scripts/feeds install -a
rm -rf ~/openwrt/feeds/packages/net/curl
cp -r ~/source.openwrt.melmac.net/curl ~/openwrt/feeds/packages/net/
rm -rf ~/openwrt/package/libs/openssl
cp -r ~/source.openwrt.melmac.net/quictls ~/openwrt/package/libs/openssl
rm -rf ~/openwrt/feeds/packages/libs/nghttp3
cp -r ~/source.openwrt.melmac.net/nghttp3 ~/openwrt/feeds/packages/libs/
rm -rf ~/openwrt/feeds/packages/libs/ngtcp2
cp -r ~/source.openwrt.melmac.net/ngtcp2 ~/openwrt/feeds/packages/libs/
make menuconfig
```

In menuconfig set up the `Target System` (and `Subtarget` if applicable) to build for your speicifc OpenWrt platform, then scroll down to `Libraries` press Enter, then scroll down to and highlight `libcurl` and press `Y` (or spacebar twice) to enable building `libcurl`, then press Enter to go to `libcurl` build settings and enable both `HTTP/3 protocol` and `QUIC protocol`. In the menuconfig menu below the list select `Save` and press Enter to save the build settings. Then use `Exit` as many times as it takes to leave menuconfig.

When you're back in the command line, paste:

```sh
make package/feeds/packages/curl/compile -j1
```

Depending on the size/CPU of your VM it make take quite some time (or none at all) to complete the build.

You can then find the `ipk` files you'll need to copy to your router below:

```sh
ls ~/openwrt/bin/packages/*/base/libopenssl3*.ipk
ls ~/openwrt/bin/packages/*/packages/lib{curl,ng}*.ipk
```

## Thanks

Information above has been created with the help of participants in [this issue discussion](https://github.com/openwrt/packages/issues/19382).
