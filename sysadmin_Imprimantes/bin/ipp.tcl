#!/prog/Tcl/bin/tclsh

if {$argc < 1} {
    puts stderr "usage :      $0 imprimante fichiers"
    puts stderr "   ou      \"qqchose qui sort du postscript\" | $0 imprimante"
    exit 1
}

#    puts stderr "$argv0 $argv"

set IMPRIMANTE [lindex $argv 0]

set MAINSERVER    u5fico

if {![info exists SERVEUR($IMPRIMANTE)]} {
    set SERVEUR($IMPRIMANTE) $MAINSERVER
#    puts stderr "L'imprimante $IMPRIMANTE n'est pas autorisée ou n'existe pas"
#    puts stderr "Sont autorisées : [lsort [array names SERVEUR]]"
#    after 3000 ;# à revoir (permet que la fenêtre pseudo-lp affiche ce message)
#    exit 2
}

set PAPIF "/prog/cap60/cap60/bin/papif \
           -P $IMPRIMANTE -n $env(USER) -h [info hostname]"

# Options a rajouter pour avoir des informations de debug (cf. man papif) :
#           -da -dd -dn -dp -ds -dk
# ne pas mettre -dv (ecrase les autres options)


if {[info hostname] != $SERVEUR($IMPRIMANTE)} {
    set PAPIF "/usr/bin/rsh $SERVEUR($IMPRIMANTE) $PAPIF"
}

puts stdout "PAPIF=$PAPIF"

if {$argc == 1} {
    catch {eval exec $PAPIF <@ stdin >&@ stdout} erreur
    puts $erreur
} else {
   # utiliser open plutot que cat
    set bubu {}
    foreach f [lrange $argv 1 end] {
        set err [catch {open $f r} fifi]
        if {$err} {
            puts stderr "Erreur sur le fichier $f : $fifi"        
        } else {
            set err [catch {read $fifi} bufi]
            if {$err} {
                puts stderr "Erreur sur le fichier $f : $bufi"        
            } else {
                append bubu $bufi
            }
            close $fifi
        }
    }
#    puts OK
#    puts [string length $bubu]
    # ça merdoie en laissant des defunct (a voir)
    catch {eval exec $PAPIF << [list $bubu] >&@ stdout} erreur
    puts $erreur
}
exit 0
