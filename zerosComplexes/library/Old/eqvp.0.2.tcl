package provide eqvp 0.2

package require fidev
package require pauli
package require blasObj

package require m22c
package require optiquePlane 0.1

load $fidev_libDir/libfidev_tcl_zeroscomplexes.0.2.so zerosComplexes

# Un nom de tableau $alName étant donné, on retourne les éléments
# d'indice xpp, ypm, xmm,...
# correspondant à des listes de parties imaginaires
# telles que, pour la partie réelle $XNm ou $XNp, 

proc ::zerosComplexes::beginOutside {alName polar eps1 eps2 d1N d2N kx0N XNm XNp YNmin YNmax divOfPeriod NDMAX DYMIN} {
    upvar $alName al

#    puts "calcul des intervalles"

    ######################################################################
    # recherche des listes de paires de points qui encadrent les courbes #
    # xpmList : courbes réel pur positif sur l'axe Re(z) = XNm           #
    # xppList : courbes réel pur positif sur l'axe Re(z) = XNp           #
    # ypmList : courbes imaginaire pur positif sur l'axe Re(z) = XNm     #
    # ...                                                                #
    ######################################################################

    foreach {xpmList ypmList xmmList ymmList} [::zerosComplexes::listOfIntervallesInC $polar $eps1 $eps2 $d1N $d2N $kx0N $XNm $YNmin $YNmax $divOfPeriod] {}
    foreach {xppList yppList xmpList ympList} [::zerosComplexes::listOfIntervallesInC $polar $eps1 $eps2 $d1N $d2N $kx0N $XNp $YNmin $YNmax $divOfPeriod] {}

#    puts "intervalles calculés"

    set al(xpp) [list]
    set al(ypm) [list]
    set al(xmm) [list]
    set al(ymm) [list]
    set al(xpp) [list]
    set al(ypp) [list]
    set al(xmp) [list]
    set al(ymp) [list]


    # à partir de chacune des 8 listes de paires (x + i y1, y + i y2) encadrant les courbes 
    # on calcule des listes de y tel que (x, y) est sur une des 4 familles de courbes

    foreach mpx {m p} XN [list $XNm $XNp] {
	foreach mpf {m p} {
	    foreach ypair [set x${mpf}${mpx}List] {
		foreach {y1 y2} $ypair {}
		lappend al(x${mpf}${mpx}) [::zerosComplexes::findZeroWithCteZrInC Im $polar $eps1 $eps2 $d1N $d2N $kx0N $XN $y1 $y2 $NDMAX $DYMIN]
	    }
	}
	foreach mpf {m p} {
	    foreach ypair [set y${mpf}${mpx}List] {
		foreach {y1 y2} $ypair {}
		lappend al(y${mpf}${mpx}) [::zerosComplexes::findZeroWithCteZrInC Re $polar $eps1 $eps2 $d1N $d2N $kx0N $XN $y1 $y2 $NDMAX $DYMIN]
	    }
	}
    }
#    puts "departs calculés"
}

#
# recherche des zéros
#

proc ::zerosComplexes::zeros {xy_mp alName polar eps1 eps2 d1N d2N kx0N XNm XNp dl dtheta DZM1 DZM2 DZwarn} {
    upvar $alName al

    set sens(ym) 1
    set sens(yp) -1
    set sens(xm) 1
    set sens(xp) -1

    set ImRe(ym) Im
    set ImRe(yp) Im
    set ImRe(xm) Re
    set ImRe(xp) Re

    # Recherches des zéros sur les lignes débutant en Re(z)<0 
    set lm [list]
    foreach YN $al(${xy_mp}m) {
	set Z [::complexes::newXY $XNm $YN]
        catch {::zerosComplexes::zeroOnCurve $ImRe($xy_mp) $polar $eps1 $eps2 $d1N $d2N $kx0N $Z $sens($xy_mp) $dl $dtheta $DZM1 $DZM2} rac
	lappend lm $rac
    }

    # Recherches des zéros sur les lignes imaginaire pur négatif, débutant en Re(z)>0 
    set lp [list]
    foreach YN $al(${xy_mp}p) {
	set Z [::complexes::newXY $XNp $YN]
	catch {::zerosComplexes::zeroOnCurve $ImRe($xy_mp) $polar $eps1 $eps2 $d1N $d2N $kx0N $Z $sens($xy_mp) $dl $dtheta $DZM1 $DZM2} rac
	lappend lp $rac
    }
    
    set tout [lsort -command ::zerosComplexes::compareRacines [concat $lm $lp]]

    set Zprec [lindex $tout 0]
    foreach Z [lrange $tout 1 end] {
	if {[::complexes::module [::complexes::sub $Z $Zprec]] <= $DZwarn} {
	    error "racine double en $Z"
	}
	set Zprec $Z
    }

    set im 0
    foreach Z $lm {
	if {[::complexes::im $Z] > 0 || ([::complexes::im $Z] == 0 && [::complexes::re $Z] >= 0)} {
	    break
	}
	incr im
    }
    set ip 0
    foreach Z $lp {
	if {[::complexes::im $Z] > 0 || ([::complexes::im $Z] == 0 && [::complexes::re $Z] >= 0)} {
	    break
	}
	incr ip
    }
    if {$im == 0 || $ip == 0} {
	puts $lm
	puts $lp
	error "mauvais depart, rendre YNm plus négatif"
    }

    set lmGood [lrange $lm $im end]
    set lpGood [lrange $lp $ip end]

#    puts "[llength $lmGood] + [llength $lpGood] racines calculées"

    set racines [lsort -command ::zerosComplexes::compareRacines [concat $lmGood $lpGood]]

    return $racines
}


proc ::zerosComplexes::compareRacines {z1 z2} {
    set z1r [::complexes::re $z1]
    set z1i [::complexes::im $z1]
    set z2r [::complexes::re $z2]
    set z2i [::complexes::im $z2]

    set dr [expr {$z2r - $z1r}]
    set di [expr {$z1i - $z2i}]

    if {$dr > 0} {
	set cr 1
    } elseif {$dr < 0} {
	set cr -1
    } else {
	set cr 0
    }
    if {$di> 0} {
	set ci 1
    } elseif {$di < 0} {
	set ci -1
    } else {
	set ci 0
    }
    set crci [expr {$cr + $ci}]
    if {$crci != 0} {
	return $crci
    }

    set gr [expr {0.5*($z2r + $z1r)}]
    set gi [expr {0.5*($z2i + $z1i)}]

    if {$gr > $gi} {
	return $cr
    } else {
	return $ci
    }

    set a1 [::complexes::arg $z1]
    set a2 [::complexes::arg $z2]
    set da [expr {$a1 - $a2}]
    if {$da > 0} {
	return 1
    } elseif {$da < 0} {
	return -1
    } else {
	return 0
    }

    set a1 [::complexes::arg $z1]
    set a2 [::complexes::arg $z2]
    set da [expr {$a1 - $a2}]
    if {$da > 0} {
	return 1
    } elseif {$da < 0} {
	return -1
    } else {
	return 0
    }
}

set PI [::expr 4.0*atan(1.0)]

proc videAvide {polar eps1 kParaN dN} {
    global PI
    set kParaNCarre [::complexes::mul $kParaN $kParaN]
    set kPerp0N [::complexes::sqrt [complexes::sub 1.0 $kParaNCarre]]
    set kPerp1N [::complexes::sqrt [complexes::sub $eps1 $kParaNCarre]]
    set arg [::complexes::mul [::complexes::newXY 0.0 [expr {2.0*$PI*$dN}]] $kPerp1N]
    # TM
    if {$polar == "TE"} {
	set rp [::complexes::div $kPerp1N $kPerp0N]
    } elseif {$polar == "TM"} {
	set rp [::complexes::div $kPerp1N [complexes::mul $eps1 $kPerp0N]]
    } else {
	error "bad polar \"$polar\""
    }
    set rpInv [::complexes::inv $rp]
    set expp [::complexes::mul $rpInv [::complexes::exp $arg]]
    set expm [::complexes::mul $rpInv [::complexes::exp [::complexes::neg $arg]]]
    set rst [::complexes::realMul 0.5 [::complexes::sub 1.0 $rp]]
    set ust [::complexes::realMul 0.5 [::complexes::add 1.0 $rp]]
    set rstCarre [::complexes::mul $rst $rst]
    set ustCarre [::complexes::mul $ust $ust]
    set m11 [::complexes::sub [::complexes::mul $ustCarre $expm] [::complexes::mul $rstCarre $expp]]
    set m22 [::complexes::sub [::complexes::mul $ustCarre $expp] [::complexes::mul $rstCarre $expm]]
    set m12 [::complexes::mul [::complexes::mul $rst $ust] [::complexes::sub $expp $expm]]
    set m21 [::complexes::neg $m12]
    return [list $m11 $m12 $m21 $m22]
}

proc interfaceTM {eps1 eps2 kParaN} {
    set kParaNCarre [::complexes::mul $kParaN $kParaN]
    set kPerp1N [::complexes::sqrt [complexes::sub $eps1 $kParaNCarre]]
    set kPerp2N [::complexes::sqrt [complexes::sub $eps2 $kParaNCarre]]
    # TM
    set rp [::complexes::div [complexes::mul $eps1 $kPerp2N] [complexes::mul $eps2 $kPerp1N]]
    set rst [::complexes::realMul 0.5 [::complexes::sub 1.0 $rp]]
    set ust [::complexes::realMul 0.5 [::complexes::add 1.0 $rp]]
    return [list $ust $rst $rst $ust]
}

proc interfaceTE {eps1 eps2 kParaN} {
    set kParaNCarre [::complexes::mul $kParaN $kParaN]
    set kPerp1N [::complexes::sqrt [complexes::sub $eps1 $kParaNCarre]]
    set kPerp2N [::complexes::sqrt [complexes::sub $eps2 $kParaNCarre]]
    # TE
    set rp [::complexes::div $kPerp2N $kPerp1N]
    set rst [::complexes::realMul 0.5 [::complexes::sub 1.0 $rp]]
    set ust [::complexes::realMul 0.5 [::complexes::add 1.0 $rp]]
    return [list $ust $rst $rst $ust]
}

proc intervalle {eps kParaN dN} {
    global PI
    set kParaNCarre [::complexes::mul $kParaN $kParaN]
    set kPerpN [::complexes::sqrt [complexes::sub $eps $kParaNCarre]]
    set arg [::complexes::mul [::complexes::newXY 0.0 [expr {2.0*$PI*$dN}]] $kPerpN]
    set expp [::complexes::exp $arg]
    set expm [::complexes::exp [::complexes::neg $arg]]
    return [list $expm 0.0 0.0 $expp]
}

proc matValPropre {md kx0N dN} {
    global PI
    if {[llength $md] != 4} {
	error "bad matrix"
    }
    foreach {md11 md12 md21 md22} $md {}
    set expm [expr {exp(-2.0*$PI*$dN*$kx0N)}]
    return [list [::complexes::sub $md11 $expm] $md12 $md21 [::complexes::sub $md22 $expm]]
}

proc videAvideTMVerif {eps1 kParaN dN} {
    set m1 [interfaceTM 1.0 $eps1 $kParaN]
    set m2 [intervalle $eps1 $kParaN $dN]
    set m3 [interfaceTM $eps1 1.0 $kParaN]
    return [::m22c::mul [22mul $m1 $m2] $m3]
}

proc 22rt {a} {
    if {[llength $a] != 4} {
	error "bad matrix"
    }
    foreach {a11 a12 a21 a22} $a {}
    set t_ab [::complexes::inv $a11]
    set r_ab [::complexes::mul $t_ab $a21]
    set r_ba [::complexes::neg [::complexes::mul $t_ab $a12]]
    set t_ba [::complexes::add $a22 [::complexes::mul $a21 $r_ba]]
    set r_ab [::complexes::toRTpi $r_ab]
    set r_ba [::complexes::toRTpi $r_ba]
    set t_ab [::complexes::toRTpi $t_ab]
    set t_ba [::complexes::toRTpi $t_ba]
    return [list $r_ab $r_ba $t_ab $t_ba]
}

proc vectPropre {mvp} {
    if {[llength $mvp] != 4} {
	error "bad matrix"
    }
    foreach {mvp11 mvp12 mvp21 mvp22} $mvp {}
    set vp1 [::complexes::toRTpi $mvp11]
    set vp2 [::complexes::toRTpi $mvp12]
    # Choix de la normalisation : différence = 2
    set t [::complexes::div 2.0 [::complexes::sub $vp1 $vp2]]
    set vp1 [::complexes::mul $t $vp1]
    set vp2 [::complexes::mul $t $vp2]
    set vp1 [::complexes::toXY $vp1]
    set vp2 [::complexes::toXY $vp2]
    return [list $vp1 $vp2]
}

proc qq {} {
    set $kappayNCarre [::complexes::mul $kappayN $kappayN]
    set kappax0N [::complexes::sqrt [complexes::sub 1.0 $kappayNCarre]]
    set kappax1N [::complexes::sqrt [complexes::sub $eps1 $kappayNCarre]]
    set kappax2N [::complexes::sqrt [complexes::sub $eps2 $kappayNCarre]]
    # reflexion TM 0 sur 1 ou 0 sur 2
    set rpi1 [::complexes::div $kappax1M [complexes::mul $eps1 $kappax0N]]
    set rpi2 [::complexes::div $kappax1M [complexes::mul $eps2 $kappax0N]]
    set rhoSurTau_x1 [::complexes::realMul 0.5 [::complexes::sub 1.0 $rpi1]]
    set rhoSurTau_x2 [::complexes::realMul 0.5 [::complexes::sub 1.0 $rpi2]]
    set unSurTau_x1 [::complexes::realMul 0.5 [::complexes::add 1.0 $rpi1]]
    set unSurTau_x2 [::complexes::realMul 0.5 [::complexes::add 1.0 $rpi2]]
    set rho_x1 [::complexes::div $rhoSurTau_x1 $unSurTau_x1]
    set rho_x2 [::complexes::div $rhoSurTau_x2 $unSurTau_x2]
}


proc preTermesA {polar eps1 eps2 d1N d2N kx0N racines} {
    # listes des pretermes
    set ptA1p [list]
    set ptA1m [list]
    set ptA2p [list]
    set ptA2m [list]
    set maxDet 0.0
    foreach kappayN $racines {
	set m1 [videAvide $polar $eps1 $kappayN $d1N]
	set m2 [videAvide $polar $eps2 $kappayN $d2N]
	set md [::m22c::mul $m1 $m2]
	set mvp [matValPropre $md $kx0N [expr {$d1N + $d2N}]]
	# verif
	set adet [::complexes::module [::m22c::det $mvp]]
	if {$adet > $maxDet} {
	    set maxDet $adet
	}
	foreach {alp alm} [vectPropre $mvp] {}
	set kappayNcarre [::complexes::mul $kappayN $kappayN]
	set pix0 [::complexes::sqrt [::complexes::sub 1.0 $kappayNcarre]]
	if {$polar == "TE"} {
	    set pix1 [::complexes::sqrt [::complexes::sub $eps1 $kappayNcarre]]
	    set pix2 [::complexes::sqrt [::complexes::sub $eps2 $kappayNcarre]]
	} elseif {$polar == "TM"} {
	    set pix1 [::complexes::div [::complexes::sqrt [::complexes::sub $eps1 $kappayNcarre]] $eps1]
	    set pix2 [::complexes::div [::complexes::sqrt [::complexes::sub $eps2 $kappayNcarre]] $eps2]
	} else {error "bad polar \"$polar\""}
	set rpix1 [::complexes::div $pix0 $pix1]
	set rpix2 [::complexes::div $pix0 $pix2]
	set rhoSurTau_x1 [::complexes::realMul 0.5 [::complexes::sub 1.0 $rpix1]]
	set rhoSurTau_x2 [::complexes::realMul 0.5 [::complexes::sub 1.0 $rpix2]]
	set unSurTau_x1 [::complexes::realMul 0.5 [::complexes::add 1.0 $rpix1]]
	set unSurTau_x2 [::complexes::realMul 0.5 [::complexes::add 1.0 $rpix2]]
	lappend ptA1p [::complexes::add [::complexes::mul $unSurTau_x1 $alp] [::complexes::mul  $rhoSurTau_x1 $alm]]
	lappend ptA1m [::complexes::add [::complexes::mul $unSurTau_x1 $alm] [::complexes::mul  $rhoSurTau_x1 $alp]]
	lappend ptA2p [::complexes::add [::complexes::mul $unSurTau_x2 $alp] [::complexes::mul  $rhoSurTau_x2 $alm]]
	lappend ptA2m [::complexes::add [::complexes::mul $unSurTau_x2 $alm] [::complexes::mul  $rhoSurTau_x2 $alp]]
    }
    puts stderr "maxDet = $maxDet"
    return [list $ptA1p $ptA1m $ptA2p $ptA2m]
}


proc bigMatrix {polar eps1 eps2 d1N d2N kx0N racines} {

    set rara [list]
    foreach z $racines {
	lappend rara [list [::complexes::re $z] [::complexes::im $z]]
    }
    set bRacines [::blas::newVector doublecomplex $rara]

    ::zerosComplexes::beginOutside al $polar $eps1 $eps2 $d1N $d2N $kx0N $XNm $XNp $YNm $YNp $divOfPeriod $NDMAX $DYMIN 
    set racines [::zerosComplexes::zerosI- al $polar $eps1 $eps2 $d1N $d2N $kx0N $XNm $XNp $dl $dtheta $DZM1 $DZM2 $DZwarn]    
    foreach {ptA1p ptA1m ptA2p ptA2m} [preTermesA $polar $eps1 $eps2 $d1N $d2N $kx0N $racines] {}

    set mInfini [llength $racines]
    if {$mInfini % 2 == 1} {
	incr mInfini -1
    } else {
	incr mInfini -2
    }
    set pInfini [expr {$mInfini/2}]
    set mList [list]
    for {set m 0} {$m <= $mInfini} {incr m} {lappend mList $m}
    set pList [list 0]
    for {set i 1} {$i <= $pInfini} {incr i} {lappend pList [expr {-$i}] $i}
}


    

set rien {

set polar TM
set eps1 [::complexes::newXY 12.5254 0.5593]
set eps2 [::complexes::newXY -140.4 3.555]

# set eps1 1.0
# set eps2 2.0

set lambda 1.55
set d 0.85
set r 0.08
set kx0N 0.0
set XNm -8.0 
set XNp 8.0
set YNm -6.0
set YNp 50.0
set NDMAX 100
set DYMIN 1e-6
set DZM1 1e-6
set DZM2 1e-12
set DZwarn 1e-4
set divOfPeriod 20
set dl 0.02
set dtheta 0.05

set DEUXPI [expr {8.0*atan(1.0)}]

set k0 [expr {$DEUXPI/$lambda}]
set dN [expr {$d/$lambda}]

set r2 $r
set r1 [expr {1.0 - $r2}]
set d1N [expr {$r1*$dN}]
set d2N [expr {$r2*$dN}]






::zerosComplexes::beginOutside al $polar $eps1 $eps2 $d1N $d2N $kx0N $XNm $XNp $YNm $YNp $divOfPeriod $NDMAX $DYMIN 
set racines1 [::zerosComplexes::zerosI- al $polar $eps1 $eps2 $d1N $d2N $kx0N $XNm $XNp $dl $dtheta $DZM1 $DZM2 $DZwarn]
set racines2 [::zerosComplexes::zerosI+ al $polar $eps1 $eps2 $d1N $d2N $kx0N $XNm $XNp $dl $dtheta $DZM1 $DZM2 $DZwarn]

puts $racines1
puts $racines2

set racines $racines1

# ancien

set kParaN [lindex $racines end]
set kParaN [lindex $racines 0]

# verification du zero
::zerosComplexes::eqvp 0 TM $eps1 $eps2 $d1N $d2N $kx0N $kParaN

# verification des formules locales
set m1 [videAvideTMVerif $eps1 $kParaN $d1N]
set m2 [videAvideTMVerif $eps2 $kParaN $d2N]
set md [::m22c::mul $m1 $m2]
::m22c::det $md
foreach {r12 r21 t12 t21} [22rt $md] {}

set m1 [videAvideTM $eps1 $kParaN $d1N]
set m2 [videAvideTM $eps2 $kParaN $d2N]
set md [::m22c::mul $m1 $m2]
::m22c::det $md
foreach {r12 r21 t12 t21} [22rt $md] {}

# verification de la valeur propre
set mvp [matValPropre $md $kx0N $dN]
::m22c::det $mvp


set m1q [trancheNue $eps1 [expr {2.0*$PI*$d1N}] $kParaN TM]
set m2q [trancheNue $eps2 [expr {2.0*$PI*$d2N}] $kParaN TM]
set mdq [::pauli::mul $m1q $m2q]
::pauli::det $mdq
set mdB [::pauli::pauliToCanon $mdq]


set m1 [videAvideTMVerif $eps1 $kParaN $d1N]
set m1qA [::pauli::canonToPauli $m1]
::m22c::det $m1
::pauli::det $m1qA
::m22c::det [pauli::pauliToCanon $m1qA]
foreach {c11 c12 c21 c22} $m1 {
    set d1 [::complexes::mul $c11 $c22]
    set d2 [::complexes::mul $c12 $c21]
}
foreach {p1 pX pY pZ} $m1qA {
    set p1 [::complexes::toRTpi $p1]
    set pY [::complexes::toRTpi $pY]
    set pZ [::complexes::toRTpi $pZ]
    set p1Carre [::complexes::mul $p1 $p1]
    set pYCarre [::complexes::mul $pY $pY]
    set pZCarre [::complexes::mul $pZ $pZ]
    set pVCarre [::complexes::add $pYCarre $pZCarre]
    puts [::complexes::sub $p1Carre $pVCarre]
}

::pauli::det $m1q
::m22c::det [::pauli::pauliToCanon $m1q]

set m1iq [::pauli::inv $m1q]
::pauli::det $m1iq
::m22c::det [::pauli::pauliToCanon $m1iq]


set m1i [::m22c::inv $m1]

}
