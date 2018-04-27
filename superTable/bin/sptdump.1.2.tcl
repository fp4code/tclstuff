#!/bin/sh
# La ligne "exec ..." est un commentaire pour tclsh, pas pour /bin/sh
# Normalement, "Bourne shell" trouve "tclsh" si celui-ci est bien install�
# (dans un des r�pertoires $PATH)
# \
exec tclsh "$0" ${1+"$@"}

# mettre dans ~/.tclshrc la ligne sans "set rien {" ni "}"
set rien {
    set fidev_tclDir /home/scollin/A/fidev/Tcl
    source $fidev_tclDir/pkgIndex.tcl
    package provide fidev 1.1
    set env(FIDEV_EXPERIMENTAL) /home/scollin/C/fidev-unknown-Linux-2.2.12-20-cc-stable/lib
}

package require fidev
package require superTable 1.5 

  # sans argument : revoie la syntaxe
    if {$argc < 1} {
        puts stderr "- Usage : $argv0 \[-filter \"noparano MD\"\]\[fichier.spt \[nomDeSupertable \[col1 ... coln\]\]\]"
        puts stderr "- nomDeSupertable peut �tre approch� (globing)"
        puts stderr "- Si le fichier ne contient qu'une superTable,"
        puts stderr "  on peut remplacer nomDeSupertable par \"*\" (�crire les guillemets pour shunter l'interpr�teur de commande Unix)"
        exit 1
    }

    set argums $argv

    if {[lindex $argums 0] == "-filter"} {
        set filter [lindex $argums 1]
        set argums [lrange $argums 2 end]
    } else {
        set filter {}
    }

  # nom du fichier � lire
    set nameOfSptFile [lindex $argums 0]

  # sans autre argument
    if {$argc == 1} {
        set lignes [::superTable::getLines $nameOfSptFile] ;# lignes
        set tlimits [::superTable::marqueTables $lignes]   ;# index des lignes @@
        set noms {}                                    ;# liste des noms
        foreach i $tlimits {
          # on supprime @@ de la ligne et on l'ajoute � la liste noms
            lappend noms [string range [lindex $lignes $i] 2 end]
        }
          # impression des noms de superTables
        puts $noms
        exit 0
    }

    set nameOfTable [lindex $argums 1]
    set cols [lrange $argums 2 end]

  # lecture de la superTable dans le tableau a
  # iii contient une triple liste
    
    set iii [::superTable::fileToTable a $nameOfSptFile nameOfTable {}]

    if {$filter != {}} {
        
    }


  # sans arguments noms de colonnes
    if {$cols == {}} {
      # impression d'une double liste : colonnes communes et non communes
        puts [lrange $iii 1 2]
        exit 0
    } 

  # avec arguments noms de colonnes : pour chaque index de ligne
    foreach i [lindex $iii 0] {
        set first 1
      # pour chaque colonne
        foreach t $cols {
            if {$first} {
                set first 0
            } else {
                puts -nonewline "\t"
            }
          # impression de la colonne
            puts -nonewline $a([list $i $t])
        }
        puts {}
    }

    exit 0
