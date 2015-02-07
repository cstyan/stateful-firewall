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
ICMPSERVICES=(0 8)

#iptables
#########

#tcp
for i in ${TCPPORTS[@]}
do
	#inbound forwarded tcp packets on DNS, HTTP, HTTPS
	iptables -A FORWARD -i em1 -o p3p1 -p tcp --sport $i -j ACCEPT  
	#outbound forwarded tcp packets
	iptables -A FORWARD -o em1 -i p3p1 -p tcp --dport $i -j ACCEPT  
done

#udp
for i in ${UDPPORTS[@]}
do
	#inbound udp on DHCP
	iptables -A FORWARD -i em1 -o p3p1 -p udp --sport $i -j ACCEPT  
	#outbound udp on DHCP
	iptables -A FORWARD -o em1 -i p3p1  -p udp --dport $i -j ACCEPT  
done

#icmp
for i in ${ICMPSERVICES[@]}
do
	#inbound ICMP on “allowed” ports 
	iptables -A FORWARD -i em1 -o p3p1 -p icmp --icmp-type $i
	#outbound ICMP on “allowed” ports 
	iptables -A FORWARD -o em1 -i p3p1 -p icmp --icmp-type $i
done