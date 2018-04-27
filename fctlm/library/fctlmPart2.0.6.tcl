# RCS: @(#) $Id: fctlm.0.5.tcl,v 1.3 2002/06/25 08:42:53 fab Exp $

# 1 juin 2001 (FP) Passage à blasObj\
# 20 juillet 2001 (FP) blasObj 0.2 et slatec 0.2

puts stderr {PAS FINI, RECODER AVEC port2 au lieu de minpack}

package require fidev
package require superTable 1.5
package require blasObj 0.2
package require slatec 0.2
package require listUtils 1.1

fidev_load ../src/libfctlm fctlm

namespace eval ::fctlm {}

# retourne une liste "v0 i0 v1 i1 ..."
proc ::fctlm::viListFromSpt {nameOfSptFile nameOfTableName} {
    upvar $nameOfTableName nameOfTable
    set iii [::superTable::fileToTable a $nameOfSptFile nameOfTable {}]
    set vi [list]
    foreach index [lindex $iii 0] {
        lappend vi $a([list $index V])
        lappend vi $a([list $index I])
    }
    return $vi
}

# 

# retourne le courant absolu max d'une liste "v0 i0 v1 i1 ..."
proc ::fctlm::imax {vi} {
    set imax 0.0
    foreach {tension courant} $vi {
        set iabs [expr {abs($courant)}]
        if {$iabs > $imax} {
            set imax $iabs
        }
    }
    return $imax
}

#
proc ::fctlm::maxAbsFromList {iList} {
    set imax 0.0
    foreach i $iList {
        set iabs [expr {abs($i)}]
        if {$iabs > $imax} {
            set imax $iabs
        }
    }
    return $imax
}

# retourne une sous-liste des courants <= imax
proc ::fctlm::sublistWithImax {vi imax} {
    set sublist [list]
    foreach {tension courant} $vi {
        if {abs($courant) <= $imax} {
            lappend sublist $tension $courant
        }
    }
    return $sublist
}







proc ::fctlm::triCol3 {arrayName l1 l2} {
    upvar $arrayName array
    set i1 [list $l1 NumDis]
    set i2 [list $l2 NumDis]
    set c [expr {$array($i1) - $array($i2)}]
    if {$c < 0} {
        return -1
    } elseif {$c > 0} {
        return 1
    }

    set e1 $array([list $l1 BLOC])
    set e2 $array([list $l2 BLOC])
    if {$array([list $l1 TYPE]) == "CC"} {
	set c [string compare [string index $e1 end] [string index $e2 end]]
	if {$c != 0} {
	    return $c
	}
    }
    set c [string compare $e1 $e2]
    if {$c != 0} {
        return $c
    }

    set i1 [list $l1 ETAT]
    set i2 [list $l2 ETAT]
    set c [string compare $array($i1) $array($i2)]
    if {$c != 0} {
        return $c
    }

    return 0
}

proc ::fctlm::triColTB {arrayName l1 l2} {
    upvar $arrayName array
    set i1 [list $l1 TYPE]
    set i2 [list $l2 TYPE]
    set c [string compare $array($i1) $array($i2)]
    if {$c != 0} {
        return $c
    }
    set i1 [list $l1 BLOC]
    set i2 [list $l2 BLOC]
    set c [string compare $array($i1) $array($i2)]
    if {$c != 0} {
        return $c
    }
    return 0
}

proc ::fctlm::bilan {geomSpt} {
    set lignes [::superTable::getLines $geomSpt]
    unset geomSpt

    set debuts [superTable::marqueTables $lignes]
    set nomsDesTables [superTable::nomsDesTables $lignes $debuts]

    set ndt [list]
    foreach n $nomsDesTables {
	if {[string match "*qualité*" $n]} {
	    lappend ndt $n
	}
    }
    unset nomsDesTables

    foreach n $ndt {
	set bloc [lindex $n end]
	if {[info exists BLOCSVUS($bloc)]} {
	    error "ERREUR: Bloc $bloc identifié 2 fois"
	}
	set BLOCSVUS($bloc) {}
	set nameOfTable $n
	set range [superTable::linesOfTable $lignes $debuts nameOfTable]
	superTable::readTable $lignes $range A TYPE
	unset range nameOfTable
	foreach e [array names A] {
	    set AGLOB([list [list [lindex $e 0] $bloc] [lindex $e 1]]) $A($e)
	}
	unset e A bloc
    }
    unset n ndt BLOCSVUS debuts lignes

    set ils {}
    foreach spt [glob fit_fctlm_resistances/mesures_\[fs\]ctlm_*.spt] {
	set nameOfTable "Résistances Mesurées*"
	set indexes [superTable::fileToTable A [file join $spt] nameOfTable {TYPE ETAT BLOC}]
	unset nameOfTable
	set ils [concat $ils [lindex $indexes 0]]
	unset indexes
    }
    unset spt

    foreach l $ils {
	set bloc [lindex $l 2]
	set d [string first # $bloc]
	if {$d > 0} {
	    incr d -1
	    set bloc [string range $bloc 0 $d]
	}
	set A([list $l OK]) $AGLOB([list [list [lindex $l 0] $bloc] OK])
    }
    unset bloc d l ils AGLOB

    set liout [superTable::createLinesFromArray A ""\
		     -sortLines {::fctlm::triCol3}\
		     -orderOfCols {TYPE NumDis BLOC ETAT R DeltaR Valide OK}];#
    foreach l $liout {
	puts stderr $l
    }
    unset l liout


    unset A
    if {[llength [info locals]] != 0} {
	error [list reste [info locals]]
    }
}

package provide fctlmPart2 0.6
