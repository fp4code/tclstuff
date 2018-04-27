
# 18 mars 2003 (FP) 0.1
# 28 aout 2003 (FP) 0.2

set INFO(fidev_stats) {
    

}


namespace eval stats {
}

proc stats::loiNormale {arrayName list} {
    upvar $arrayName array

    if {![info exists array(non_confiance_sup)]} {
	set array(non_confiance_sup) [list 0.025 0.05 0.10]
    }

    set tot [expr {double(0.0)}]
    set N 0
    foreach x $list {
	if {![info exists array(valeur_minimale)] || $x < $array(valeur_minimale)} {
	    set array(valeur_minimale) $x
	}
	if {![info exists array(valeur_maximale)] || $x > $array(valeur_maximale)} {
	    set array(valeur_maximale) $x
	}
	set tot [expr {double($tot) + double($x)}]
	incr N
    }
    set moy [expr {$tot/double($N)}]
    set array(moyenne_arithmétique) $moy
    set array(étendue) [expr {$array(valeur_maximale) - $array(valeur_minimale)}]

    set tot [expr {double(0.0)}]
    set N 0
    foreach x $list {
	set xe [expr {double($x) - double($moy)}]
	set tot [expr {double($tot) + double($xe*$xe)}]
	incr N
    }
    
    set sumcar $tot
    set array(écart_quadratique_moyen) [expr {sqrt($sumcar/double($N))}]
    set array(écart_type_estimé) [expr {sqrt($tot/double($N-1))}]
    
    set array(nombre_d_échantillons) $N

    if {[info exists array(non_confiance_inf)]} {
	package require dcdflib 0.1
	set array(écart_type_limite_inf) [list]
	foreach v $array(non_confiance_inf) {
	    set chi2 [dcdf::chi2 X [expr {$N-1}] [list [expr {1.0 - $v}] $v]]
	    lappend array(écart_type_limite_inf) $v [expr {sqrt($sumcar/$chi2)}]
	}
    }
    if {[info exists array(non_confiance_sup)]} {
	package require dcdflib 0.1
	set array(écart_type_limite_sup) [list]
	foreach v $array(non_confiance_sup) {
	    set chi2 [dcdf::chi2 X [expr {$N-1}] [list $v [expr {1.0 - $v}]]]
	    lappend array(écart_type_limite_sup) $v [expr {sqrt($sumcar/$chi2)}]
	}
    }
    
    return
}


package provide fidev_stats 0.2

proc stats::test {} {
		  
    set data {
	65.50
	65.62
	65.35
	65.86
	66.19
	65.35
	65.89
	66.01
	66.00
	65.53
	65.65
	65.76
	66.49
	66.25
	65.88
	65.59
	65.71
	65.76
    }
   
    set a(non_confiance_inf) {0.025 0.05}
    set a(non_confiance_sup) {0.025 0.05}

    stats::loiNormale a $data

    parray a
    array set écart_type_limite_inf $a(écart_type_limite_inf)
    array set écart_type_limite_sup $a(écart_type_limite_sup)


}
