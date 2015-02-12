@ip

def testSF
	`hping3 #{@ip} -c 1 -s 22 -p 8888 -SF`
end

def testXmas
	`hping3 #{@ip} -c 1 -s 22 -p 8888 -UPF`
end

def testNull
	`hping3 #{@ip} -c 1 -s 22 -p 8888 -S`
end

def testTelnet
	`hping3 #{@ip} -c 1 -s 8888 -p 23 -S`
end

def testInSubnet
	`hping3 #{@ip} -c 1 -s 8888 -p 8888 --spoof 192.168.10.5 -S`
	#This ends up showing up on the dropped output chain
end

def synHigh
	`hping3 #{@ip} -c 1 -s 8888 -p 8888 -S`
end

#ports required to be dropped via assignment requirements
def dropStatic
	`hping3 #{@ip} -c 1 -p 32768 -s 80 -S`
	`hping3 #{@ip} -c 1 -p 138 -s 80 -S`
	`hping3 #{@ip} -c 1 -p 32768 -s 80 --udp`
	`hping3 #{@ip} -c 1 -p 138 -s 80 --udp`
	`hping3 #{@ip} -c 1 -p 111 -s 80 -S`
	`hping3 #{@ip} -c 1 -p 515 -s 80 -S`
end

puts "Start of testing script for 8006 A2 - Stateful Firewall"
puts "All tests send 1 packet per test case."
puts"Please enter the em1 IP of the firewall to use for testing."
@ip = gets.chomp
puts "Initial verbose iptables output."
puts "*******************************************************"
`iptables -L -x -v -n`
puts "******************************************************"
puts "Tests start now."
puts "*******************************************************"
testSF
testXmas
testTelnet
testInSubnet
synHigh
dropStatic