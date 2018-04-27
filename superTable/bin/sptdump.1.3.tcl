#!/bin/sh
# La ligne "exec ..." est un commentaire pour tclsh, pas pour /bin/sh
# Normalement, "Bourne shell" trouve "tclsh" si celui-ci est bien installé
# (dans un des répertoires $PATH)
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


# A METTRE EN BIBLI
# ~/A/fidev/Tcl/sup*/bin/sptdump.1.3.tcl -filter "noParano MD Ie {Se Sb Sc}" 13N100x100#1.spt "*" Ve Ib Ic
# 
proc noParano {sens tricol cleancolnames arrayName lList colnames} {
    upvar $arrayName a
    if {$sens == "M"} {
        set M 1
        set D 0
    } elseif {$sens == "D"} {
        set M 0
        set D 1
    } elseif {$sens == "MD"} {
        set M 1
        set D 1
    } else {
        return -code error "sens should be \"M\", \"D\" or \"MD\""
    }

    # Construction des lignes de données gnuplot à partir du tableau "a"

    # nettoyage des lignes

    set goodLines [list]

    foreach ili $lList {
	set Ok 1
	foreach cc $cleancolnames {
            set case [list $ili $cc]
	    if {[info exists a($case)] && $a($case) != {}} {
		set Ok 0
		break
	    }
	}
	if {$Ok} {
            lappend goodLines $ili
        }
    }

    # montée/descente

    set nils [list]
    set max 1e99
    catch {unset ilmax}
    set ii 0

    foreach il $goodLines {
        set ie [superTable::getCell a $il $tricol]
        if {$ie < $max} {
            set max $ie
            set ilmax $ii
        } elseif {$ie == $max} {
            lappend ilmax $ii
        }
        lappend nils $il
        incr ii
    }

    if {![info exists ilmax]} {
        return -code error "Warning: pas d'ilmax"
    }
    if {[llength $ilmax] != 2} {
        puts stderr "Warning: extrema n'est pas en 2 points : $ilmax"
    } 

    set ilsM [lrange $nils 0 [lindex $ilmax 0]]
    set ilsD [lrange $nils [lindex $ilmax end] end]

    set nils [list]

    # Nettoyage des mesures paranos
    
    if {$M} {
        set lastIe 1e99
        foreach il $ilsM {
            set ie [superTable::getCell a $il $tricol]
            if {$ie < $lastIe} {
                lappend nils $il
                set lastIe $ie
            }
        }
    }

    if {$D} {
        set lastIe -1e99
        foreach il $ilsD {
            if {[superTable::getCell a $il $tricol] > $lastIe} {
                lappend nils $il
                set lastIe $ie
            }
        }
    }
    
    set datas ""

    append datas #
    append datas [uplevel {set nameOfTable}]
    append datas \n
    append datas #
    set first 1
    foreach col $colnames {
        if {!$first} {
            append datas \t
        } else {
            set first 0
        }
        append datas $col
    }    
    append datas \n
    
    foreach ili $nils {
        set first 1
        foreach col $colnames {
            set case [list $ili $col]
            if {[info exists a($case)]} {
                set val $a($case)
            } else {
                set val "nc"
            }
            if {!$first} {
                append datas \t
            } else {
                set first 0
            }
            append datas $val
        }
        append datas \n
    }
    # puts "datas =\n $datas"
    return $datas
}


  # sans argument : revoie la syntaxe
    if {$argc < 1} {
        puts stderr "- Usage : $argv0 \[-filter \"noParano MD Ie {Se Sb Sc}\"\] \[fichier.spt \[nomDeSupertable \[col1 ... coln\]\]\]"
        puts stderr "- nomDeSupertable peut être approché (globing)"
        puts stderr "- Si le fichier ne contient qu'une superTable,"
        puts stderr "  on peut remplacer nomDeSupertable par \"*\" (écrire les guillemets pour shunter l'interpréteur de commande Unix)"
        exit 1
    }

    set argums $argv

    if {[lindex $argums 0] == "-filter"} {
        set filter [lindex $argums 1]
        set argums [lrange $argums 2 end]
    } else {
        set filter {}
    }

  # nom du fichier à lire
    set nameOfSptFile [lindex $argums 0]

  # sans autre argument
    if {$argc == 1} {
        set lignes [::superTable::getLines $nameOfSptFile] ;# lignes
        set tlimits [::superTable::marqueTables $lignes]   ;# index des lignes @@
        set noms {}                                    ;# liste des noms
        foreach i $tlimits {
          # on supprime @@ de la ligne et on l'ajoute à la liste noms
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


  # sans arguments noms de colonnes
    if {$cols == {}} {
      # impression d'une double liste : colonnes communes et non communes
        puts [lrange $iii 1 2]
        exit 0
    } 

    if {$filter != {}} {
        set ret [eval $filter [list a [lindex $iii 0] $cols]]
        puts $ret
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
