@ip

def testSF
	`hping3 #{@ip} -c 1 -s 1000 -p 8888 -SF`
end

def testXmas
	`hping3 #{@ip} -c 1 -s 1000 -p 8888 -UPF`
end

def testNull
	`hping3 #{@ip} -c 1 -S -s 1000 -p 8888`
end

def testTelnet
	`hping3 #{@ip} -c 1 -S -s 8888 -p 23`
end

def testInSubnet
	`hping3 #{@ip} -c 1 -S -s 8888 -p 8888 --spoof 192.168.10.5`
	#This ends up showing up on the dropped output chain
end

def synHigh
	`hping3 #{@ip} -c 1 -S -s 8888 -p 8888`
end

#ports required to be dropped via assignment requirements
def dropStatic
	`hping3 #{@ip} -c 1 -S -p 32768 -s 80`
	`hping3 #{@ip} -c 1 -S -p 138 -s 80`
	`hping3 #{@ip} -c 1 --udp -V -p 32768`
	`hping3 #{@ip} -c 1 -2 -V -p 137`
	`hping3 #{@ip} -c 1 -S -p 111 -s 80`
	`hping3 #{@ip} -c 1 -S -p 515 -s 80`
end

puts "Start of testing script for 8006 A2 - Stateful Firewall"
puts "All tests send 1 packet per test case."
puts "All tests should produce 100% packet loss.
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
