#!/bin/sh
# The next line is executed by /bin/sh, but not tcl \
exec tclsh "$0" ${1+"$@"}

##
## maison25.tcl
##
## connecte à labo25.tcl
##
## inclus X11 multifenêtres, echo et get/put
##

source commun25.tcl

proc errmsg {message} {
    puts stderr $message
}

proc psLu {} {
    global PSstat IN OUT TUNPS
    if {[info exists IN($PSstat(active))]} {
        # puts stderr "$PSstat(active) -> $IN($PSstat(active)) [string length $PSstat(data)]"
        puts -nonewline $IN($PSstat(active)) $PSstat(data)
        flush $IN($PSstat(active))
        return
    }
    switch $PSstat(active) [list "$TUNPS(stderr)" {
        puts stderr "STDERR = \"$PSstat(data)\""
    } "$TUNPS(stdout)" {
        puts stderr "STDOUT = \"$PSstat(data)\""
    } "$TUNPS(stdin)" {
        commande $PSstat(data)
    } "$TUNPS(put)" {
        set err [catch {putOnFile $PSstat(data)} message]
        if {$err} {
            puts stderr $message
        }
    } "$TUNPS(x11)" {    
        # demande X11
        set err [catch {socket localhost 6000} ecran]
        if {$err} {
            writeTunnel $TUNPS(stderr) $ecran
            writeTunnel $TUNPS(stdin) "_CLOSE_ sock$idSockProg"
            return
        }
        set err [catch {idSock $PSstat(data)} idSockProg]
        if {$err} {
            writeTunnel $TUNPS(stderr) $idSockProg
            writeTunnel $TUNPS(stdin) "_CLOSE_ sock$idSockProg"
            return
        }
        set IN($idSockProg) $ecran
        set OUT($ecran) $idSockProg
        fconfigure $ecran -blocking 0 -buffering full -buffersize 4096 -translation binary -encoding binary
        fileevent $ecran readable [list transmetsOut $ecran]
    }]
}
    
proc commande argum {
    global IN OUT
    set commande [lindex $argum 0]
    puts stderr "commande $argum ($commande)"
    switch $commande {
        "_CLOSE_" {
            set quoi [lindex $argum 1]
            puts stderr "_CLOSE_ $quoi"
            if {[info exists IN($quoi)]} {
                fileevent $IN($quoi) readable {}
                close $IN($quoi)
                unset OUT($IN($quoi))
                unset IN($quoi)
            }
        }
    }
}

proc accept {tunnel addr port} {
    global TUNNEL SOCKSERVER
    close $SOCKSERVER
    set TUNNEL $tunnel
    fileevent $TUNNEL readable readTunnel
    fconfigure $TUNNEL -blocking 0 -buffering full -buffersize 4096 -translation binary -encoding binary
    puts stderr "Connecté !"
    fconfigure stdin -blocking 0 -buffering line
    fileevent stdin readable sendLabo
}

proc sendLabo {} {
    global TUNNEL TUNPS
    set command [gets stdin]
    if {[lindex $command 0] == "put"} {
        foreach f [lrange $command 1 end] {
            putFile $f
        }
        return
    }
    writeTunnel $TUNPS(stdin) $command
    if {[eof stdin]} {
        puts stderr "mauvaise idée : EOF stdin"
    }
}

set PSstat(active) 0
set PSstat(isData) 0 ;# entête -> 0, data -> 1
set PSstat(size) 6
set PSstat(data) ""
set SOCKSERVER [socket -server accept $tunnelPort]
vwait eventLoop
puts $eventLoop
