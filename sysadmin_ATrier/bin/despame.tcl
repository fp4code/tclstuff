#!/prog/Tcl/bin/tclsh

# Pour trier une liste de listes par la longueur
proc compareLength {l1 l2} {
    return [expr {[llength $l1] - [llength $l2]}]
}

proc despame {} {

    # du blabla pour sysadmin
    set blabla [clock format [clock seconds]]
    append blabla "\narret de sendmail\n"

    # arrêt de sendmail
    catch {exec /etc/init.d/sendmail stop} message
    append blabla "$message\n"
    
    # les fichiers en attente sont dans /var/spool/mqueue
    cd /var/spool/mqueue

    # les fichiers "de communication"
    set fichiers [glob qf*]
    
    foreach fichier $fichiers {

        # on lit les lignes
        set f [open $fichier r]
        set lignes [split [read -nonewline $f] \n]
        close $f

        # qf$num est le fichier de communication
        # df$num est le contenu du message
        set num [string range $fichier 2 end]

        # extraction de l'expéditeur et du sujet
        foreach l $lignes {
            if {[string index $l 0] == "S"} {
                set qui [string range $l 1 end]
                # puts [list $l $qui]
                lappend NUM($qui) $num
            } elseif {[string range $l 0 9] == "HSubject: "} {
                set SUJET($num) [string range $l 10 end]
            }
        }

        # pour faciliter la suite
        if {![info exists SUJET($num)]} {
            set SUJET($num) {(pas de sujet)}
        }
    }
    
    puts $blabla


    # tri des expéditeurs par nombre de message
    set quis [lsort -command compareLength [array names NUM]]

    # blabla
    append blabla "Travail effectue dans l2m:/var/spool/mqueue\n"

    # balayage sur les expéditeurs
    foreach qui $quis {

        puts $qui

        # nombre de messages
        set nombre [llength $NUM($qui)]

        # blabla
        append blabla "\n##########\n$qui -> $nombre"

        ##############################################################################
        # CODE DUR - CODE DUR - CODE DUR - CODE DUR - CODE DUR - CODE DUR - CODE DUR #
        ##############################################################################

        # spammeurs avérés: adresses connues
        #                   plus de 50 messages

        # expéditeurs locaux: message retourné à l'expéditeur sur u5info

        if {\
                [string match *@indiatimes.com> $qui] ||\
                [string match *@happster.com>   $qui] ||\
                $nombre > 50} {
            
            # on efface tous les fichiers
            foreach num $NUM($qui) {
                eval file delete [glob ??$num]
            }
            # on le supprime du tableau (pas utile dans Version 1.0)
            unset NUM($qui)
            # blabla
            append blabla " supprime d'office" 
        } elseif {$qui == "Mailer-Daemon"} {
            foreach num $NUM($qui) {
                append blabla "\n envoi sysadmin@u5info [retour sysadmin@u5info $num $SUJET($num)]"
                eval file delete [glob ??$num]
            }
            unset NUM($qui)            
        } elseif {![string match *@* $qui] && [string length $qui] <= 8} {
            foreach num $NUM($qui) {
                append blabla "\n envoi ${qui}@u5info [retour ${qui}@u5info $num $SUJET($num)]"
                eval file delete [glob ??$num]
            }
            unset NUM($qui)
        } else {
            append blabla " on ne fait rien"
        }
    }

    # blabla
    append blabla "\n[clock format [clock seconds]]\n"
    append blabla "redemarrage de sendmail\n"

    # redémarrage de sendmail
    catch {exec /etc/init.d/sendmail start} message
    append blabla "$message\n"

    # envoi du blabla à sysadmin
    exec /usr/bin/mailx -s "Despame" -c fab@u5info sysadmin@u5info << $blabla
}

# retour du message df$num à $dest
proc retour {dest num sujet} {
    catch {exec /usr/bin/mailx -s "Non transmis (il fallait etre sur u5info): $sujet" $dest < df$num} message
    return $message
}

# procédure auto-scrutatrice au rythme de 1/60s
# elle lance "despame" si la queue contient plus de 150 messages 
proc veille {} {
    cd /var/spool/mqueue
    if {[llength [glob -nocomplain *]] > 150} {
        puts "despame !!"
        despame
    } else {
        puts OK
    }
    after 60000 veille
}

set fin 0
veille

# truc pour lancer la scrutation sans fin (nécessaire avec tclsh, pas avec wish)
vwait fin

