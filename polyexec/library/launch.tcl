#!/usr/local/bin/tclsh


proc fini {fifi} {
    global kiki
    # indispensable
    if {[eof $fifi]} {
        close $fifi
	incr kiki -1
	puts "fini : $fifi"
    } else {
        set toto [gets $fifi]
        puts "toto = \"$toto\""
    }
}

set kiki 0
set resul1 [open "|./aProg.tcl 20000"]
incr kiki
set resul2 [open "|./aProg.tcl 10000"]
incr kiki

fconfigure $resul1 -buffering line
fconfigure $resul2 -buffering line

puts "resul1 = $resul1, [fconfigure $resul1]"
puts "resul2 = $resul2, [fconfigure $resul1]"

fileevent $resul1 readable "fini $resul1"
fileevent $resul2 readable "fini $resul2"

while {$kiki > 0} {
    vwait kiki
}

puts "fini fini"
