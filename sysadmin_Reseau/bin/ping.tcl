#!/bin/sh
#\
exec wish "$0" ${1+"$@"}

set BIG1 "0123456789"
set BIG2 ""
for {set i 0} {$i < 10} {incr i} {
    append BIG2 $BIG1
}
set BIG3 ""
for {set i 0} {$i < 10} {incr i} {
    append BIG3 $BIG2
}
set BIG4 ""
for {set i 0} {$i < 10} {incr i} {
    append BIG4 $BIG3
}
set BIG5 ""
for {set i 0} {$i < 10} {incr i} {
    append BIG5 $BIG4
}
set BIG6 ""
for {set i 0} {$i < 10} {incr i} {
    append BIG6 $BIG5
}

set timedelay 10000

# Accept-Connection handler for Server. 
# called When client makes a connection to the server
# Its passed the channel we're to communicate with the client on, 
# The address of the client and the port we're using
#
# Setup a handler for (incoming) communication on 
# the client channel - send connection Reply and log connection

proc acceptProc {sock addr port} {
  
    global CONSTAT CLW
    
    set secondes [clock seconds]
    set dada [clock format $secondes -format {%Y/%m/%d %H:%M:%S}]
    puts "Voici la date : $dada"
    
    # Note we've accepted a connection (show how get peer info fm socket)
    
    foreach {address hostName portNumber} [fconfigure $sock -sockname] {}
    puts "sockname : ip=$address ($hostName) port=$portNumber)"
    
    foreach {address hostName portNumber} [fconfigure $sock -peername] {}
    puts "peername : ip=$address ($hostName) port=$portNumber)"
    
    # log the connection
    puts "Accepted connection from $addr at $dada, sock = $sock"
    set CONSTAT($hostName/$portNumber) $sock
    
    # Read big client input
    fconfigure $sock -buffering full -buffersize 1000000 -blocking 0  -encoding binary -translation binary
    # fconfigure $sock -buffering full -buffersize 1000 -blocking 1

    set id [gets $sock]
    puts "\"$id\""
}

# Create a server socket on port $svcPort. 
# Call proc accept when a client attempts a connection.

set ok 0
for {set svcPort 33000} {$svcPort < 65000} {incr svcPort} {
    set err [catch {socket -server acceptProc $svcPort} message]
    if {!$err} {
        set ok 1
        break
    }
    if {($errorCode == "NONE" && $message == "couldn't open socket: address already in use") ||\
        [lindex $errorCode 0] == "POSIX" && [lindex $errorCode 1] == "EADDRINUSE"} {
        continue
    } else {
        return -code error $message
    }
}

puts "port=$svcPort"
flush stdout

# en fait, cette procédure peut bloquer pour de grosses écritures.
# On configure donc -blocking 0, et c'est securegets qui fait le boulot
# de savoir si la lecture est OK.
proc putIt {sock data} {
    global PUTITDONE MESSAGE PUTITRESTE
    puts stderr [list putIt [string length $data] octets]
    puts $sock $data
    if {[catch {flush $sock} MESSAGE]} {
        fileevent $sock writable {}
        set PUTITDONE -2
    }
    set PUTITRESTE [expr {$PUTITRESTE - [string length $data]}]
    if {$PUTITRESTE == 0} {
        set PUTITDONE 1
    } else {
        set PUTITDONE 0
    }
    fileevent $sock writable {}
}

proc secureputs {sock data timeout} {
    global PUTITDONE MESSAGE PUTITRESTE
    set PUTITDONE 0
    set PUTITRESTE [string length $data]
    puts stderr [list psecure [string length $data] octets]
    set id [after $timeout {set PUTITDONE -1; set MESSAGE "timeout on secureputs"}]
    while {$PUTITRESTE > 0 && $PUTITDONE == 0} {
        set reste [string range $data end-[expr {$PUTITRESTE-1}] end]
        puts stderr "PUTITRESTE = $PUTITRESTE -> [string length $reste] octets"
        fileevent $sock writable "putIt $sock $reste"
        vwait PUTITDONE
    }
    after cancel $id
    if {$PUTITDONE == 1} {
        return
    } else {
        if {![info exists MESSAGE]} {
            set MESSAGE "PUTITDONE = $PUTITDONE"
        }
        return -code error $MESSAGE
    }
}

proc getIt {sock n} {
    global GETITDONE GETITRESTE
    
    puts stderr " getIt $sock $n"
    if {$GETITRESTE <= 0} {
        fileevent $sock readable {}
        return
    }

    if {[eof $sock]} {
        close $sock
        return -code error "$sock is closed"
    }
    set s [gets $sock]
    set nlu [string length $s]
    set GETITRESTE [expr {$GETITRESTE - $nlu}]
    puts stderr "lu $nlu sur $n ([string range $s 0 2]...[string range $s end-2 end]), reste $GETITRESTE"
    
    if {$GETITRESTE <= 0} {
        puts stderr " fileevent $sock readable {}"
        fileevent $sock readable {}
        set GETITDONE 1
    }
}

proc securegets {sock n timeout} {
    global GETITDONE GETITRESTE

    puts stderr "securegets $sock $n $timeout"

    set GETITDONE 0
    set GETITRESTE $n
    fileevent $sock readable "getIt $sock $n"
    set id [after $timeout {set GETITDONE -1}]
    vwait GETITDONE
    after cancel $id
    if {$GETITDONE != 1} {
        return -code error "timeout on securegets, GETITRESTE = $GETITRESTE, GETTITDONE = $GETITDONE"
    }
    return {}
}

proc doOneTest {BIGNAME timeout} {
    global CONSTAT
    upvar $BIGNAME BIG

    update

    set lcon [array names CONSTAT]
    set n [llength $lcon]
    if {$n == 0} {
        puts stderr "no connexion"
        return {}
    }
    set i [expr {int(rand()*$n)}]
    set con [lindex $lcon $i]
    set sock $CONSTAT($con)
    puts "sock = $sock"
    set nlu [string length $BIG]
    set top0 [clock clicks -milliseconds]
    if [catch {
        secureputs $sock "N=[string length $BIG]" $timeout
        secureputs $sock $BIG $timeout
        securegets $sock $nlu $timeout
    } message] {
        unset CONSTAT($con)
        close $sock
        return [list $con 0 $message]
    }
    set top1 [clock clicks -milliseconds]
    set dt [expr {0.001*($top1 - $top0)}]
    if {$dt == 0.0} {
        set v Inf
    }
    set v [expr {(2.*$nlu*8.*1e-6)/$dt}]
    puts "AR avec $con de $nlu octets en $dt s, soit [format %.2f $v]Mbit/s"
    return [list $con $v]
}


proc newclient {client svcPort} {
    global CLW

    set randid [format %08x [expr {int(0x7fffffff*rand())}]]

    set clientprog {
        # lecture de ce qui sort de la chaussette $sock et impression à l'écran 
        # la variable globale eventLoop est modifiée si le serveur meurt
        proc read_sock {sock} {
            global eventLoop
            if [eof $sock] {
                close $sock             ;# close the socket client connection
                set eventLoop "server is dead"     ;# terminate the vwait (eventloop)
            } else {
                set n [gets $sock]
                if {$n == {}} {
                    puts stderr "client lit vide"
                    return
                }
                if {[string range $n 0 1] != "N="} {
                    puts stderr "\"$n\" au lieu de \"N=...\""
                }
                set n [string range $n 2 end]
                puts stderr "N:=$n"
                puts stderr [list gets $sock]
                set l [gets $sock]
                puts stderr "client a lu [string length $l] octets sur $n"
                puts $sock $l
                flush $sock
                puts stderr "client a flushe"
            }
        }
        
        proc open_sock {host port id} {
            set sock [socket $host $port]
            puts "sock client = $sock"
            fileevent $sock readable [list read_sock $sock]
            fconfigure $sock -buffering full -buffersize 1000000 -encoding binary -translation binary
            puts $sock "$id"
            flush $sock
        }
    }

    append clientprog "    open_sock [info host] $svcPort $randid\n"
    append clientprog "    vwait eventLoop\n"
    
    exec rsh $client tclsh << $clientprog &
    set CLW($randid/$client) [clock seconds]
}


# exec rsh l2m tclsh << $clientprog &
# exec rsh mbe4 tclsh << $clientprog &
# exec rsh fico9 tclsh << $clientprog &

newclient mbe4 $svcPort

proc d {} {global BIG1; doOneTest BIG1 20000}
proc dd {} {global BIG5; doOneTest BIG5 20000}

newclient u5fico $svcPort

proc doudou {} {
    global BIG5
    set rep [doOneTest BIG5 5000]
    if {$rep == {}} {
        bell
    } else {
        set t [lindex $rep 1]
        if {$t == 0} {
            bell
            puts stderr $rep
        } elseif {$t < 1.0} {
            bell
            puts stderr $rep
        } else {
            puts stderr $rep
        }
    }
    after 10000 doudou
}

doudou
