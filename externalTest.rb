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


puts "Start of testing script for 8006 A2 - Stateful Firewall"
puts "All tests send 5 packets per test case."
puts"Please enter the em1 IP of the firewall to use for testing."
@ip = gets.chomp
puts "Initial verbose iptables output."
puts "*******************************************************"
`iptables -L -x -v -n`
puts "*******************************************************"
puts "Tests start now."
puts "*******************************************************"
