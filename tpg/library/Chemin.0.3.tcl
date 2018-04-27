#
# chemins : un chemin est une liste triple "x0 y0 qualité01 x1 x2 qualité12 ... qualitéN-1_N xN yN"
# la qualité est "E" (externe) "I" (interne) ou "C" (corriger)
#
# Un chemin est clos ou non. Il faut le clore pour l'utiliser comme boundary
#

namespace eval ::tpg::Chemin {
    variable SP "\[ \t\]*"
    variable IP {[0-9]+}
}

############################
# constructeurs de chemins #
############################

set HELP(::tpg::Chemin::new) {
    construit un chemin à partir d'une liste triple -1 d'arguments
}
proc ::tpg::Chemin::new {args} {
    set nargs [llength $args]
    if {($nargs % 3) != 2} {
	error "nombre d'arguments ($nargs) incorrect"
    }
    return [concat $args]
}

set HELP(::tpg::Chemin::new) {
    construit un chemin à partir d'une chaine compacte
}
proc ::tpg::Chemin::newFromString {chaine} {
    variable SP
    variable IP
    set commandes [split $chaine ";"]
    set qualite E
    set x 0
    set y 0
    if {[lindex $commandes end] != {}} {
	error "newFromString $chaine manque ;"
    }
    set l [expr {[llength $commandes] - 2}]
    set commandes [lrange $commandes 0 $l]
    set points [list]
    foreach ptExpr $commandes {
	while {$ptExpr != {}} {
	    # à étendre pour les flottants
	    if       {[regexp "^${SP}x${SP}=${SP}(-?${IP})(.*)${SP}" $ptExpr d x ptExpr]} {
	    } elseif {[regexp "^${SP}y${SP}=${SP}(-?${IP})(.*)${SP}" $ptExpr d y ptExpr]} {
	    } elseif {[regexp "^${SP}>${SP}(${IP})(.*)${SP}" $ptExpr d dx ptExpr]} {
		set x [expr $x + $dx]
	    } elseif {[regexp "^${SP}<${SP}(${IP})(.*)${SP}" $ptExpr d dx ptExpr]} {
		set x [expr $x - $dx]
	    } elseif {[regexp "^${SP}\\^${SP}(${IP})(.*)${SP}" $ptExpr d dy ptExpr]} {
		set y [expr $y + $dy]
	    } elseif {[regexp "^${SP}v${SP}(${IP})(.*)${SP}" $ptExpr d dy ptExpr]} {
		set y [expr $y - $dy]
	    } elseif {[regexp "^${SP}(E|I|C)${SP}(.*)${SP}" $ptExpr d qualite ptExpr]} {
	    } else {
		error "Erreur  : new.chemin $chaine : \"$ptExpr\""
	    }
	}
	if {$points != {}} {
	    lappend points $qualite
	}
	lappend points $x $y
    }
    return $points
}

set HELP(::tpg::Chemin::rectangleCentre) {
    construit un chemin clos rectangulaire centré, de largeur 2*$x1, de hauteur 2*$y1
}
proc ::tpg::Chemin::rectangleCentre {x1 y1} {
    global enCours 
    set x0 [expr {-$x1}]
    set y0 [expr {-$y1}]
    return [new $x0 $y0 E \
	    $x1 $y0 E \
	    $x1 $y1 E \
	    $x0 $y1 E \
	    $x0 $y0]
}

set HELP(::tpg::Chemin::rectangleXY) {
    construit un chemin clos rectangulaire $dx, de hauteur $dy
}
proc ::tpg::Chemin::rectangleXY {x0 y0 dx dy} {
    global enCours
    set x1 [expr {$x0 + $dx}]
    set y1 [expr {$y0 + $dy}]
    return [new $x0 $y0 E \
	    $x1 $y0 E \
	    $x1 $y1 E \
	    $x0 $y1 E \
	    $x0 $y0]
}

set HELP(::tpg::Chemin::translated) {
    construit un nouveau chemin en translatant de ($dx, $dy) le chemin $chemin
}
proc ::tpg::Chemin::translated {dx dy chemin} {
    set x [lindex $chemin 0]
    set y [lindex $chemin 1]
    set retour [::tpg::Chemin::new [expr {$x + $dx}] [expr {$y + $dy}]]
    foreach {q x y} [lrange $chemin 2 end] {
	::tpg::Chemin::appendPoint retour $q [expr {$x + $dx}] [expr {$y + $dy}]
    }
    return $retour
}

set HELP(::tpg::Chemin::transformed) {
    construit un nouveau chemin en appliquant la transformation ponctuelle ::tpg::Point::$transform au chemin $chemin
}
proc ::tpg::Chemin::transformed {transform chemin} {
    set x [lindex $chemin 0]
    set y [lindex $chemin 1]
    set retour [::tpg::Point::$transform $x $y]
    foreach {q x y} [lrange $chemin 2 end] {
	foreach {x y} [::tpg::Point::$transform $x $y] {
	    ::tpg::Chemin::appendPoint retour $q $x $y
	}
    }
    return $retour
}

set HELP(::tpg::Chemin::transformed) {
    construit un nouveau chemin en appliquant la transformation ponctuelle
    "::tpg::Point::$transform $argum" au chemin $chemin
}
proc ::tpg::Chemin::transformed2 {transform chemin argum} {
    set x [lindex $chemin 0]
    set y [lindex $chemin 1]
    set retour [::tpg::Point::$transform $x $y $argum]
    foreach {q x y} [lrange $chemin 2 end] {
	foreach {x y} [tpg::Point::$transform $x $y $argum] {
	    ::tpg::Chemin::appendPoint retour $q $x $y
	}
    }
    return $retour
}

set HELP(::tpg::Chemin::dilated) {
    construit un nouveau chemin en appliquant un facteur $facteur aus coordonnées de $chemin
}
proc ::tpg::Chemin::dilated {facteur chemin} {
    set x [lindex $chemin 0]
    set y [lindex $chemin 1]
    set retour [new [expr {$x*$facteur}] [expr {$y*$facteur}]]
    foreach {q x y} [lrange $chemin 2 end] {
	::tpg::Chemin::appendPoint retour $q [expr {$x*$facteur}] [expr {$y*$facteur}]
    }
    return $retour
}

proc ::tpg::Chemin::inverse {chemin} {
    set n [llength $chemin]
    set ret [list]
    incr n -2
    lappend retour [lindex $chemin $n]
    incr n 1
    lappend retour [lindex $chemin $n]
    while {$n > 1} {
	incr n -2
	lappend retour [lindex $chemin $n]
	incr n -2
	lappend retour [lindex $chemin $n]
	incr n 1
	lappend retour [lindex $chemin $n]
    }
    return $retour
}

proc ::tpg::Chemin::bonSens {chemin} {
    if {![::tpg::Chemin::isClos $chemin]} {
	error "chemin non clos : $chemin"
    }
    set n [tours $chemin]
    if {$n == 1} {
	return $chemin
    } elseif {$n == -1} {
	return [inverse $chemin]
    } else {
	error "\[tours $chemin\] == $n"
    }
}

set HELP(::tpg::Chemin::empated) {
    construit un chemin clos en empatant un chemin clos
}
proc ::tpg::Chemin::empated {e chemin} {
    if {![::tpg::Chemin::isClos $chemin]} {
	error "chemin non clos"
    }
    set n  [expr {[llength $chemin] - 5}]
    if {$n < 6} {
	error "chemin trop court"
    }
    foreach {xa ya qa x0 y0} [lrange $chemin $n end] {}
    # puts "$x0 - $xa , $y0 - $ya"
    foreach {vax vay} [::tpg::Vector::normalise [expr {$x0 - $xa}] [expr {$y0 - $ya}]] {}
    set nc {}
    appendPoint chemin [lindex $chemin 2] [lindex $chemin 3] [lindex $chemin 4]
    foreach {qb xb yb} [lrange $chemin 2 end] {
	# puts -nonewline "$xa $ya $qa $x0 $y0 $qb $xb $yb "
	foreach {vbx vby} [tpg::Vector::normalise [expr {$xb - $x0}] [expr {$yb - $y0}]] {}
	if {$qb == "I"} {
	    if {$qa == "I"} {
		::tpg::Chemin::appendPoint nc $qa $x0 $y0
	    } elseif {$qa == "E"} {
		set tempo [expr {$vax*$vby - $vay*$vbx}]
		if {$tempo == 0} {
		    # E et I alignés
		    ::tpg::Chemin::appendPoint nc E [expr {$x0+round((-$vax+$vay)*$e)}] [expr {$y0+round((-$vay+$vax)*$e)}]
		    ::tpg::Chemin::appendPoint nc I [expr {$x0-round($vax*$e)}] [expr {$y0-round($vay*$e)}]
		} elseif {abs(abs($tempo)-1.0) < 0.2} {
		    # quasi orthogonaux (arbitraire)
		    set tempo [expr {$e/$tempo}]
		    ::tpg::Chemin::appendPoint nc E [expr {$x0-round($vbx*$tempo)}] [expr {$y0-round($vby*$tempo)}]
		} else {
		    error "le raccord Interne-Externe doit être colinéaire ou quasi orthogonal"
		}
	    } else {
		error "qa == $qa"
	    }
	} elseif {$qb == "E"} {
	    if {$qa == "I"} {
		set tempo [expr {$vax*$vby - $vay*$vbx}]
		if {$tempo == 0.0} {
		    # I et E alignés
		    ::tpg::Chemin::appendPoint nc I [expr {$x0+round($vax*$e)}] [expr {$y0+round($vay*$e)}]
		    ::tpg::Chemin::appendPoint nc I [expr {$x0+round(($vax+$vay)*$e)}] [expr {$y0+round(($vay-$vax)*$e)}]
		} elseif {abs(abs($tempo)-1.0) < 0.2} {
		    # quasi orthogonaux (arbitraire)
		    set tempo [expr {$e/$tempo}]
		    ::tpg::Chemin::appendPoint nc I [expr {$x0+round($vax*$tempo)}] [expr {$y0+round($vay*$tempo)}]
		} else {
		    error "le raccord Interne-Externe doit être colinéaire ou quasi orthogonal"
		}
	    } elseif {$qa == "E"} {
		# E -> E
		# puts "vax=$vax vay=$vay vbx=$vbx vby=$vby"
		set tempo [expr {$e/(1.0+$vax*$vbx+$vay*$vby)}]
		::tpg::Chemin::appendPoint nc E [expr {$x0+round(($vay+$vby)*$tempo)}] [expr {$y0+round((-$vax-$vbx)*$tempo)}]
	    } else {
		error "qa == $qa"
	    }
	} else {
	    error "qb == $qb"
	}
	# attention a l'ordre
	set xa $x0
	set ya $y0
	set x0 $xb
	set y0 $yb
	set qa $qb
	set vax $vbx
	set vay $vby
    }
    ::tpg::Chemin::supprimeDoubles nc
    return $nc
}

################################
# fonctions d'info sur chemins #
################################

set HELP(::tpg::Chemin::minimax) {
    retourne la liste "$xmin $ymin $xmax $ymax" des coordonnées extrèmes d'un chemin $chemin
}
proc ::tpg::Chemin::minimax {chemin} {
    set xmin [lindex $chemin 0]
    set ymin [lindex $chemin 1]
    set xmax $xmin
    set ymax $ymin
    foreach {q x y} [lrange $chemin 2 end] {
	if {$x < $xmin} {
	    set xmin $x
	} elseif {$x > $xmax} {
	    set xmax $x
	}
	if {$y < $ymin} {
	    set ymin $y
	} elseif {$y > $ymax} {
	    set ymax $y
	}
    }
    return [list $xmin $ymin $xmax $ymax]
}

set HELP(::tpg::Chemin::isClos) {
    retourne 1 si le chemin est clos
}
proc ::tpg::Chemin::isClos {chemin} {
    set n [expr {[llength $chemin] - 2}]
    if {[lindex $chemin 0] != [lindex $chemin $n]} {
	return 0
    } 
    if {[lindex $chemin 1] != [lindex $chemin end]} {
	return 0
    }
    return 1
}

set Aide(::tpg::Chemin::tours) {
    le chemin est supposé clos
}
proc ::tpg::Chemin::tours {chemin} {
    set nt 0
    set i [llength $chemin]
    incr i -5
    set x0 [lindex $chemin $i]
    incr i
    set y0 [lindex $chemin $i]
    set x1 [lindex $chemin 0]
    set y1 [lindex $chemin 1]
    set vax [expr {$x1 - $x0}]
    set vay [expr {$y1 - $y0}]
    set dp [::tpg::Vector::getDir $vax $vay]
    # puts "getDir $vax $vay -> $dp"
    set x0 $x1
    set y0 $y1
    foreach {q x1 y1} [lrange $chemin 2 end] {
	# puts "($x1 - $x0) ($y1 - $y0)"
	set vbx [expr {$x1 - $x0}]
	set vby [expr {$y1 - $y0}]
	set di [::tpg::Vector::getDir $vbx $vby]
	
	set dt [expr {$di - $dp}]
	if {$dt < -8} {
	    incr dt 16
	} elseif {$dt > 8} {
	    incr dt -16
	} elseif {$dt == 8 || $dt == -8} {
	    if {[tpg::Vector::isExactDir $di]} {
		error "angle de 180 degrés interdit : ($x0, $y0) de $chemin"
	    } else {
		# il faudrait du long long
		set pv [expr {double($vax)*double($vby)-double($vbx)*double($vay)}]
		if {$pv > 0} {
		    set dt 8
		} elseif {$pv == 0} {
		    error "angle de 180 degrés interdit : ($x0, $y0) de $chemin"
		} else {
		    set dt -8
		}
	    } 
	}
	incr nt $dt
	# puts "getDir $vbx $vby -> $di dt=$dt nt=$nt"
	set x0 $x1
	set y0 $y1
	set dp $di
	set vax $vbx
	set vay $vby
    }
    if {$nt & 16 != 0} {
	error "nt == $nt devrait être un multiple de 16"
    }
    set nt [expr {$nt / 16}]
    if {$nt != 1 && $nt != -1} {
	error "chemin de $nt tours"
    }
    return $nt
}

############################
# modificateurs de chemins #
############################

set HELP(::tpg::Chemin::appendPoint) {
    ajoute au chemin de nom $cheminName un point supplémentaire, le segment étant de qualité $qualite
    (E, I ou C)
}
proc ::tpg::Chemin::appendPoint {cheminName qualite x y} {
    upvar $cheminName chemin
    # puts "appendPoint $qualite $x $y"
    if {$chemin == {}} {
	lappend chemin $x $y
    } else {
	lappend chemin $qualite $x $y
    }
}

set HELP(::tpg::Chemin::appendArc) {
    ajoute au chemin de nom $cheminName un arc, les segments étant de qualité $qualite
    (E, I ou C)
    Le nombre de segments est $nseg
    Le centre est $x $y
    le rayon est $r
    L'angle de départ est $ad degrés
    L'angle d'arrivée est $af degrés
    
}
proc ::tpg::Chemin::appendArc {cheminName q ad af nseg x y r} {
    upvar $cheminName chemin
    if {$nseg <= 0} {
	error "le nombre de segments doit etre >0"
    }
    set pas [expr {double($af - $ad) / $nseg}]
    for {set n 0} {$n<=$nseg} {incr n} {
	
	set a [expr {(($pas * $n) + $ad) * 0.0174532925199432953}]
	set c [expr {round($x+$r*cos($a))}]
	set s [expr {round($y+$r*sin($a))}]
	lappend chemin $q $c $s
    }
}

set HELP(::tpg::Chemin::supprimeDoubles) {
    Nettoie le chemin pour supprimer les points successifs confondus
    Un chemin clos (de 3 points au moins) reste clos
}
proc ::tpg::Chemin::supprimeDoubles {cheminName} {
    upvar $cheminName chemin

    # on pourrait utiliser lreplace

    set xp [lindex $chemin 0]
    set yp [lindex $chemin 1]
    set retour [new $xp $yp]
    foreach {q x y} [lrange $chemin 2 end] {
	if {$xp != $x || $yp != $y} {
	    ::tpg::Chemin::appendPoint retour $q $x $y
	    set xp $x
	    set yp $y
	}
    }
    set chemin $retour
}

#####################################################################
# modificateurs de chemins. Il est conseillé d'en créer de nouveaux #
#####################################################################

proc ::tpg::Chemin::transform {cheminName transform} {
    upvar $cheminName chemin
    set chemin [transformed $transform $chemin]
}

proc ::tpg::Chemin::transform2 {cheminName transform argum} {
    upvar $cheminName chemin
    set chemin [::tpg::Chemin::transformed2 $transform $chemin $argum]
}

proc ::tpg::Chemin::translate {cheminName dx dy} {
    upvar $cheminName chemin
    set chemin [::tpg::Chemin::translated $dx $dy $chemin]
}

proc ::tpg::Chemin::dilate {cheminName fact} {
    upvar $cheminName chemin
    set chemin [::tpg::Chemin::dilated $fact $chemin]
}





# COUPE PAS FINIE

proc ::tpg::Chemin::coupeSimple {chemin xc0 yc0 xc1 yc1} {
    set x0 [lindex $chemin 0]
    set y0 [lindex $chemin 1]
    foreach {q x1 y1} [lrange $chemin 2 end] {
	set n [
    }
    
}

set rien {    
    
    (const SB& canif) {
	Pix pn=this->first();
	while(pn)  {
	    SB& sbn=(*this)(pn);
	    Point pt1, pt2;
	    int n=sbn.intersection(canif, pt1, pt2);
    if (n>0) {
      if (n!=1) {
        cerr<<"coupe_simple : canif parallèle interdit" << endl;
        return n;
      } else {
        Corrections c=sbn.getcorr();
        Pix pdel=pn;
        this->next(pdel);
        while(pdel) {
          this->del(pdel, 1);
        }
        if (!(pt1==sbn.getsommet())) {
          this->append(pt1, c);
        }
        return 1;
      }
    }
  this->next(pn);
  }
  return 0;
}


}


