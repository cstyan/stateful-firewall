@ip

def test1024
	puts "Test 1: Drop all incomming packets to low ports (less than 1024)."
	puts "-- TCP --"
	`hping3 #{@ip} -c 1 -V -p 22 -s 22 -S`
	`hping3 #{@ip} -c 1 -V -p 22 -s 8080 -S`
	puts "-- UDP --"
	`hping3 #{@ip} -c 1 -V -p 22 -s 22 --udp`
	`hping3 #{@ip} -c 1 -V -p 22 -s 8080 ---udp`
end

def testChristmas
	puts "Test2: Block incomming Christmans Tree scans."
	`hping3 #{@ip} -c 5 -V -p 8000 -s 8080 -SFRUPA`
end

def testNull
	puts "Test3: Block incmming Null scans."
	`hping3 #{@ip} -c 5 -V -p 8000 -s 8080`
end

def testSynFin
	puts "Test 4: Block incomming packets"
	`hping3 #{@ip}-c 5 -V -p 8080 -s 8080 -SF`
end

def testTcp
	puts "shit"
end

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
	`hping 3 #{@ip} -c 1 -p 32768 -s 80 -S`
	`hping 3 #{@ip} -c 1 -p 138 -s 80 -S`
	`hping 3 #{@ip} -c 1 -p 32768 -s 80 --udp`
	`hping 3 #{@ip} -c 1 -p 138 -s 80 --udp`
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