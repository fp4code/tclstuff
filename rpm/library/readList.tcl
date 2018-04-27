#!/usr/local/bin/tclsh

set SEPARATEUR "================================================================"

proc interprete2 {iLigne etat l a1 a2 varName1 varName2} {
    upvar $varName1 var1
    upvar $varName2 var2
    if {![regexp "^$a1\(.*\)\[ \]*$a2\(.*\)\$" $l tout var1 var2]} {
        error "Ligne $iLigne etat \"$etat\" illisible"
    }
}

proc interprete1 {iLigne etat l a varName} {
    upvar $varName var
    if {![regexp "^$a\(.*\)\$" $l tout var]} {
        error "Ligne $iLigne etat \"$etat\" illisible"
    }
}

proc readList {fichier} {
    global SEPARATEUR
    
    global Veulent
    global Fichiers
    
    set f [open $fichier r]
    set lignes [read -nonewline $f]
    close $f
    unset f
    set lignes [split $lignes \n]
    
    set etat SEPARATEUR
    set iLigne 0
    foreach l $lignes {
        incr iLigne
        if {$etat == "SEPARATEUR"} {
            if {$l != $SEPARATEUR} {
                error "Ligne $iLigne : attendu \"$SEPARATEUR\""
            }
            set etat RPMFILE
        } elseif {$etat == "RPMFILE"} {
            set rpmFile $l
puts $rpmFile
            set etat Divers
            set Divers [list]
        } elseif {$etat == "Divers"} {
              if {$l == "--- DOCS ---"} {
                set etat DOCS
                set DOCS [list]
            } else {
                lappend Divers $l
            }
        } elseif {$etat == "DOCS"} {
            if {$l == "--- CONFIGS ---"} {
                set etat CONFIGS
                set CONFIGS [list]
            } else {
                lappend DOCS $l
            }
        } elseif {$etat == "CONFIGS"} {
            if {$l == "--- FICHIERS ---"} {
                set etat FICHIERS
                set FICHIERS [list]
            } else {
                lappend CONFIGS $l
            }
        } elseif {$etat == "FICHIERS"} {
            if {$l == "--- SCRIPTS ---"} {
                foreach f $FICHIERS {
                    lappend Fichiers($f) $rpmFile
                }
                set etat SCRIPTS
                set SCRIPTS [list]
            } else {
                lappend FICHIERS $l
            }
        } elseif {$etat == "SCRIPTS"} {
            if {$l == "--- REQUIS ---"} {
                set etat REQUIS
                set REQUIS [list]
            } else {
                lappend SCRIPTS $l
            }
        } elseif {$etat == "REQUIS"} {
            if {$l == "" || $l == "(none)"} {
                foreach r $REQUIS {
                    lappend Veulent($r) $rpmFile
                }
                set etat SEPARATEUR
            } else {
                lappend REQUIS $l
            }
        } else {
            error "Etat \"$etat\" inconnu"
        }
    }
}

readList /prog/linux/RPMS/toutRH5.1

puts "--- Fichiers ---"

foreach f [lsort [array names Fichiers]] {
    puts $f
    foreach rpm $Fichiers($f) {
        puts "    $rpm"
    }
}

puts "--- Veulent ---"

foreach f [lsort [array names Veulent]] {
    puts $f
    foreach rpm $Veulent($f) {
        puts "    $rpm"
    }
}



set FORMATFICHIER {
echo '================================================================'
echo $1
rpm -qpi $1
echo '--- DOCS ---'
rpm -qpld $1
echo '--- CONFIGS ---'
rpm -qplc $1
echo '--- FICHIERS ---'
rpm -qpl $1
echo '--- SCRIPTS ---'
rpm -qp --scripts $1
echo '--- REQUIS ---'
rpm -qpR $1
echo ''
}
