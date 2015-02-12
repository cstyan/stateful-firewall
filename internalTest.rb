@ip

def testSF
	`hping3 -c 1 -s 22 -p 8888 -SF #{@ip}`
end

def testXmas
	`hping3 -c 1 -s 22 -p 8888 -UPF #{@ip}`
end

def testNull
	`hping3 -c 1 -s 22 -p 8888 -S #{@ip}`
end

def testTelnet
	`hping3 -c 1 -s 8888 -p 23 -S #{@ip}`
end

def synHigh
	`hping3 -c 1 -s 8888 -p 8888 -S #{@ip}`
end

#these tests may be unnecessary
def testStatic
	`hping3 #{@ip} -c 1 -S -p 32768 -s 80`
	`hping3 #{@ip} -c 1 -S -p 138 -s 80`
	`hping3 #{@ip} -c 1 --udp -V -p 32768`
	`hping3 #{@ip} -c 1 -2 -V -p 137`
	`hping3 #{@ip} -c 1 -S -p 111 -s 80`
	`hping3 #{@ip} -c 1 -S -p 515 -s 80`
end

puts "Start of internal testing script for 8006 A2 - Stateful Firewall"
puts "All tests send 1 packet per test case."
puts "All tests should produce 100% packet loss."
puts "Please enter the p3p1 IP of the firewall to use for testing."
@ip = gets.chomp
puts "******************************************************"
puts "Tests start now."
puts "*******************************************************"
testSF
testXmas
testNull
testTelnet
testStatic
puts "End"