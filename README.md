routes-apply.sh
=======================
A small bash script to safely apply route rules. It is supposed to be an equivalent to iptable's `iptables-apply` command. 

# Usage
The tool needs to be executed as root to be able to change the routes. The first argument should be a file containing line-wise arguments to `ip route`.  
For example:

```
del 10.0.0.0/8 via 192.168.2.1
add 10.10.0.0/16 via 192.168.2.1
add 10.20.0.0/16 via 192.168.200.200
add 10.50.0.0/16 via 192.168.50.50
del default via 192.168.2.1
add default via 192.168.13.37
```

Sample run with accidently deleting the default route, thus terminating the connection:
```
pi@raspberrypi ~> sudo bash /tmp/routes-apply.sh /tmp/routes.txt 
[sudo] password for pi: 
[*] Current routes are:

default via 192.168.2.1 dev eth0 proto static 
172.16.10.0/24 dev homelan proto kernel scope link src 172.16.10.3 
192.168.2.0/24 dev eth0 proto kernel scope link src 192.168.2.93 

[*] Saving current routes to /tmp/routes-apply-13Ynu2R1
[*] Applying route commands from /tmp/routes.txt

++ /usr/bin/ip route del 10.0.0.0/8 via 192.168.2.1
RTNETLINK answers: No such process
++ /usr/bin/ip route add 10.10.0.0/16 via 192.168.2.1
++ /usr/bin/ip route add 10.20.0.0/16 via 192.168.200.200
Error: Nexthop has invalid gateway.
++ /usr/bin/ip route add 10.50.0.0/16 via 192.168.50.50
Error: Nexthop has invalid gateway.
++ /usr/bin/ip route del default via 192.168.2.1
++ /usr/bin/ip route add default via 192.168.13.37
Error: Nexthop has invalid gateway.

[*] The routes are now:

10.10.0.0/16 via 192.168.2.1 dev eth0 
172.16.10.0/24 dev homelan proto kernel scope link src 172.16.10.3 
192.168.2.0/24 dev eth0 proto kernel scope link src 192.168.2.93 

[*] Packets still flowing and is the connection alive? (y/N) 
[*] Restoring routes!
[*] The routes are now:

default via 192.168.2.1 dev eth0 proto static 
172.16.10.0/24 dev homelan proto kernel scope link src 172.16.10.3 
192.168.2.0/24 dev eth0 proto kernel scope link src 192.168.2.93 
```
The script waited until the timeout and then reverted to the lastest rule set.

# License
MIT - See [LICENSE](./LICENSE)
