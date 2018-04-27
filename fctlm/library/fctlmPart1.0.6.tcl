# RCS: @(#) $Id $

# 1 juin 2001 (FP) Passage à blasObj\
# 20 juillet 2001 (FP) blasObj 0.2 et slatec 0.2
# 13 mars 2003 (FP) séparation de fctlm.0.5 en fctlmPart1.0.6 et fctlmPart2.0.6

package require fidev
package require superTable 1.5
package require blasObj 0.2
package require slatec 0.2

namespace eval ::fctlm {}

set HELP(fctlm::fitAll) {
    $fichResulName nom du fichier de résultat des fits de résistances
    $dir           nom du répertoire contenant les mesures
    $repert        ? idem plus un cran de parent ?
    $imaxForFit    courant de mesure max pris en compte
    $NLMax         Non-linéarité max
    $NumDisList    Numéro de dispo (0 à 12)

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
	    # 
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

    foreach cellpos [array names table1] {
	set li [lindex $cellpos 0]
	lappend table1aux([lrange $li 0 2]) [lrange $li 3 4] ;# repert NumDis fichier  -> imax im
    }

    foreach nameOfSptFile $blocs {
	for {set NumDis 0} {$NumDis <= 12} {incr NumDis} {
	    set err [catch {::fctlm::resFitNtoResFit table1 table1aux table2 $nameOfSptFile $NumDis $imaxForFit $NLMax} message]
            if {$err} {
                puts stderr $message
            }
	}
    }

    puts stderr Done

    set lignes1 [superTable::createLinesFromArray table1 "Fit Brut de $repert"\
		     -sortLines {::fctlm::triCol1}\
		     -orderOfCols {repert fichiers NumDis TYPE R n imax i0}]
    set lignes2 [superTable::createLinesFromArray table2 "Résistances Mesurées $repert"\
		     -sortLines {::fctlm::triCol2}\
		     -orderOfCols {ETAT BLOC TYPE NumDis R DeltaR Valide}]
 
    set lignes [concat $lignes1 $lignes2]

    puts stderr "écriture du fichier"
    superTable::writeToFile $fichResulName $lignes

    return
}


set HELP(::fctlm::fitTable) {
    Complète à partir d'une supertable "mes*-$NumDis:*"
    contenue dans un fichier $nameOfSptFile, pour un ensemble
    de courants max $listImax une table de nom ${&table},
    dont les colonnes sont
    fichier fichier
    repert  répertoire
    NumDis  0 à 12
    TYPE    genre 6x10
    imax    courant max de fit
    im      indice montée-descente
    n       nombre de points de mesure
    ns      nombre de points non aberrants
    R       résistance
    i0      écart i0
    
    La table est indexable par [list $repert $NumDis $fichier $imax $im]
}
proc ::fctlm::fitTable {&table nameOfSptFile NumDis listImax} {
    upvar ${&table} table
    
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

	set vi [fctlm::sublistsWithImax $tensions $courants $imax]
	set v [lindex $vi 0]
	set i [lindex $vi 1]
	unset vi

        set nnsRi0s [extract_nnsRi0s $v $i]

        set im 0 ;# index montée-descente
        foreach {n ns R i0} $nnsRi0s {
            set R [format %.4f $R]
            set i0 [format %.4g $i0]

            set indiceDeLigne [list $repert $NumDis $fichier $imax $im]
            foreach c "fichier repert NumDis TYPE imax im n ns R i0" {
                superTable::setCell table $indiceDeLigne $c [set $c]
            }
            incr im
        }
    }    
}

set HELP(::fctlm::readV+IFromSpt) {
    - Remplit les listes de nom $vName $iName
    à partir des colonnes V et I de la supertable dont le nom est
    $nameOfTableName et qui est contenue dans le fichier $nameOfSptFile
    - Ne prend pas en compte les mesures dont la colonne "statut" n'est pas vide
    - retourne la longueur des listes
}
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

set HELP(::fctlm::sublistsWithImax) {
    retourne deux sous-listes tensions et courants avec courant <= imax
}
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

set HELP(::fctlm::extract_nnsRi0s) {
    retourne une liste quadruple "n ns R i0 n ns R i0 ...",
    quatre valeurs pour chaque sens de mesure
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

set HELP(::fctlm::extractRcleaned) {
    Utilise la distance du point à la droite pour éliminer les points aberrants
    On a v = R*(i - i0)
    
    n = nombre de points de mesure
    ns = nombres de points non aberrants
}

set _extractRcleaned_MessageGiven 0
proc ::fctlm::extractRcleaned {tensions courants} {

    global _extractRcleaned_MessageGiven
    if {!$_extractRcleaned_MessageGiven} {
	puts stderr "La procédure ::fctlm::extractRcleaned ne nettoie pas les points aberrants"
	set _extractRcleaned_MessageGiven 1
    }

    set R [::fctlm::extractR $tensions $courants i0]

    set n [llength $tensions]
    set ns {pas nettoyé}
    # modifier n
    return [list $n $ns $R $i0]
}

set HELP(::fctlm::extractR) {
    <intro>
    Mise en oeuvre de ::slatec::dpolft et ::slatec::dpcoef
    pour fit à partir de deux listes
    </intro>

    Retourne R
    i0Name accueille la valeur de i0
}

proc ::fctlm::extractR {tensions courants i0Name} {
    upvar $i0Name i0
  
    set n [llength $tensions]
    if {[llength $courants] != $n} {
	return -code error "x et y pas de même longueur"
    }
    if {$n < 2} {
	return -code error "ERROR: ::fctlm::extractR with n < 2"
    }
    set x [::blas::vector create double $tensions]
    set y [::blas::vector create double $courants]
    # tableau de poids. Promière valeur négative => poids égaux
    set w [::blas::vector create double -length $n]
    blas::vector set w 1 -1.0
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
    
    set i0 [::blas::vector get $tc 1]
    set rInv [::blas::vector get $tc 2]
    set resistance [expr {1.0/$rInv}]
    
    return $resistance
}

#################
# seconde étape #
#################

set HELP(::fctlm::resFitNtoResFit) {
    construit la table2 à partir de la table1

}

proc ::fctlm::resFitNtoResFit {&table1 &table1aux &table2 nameOfSptFile NumDis listImax NLMax} {
    upvar ${&table1} table1
    upvar ${&table1aux} table1aux
    upvar ${&table2} table2

    set fichier [file tail $nameOfSptFile]
    set repert [file dirname $nameOfSptFile]
    set repert [file tail $repert]
    # on accepte provisoirement sctlm et fctlm
    if {[regexp {^mesures_.ctlm_(.*)$} $repert tout minirepert] != 1} {
        error "Le repertoire \"$repert\" n'est pas du type \"mesures_fctlm_*\""
    }
    set ETAT $minirepert
    set BLOC [file rootname $fichier]

    set lowpart [list $repert $NumDis $fichier]

    set indiceDeLigne2 [list $BLOC $ETAT $NumDis]
    set reference {}
    # améliorer le tri $imax $im
    foreach highpart [lsort $table1aux($lowpart)] {
        set indiceDeLigne1 [concat $lowpart $highpart]
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

package provide fctlmPart1 0.6
