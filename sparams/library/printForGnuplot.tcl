package require blas 1.0

# Cr�e une chaine repr�sentant les lignes de donn�es Gnuplot
# � partir de colonnes donn�es d'une tkTable.
# La chaine doit �tre s�par�e et termin�e par des "\n" mais elle ne doit pas contenir le "e" final
# La tkTable est � la sauce tkSuperTable et les colonnes sont donn�es par leur nom.

proc sparams::printForGnuplot {tkTable colnames} {

    # R�cup�ration du tableau associ� � la tkTable

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

    # Construction des lignes de donn�es gnuplot � partir du tableau "tkTableArray"
     
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
