puts "internal host config start"
	`service NetworkManagers stop`
	`ifconfig em1 down`
	`ifconfig p3p1 192.168.10.2 up`
	`route add default gw 192.168.10.1`
puts "end"