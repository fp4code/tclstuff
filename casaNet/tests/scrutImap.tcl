#!/bin/sh
# The next line is executed by /bin/sh, but not tcl \
exec tclsh "$0" ${1+"$@"}

##
## labo21.tcl
##
## succédané de "telnet imap imap"
## reconnecte lorsque la liaison est perdue
## 
## reste à traiter les erreurs
##


set IMAP imap.lpn.prive
set RECONNECT_TIMEOUT [expr {15*60*1000}]
set PERIOD [expr {30*1000}]
set SOIR 19:00
set MATIN 09:00
set MESSAGES(dummy) {}
set STATUS(message) notag
set PROGRAMME(13) ./labo13.tcl
set PROGRAMME(23) ./labo23.tcl

puts -nonewline stderr "login/mot_imap : "
set lopass [gets stdin]
set lopass [split $lopass /]
set LOGIN [lindex $lopass 0]
set PASS [lindex $lopass 1]

puts -nonewline stderr "mot de liaison : "
set PASS2 [gets stdin]

set STATUS(imap) unconnected

proc bgerror {message} {
    global errorInfo
    puts stderr "ERROR : $errorInfo"
}
proc readImap {} {
    global STATUS IMAPSOCK MESSAGES
    if [eof $IMAPSOCK] {
        close $IMAPSOCK
        puts stderr "Imap is dead"
        set STATUS(imap) disconnected
    } else {
        set l [gets $IMAPSOCK]
        puts stdout "Imap: \"$l\""
        lappend MESSAGES($STATUS(message)) $l
        if {$STATUS(imap) == "connected?"} {
            if {[string match "\* OK *" $l]} {
                set STATUS(message) "${STATUS(message)} OK"
                set STATUS(imap) non-authenticated
            }
        } elseif {![string match "* OK" $STATUS(message)]} {
            if {[regexp "^$STATUS(message) OK" $l]} {
                set STATUS(message) "${STATUS(message)} OK"
            }
        }
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

proc itagIncr {} {
    global ITAG STATUS
    incr ITAG
    set STATUS(message) [format %07x $ITAG]
}

proc authenticateImap {} {
    global STATUS IMAPSOCK LOGIN PASS
    itagIncr
    putsImap "$STATUS(message) LOGIN $LOGIN $PASS"
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


while 1 {
    puts stderr {}
    puts stderr [clock format [clock seconds]]
    puts stderr {}
    parray STATUS
    puts stderr {}

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
                if {[string compare "$tag OK LOGIN completed" [lindex $MESSAGES($tag) end]]} {
                    return -code error "Désynchronisation tag = $tag, réponse = [lindex $MESSAGES($tag) end]"
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
                    after $PERIOD searchImap
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
                        } else {
                            set HEADERS([string tolower $left]) $right
                        }
                    }
                    parray HEADERS
                    puts stderr {}
                    set maisonHost [lindex $HEADERS(subject) end-1]
                    set programme [lindex $HEADERS(subject) end]
                    puts stderr "ON DEMARRE vers $maisonHost"
                    if {![info exists PROGRAMME($programme)]} {
                        puts stderr "========== programme \"$programme\" inexistant =========="
                    } else {
                        exec $PROGRAMME($programme) $maisonHost << $PASS2 &
                    }
                    set STATUS(imap) messages?
                    after $PERIOD searchImap
                }
            }
        }
    }
    vwait STATUS
}
