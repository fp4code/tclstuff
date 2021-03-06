# RCS: @(#) $Id: fctlm.0.5.tcl,v 1.4 2003/05/05 08:07:54 fab Exp $

# 1 juin 2001 (FP) Passage � blasObj\
# 20 juillet 2001 (FP) blasObj 0.2 et slatec 0.2

puts stderr {PAS FINI, RECODER AVEC port2 au lieu de minpack}

package require fidev
package require superTable 1.5
package require blasObj 0.2
package require slatec 0.2
package require listUtils 1.1

# fidev_load ../src/libfctlm.0.5 fctlm

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
proc ::fctlm::readV+IFromSpt {nameOfSptFile nameOfTableName vName iName} {
    upvar $nameOfTableName nameOfTable
    upvar $vName tension
    upvar $iName courant
    set tension [list]
    set courant [list]
    set n 0
    set iii [::superTable::fileToTable a $nameOfSptFile nameOfTable {}]
    foreach index [lindex $iii 0] {
        set iV [list $index V]
        set iI [list $index I]
	set istatut [list $index statut]
	if {$a($istatut) == {}} {
	    lappend tension $a($iV)
	    lappend courant $a($iI)
	    incr n
	}
    }
    return $n
}


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


# retourne deux sous-listes des courants <= imax
proc ::fctlm::sublistsWithImax {tensions courants imax} {
    set v [list]
    set i [list]
    foreach tension $tensions courant $courants {
        if {abs($courant) <= $imax} {
            lappend v $tension
            lappend i $courant
        }
    }
    return [list $v $i]
}

proc ::fctlm::extractR {n tensions courants i0Name} {
    upvar $i0Name i0
  
    if {$n < 2} {
	return -code error "ERROR: ::fctlm::extractR with n < 2"
    }
    set x [::blas::vector create double $tensions]
    set y [::blas::vector create double $courants]
    set w [::blas::vector create double -length $n]
    set w [lreplace $w 1 1 -1.0] ;# A REECRIRE
    set maxdeg 1
    set eps 0.
    set r [::blas::vector create double -length $n]
    set a [::blas::vector create double -length [expr 3*$n+3*$maxdeg+3]]
    
    ::slatec::dpolft $x $y $w $maxdeg ndeg eps r ierr a
      
    set l 1
    if {$l > $ndeg} {
        error {Il faut $l > $ndeg}
    }
    set c 0.0
    set tc [::blas::vector create double -length 2]
  
    ::slatec::dpcoef $l $c tc $a
    
    foreach {i0 rInv} [lrange $tc 1 2] {}
    set resistance [expr {1.0/$rInv}]
    
    return $resistance
}

set HELP(::fctlm::extractRcleaned) {
    Utilise la distance du point � la droite pour �liminer les points aberrants
    On a v = R*(i - i0)
    


}
proc ::fctlm::extractRcleaned {tensions courants} {
    set n [llength $tensions]
    set R [::fctlm::extractR $n $tensions $courants i0]


    set ns {ns, je ne sais pas ce que c'est}
    # modifier n
    return [list $n $ns $R $i0]
}

proc ::fctlm::extract_nnsRi0s {tensions courants} {
    set nnsRi0s [list]
    foreach ii [::listUtils::scindeMonotone $courants] {
        set ia [lindex $ii 0]
        set ib [lindex $ii 1]
        set stensions [lrange $tensions $ia $ib]
        set scourants [lrange $courants $ia $ib]
        set nnsRi0s [concat $nnsRi0s [::fctlm::extractRcleaned $stensions $scourants]]
    }
    return $nnsRi0s
}

proc ::fctlm::fitTable {tableName nameOfSptFile NumDis listImax} {
    upvar $tableName table
    
    set fichier [file tail $nameOfSptFile]
    set repert [file dirname $nameOfSptFile]
    set repert [file tail $repert]

    set nameOfTable "mes*-$NumDis:*"

    set n [::fctlm::readV+IFromSpt $nameOfSptFile nameOfTable tensions courants]
    puts -nonewline  stderr ", $n pts"

    # Les listes tensions et courants sont nettes de compliance

    if {![regexp ^mes.*-$NumDis:\(.*\)\$ $nameOfTable tout TYPE]} {
        error "Le nom de la table \"$nameOfTable\" n'est pas conforme"
    }
    # patch pour tables incorrectement construites
    if {[regexp {^ghost_tlm_typesOfMotifs\(([0-9]*)\)$} $TYPE tout n]} {
	set TYPE [lindex {Vide 1.5x4 2x4 3x4 3x3 4x4 6x4 8x4 15x4 28x4 60x4 192x4 CC} $n]
    }
  
    foreach imax $listImax {

        foreach {v i} [sublistsWithImax $tensions $courants $imax] {}
        set nnsRi0s [extract_nnsRi0s $v $i]

        set im 0
        foreach {n ns R i0} $nnsRi0s {
            set R [format %.4f $R]
            set i0 [format %.4g $i0]

            set indiceDeLigne [list $repert $NumDis $fichier $imax $im]
            foreach c "fichier repert NumDis TYPE imax im n ns R i0" {
                set table([list $indiceDeLigne $c]) [set $c]
            }
            incr im
        }
    }    
}

proc ::fctlm::resFitNtoResFit {table1Name table2Name nameOfSptFile NumDis listImax NLMax} {
    upvar $table1Name table1
    upvar $table2Name table2

    set fichier [file tail $nameOfSptFile]
    set repert [file dirname $nameOfSptFile]
    set repert [file tail $repert]
    # on accepte provisoirement sctlm et fctlm
    if {[regexp {^mesures_.ctlm_(.*)$} $repert tout minirepert] != 1} {
        error "Le repertoire \"$repert\" n'est pas du type \"mesures_fctlm_*\""
    }
    set ETAT $minirepert
    set BLOC [file rootname $fichier]

    set reference {}
    
    foreach imax $listImax {
        set indiceDeLigne1 [list $repert $NumDis $fichier $imax]
        set indiceDeLigne2 [list $BLOC $ETAT $NumDis $imax]
        if {[info exists reference]} {
            set R $table1([list $indiceDeLigne1 R])
            unset reference
        } else {
            set R_tmp $table1([list $indiceDeLigne1 R])
            set DeltaR_tmp [expr {abs($R_tmp - $R)}]
            if {![info exists DeltaR] || $DeltaR_tmp > $DeltaR} {
                set DeltaR $DeltaR_tmp
            }
        }
    }
    set table2([list $indiceDeLigne2 R]) $R
    set table2([list $indiceDeLigne2 BLOC]) $BLOC
    set table2([list $indiceDeLigne2 ETAT]) $ETAT
    set table2([list $indiceDeLigne2 NumDis]) $NumDis
    set table2([list $indiceDeLigne2 TYPE]) $table1([list $indiceDeLigne1 TYPE])
    if {[info exists DeltaR]} {
        set table2([list $indiceDeLigne2 DeltaR]) $DeltaR
        if {$DeltaR != 0.0 && ($DeltaR/$R <= $NLMax)} {
            set table2([list $indiceDeLigne2 Valide]) 1
        } else {
            set table2([list $indiceDeLigne2 Valide]) 0
	}
    }
}

proc fctlm::fitAll {fichResulName dir repert imaxForFit NLMax NumDisList} {

    set blocs [list]

    set fichiers [glob [file join $dir *.spt]]
    set fichiers [lsort $fichiers]
    set nafiter [expr {[llength $fichiers] * [llength $NumDisList]}]
    set n 0
    set depart [clock seconds]
    foreach nameOfSptFile $fichiers {
	lappend blocs $nameOfSptFile
	foreach NumDis $NumDisList {
            incr n
            puts -nonewline stderr "[format %3d $nafiter] $nameOfSptFile $NumDis"
	    set err [catch {fctlm::fitTable table1 $nameOfSptFile $NumDis $imaxForFit} msg]
            incr nafiter -1
            set maintenant [clock seconds]
            set reste [expr {round(($maintenant-$depart)*double($nafiter)/double($n))}]
            puts stderr ", reste $reste s"
	    if {$err} {
		puts stderr " ERREUR = $msg"
	    }
	}
    }

    puts stderr {appel de ::fctlm::resFitNtoResFit sur toutes les mesures}

    foreach nameOfSptFile $blocs {
	for {set NumDis 0} {$NumDis <= 12} {incr NumDis} {
	    set err [catch {::fctlm::resFitNtoResFit table1 table2 $nameOfSptFile $NumDis $imaxForFit $NLMax} message]
            if {$err} {
                puts stderr $message
            }
	}
    }

    set lignes1 [superTable::createLinesFromArray table1 "Fit Brut de $repert"\
		     -sortLines {::fctlm::triCol1}\
		     -orderOfCols {repert fichiers NumDis TYPE R n imax i0}]
    set lignes2 [superTable::createLinesFromArray table2 "R�sistances Mesur�es $repert"\
		     -sortLines {::fctlm::triCol2}\
		     -orderOfCols {ETAT BLOC TYPE NumDis R DeltaR Valide}]
 
    set lignes [concat $lignes1 $lignes2]

    puts stderr "�criture du fichier"
    superTable::writeToFile $fichResulName $lignes

    return
}

proc ::fctlm::triCol1 {arrayName l1 l2} {
    upvar $arrayName array
    set i1 [list $l1 repert]
    set i2 [list $l2 repert]
    set c [string compare $array($i1) $array($i2)]
    if {$c != 0} {
        return $c
    }
    set i1 [list $l1 NumDis]
    set i2 [list $l2 NumDis]
    set c [expr {$array($i1) - $array($i2)}]
    if {$c < 0} {
        return -1
    } elseif {$c > 0} {
        return 1
    }
    set i1 [list $l1 fichier]
    set i2 [list $l2 fichier]
    set c [string compare $array($i1) $array($i2)]
    if {$c != 0} {
        return $c
    }
    set i1 [list $l1 imax]
    set i2 [list $l2 imax]
    set c [expr {$array($i1) - $array($i2)}]
    if {$c < 0} {
        return -1
    } elseif {$c > 0} {
        return 1
    }
    return 0
}

proc ::fctlm::triCol2 {arrayName l1 l2} {
    upvar $arrayName array
    set i1 [list $l1 BLOC]
    set i2 [list $l2 BLOC]
    set c [string compare $array($i1) $array($i2)]
    if {$c != 0} {
        return $c
    }
    set i1 [list $l1 NumDis]
    set i2 [list $l2 NumDis]
    set c [expr {$array($i1) - $array($i2)}]
    if {$c < 0} {
        return -1
    } elseif {$c > 0} {
        return 1
    }
    return 0
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
	if {[string match "*qualit�*" $n]} {
	    lappend ndt $n
	}
    }
    unset nomsDesTables

    foreach n $ndt {
	set bloc [lindex $n end]
	if {[info exists BLOCSVUS($bloc)]} {
	    error "ERREUR: Bloc $bloc identifi� 2 fois"
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
	set nameOfTable "R�sistances Mesur�es*"
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

package provide fctlm 0.5
