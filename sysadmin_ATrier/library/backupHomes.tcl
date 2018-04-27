#!/home/Tcl/bin/tclsh

# crée les tableaux 

set Externe {}
set Machine {}
set Actif {}
set Clos {}
set Prog {}
set NonCommente {}
set Autre {}
set S1 {}
set Obsolete {}
set Tempo {}

set auto_home [exec /usr/bin/niscat auto_home.org_dir]
set auto_home [split $auto_home "\n"]

foreach ligne $auto_home {
    set i [string first "#" $ligne]
    if {$i < 0} {
        lappend NonCommente $ligne
    } else {
        set comment [string range $ligne [expr $i+1] end]
        set comment [string trim $comment]
        set body [string range $ligne 0 [expr $i-1]]
        set body [string trim $body]
        switch $comment {
            ACTIF {lappend Actif $body}
            CLOS {lappend Clos $body}
            PROG {lappend Prog $body}
            EXTERNE {lappend Externe $body}
            OBSOLETE {lappend Obsolete $body}
            MACHINE {lappend Machine $body}
            TEMPO {lappend Tempo $body}
            S1 {lappend S1 $body}
            default {lappend Autre $ligne}
        }
    }
}



# on part d'une liste {n1 machine1:/path1} {n2 machine2:/path2}
# on initialise le tableau n1 -> machine1 path1
#                          n2 -> machine2} path2
proc splitAutoHomeInTable {Tableau Liste} {
    upvar $Tableau tableau 
    foreach a [array names tableau] {
        unset tableau($a)
    } 
    foreach ligne $Liste {
        set elems [split $ligne]
        if {[llength $elems] != 2} {
            puts stderr "DANGER : [llength $elems] éléments (au lieu de 2) pour $ligne"
        }
        set qui [lindex $elems 0]
        set ou [lindex $elems 1]
        set ou [split $ou ":"]
        if {[llength $ou] != 2} {
          puts stderr "DANGER : path incorrect : $ligne"
        }
        set tableau($qui) $ou 
    }
}


set LEVEL 0
set DUMP "/usr/sbin/ufsdump"
set PRINT "rsh fico lp -o nobanner -d BatK"
set FORME "/usr/openwin/bin/mp -lo"
# autorisés : 0 0b 0n 0bn 0l 0lb 0ln 0lbn 0m 0mb 0mn 0mbn
set TAPE "/dev/rmt/0mn"
set DUMPOP "$DUMP ${LEVEL}dsbfu 54000 13000 126"
set SERVEUR fico6

 


proc sauve {TableArg names} {
    upvar $TableArg Table
    foreach qui $names {
        global numero DUMPOP SERVEUR TAPE log
        incr numero
        set ou $Table($qui)
        set machine [lindex $ou 0]
        set path [lindex $ou 1]
        puts "$numero -> $qui $machine $path"
        puts "rsh -n $machine $DUMPOP ${SERVEUR}:${TAPE} $path"
        set err [catch {exec rsh -n $machine $DUMPOP ${SERVEUR}:${TAPE} $path} messages]
        puts "messages = $messages"
        puts "err = $err"
        set lmess [split $messages "\n"]
        if {![string match {  DUMP: DUMP IS DONE} [lindex $lmess end] ]} {
            puts $log "ERREUR -> $qui $machine $path (status = $err)"
            puts $log $messages
            incr numero -1
        } else {
            puts $log "$numero -> $qui $machine $path (status = $err)"
            foreach l $lmess {
                if {[string match {  DUMP: Date of this*} $l]} {
                    puts $log $l
                } elseif {[string match {    DUMP: Dumping*} $l]} {
                    puts $log $l
#                } elseif {[string match {  DUMP:*blocks*} $l]} {
                } elseif {[regexp {DUMP: [0-9]+ blocks} $l]} {
                    puts $log $l
                }
            }
            puts $log {  DUMP: DUMP IS DONE}
        }
        flush $log
    }
}

proc sauvetout Liste {
    set Table(dummy) {}
    splitAutoHomeInTable Table $Liste
    set names [lsort [array names Table]]
    sauve Table $names
}

set dada [exec /usr/bin/date +%y%m%d]
set log [open /home/logs/backup.$dada a]



puts $log {Les numéros de fichier sur bande démarrent à 1.
Pour récupérer les fichiers Numéro1 et Numéro2, on peut utiliser
	# /usr/sbin/ufsrestore ifs fico6:/dev/rmt/0mn Numéro1
puis
	# /usr/sbin/ufsrestore ifs fico6:/dev/rmt/0mn Numéro2-Numéro1
mais cela ne marche pas en arrière.
Le mieux est
	# /usr/bin/rsh -n fico6 mt -f /dev/rmt/0mn asf Numéro1
	# /usr/sbin/ufsrestore if fico6:/dev/rmt/0mn
	# /usr/bin/rsh -n fico6 mt -f /dev/rmt/0mn asf Numéro2
	# /usr/sbin/ufsrestore if fico6:/dev/rmt/0mn
Bien qu'il soit évidemment préférable d'aller dans un ordre croissant,
l'exabyte retrouve très vite les fichiers.
} 
flush $log

set numero 0
puts "rsh -n $SERVEUR mt -f $TAPE rewind"
exec rsh -n $SERVEUR mt -f $TAPE rewind
sauvetout $Actif
sauvetout {{/usr/local sbl3:/usr/local}}
sauvetout $Prog

close $log
