#!/bin/sh
# The next line is executed by /bin/sh, but not tcl \
exec tclsh "$0" ${1+"$@"}

##
## scrutImap.1.0.tcl 22 mars 200 (FP)
##
## reste à traiter les erreurs
##

puts stderr "Variante=./scrutImap.26.tcl >| ~/Z/s.log 2>&1"

set IMAP imap.lpn.prive
set RECONNECT_TIMEOUT [expr {15*60*1000}]
#set SCRUT_PERIOD [expr {40*1000}]
set SCRUT_PERIOD [expr {20*1000}]
set SOIR 19:00
set MATIN 09:00
#set PROGRAMME(csh) ./labo13.tcl
#set PROGRAMME(emacs) ./laboEmacs.1.0.tcl
set PROGRAMME(26) ./casaNetLabo.26.tcl
set PROGRAMME(27) ./casaNetLabo.27.tcl

if {![string match ./* $argv0]} {
    puts stderr "Se placer dans le répertoire contenant le programme" 
    exit 1
}

set HELP(VariablesGlobales) {
    STATUS(imap) {
        état de la liaison avec le serveur Imap, un de
        disconnected
        unconnected
        connected?
        non-authenticated
        authenticated?
        authenticated
        selected?
        selected
        messages?
        lastMessage?
    }
    STATUS(message) {
        à l'émission vers Imap, successivement
        0000001, 0000002, 0000003...
        après réception de "OK" de la part de Imap, "0000001 OK"
    }
    STATUS(messageList) {
        contenu du message reçu de Imap
    }
    MESSAGES(0000001) résultat de la première communication avec Imap
    MESSAGES(0000002) résultat de la seconde communication avec Imap

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

proc readImap {} {
    global STATUS MESSAGES IMAPSOCK

    if {[eof $IMAPSOCK]} {
        close $IMAPSOCK
        puts stderr "Imap is dead"
        set STATUS(imap) disconnected
        return
    }

    set line [gets $IMAPSOCK]
    puts stderr "Imap: \"$line\""
    lappend MESSAGES($STATUS(message)) $line
    if {$STATUS(imap) == "connected?"} {
        if {[regexp {^\* OK.*$} $line]} {
            set STATUS(message) "${STATUS(message)} OK"
            set STATUS(imap) non-authenticated
        }
        return
    }

    if {![regexp {^.* OK$} $STATUS(message)]} {
        # Il faudrait gérer "* BAD"
        if {[regexp "^$STATUS(message) OK" $line]} {
            set STATUS(message) "${STATUS(message)} OK"
        }
        return
    }

}

proc putsImap {commande} {
    global IMAPSOCK
    if {[lindex $commande 1] == "LOGIN"} {
        puts stderr " moi: \"[lrange $commande 0 end-1] XXXcensuréXXX\""
    } else {
        puts stderr " moi: \"$commande\""
    }
    puts $IMAPSOCK $commande
}

proc itagIncr {} {
    global ITAG STATUS MESSAGES
    if {[catch {unset MESSAGES([lindex $STATUS(message) 0])} blabla]} {
        puts stderr $blabla
    }
    incr ITAG
    set STATUS(message) [format %07x $ITAG]
}

proc connecteImap {} {
    global STATUS IMAP IMAPSOCK ITAG
    set IMAPSOCK [socket $IMAP imap]
    fileevent $IMAPSOCK readable readImap
    fconfigure $IMAPSOCK -buffering line -blocking 0
    puts stderr "[clock format [clock seconds]] Connecté à imap !"
    set STATUS(imap) connected?
    set ITAG -1
    itagIncr
}

proc authenticateImap {} {
    global STATUS IMAPSOCK IMAP_LOGIN IMAP_PASS
    itagIncr
    putsImap "$STATUS(message) LOGIN $IMAP_LOGIN $IMAP_PASS"
    set STATUS(imap) authenticated?
}

proc selectImap {} {
    global STATUS IMAPSOCK
    itagIncr
    putsImap "$STATUS(message) SELECT INBOX"
    set STATUS(imap) selected?
}

proc searchImap {} {
    global STATUS IMAPSOCK
    itagIncr
    putsImap "$STATUS(message) SEARCH RECENT UNSEEN SUBJECT maison-lpn"
    set STATUS(imap) messages?
}

proc fetchImap {} {
    global STATUS IMAPSOCK
    itagIncr
    set message [lindex $STATUS(messageList) 0]
    putsImap "$STATUS(message) FETCH $message  BODY\[HEADER.FIELDS \(DATE FROM SUBJECT\)\]"
    set STATUS(imap) lastMessage?
}


set HELP(msecPartiDuLabo) {
    Permet de gérer le conflit d'accès à INBOX avec Netscape, dtmail ou autre :
    retourne dans combien de msec on sera parti du labo

    À envisager : travailler sur la boite en lecture seule
}

proc msecPartiDuLabo {} {
    global SOIR MATIN
    # risque de boguer vers minuit +- quelques pouillèmes
    set instant [clock seconds]
    set soir [clock scan $SOIR]
    set matin [clock scan $MATIN]
    set jour [clock format $instant -format %a]
    if {$jour == "Sat" || $jour == "Sun" || $instant < $matin || $instant > $soir} {
        return 0
    }
    return [expr {($soir - $instant)*1000}]
}


set MESSAGES(dummy) {}
set STATUS(message) notag

puts -nonewline stderr "login/mot_imap : "
set lopass [gets stdin]
set lopass [split $lopass /]
set IMAP_LOGIN [lindex $lopass 0]
set IMAP_PASS [lindex $lopass 1]

puts -nonewline stderr "mot de passe casaNet : "
set CASANET_PASS [gets stdin]

set STATUS(imap) unconnected

while 1 {
    puts stderr {}
    puts stderr [clock format [clock seconds]]
    puts stderr {}
    parray STATUS
    puts stderr {}

    # J'utilise "after 0" pour passer par la ligne "vwait STATUS"
    switch $STATUS(imap) {
        "disconnected" {
            foreach after [after info] {
                after cancel $after
            }
            set attente [msecPartiDuLabo]
            puts stderr "******* Attente, parti du labo dans $attente msec *******"
            after $attente {
                set STATUS(imap) unconnected
            }
        }
        "unconnected" {
            after 0 {
                set err [catch {connecteImap} message]
                if {$err} {
                    puts stderr $message
                    after $RECONNECT_TIMEOUT {set STATUS(imap) unconnected}
                }
            }
        }
        "connected?" {
            # traité dans readImap
        }
        "non-authenticated" {
            after 0 {
                authenticateImap
            }
        }
        "authenticated?" {
            if {[string match "* OK" $STATUS(message)]} {
                set tag [lindex $STATUS(message) 0]
#                if {[string compare "$tag OK LOGIN completed" [lindex $MESSAGES($tag) end]]} {
#                    return -code error "Désynchronisation tag = $tag, réponse = [lindex $MESSAGES($tag) end]"
#                }
                set mama "$tag OK * User $IMAP_LOGIN authenticated"
                if {![string match $mama [lindex $MESSAGES($tag) end]]} {
                    return -code error "Désynchronisation tag = $tag, réponse = [lindex $MESSAGES($tag) end],\nmama = $mama,\n[lindex $MESSAGES($tag) end]"
                }
                set $STATUS(imap) authenticated
                after 0 {
                    selectImap
                }
            }
        }
        "selected?" {
            if {[string match "* OK" $STATUS(message)]} {
                set tag [lindex $STATUS(message) 0]
                if {[string compare "$tag OK \[READ-WRITE\] SELECT completed" [lindex $MESSAGES($tag) end]]} {
                    return -code error "Désynchronisation tag = $tag, réponse = [lindex $MESSAGES($tag) end]"
                }
                set $STATUS(imap) selected
                after 0 {
                    searchImap
                }
            }
        }
        "messages?" {
            if {[string match "* OK" $STATUS(message)]} {
                set tag [lindex $STATUS(message) 0]
                if {[string compare "$tag OK SEARCH completed" [lindex $MESSAGES($tag) end]]} {
                    return -code error "Désynchronisation tag = $tag, réponse = [lindex $MESSAGES($tag) end]"
                }
                set results [lindex $MESSAGES($tag) end-1]
                if {[lindex $results 0] != "*" || [lindex $results 1] != "SEARCH" || [llength $results] < 3} {
                    after $SCRUT_PERIOD searchImap
                } else {
                    set results [lrange $results 2 end]
                    set STATUS(messageList) $results
                    after 0 {
                        fetchImap
                    }
                }
            }
        }
        "lastMessage?" {
            if {[string match "* OK" $STATUS(message)]} {
                set STATUS(messageList) [lrange $STATUS(messageList) 1 end]
                if {[llength $STATUS(messageList)] != 0} {
                    after 0 {
                        fetchImap
                    }
                } else {
                    set tag [lindex $STATUS(message) 0]
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

