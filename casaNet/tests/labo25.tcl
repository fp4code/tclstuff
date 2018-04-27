#!/bin/sh
# The next line is executed by /bin/sh, but not tcl \
exec tclsh "$0" ${1+"$@"}

##
## labo25.tcl
##
## connecte à maison25.tcl
##
## inclus X11 multifenêtres, echo et get/put
## 

source commun25.tcl

set PROG xterm

proc errmsg {message} {
    global TUNPS
    writeTunnel $TUNPS(stderr) $message
}

proc acceptX11 {pseudoProgramme host port} {
    global IN OUT TUNPS
    writeTunnel $TUNPS(x11) $pseudoProgramme
    set idSockProg [idSock $pseudoProgramme]
    set IN($idSockProg) $pseudoProgramme
    set OUT($pseudoProgramme) $idSockProg
    fconfigure $pseudoProgramme -blocking 0 -buffering full -buffersize 4096 -translation binary -encoding binary
    fileevent $pseudoProgramme readable [list transmetsOut $pseudoProgramme]
}

proc demarrePseudoEcran {} {
    set ok 0
    set ecran 10
    while {!$ok} {
        set err [catch {socket -server acceptX11 [expr {6000 + $ecran}]} pseudoEcran]
        if {$err} {
            puts stderr "écran $ecran déjà utilisé"
            incr ecran
            if {$ecran > 20} {
                return -code error "pas assez d'écrans disponibles"
            }
        } else {
            set ok 1
        }
    }
    return $ecran
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
            writeTunnel $TUNPS(stderr) $message
        }
    }]
}

proc commande argum {
    global IN OUT TUNPS
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
        "echo" {
            writeTunnel $TUNPS(stdout) [lrange $argum 1 end]
        }
        "get" {
            foreach f [lrange $argum 1 end] {
                putFile $f
            }
        }
    }
}

proc doIt {tunnelHost tunnelPort} {
    global TUNNEL PROG TUNPS
    set TUNNEL [socket $tunnelHost $tunnelPort]
    fileevent $TUNNEL readable readTunnel
    fconfigure $TUNNEL -blocking 0 -buffering full -buffersize 4096 -translation binary -encoding binary
    puts stderr "Connecté !"
    writeTunnel $TUNPS(stderr) "essai erreur"
    set ecran [demarrePseudoEcran]
    #exec $PROG -display localhost:$ecran &    
    # exec $PROG -display localhost:$ecran &
    set display localhost:$ecran
    writeTunnel $TUNPS(stdout) "DISPLAY=$display"
    exec xterm -display $display &    
}

set PSstat(active) 0
set PSstat(isData) 0 ;# entête -> 0, data -> 1
set PSstat(size) 6
set PSstat(data) ""
close stdin
doIt tif $tunnelPort
vwait eventLoop
puts $eventLoop
