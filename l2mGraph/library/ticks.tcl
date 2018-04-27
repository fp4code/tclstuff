package provide l2mGraphTicks 1.2

#########
# ticks #
#########

namespace eval l2mGraph {}

###############
# échelle Lin #
###############

set HELP(l2mGraph::createLinTicks) {
    Intro {
        construction de graduations linéaires
    }

    Arguments {
        $min        coordonnée utilisateur minimale
        $max        coordonnée utilisateur maximale
        $sizeUnit   unité utilisateur exprimée en coordonnées physiques (pixels ou autres)
        $sizeMinDiv distance physique minimale entre deux subdivisions de second niveau 
    }

    Retour {
        liste composée de 3 sous-listes
            sous-liste 0 : divisions (selon une des puissances de 10)
            sous-liste 1 : subdivisions de premier niveau
            sous-liste 2 : subdivisions de second niveau
    }
        
    ??? {
        L'espacement des ticks est $ticksSpace
        Le nombre de divisions des ticks en subticks est $nSubdiv
    }
}

proc l2mGraph::createLinTicks {min max sizeUnit sizeMinDiv} {
    set als [autoLinearSubdivMin $sizeUnit $sizeMinDiv]
    foreach {fracSubdiv ndiv1 ndiv2} $als {}

    # indice de la graduation inférieure
    set itmin [expr ceil(double($min)/$fracSubdiv)]

    # nombre de graduations
    set itmax [expr floor(double($max)/$fracSubdiv)]

    set ticks0 {}
    set ticks1 {}
    set ticks2 {}
    
    # il vaudrait mieux introduire un indice "int" décalé.
    for {set it $itmin} {$it <= $itmax} {set it [expr {$it + 1}]} {
	if {abs($it - $ndiv1 * round($it / $ndiv1)) < 0.1} {
            # fin de course des subdivisions de premier niveau => division
	    lappend ticks0 [expr $it*$fracSubdiv]
	} elseif {abs($it - $ndiv2 * round($it / $ndiv2)) < 0.1} {
            # fin de course des subdivisions de second niveau => subdivision de premier niveau
	    lappend ticks1 [expr $it*$fracSubdiv]
	} else {
            # subdivision de second niveau
	    lappend ticks2 [expr $it*$fracSubdiv]
	}
    }
    set ret [list $ticks0 $ticks1 $ticks2]
    return $ret
}

set HELP(l2mGraph::autoLinearSubdivMin) {
    Intro {
        calcul de subdivisions
    }
    Arguments {
	$sizeUnit   taille physique (pixels ou autre) d'un intervalle égal à une unité utilisateur
	$sizeMinDiv intervalle physique minimal (en pixels ou autres) entre deux subdivisions de second niveau
    }
    Retour {
        liste composée de 3 sous-listes
            sous-liste 0 : nombre de subdivisions de premier niveau dans une division
            sous-liste 1 : nombre de subdivisions de second niveau dans une subdivision de premier niveau
            sous-liste 2 : valeur, en unités utilisateur, de la subdivision de second niveau
    }    


    3 types de subdivisions : (Gx = grande, Px = petite)
        "a5"  : G0 P2 P4 P6 P8 G10                        retour = "xxx.xx2 5 1"
        "a10" : G0 P1 P2 P3 P4 M5 P6 P7 P8 P9 G10         retour = "xxx.xx1 10 5"
        "a20" : G0 P5 M10 P15 M20 P25 M30 P35 M40 P45 G50 retour = "xxx.xx5 10 2"
    
    seuils de transition :
         5 graduations "a5"  <->  10 graduations "a10"
        10 graduations "a10" <->  20 graduations "a20"
        20 graduations "a20" <->  50 graduations "a5"

}

proc l2mGraph::autoLinearSubdivMin {sizeUnit sizeMinDiv} {
    set x5  [expr log10(double($sizeUnit)/( 5.0*double($sizeMinDiv)))]
    set x10 [expr log10(double($sizeUnit)/(10.0*double($sizeMinDiv)))]
    set x20 [expr log10(double($sizeUnit)/(20.0*double($sizeMinDiv)))]
    
    set rx5 [expr $x5   - floor($x5)]
    set rx10 [expr $x10 - floor($x10)]
    set rx20 [expr $x20 - floor($x20)]
    
    # 10**rxN est le rapport entre la taille de l'unité et la
    # taille minimale de l'unité pour une subdivision xN
    if {$rx5 < $rx10} {
	if {$rx20 < $rx5} {
	    # la subdivision x20 est la plus proche
	    set ndiv1 10
	    set ndiv2 2
	    set fracSubdiv [expr pow(10.,-floor($x20))/20.]
	} else {
            # la subdivision x5 est la plus proche
	    set ndiv1 5
	    set ndiv2 1
	    set fracSubdiv [expr pow(10.,-floor($x5))/5.]
	}
    } else {
	if {$rx20 < $rx10} {
            # la subdivision x20 est la plus proche
	    set ndiv1 10
	    set ndiv2 2
	    set fracSubdiv [expr pow(10.,-floor($x20))/20.]
	} else {
            # la subdivision x10 est la plus proche
	    set ndiv1 10
	    set ndiv2 5
	    set fracSubdiv [expr pow(10.,-floor($x5))/10.]
	}
    }
    return [list $fracSubdiv $ndiv1 $ndiv2]
}

###############
# échelle Log #
###############

set HELP(l2mGraph::createLogTicks) {
    Intro {

    }

    Arguments {
	$min
	$max
	$size10Unit 
	$sizeMinDiv distance physique minimale entre deux subdivisions
    }
    
}

proc l2mGraph::createLogTicks {min max size10Unit sizeMinDiv} {
    if {$min<=0 || $max <=0} {
	error "createLogTicks sur zone négative"
    }
    set log2 [expr log10(2)]
    set log5 [expr log10(5)]
    set ticks0 {}
    set ticks1 {}
    set ticks2 {}
    set mant [expr log10($min)]
    set range [expr floor($mant)]
    set mant [expr $mant-$range]
    set range [expr pow(10,$range)]
    if {$log2*$size10Unit >= $sizeMinDiv} {
	if {$mant > $log5} {
	    set range [expr 10.*$range]
	    set mant 1
	} elseif {$mant > $log2} {
	    set mant 5
	} else {
	    set mant 2
	}
	set val [expr $mant*$range]
	while {$val <= $max} {
	    switch $mant {
		1 {
		    lappend ticks0 $val
		    set mant 2
		}
		2 {
		    lappend ticks1 $val
		    set mant 5
		}
		5 {
		    lappend ticks1 $val
		    set mant 1
		    set range [expr 10.*$range]
		}
	    }
	    set val [expr $mant*$range]
	}
    } elseif {($size10Unit >= $sizeMinDiv) || (1 == 1)} {
	if {$mant != 1} {
	    set range [expr 10.*$range]
	}
	set val [expr $range]
	while {$val <= $max} {
	    lappend ticks0 $val
	    set range [expr 10.*$range]
	    set val [expr $range]
	}
    }
    return [list $ticks0 $ticks1 $ticks2]
}












