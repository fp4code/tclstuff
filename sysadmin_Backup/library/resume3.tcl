#!/usr/local/bin/tclsh

if {$argc != 1} {
    error "Syntaxe : $argv0 fichier"
}

set fichier [lindex $argv 0]

set err [catch {open $fichier r} f]
if {$err} {
    error "$fichier : $f"
}

set lignes [read -nonewline $f]
close $f
set lignes [split $lignes \n]

set iligne 0
set numero 0
set trouve 0

while {1} {
    incr iligne
    if {$iligne >= [llength $lignes]} {
        break
    }
    set l [lindex $lignes $iligne]
    if {[string match "0 -> *" $l]} {
        set trouve 1
        break
    }
}

if {!$trouve} {
    error "ligne \"0 -> ...\" non trouvée"
}

set fini 0
set MTOT 0.
set LISTE [list]

while {!$fini} {

    if {![string match "$numero -> *" $l]} {
        error "ligne $iligne non \"$numero -> ...\" : $l"
    }

    set nom [lindex $l 2] 
    set ou [lindex $l 3] 
    set quoi [lindex $l 4]

    set lastil $iligne
    while {1} {
        incr iligne
        if {$iligne >= [llength $lignes]} {
            set fini 1
            break
        }
        set l [lindex $lignes $iligne]
        if {![string match "  DUMP: *" $l]} {
            break
        }
        if {[string match {  DUMP: Date of this level 0 dump: *} $l]} {
            set date [lrange $l 7 end]
            set err [catch {clock scan $date} seconds]
            if {$err} {
                error "ligne $iligne : date illisible : $date"
            }
        }
        if {[string match {  DUMP: * blocks (*) on * volume at *} $l]} {
            if {[lindex $l 2] == "blocks"} {
                set blocs [lindex $l 1]
            }
        }
    }

    if {[lindex $lignes [expr {$iligne - 1}]] != "  DUMP: DUMP IS DONE"} {
        set lastil $iligne
    } else {
        set moctets [expr {$blocs*512.e-6}]
        set MTOT [expr {$MTOT+$moctets}]
        puts -nonewline [format %3d $numero]
        puts -nonewline " [clock format $seconds -format {%Y-%m-%d %H:%M:%S}]"
        puts -nonewline " [format %8.2f $moctets]"
        puts -nonewline " $ou"
        puts -nonewline " $quoi"
        puts {}
        lappend LISTE $ou:$quoi
        set SAUVE($ou:$quoi) [list $numero $blocs $seconds]
        incr numero
    }
}

puts $MTOT

set f [open $fichier.resume w]

puts $f {Pour récupérer le fichiers $num, le mieux est
	# /usr/bin/rsh -n $SERVEUR mt -f /dev/rmt/0mn asf $num
	# /usr/sbin/ufsrestore if $SERVEUR:/dev/rmt/0mn
La première commande positionne la bande au début du fichier $num,
$num étant compté en absolu (asf = rewind + fsf).
La deuxième commande restaure le fichier courant de la bande en
interactif.
Bien qu'il soit évidemment préférable d'aller dans un ordre croissant,
l'exabyte retrouve très vite les fichiers.
}

puts $f "num       jour    heure      MB"

foreach e $LISTE {
    foreach {numero blocs seconds} $SAUVE($e) {}
    set moctets [expr {$blocs*512.e-6}]
    puts -nonewline $f [format %3d $numero]
    puts -nonewline $f " [clock format $seconds -format {%Y-%m-%d %H:%M:%S}]"
    puts -nonewline $f " [format %7.2f $moctets]"
    puts $f " $e"
}
puts $f "\nTotal = [format %8.2f $MTOT] MB"

close $f

puts "fichier $fichier.resume créé"
exec mp -lo -s $fichier.resume $fichier.resume | lp -d BatK
puts "fichier $fichier.resume imprimé"
exec cat $fichier.resume | mailx -s $fichier.resume sysadmin
puts "fichier $fichier.resume envoyé"
