#!/bin/sh
# The next line is executed by /bin/sh, but not tcl \
exec tclsh "$0" ${1+"$@"}

##
## scrutImap.29.tcl 2003-11-14 (FP)
## Changement de boite 
## scrutImap.31.tcl 2005-11-21 (FP)
## Changement de MTA, plus de tri en amont -> changement de boite
## Fonctionnement différent : réponses différentes, nécessité de refaire SELECT à chaque fois

## reste à traiter les erreurs
##

puts stderr "Variante=./scrutImap.31.tcl >| ~/Z/s.log 2>&1"

set IMAP imap.lpn.prive
# set BOITE Mail/m-l
set BOITE Inbox
set RECONNECT_TIMEOUT [expr {15*60*1000}]
set SCRUT_PERIOD [expr {20*1000}]
# set SCRUT_PERIOD [expr {5*1000}]
set SOIR 19:00
set MATIN 09:00
set PROGRAMME(30) ./casaNetLabo.30.tcl


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
    puts stderr "\nImap: \"$line\""
    lappend MESSAGES($STATUS(message)) $line
    if {$STATUS(imap) == "connected?"} {
        if {[regexp {^\* OK.*$} $line]} {
            set STATUS(message) "${STATUS(message)} OK"
            set STATUS(imap) non-authenticated
	}
        return
    }

    if {![regexp {^(.* OK)(.*)$} $STATUS(message) tout iok reste]} {
        # Il faudrait gérer "* BAD"
        if {[regexp "^$STATUS(message) OK" $line]} {
            set STATUS(message) "${STATUS(message)} OK"
        }
        return
    } else {
	puts stderr "iok = \"$iok\, reste = \"$reste\""
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
    global STATUS IMAPSOCK BOITE
    itagIncr
    putsImap "$STATUS(message) SELECT $BOITE"
    set STATUS(imap) selected?
}

proc searchImap {} {
    global STATUS IMAPSOCK
    itagIncr
# RECENT UNSEEN
    putsImap "$STATUS(message) SEARCH SUBJECT maison-lpn"
    set STATUS(imap) messages?
}

proc fetchImap {} {
    global STATUS IMAPSOCK
    itagIncr
    putsImap "$STATUS(message) FETCH $STATUS(last) BODY\[HEADER.FIELDS \(DATE FROM SUBJECT\)\]"
    set STATUS(imap) lastMessage?
}


set HELP(msecPartiDuLabo) {
    Permet de gérer le conflit d'accès à INBOX avec Netscape, dtmail ou autre :
    retourne dans combien de msec on sera parti du labo

    obsolète depuis qu'on travaille sur une sous-boite
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
set STATUS(last) -2 ;# début

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
            # set attente [msecPartiDuLabo]
	    set attente 0
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
		puts stderr "\$STATUS(message) = \"$STATUS(message)\""
            if {[string match "* OK" $STATUS(message)]} {
		puts stderr "string match * OK"
                set tag [lindex $STATUS(message) 0]
#                if {[string compare "$tag OK LOGIN Ok." [lindex $MESSAGES($tag) end]]} {
#                    return -code error "Désynchronisation tag = \"$tag\", réponse = \"[lindex $MESSAGES($tag) end]\""
#                }
                set $STATUS(imap) authenticated
                after 0 {
                    selectImap
                }
            }
        }
        "selected?" {
            if {[string match "* OK" $STATUS(message)]} {
                set tag [lindex $STATUS(message) 0]
                if {[string compare "$tag OK \[READ-WRITE\] Ok" [lindex $MESSAGES($tag) end]]} {
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
                if {[string compare "$tag OK SEARCH done." [lindex $MESSAGES($tag) end]]} {
                    return -code error "Désynchronisation tag = $tag, réponse = [lindex $MESSAGES($tag) end]"
                }
                set results [lindex $MESSAGES($tag) end-1]
		set riennouveau true
                if {[lindex $results 0] == "*" && [lindex $results 1] == "SEARCH"} {
		    if {[llength $results] < 3} {
			set STATUS(last) -1
		    } else {
			puts stderr "\$results = \"$results\""
			set dernier [lindex $results end]
			if {$STATUS(last) == -2} {
			    # démarrage du programme
			    set STATUS(last) $dernier
			} elseif {$dernier > $STATUS(last)} {
			    set STATUS(last) $dernier
			    set riennouveau false
			}
		    }
		}
		if {$riennouveau} {
                    # after $SCRUT_PERIOD searchImap
		    set $STATUS(imap) authenticated
		    after $SCRUT_PERIOD {
			selectImap
		    }
                } else {
                    set STATUS(messageList) $results ;# utile ?
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
                        if {$programme == 30} {
                            set maisonHost [lindex $HEADERS(subject) end-2]
                            set machineSSH [lindex $HEADERS(subject) end-1]
                            puts stderr "ON DEMARRE vers $maisonHost [list $PROGRAMME($programme) $maisonHost $machineSSH 22]"
                            set err [catch {exec $PROGRAMME($programme) $maisonHost $machineSSH 22 << $CASANET_PASS &} blabla]
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
