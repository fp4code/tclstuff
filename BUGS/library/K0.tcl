proc rr {} {
    set cli0 [clock clicks]
    smuC write "Q1,-0.1,5.0,0.02,0,0X"
    set cli1 [clock clicks]
    set err [catch {smuC write "Q7,5.0,-0.1,-0.02,0,0X"} message]
    if {$err} {
	puts "ERREUR : $message"
    }
    puts stderr "----- [expr {$cli1 - $cli0}]"
}

smuC write K0
rr
smuC write K2
rr
