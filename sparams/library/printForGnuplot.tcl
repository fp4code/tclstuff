package require blas 1.0

# Crée une chaine représentant les lignes de données Gnuplot
# à partir de colonnes données d'une tkTable.
# La chaine doit être séparée et terminée par des "\n" mais elle ne doit pas contenir le "e" final
# La tkTable est à la sauce tkSuperTable et les colonnes sont données par leur nom.

proc sparams::printForGnuplot {tkTable colnames} {

    # Récupération du tableau associé à la tkTable

    upvar #0 [$tkTable cget -variable] tkTableArray

    set scols {freq s11_m s11_deg s12_m s12_deg s21_m s21_deg s22_m s22_deg}

    set ilignes [tkSuperTable::toutesLignes $tkTable]
    set nlignes [llength $ilignes]

    foreach colname $scols {
	set ic [tkSuperTable::getColIndex $tkTable $colname]
	set vals [list]
	foreach ili $ilignes {
	    lappend vals  $tkTableArray($ili,$ic)
	}
	set V($colname) [blas::newVector double $vals]

    }

    # Construction des lignes de données gnuplot à partir du tableau "tkTableArray"
     
    set datas ""

    for {set ili 0} {$ili < $nlignes} {incr ili} {
	set ic 0
	foreach colname $colnames {
	    incr ic
	    set val [blas::getAtIndex $V($colname) $ili]  
	    if {$ic != 1} {
		append datas \t
	    }
	    append datas $val
	}
	append datas \n
    }
    
    foreach colname $scols {
	blas::deleteVector $V($colname)
    }
    
   return $datas
}
