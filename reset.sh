#!/bin/bash

#flush existing rules
iptables -F

#default rules
iptables -P INPUT ACCEPT
iptables -P OUTPUT ACCEPT
iptables -P FORWARD ACCEPT