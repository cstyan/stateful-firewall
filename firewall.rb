#### CONFIG SECTION
#globals
@filepath
@intNetwork = "192.168.10.0/24"
@internalInterface = "p3p1"
@extNetwork
@externalInterface = "em1"
@tcpServices = Array[194]
@udpServices = Array[194]
@icmpServices = Array[0, 8]
#### end of config


#things we always want to drop
def drop
	#inbound SYNFIN
	`iptables -A FORWARD -p tcp -i #{@externalInterface} -o #{@internalInterface} --tcp-flag SYN,FIN SYN,FIN -j drop`
	`iptables -A INPUT -p tcp --tcp-flag SYN,FIN SYN,FIN -j drop`
	
	#outbound SYNFIN
	`iptables -A FORWARD -p tcp -o #{@externalInterface} -i #{@internalInterface} --tcp-flag SYN,FIN SYN,FIN -j drop`
	
	#inbound christmas tree
	`iptables -A INPUT -p tcp --tcp-flag URG,PSH,FIN URG,PSH,FIN -j drop`
	`iptables -A FORWARD -p tcp  -i #{@externalInterface} -o #{@internalInterface} --tcp-flag URG,PSH,FIN URG,PSH,FIN -j drop`
	
	#outbound christmas tree
	`iptables -A FORWARD -p tcp -o #{@internalInterface} -i #{@externalInterface} --tcp-flag URG,PSH,FIN URG,PSH,FIN -j drop`
	`iptables -A INPUT -p tcp --tcp-flag ALL NONE -j drop`
	`iptables -A FORWARD -p tcp -i #{@externalInterface} -o #{@internalInterface} --tcp-flag ALL NONE -j drop`
	
	#inbound telnet
	`iptables -A FORWARD -p tcp -i #{@externalInterface} -o #{@internalInterface} --dport 23 -j drop`
	
	#outbound telnet 
	`iptables -A FORWARD -p tcp -o #{@externalInterface} -i #{@internalInterface} --dport 23 -j drop`
	
	#inbound packets external interface with an IP of the internal network
	`iptables -A FORWARD -i #{@internalInterface} -o #{@externalInterface} -s #{@intNetwork} -j drop`
	
	#drop inbound syn packets to high ports
	`iptables -A FORWARD -p tcp -i #{@externalInterface} -o #{@internalInterface} --dport 1023: --tcp-flag SYN SYN -j drop`
	
	###### DROP OUTBOUND PACKETS VIA TCP AND UDP TO PORTS 32768-32755 && 137 - 139 ######
	#### TCP
	`iptables -A FORWARD -p tcp -o #{@externalInterface} -i #{@internalInterface} --dport 32755:32768 -j drop`
	`iptables -A FORWARD -p tcp -o #{@externalInterface} -i #{@internalInterface} --dport 137:139 -j drop`
	
	#### UDP
	`iptables -A FORWARD -p udp -o #{@externalInterface} -i #{@internalInterface} --dport 32755:32768 -j drop`
	`iptables -A FORWARD -p udp -o #{@externalInterface} -i #{@internalInterface} --dport 137:139 -j drop`
	
	####### DROP OUTBOUND PACKETS TO TCP PORTS 111 && 515 #############
	`iptables -A FORWARD -p tcp -o #{@externalInterface} -i #{@internalInterface} -m multiport --dport 111,515 -j drop`
	
	### BLOCK FRAGMENTS FROM NEW CONNECTIONS
	###INBOUND FRAGMENTS ON NEW
	`iptables -A FORWARD -p tcp -i #{@externalInterface} -o #{@internalInterface} -m state --state NEW -f -j drop`
	###OUTBOUND FRAGMENTS ON NEW
	`iptables -A FORWARD -p tcp -o #{@externalInterface} -i #{@internalInterface} -m state --state NEW -f -j drop`

	######### ACCEPT FRAGMENTS FROM ESTABLISHED UDP CONNECTIONS #################
	#### INBOUND FRAGMENTS
	`iptables -A FORWARD -p udp -i #{@externalInterface} -o #{@internalInterface} -m state --state ESTABLISHED -f -j ACCEPT`
	#### OUTBOUND FRAGMENTS
	`iptables -A FORWARD -p udp -o #{@externalInterface} -i #{@internalInterface} -m state --state ESTABLISHED -f -j ACCEPT`

	#drop anything that gets forwarded to drop chain
	`iptables -A drop -j DROP`
end

#removes user chains that are created by this script
def removeUserChains
	#tcpIn
	`iptables -X tcpIn`
	#tcpOut
	`iptables -X tcpOut`
	#udpIn
	`iptables -X udpIn`
	#udpOut
	`iptables -X udpOut`
	#icmpIn
	`iptables -X icmpIn`
	#icmpOut
	`iptables -X icmpOut`
	#general drop rules
	`iptables -X drop`
	#others?
	`iptables -X other`
end

#creates user chains used by this script for IPTables
def createUserChains
	#tcpIn
	`iptables -N tcpIn`
	#tcpOut
	`iptables -N tcpOut`
	#udpIn
	`iptables -N udpIn`
	#udpOut
	`iptables -N udpOut`
	#icmpIn
	`iptables -N icmpIn`
	#icmpOut
	`iptables -N icmpOut`
	#general drop rules
	`iptables -N drop`
	#others?
	`iptables -N other`
end

#allows dns and dhcp on the in/out chains of the firewall
#note that this has nothing to do with the forwarding
def allowLocal
	#allow dhcp
	`iptables -A INPUT -p udp --dport 67:68 --sport 67:68 -j ACCEPT`

	#allow dns
	`iptables -A INPUT -p udp --sport 53 -j ACCEPT`
	`iptables -A OUTPUT -p udp --dport 53 -j ACCEPT`
end

#rules that we always want to allow
#such as ftp and HTTP(S)
def staticRules
	##INBOUND SSH
	#incoming SSH
	`iptables -A FORWARD -p tcp -i em1 -o p3p1 -m state --state NEW,ESTABLISHED --dport 22 -j ACCEPT`
	#responding SSH
	`iptables -A FORWARD -p tcp -o em1 -i p3p1 -m state --state ESTABLISHED --sport 22 -j ACCEPT`

	##OUTBOUND SSH
	#outgoing ssh
	`iptables -A FORWARD -p tcp -o em1 -i p3p1 -m state --state NEW,ESTABLISHED --dport 22 -j ACCEPT`
	#responding ssh
	`iptables -A FORWARD -p tcp -i em1 -o p3p1 -m state --state ESTABLISHED --sport 22 -j ACCEPT`
	######### SSH #############

	#outbound www
	`iptables -I FORWARD -p tcp -i p3p1 -o em1 -m state --state NEW,ESTABLISHED -m multiport --dport 80,443 -j ACCEPT`
	#responding www
	`iptables -I FORWARD -p tcp -i em1 -o p3p1 -m state --state ESTABLISHED -m multiport --sport 80,443 -j ACCEPT`

	#outbound ftp-data
	`iptables -I FORWARD -p tcp -i p3p1 -o em1 -m state --state NEW,ESTABLISHED  --dport 20 -j ACCEPT`
	#responding ftp-data
	`iptables -I FORWARD -p tcp -o p3p1 -i em1 -m state --state ESTABLISHED  --sport 20 -j ACCEPT`
	#outbound ftp-cmd
	`iptables -I FORWARD -p tcp -i p3p1 -o em1 -m state --state NEW,ESTABLISHED  --dport 21 -j ACCEPT`
	#responding ftp-cmd
	`iptables -I FORWARD -p tcp -o p3p1 -i em1 -m state --state ESTABLISHED  --sport 21 -j ACCEPT`
end

def writeTCP
	run = 0
	while run < @tcpServices.length
		#convert the current type to a string for the iptables command
		port = @tcpServices[run]
		#inbound forwarded tcp packets
		`iptables -A FORWARD -i #{@internalInterface}  -o #{@externalInterface} -p tcp --dport #{port} -m state --state NEW,ESTABLISHED -j tcpIn`
		#outbound forwarded tcp packets
		`iptables -A FORWARD -o #{@internalInterface}  -i #{@externalInterface} -p tcp --sport #{port} -m state --state NEW,ESTABLISHED -j tcpOut`
		run = run + 1
	end
	#accept everything that gets forwarded to tcpIn and tcpOut
	`iptables -A tcpIn -j ACCEPT`
	`iptables -A tcpOut -j ACCEPT`
end

def writeUDP
	run = 0
	while run < @udpServices.length
		#convert the current type to a string for the iptables command
		port = @udpServices[run]
		#inbound forwarded UDP packets
		`iptables -A FORWARD -i #{@internalInterface}  -o #{@externalInterface} -p udp --dport #{port} -m state --state NEW,ESTABLISHED -j udpIn`
		#outbound forwarded UDP packets
		`iptables -A FORWARD -o #{@internalInterface}  -i #{@externalInterface} -p udp --sport #{port} -m state --state NEW,ESTABLISHED -j udpOut`
		
		######### ACCEPT FRAGMENTS FROM ESTABLISHED UDP CONNECTIONS #################
		#### INBOUND FRAGMENTS
		`iptables -A FORWARD -p udp -i em1 -o p3p1 -m state --state ESTABLISHED -f -j ACCEPT`
		#### OUTBOUND FRAGMENTS
		`iptables -A FORWARD -p udp -o em1 -i p3p1 -m state --state ESTABLISHED -f -j ACCEPT`
		######### ACCEPT FRAGMENTS FROM RELATED UDP CONNECTIONS #################

		run = run + 1
	end
	#accept everything that gets forwarded to udpIn and udpOut
	`iptables -A udpIn -j ACCEPT`
	`iptables -A udpOut -j ACCEPT`
end

def writeICMP
	run = 0
	while run < @icmpServices.length
		#convert the current type to a string for the iptables command
		typeString = @icmpServices[run]
		#inbound ICMP on allowed ports
		`iptables -A FORWARD -i #{@internalInterface} -o #{@externalInterface} -p icmp --icmp-type #{typeString} -m state --state NEW,ESTABLISHED -j icmpIn`
		#outbound ICMP on allowed ports
		`iptables -A FORWARD -i #{@externalInterface} -o #{@internalInterface} -p icmp --icmp-type #{typeString} -m state --state NEW,ESTABLISHED -j icmpOut`
		run = run + 1
	end
	#accept everything that gets forwarded to to icmpIn and icmpOut
	`iptables -A icmpIn -j ACCEPT`
	`iptables -A icmpIn -j ACCEPT`
end

def defaultPolicy
	#set default for every chain to drop
	`iptables -P INPUT DROP`
	`iptables -P OUTPUT DROP`
	`iptables -P FORWARD DROP`
end

#sets up ip's and routing 
def configuration
	firewallIP = "192.168.0.17"
	puts "nat stuff"
	#maybe we should use variables for some of these?
	#18 is the firewall machine
	`ifconfig p3p1 192.168.10.1 up`
	`echo "1" >/proc/sys/net/ipv4/ip_forward`
	`route add -net 192.168.0.0 netmask 255.255.255.0 gw #{firewallIP}`
	`route add -net 192.168.10.0/24 gw 192.168.10.1`
	`iptables -t nat -A POSTROUTING -o em1 -j MASQUERADE`
	#{}`iptables -t nat -A PREROUTING -i em1 -j DNAT --to-destination 192.168.10.2`
end

#start of the firewall
def writeFirewall
	#flush existing tables
	puts "flushing IPTables"
	`iptables -F`

	puts "removing existing user chain"
	removeUserChains
	
	puts"creating user chains"
	createUserChains

	puts "setting default policies to drop"
	defaultPolicy

	puts "writing drop rules to IPTables"
	drop
	
	puts "allowing dns and dhcp"
	allowLocal

	puts "writing accept rules to IPTables"	
	writeTCP
	writeUDP
	writeICMP
end

def main
	#we should call config nat here
	configuration
	writeFirewall
end

#start script
main
