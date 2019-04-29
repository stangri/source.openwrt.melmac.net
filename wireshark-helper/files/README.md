# Wireshark Helper

## Description

This service can be used to configure router to sniff packets to/from monitored device on the device running Wireshark app.

Pick an IP address of the monitored device, an IP address of the deivce running Wireshark app and start the service (from Web UI or manually).

In the Wireshark app, set the filter to monitored IP, for example if the IP of the device you want to sniff packets to/from is 192.168.1.121, then set the Wireshark filter to ```(ip.src == 192.168.9.121) || (ip.dst == 192.168.9.121)```.

## Thanks

Credit for ```iptables``` rules and instructions goes to [Ayoma Gayan Wijethunga](https://www.ayomaonline.com/security/analyzing-network-traffic-with-openwrt/).
