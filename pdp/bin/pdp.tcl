set PDP attila.lpn.prive

proc readPDP {} {
    global STATUS PDPSOCK
    
    if {[eof $PDPSOCK]} {
        close $PDPSOCK
        puts stderr "PDP is dead"
        set STATUS(pdp) disconnected
        return
    }

    set line [gets $PDPSOCK]
    puts stderr "PDP: [string length $line]\n\"$line\""
}

proc putsPDP {commande} {
    global PDPSOCK
    if {[lindex $commande 1] == "LOGIN"} {
        puts stderr " moi: \"[lrange $commande 0 end-1] XXXcensuréXXX\""
    } else {
        puts stderr " moi: \"$commande\""
    }
    puts $PDPSOCK $commande
}

proc connectePDP {} {
    global STATUS PDP PDPSOCK ITAG
    set PDPSOCK [socket $PDP telnet]
    fileevent $PDPSOCK readable readPDP
    fconfigure $PDPSOCK -buffering none -blocking 0 -encoding binary  -translation crlf
    puts stderr "[clock format [clock seconds]] Connecté au PDP !"
}










set pdp [spawn telnet attila.lpn.prive]

exp_send \r

interact {
    $      {send_user "The date is [exec date]."}
    \003   exit
    foo    {send_user "bar"}
    fin
}

expect {
    > {puts MCR}
    {JEOL $} puts DCL
}
