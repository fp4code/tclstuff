#!/bin/sh
# The next line is executed by /bin/sh, but not tcl \
exec tclsh "$0" ${1+"$@"}

##
## scrutImap.1.0.tcl 22 mars 200 (FP)
##
## reste à traiter les erreurs
##

set DEST Fabrice.Pardo@free.fr
set PROXY proxy
set PORT 8080
set CADENCE [expr {5*60*1000}]

proc message {subject message} {
    global DEST
    puts stderr "message $subject $message"
    if {[catch {exec mailx -s $subject $DEST << $message} erreur]} {
        puts stderr $erreur
    }
}

proc date {} {
    return [clock format [clock seconds] -format "%Y-%m-%d %H:%M:%S"]
}

proc scrute {proxy port ok cadence} {
    if {[catch {socket $proxy $port} socket]} {
        if {$ok} {
            message "not ok ([date])" $socket 
            set ok 0
        }
    } else {
        close $socket
        if {!$ok} {
            message "    ok ([date])" {}
            set ok 1
        }
    }
    after $cadence [list scrute $proxy $port $ok $cadence]
}

scrute $PROXY $PORT 1 $CADENCE

vwait pourToujours


