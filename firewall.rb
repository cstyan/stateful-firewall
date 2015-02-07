#globals
@filepath
@intNetwork = "192.168.10.0/24"
@internalInterface = "p3p1"
@extNetwork
@externalInterface = "em1"
@tcpServices = Array.new(53, 80, 443)
@udpServices = Array.new(67, 68)
@icmpServices = Array.new(0, 8)


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

def writeTCP
	run = 0
	while run < @tcpServices.length
		#convert the current type to a string for the iptables command
		port = @tcpServices[run]
		#inbound forwarded tcp packets on DNS, HTTP, HTTPS
		`iptables -A FORWARD -i #{@internalInterface}  -o #{@externalInterface} -p tcp -dport #{port} -m state--state NEW,ESTABLISHED`
		#outbound forwarded tcp packets on DNS, HTTP, HTTPS
		`iptables -A FORWARD -o #{@internalInterface}  -i #{@externalInterface} -p tcp -dport #{port} -m state --state NEW,ESTABLISHED`
		run = run + 1
	end
end

def writeUDP
	run = 0
	while run < @tcpServices.length
		#convert the current type to a string for the iptables command
		port = @tcpServices[run]
		#inbound forwarded UDP packets
		`iptables -A FORWARD -i #{@internalInterface}  -o #{@externalInterface} -p udp -dport #{port} -m state --state NEW,ESTABLISHED`
		#outbound forwarded UDP packets
		`iptables -A FORWARD -o #{@internalInterface}  -i #{@externalInterface} -p udp -dport #{port} -m state --state NEW,ESTABLISHED`
		run = run + 1
	end
end

def writeICMP
	run = 0
	while run < @icmpServices.length
		#convert the current type to a string for the iptables command
		typeString = @icmpServices[run]
		#inbound ICMP on allowed ports
		`iptables -A FORWARD -i #{@internalInterface} -o #{@externalInterface} -p icmp --icmp-type #{typeString} -m state --state NEW,ESTABLISHED -j ACCEPT`
		#outbound ICMP on allowed ports
		`iptables -A FORWARD -i #{@externalInterface} -o #{@internalInterface} -p icmp --icmp-type #{typeString} -m state --state NEW,ESTABLISHED -j ACCEPT`
		run = run + 1
	end
end

#start of the firewall
def writeFirewall
	#flush existing tables
	puts "flushing firewall"
	`sudo iptables -F`
	#clear any user defined chains we have

	#write tcp
	#write udp
	#write icmp
end

def main
	#userParams
	writeFirewall
end

#start script
main


