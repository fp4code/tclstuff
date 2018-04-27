#!/bin/sh
# The next line is executed by /bin/sh, but not tcl \
exec tclsh "$0" ${1+"$@"}

##
## scrutImap.1.0.tcl 22 mars 200 (FP)
##
## reste à traiter les erreurs
##

puts stderr "Variante=./scrutImap.27.tcl >| ~/Z/s.log 2>&1"

set SCRUT_PERIOD [expr {5*1000}]
set PROGRAMME(26) ./casaNetLabo.26.tcl
set PROGRAMME(27) ./casaNetLabo.27.tcl

if {![string match ./* $argv0]} {
    puts stderr "Se placer dans le répertoire contenant le programme" 
    exit 1
}

#
# redéfinir la procédure "bgerror" permet d'afficher les erreurs asynchrones
#

proc bgerror {message} {
    global errorInfo
    puts stderr "ERREUR : $errorInfo"
}

#
#  
#

proc scrute {SCRUT_PERIOD} {
    set fichiers [glob -nocomplain \[1-9\]*]
    if {[catch {lsort -integer $fichiers} m]} {
	return -code error "scrute -> $m"
    }
    set last [lindex $m end]
    

    after $SCRUT_PERIOD [list scrute $SCRUT_PERIOD]
}







                    catch {unset HEADERS}
                    foreach line [lrange $MESSAGES($tag) 1 3] {
                        if {![regexp {^([^:]+): (.*)$} $line tout left right]} {
                            puts stderr "CANNOT REGEXP \"$line\""
                            puts stderr "MESSAGES($tag) =  $MESSAGES($tag)"
                        } else {
                            set HEADERS([string tolower $left]) $right
                        }
                    }
                    parray HEADERS
                    puts stderr {}
                    if {[info exists HEADERS(subject)]} {
                        set programme [lindex $HEADERS(subject) end]
                        if {$programme == 27} {
                            set maisonHost [lindex $HEADERS(subject) end-2]
                            set machineSSH [lindex $HEADERS(subject) end-1]
                            puts stderr "ON DEMARRE vers $maisonHost"
                            set err [catch {exec $PROGRAMME($programme) $maisonHost $machineSSH << $CASANET_PASS &} blabla]
                            if {$err} {
                                puts stderr "ERREUR de démarrage \"$blabla\""
                            }
                        } elseif {![info exists PROGRAMME($programme)]} {
                            puts stderr "========== programme \"$programme\" inexistant =========="
                        } else {
                            set maisonHost [lindex $HEADERS(subject) end-1]
                            puts stderr "ON DEMARRE vers $maisonHost"
                            set err [catch {exec $PROGRAMME($programme) $maisonHost << $CASANET_PASS &} blabla]
                            if {$err} {
                                puts stderr "ERREUR de démarrage \"$blabla\""
                            }
                        }
                    } else {
                        puts stderr "ERREUR ERREUR ERREUR ERREUR ERREUR ERREUR ERREUR ERREUR"
                    }
                    set STATUS(imap) messages?
                    after $SCRUT_PERIOD searchImap
                }
            }
        }
    }
    vwait STATUS
}

