#!/usr/local/bin/tclsh

# cr�e les tableaux 



set LEVEL 0
set DUMP "/usr/sbin/ufsdump"
set PRINT "rsh fico lp -o nobanner -d BatK"
set FORME "/usr/openwin/bin/mp -lo"
# autoris�s : 0 0b 0n 0bn 0l 0lb 0ln 0lbn 0m 0mb 0mn 0mbn
set TAPE "/dev/rmt/0mn"
set DUMPOP "$DUMP ${LEVEL}dsbfu 54000 13000 126"
set SERVEUR fico6

 


proc sauve {names} {
    foreach path $names {
        global numero DUMPOP SERVEUR TAPE log
        incr numero
        set machine l2m
        puts "$numero -> $machine $path"
        puts "rsh -n $machine $DUMPOP ${SERVEUR}:${TAPE} $path"
        set err [catch {eval exec $DUMPOP ${SERVEUR}:${TAPE} $path} messages]
        puts "messages = $messages"
        puts "err = $err"
        set lmess [split $messages "\n"]
        if {![string match {  DUMP: DUMP IS DONE} [lindex $lmess end] ]} {
            puts $log "ERREUR -> $machine $path (status = $err)"
            puts $log $messages
            incr numero -1
        } else {
            puts $log "$numero -> $machine $path (status = $err)"
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

set dada [exec /usr/bin/date +%y%m%d]
set log [open /home/logs/backup.$dada a]



puts $log {Les num�ros de fichier sur bande d�marrent � 1.
Pour r�cup�rer les fichiers Num�ro1 et Num�ro2, on peut utiliser
	# /usr/sbin/ufsrestore ifs fico6:/dev/rmt/0mn Num�ro1
puis
	# /usr/sbin/ufsrestore ifs fico6:/dev/rmt/0mn Num�ro2-Num�ro1
mais cela ne marche pas en arri�re.
Le mieux est
	# /usr/bin/rsh -n fico6 mt -f /dev/rmt/0mn asf Num�ro1
	# /usr/sbin/ufsrestore if fico6:/dev/rmt/0mn
	# /usr/bin/rsh -n fico6 mt -f /dev/rmt/0mn asf Num�ro2
	# /usr/sbin/ufsrestore if fico6:/dev/rmt/0mn
Bien qu'il soit �videmment pr�f�rable d'aller dans un ordre croissant,
l'exabyte retrouve tr�s vite les fichiers.
} 
flush $log

set numero 0
puts "rsh -n $SERVEUR mt -f $TAPE rewind"
exec rsh -n $SERVEUR mt -f $TAPE rewind

set reperts [glob /export/home1404/* /export/homebis/*]
set reperts [lsort $reperts]

sauve $reperts

close $log
