#globals
@filepath
@intNetwork = "192.168.10.0/24"
@internalInterface = "p3p1"
@extNetwork
@externalInterface = "em1"
@tcpServices = Array[80, 443]
#I needed to put 53 in udp not tcp
@udpServices = Array[53, 67, 68]
@icmpServices = Array[0, 8]


#get all use input
def userParams
	puts "Please enter the full path to iptables or other utility you wish to use."
	@filepath = gets.chomp

	puts "Please enter the internal network space."
	@intNetwork = gets.chomp

	puts "Please enter the internal network interface."
	@internalInterface = gets.chomp

	puts "Please enter the external network space"
	@extNetwork = gets.chomp

	puts "Please enter the external network interface."
	@externalInterface = gets.chomp

	puts "Please enter TCP services you wish to allow by port #."
	puts "Seperate each service with a comma."
	@tcpServices = gets.chomp
	@tcpServices = @tcpServices.split(",")

	puts "Please enter UDP services you wish to allow by port #."
	puts "Seperate each service with a comma."
	@udpServices = gets.chomp
	@udpServices = udpServices.split(",")

	puts "Please enter ICMP services you wish to allow by type #."
	puts "Seperate each service with a comma."
	@icmpServices = gets.chomp
	@icmpServices = tcpServices.split(",")
end

def drop
	#all inbound packets to ports less than 1024, can't do two protocols in one line
	`iptables -A FORWARD -i em1 -o p3p1 -p tcp --dport 0:1023 -j drop`
	`iptables -A FORWARD -i em1 -o p3p1 -p udp --dport 0:1023 -j drop`
	#drop incoming christmas tree packets
	`iptables -A FORWARD -p tcp -i em1 --tcp-flags ALL ALL -j drop`
	#drop outbound christmas tree packets
	`iptables -A FORWARD -p tcp -o em1 --tcp-flags ALL ALL -j drop`
	#drop incoming null scan packets
	`iptables -A FORWARD -p tcp -i em1 --tcp-flags ALL NONE -j drop`
	#drop outbound null scan packets
	`iptables -A FORWARD -p tcp -o em1 --tcp-flags ALL NONE -j drop`
	#drop all fin,syn’s
	`iptables -A FORWARD -p tcp -i em1 -o p3p1 --tcp-flags FIN,SYN SYN,FIN -j DROP`

	#drop anything that gets forwarded to drop chain
	`iptables -A drop -j DROP`
end

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

def routing
	
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
	`iptables -t nat -A PREROUTING -i em1 -j DNAT --to-destination 192.168.10.2`
end
#start of the firewall
def writeFirewall
	#flush existing tables
	puts "flushing IPTables"
	`iptables -F`

	puts "removing existing user chain"
	removeUserChains

	puts "setting default policies to drop"
	defaultPolicy

	allowLocal

	puts"creating user chains"
	createUserChains
	
	puts "writing drop rules to IPTables"
	drop

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
