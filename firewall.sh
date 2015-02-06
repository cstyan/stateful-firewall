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
	iptables -A FORWARD -i em1 -o p3p1 -p tcp --sport $i -j ACCEPT  
	#outbound forwarded tcp packets
	iptables -A FORWARD -o em1 -i p3p1 -p tcp --dport $i -j ACCEPT  
done

for i in ${UDPPORTS[@]}
do
	#inbound udp on DHCP
	iptables -A FORWARD -i em1 -o p3p1 -p udp --sport 53 -j ACCEPT  
	#outbound udp on DHCP
	iptables -A FORWARD -o em1 -i p3p1  -p udp --dport 53 -j ACCEPT  
done