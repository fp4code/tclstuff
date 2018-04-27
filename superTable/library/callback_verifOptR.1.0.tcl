package provide tkstcb_verifOptR 1.0

namespace eval tkSuperTable::callbacks {}

proc tkSuperTable::callbacks::verifOptR {win} {
  # r�cup�ration du tableau associ� � la table
    upvar #0 [$win cget -variable] tableau
  # r�cup�ration des index des colonnes "n" et "k"
    set icn  [tkSuperTable::getColIndex $win n]
    set ick  [tkSuperTable::getColIndex $win k]
    if {$icn == {} || $ick == {}} {
	return
    }
  # ajout de deux colonnes "Rcalc" et "erreur"
    if {[catch {tkSuperTable::ajouteColonne $win Rcalc}]} return
    if {[catch {tkSuperTable::ajouteColonne $win erreur}]} return
  # r�cup�ration des index des colonnes "R", "Rcalc" et "erreur"
    set icrt [tkSuperTable::getColIndex $win R]
    set icr  [tkSuperTable::getColIndex $win Rcalc]
    set ice  [tkSuperTable::getColIndex $win erreur]
  # boucle sur tous les index deligne
    foreach ili [tkSuperTable::toutesLignes $win] {
      # si les cases "n" et "k" existent
	if {[info exists tableau($ili,$icn)] && [info exists tableau($ili,$ick)]} {
	    set n $tableau($ili,$icn)
	    set k $tableau($ili,$ick)
	    set n2pk2 [expr {$n*$n + $k*$k}]
	    set denom [expr {$n2pk2 + 2.0*$n + 1.0}]
	    if {$denom == 0.0} {
		continue
	    }
	    set re [expr {($n2pk2 - 1.0)/$denom}]
	    set im [expr {2.0*$k/$denom}]
	    set r [expr {$re*$re + $im*$im}]
	  # remplissage de la case "Rcalc"
	    set tableau($ili,$icr) [format %.4f $r]
	  # si la case "R" existe
	    if {$icrt != {} && [info exists tableau($ili,$icrt)]} {
	      # remplissage de la case "erreur"
		set err [expr {abs($tableau($ili,$icrt) - $r)}]
		set tableau($ili,$ice) [format %.4f $err]
	    }
	}
    }
  # visualisation de la premi�re ligne de la colonne "erreur"
    $win see -1,$ice
}

set tkSuperTable::callbacks::CALLBACKS(verifOptR) {}

