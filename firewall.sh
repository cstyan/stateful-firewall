#!/bin/bash

#flush existing rules
iptables -F

#default rules
iptables -P INPUT DROP
iptables -P OUTPUT DROP
iptables -P FORWARD DROP

#config
TCPPORTS=(53 80 443)
UDPPORTS=(67 68)
ICMPSERVICES=()

#iptables
for i in ${TCPPORTS[@]}
do
	#inbound forwarded tcp packets on DNS, HTTP, HTTPS
	iptables -A FORWARD -i em1 -o p3p1 --sport $i -p tcp -j ACCEPT  
	#outbound forwarded tcp packets
	iptables -A FORWARD -o em1 -i p3p1 --dport $i -p tcp -j ACCEPT  
done