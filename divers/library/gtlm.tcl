set HELP(gtlm:sgtToR) {
    Dans le répertoire $repertoire
    Lit la table de nom $nom dans le fichier .sgt correspondant à la ligne $li et à la colonne $co
    Lit la table d'examen visuel de qualité dans le fichier .tri
    Remplit le tableau $a avec  résultats de fit linéaire
}
proc gtlm:sgtToR {tableau repertoire nom li co ndisp} {
    upvar $tableau t 
    
    set numOfDisp [format %02d $li][format %02d $co]
    # $numOfDisp est du genre 0102 (lico)
    
    set nameOfFile $repertoire/$numOfDisp.sgt
    # fichier des mesures
    
    set nameOfFileTri $repertoire/$numOfDisp.tri
    # fichier compte-rendu de l'apparence visuelle
    
    set lignes [superTable:getLines $nameOfFile] ;# ne pas afficher
    set lignesTri [superTable:getLines $nameOfFileTri] ;# ne pas afficher
    # listes des lignes des fichiers

    set tlimits [superTable:marqueTables $lignes]
    set tlimitsTri [superTable:marqueTables $lignesTri]
    # $listes des index des lignes commençant par @@

    set nameOfTable "*$nom-$numOfDisp-$ndisp"
    set range [superTable:linesOfTable $lignes $tlimits nameOfTable]
    set nameOfTableTri "*$nom-$numOfDisp-$ndisp"
    set rangeTri [superTable:linesOfTable $lignesTri $tlimitsTri nameOfTableTri]
    # listes de deux éléments : première et dernière ligne
    # de la table voulue dans le fichier
    # la première ligne est la ligne @@...

    set table [lrange $lignes [expr [lindex $range 0]+1] [lindex $range 1]]
    set tableTri [lrange $lignesTri [expr [lindex $rangeTri 0]+1] [lindex $rangeTri 1]]
    # $table est la liste des lignes du fichier correspondant à
    # la table $globNameOfTable

    if {[array exists a]} {
        unset a
    }
    if {[array exists aTri]} {
        unset aTri
    }
    set indexes [superTable:readTable $lignes $range a instant]
    set indexesTri [superTable:readTable $lignesTri $rangeTri aTri qualité]
    # $indexes est la liste des valeurs de la colonne d'index instant
    # L'élément ligne $instant colonne $c est $a($instant:$c)
    
    set ival {}
    set vval {}
    if {[array exists rejets]} {
        unset rejets
    }
    foreach i $indexes {
        set statut $a($i:statut)
        if {$statut == "V(I)"} {
# ATTENTION V et I echanges !!!!!!!!!!

            lappend ival $a($i:V) 
            lappend vval $a($i:I)
        } else {
            if {[info exists rejets($statut)]} {
                incr rejets($statut)
            } else {
                set rejets($statut) 1
            }
        }
    }
    foreach r [array names rejets] {
        set nr $rejets($r)
        puts -nonewline "$nr rejet"
        if {$nr > 1} {puts -nonewline "s"}
        puts " pour statut = $r"
    }
    # un seul élément : pas de scrupule
    set quality $aTri([array names aTri])
    
    if {[llength $vval] < 3} {
        set r {}
        set sigr {}
        set sigi {}
    } else {
        fitlin a $vval $ival
        set r [expr 1.0/$a(a1)]           ;# résistance I(V)
        set sigr [expr $a(sig1)*$r*$r]
        set sigi $a(sigdat)
    }
    set t(BLOC) $numOfDisp
    set t(NumDis) $ndisp
    set t(qualité) $quality
    set t(R) $r
    set t(DeltaR) $sigr
    set t(sigi) $sigi
    return
}

set HELP(fitlin) {
    À partir des points $xlist $ylist
    calcule le fit a0 + a1 x
    Remplit le tableau de nom $array
    avec les éléments a0 a1 sig0 sig1 chi2
    Retourne la liste [a0 a1]
}
proc fitlin {array xlist ylist} {
    upvar $array arr
    set n 0
    set sx 0.0
    set sy 0.0
    set st2 0.0
    set b 0.0
    foreach x $xlist y $ylist {
        incr n
        set sx [expr $sx + $x]
        set sy [expr $sy + $y]
    }
    set ss $n
    set sxoss [expr $sx/$ss]
    foreach x $xlist y $ylist {
        set t [expr $x - $sxoss]
        set st2 [expr $st2 + $t*$t]
        set b [expr $b + $t*$y]
    }
    set b [expr $b/$st2]
    set a [expr ($sy - $sx*$b)/$ss]
    set siga [expr sqrt((1.0 + $sx*$sx/($ss*$st2))/$ss)]
    set sigb [expr sqrt(1.0/$st2)]
    set chi2 0.0
    foreach x $xlist y $ylist {
        set t [expr $y-$a-$b*$x]
        set chi2 [expr $chi2 + $t*$t]
    }
    set sigdat [expr sqrt($chi2/($n-2))]
    set arr(sig0) [expr $siga*$sigdat]
    set arr(sig1) [expr $sigb*$sigdat]
    set arr(sigdat) $sigdat
    set arr(chi2) $chi2
    set arr(a0) $a
    set arr(a1) $b
    return [list $a $b]
}

