# RCS: @(#) $Id: eqvp.0.4.tcl,v 1.3 2002/06/25 08:43:09 fab Exp $

package provide eqvp 0.4

# 22 juin 2001 (FP) passage à supercomplex
# 23 juillet 2001 (FP) fidevObj

package require fidev
package require pauli 1.2
package require blasObj 0.2
package require supercomplex 0.2

#package require m22c
#package require optiquePlane 0.1

fidev_load ../src/libtclzeroscomplexes.0.4 zerosComplexes

# Un nom de tableau $alName étant donné, on retourne les éléments
# d'indice xpp, ypm, xmm,...
# correspondant à des listes de parties imaginaires
# telles que, pour la partie réelle $XNm ou $XNp, 

proc ::zerosComplexes::beginOutside {alName polar eps1 eps2 d1N d2N kx0N XNm XNp YNmin YNmax divOfPeriod NDMAX DYMIN} {
    upvar $alName al

    puts stderr "calcul des intervalles"

    ######################################################################
    # recherche des listes de paires de points qui encadrent les courbes #
    # xpmList : courbes réel pur positif sur l'axe Re(z) = XNm           #
    # xppList : courbes réel pur positif sur l'axe Re(z) = XNp           #
    # ypmList : courbes imaginaire pur positif sur l'axe Re(z) = XNm     #
    # ...                                                                #
    ######################################################################

    puts stderr "polar = $polar"

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

    set erreurs [list]

    # Recherches des zéros sur les lignes débutant en Re(z)<0 
    set lm [list]
    foreach YN $al(${xy_mp}m) {
	set Z [supercomplex create xy $XNm $YN]
        if {[catch {::zerosComplexes::zeroOnCurve $ImRe($xy_mp) $polar $eps1 $eps2 $d1N $d2N $kx0N $Z $sens($xy_mp) $dl $dtheta $DZM1 $DZM2} rac]} {
            lappend erreurs "*** $rac ***"
        } else {
            lappend lm $rac
        }
    }

    # Recherches des zéros sur les lignes imaginaire pur négatif, débutant en Re(z)>0 
    set lp [list]
    foreach YN $al(${xy_mp}p) {
	set Z [supercomplex create xy $XNp $YN]
	if {[catch {::zerosComplexes::zeroOnCurve $ImRe($xy_mp) $polar $eps1 $eps2 $d1N $d2N $kx0N $Z $sens($xy_mp) $dl $dtheta $DZM1 $DZM2} rac]} {
            lappend erreurs "*** $rac ***"
        } else {
            lappend lp $rac
        }
    }
    
    set tout [list]
    foreach rac [concat $lm $lp] {
        set x [supercomplex re $rac]
        set y [supercomplex im $rac]
        if {($y > 0) || ($y == 0) && ($x >= 0)} {
            lappend tout "$rac"
        }
    }

    puts stderr [supercomplex module [lindex $tout 0]]
    set tout [lsort -command ::zerosComplexes::compareRacines $tout]
    puts stderr [supercomplex module [lindex $tout 0]]

    set racines [list]

    set Zprec [lindex $tout 0]
    lappend racines $Zprec
    foreach Z [lrange $tout 1 end] {
        if {[supercomplex module [supercomplex sub $Z $Zprec]] <= $DZwarn} {
	    lappend erreurs "*** racine double en $Z ***"
	} else {
            lappend racines $Z
        }
	set Zprec $Z
    }

set rien {

    set im 0
    foreach Z $lm {
	if {[supercomplex im $Z] > 0 || ([supercomplex im $Z] == 0 && [supercomplex re $Z] >= 0)} {
	    break
	}
	incr im
    }
    set ip 0
    foreach Z $lp {
	if {[supercomplex im $Z] > 0 || ([supercomplex im $Z] == 0 && [supercomplex re $Z] >= 0)} {
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
}

    puts stderr A[supercomplex module [lindex $tout 0]]
    if {$erreurs != {}} {
        # si vide, $tout devient une chaine et non plus une liste
        set tout [concat $tout $erreurs]
    }
    puts stderr B[supercomplex module [lindex $tout 0]]
    return $tout
}


proc ::zerosComplexes::compareRacines {z1 z2} {
    if {[catch  {supercomplex re $z1} z1r]} {
        return 1
    }
    if {[catch {supercomplex im $z1} z1i]} {
        return 1
    }
    if {[catch {supercomplex re $z2} z2r]} {
        return -1
    }
    if {[catch {supercomplex im $z2} z2i]} {
        return -1
    }

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

    set a1 [supercomplex arg $z1]
    set a2 [supercomplex arg $z2]
    set da [expr {$a1 - $a2}]
    if {$da > 0} {
	return 1
    } elseif {$da < 0} {
	return -1
    } else {
	return 0
    }

    set a1 [supercomplex arg $z1]
    set a2 [supercomplex arg $z2]
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
    set kParaNCarre [supercomplex mul $kParaN $kParaN]
    set kPerp0N [supercomplex sqrt [complexes::sub 1.0 $kParaNCarre]]
    set kPerp1N [supercomplex sqrt [complexes::sub $eps1 $kParaNCarre]]
    set arg [supercomplex mul [supercomplex create xy 0.0 [expr {2.0*$PI*$dN}]] $kPerp1N]
    # TM
    if {$polar == "TE"} {
	set rp [supercomplex div $kPerp1N $kPerp0N]
    } elseif {$polar == "TM"} {
	set rp [supercomplex div $kPerp1N [complexes::mul $eps1 $kPerp0N]]
    } else {
	error "bad polar \"$polar\""
    }
    set rpInv [supercomplex inv $rp]
    set expp [supercomplex mul $rpInv [supercomplex exp $arg]]
    set expm [supercomplex mul $rpInv [supercomplex exp [supercomplex neg $arg]]]
    set rst [supercomplex realMul 0.5 [supercomplex sub 1.0 $rp]]
    set ust [supercomplex realMul 0.5 [supercomplex add 1.0 $rp]]
    set rstCarre [supercomplex mul $rst $rst]
    set ustCarre [supercomplex mul $ust $ust]
    set m11 [supercomplex sub [supercomplex mul $ustCarre $expm] [supercomplex mul $rstCarre $expp]]
    set m22 [supercomplex sub [supercomplex mul $ustCarre $expp] [supercomplex mul $rstCarre $expm]]
    set m12 [supercomplex mul [supercomplex mul $rst $ust] [supercomplex sub $expp $expm]]
    set m21 [supercomplex neg $m12]
    return [list $m11 $m12 $m21 $m22]
}

proc interfaceTM {eps1 eps2 kParaN} {
    set kParaNCarre [supercomplex mul $kParaN $kParaN]
    set kPerp1N [supercomplex sqrt [complexes::sub $eps1 $kParaNCarre]]
    set kPerp2N [supercomplex sqrt [complexes::sub $eps2 $kParaNCarre]]
    # TM
    set rp [supercomplex div [complexes::mul $eps1 $kPerp2N] [complexes::mul $eps2 $kPerp1N]]
    set rst [supercomplex realMul 0.5 [supercomplex sub 1.0 $rp]]
    set ust [supercomplex realMul 0.5 [supercomplex add 1.0 $rp]]
    return [list $ust $rst $rst $ust]
}

proc interfaceTE {eps1 eps2 kParaN} {
    set kParaNCarre [supercomplex mul $kParaN $kParaN]
    set kPerp1N [supercomplex sqrt [complexes::sub $eps1 $kParaNCarre]]
    set kPerp2N [supercomplex sqrt [complexes::sub $eps2 $kParaNCarre]]
    # TE
    set rp [supercomplex div $kPerp2N $kPerp1N]
    set rst [supercomplex realMul 0.5 [supercomplex sub 1.0 $rp]]
    set ust [supercomplex realMul 0.5 [supercomplex add 1.0 $rp]]
    return [list $ust $rst $rst $ust]
}

proc intervalle {eps kParaN dN} {
    global PI
    set kParaNCarre [supercomplex mul $kParaN $kParaN]
    set kPerpN [supercomplex sqrt [complexes::sub $eps $kParaNCarre]]
    set arg [supercomplex mul [supercomplex create xy 0.0 [expr {2.0*$PI*$dN}]] $kPerpN]
    set expp [supercomplex exp $arg]
    set expm [supercomplex exp [supercomplex neg $arg]]
    return [list $expm 0.0 0.0 $expp]
}

proc matValPropre {md kx0N dN} {
    global PI
    if {[llength $md] != 4} {
	error "bad matrix"
    }
    foreach {md11 md12 md21 md22} $md {}
    set expm [expr {exp(-2.0*$PI*$dN*$kx0N)}]
    return [list [supercomplex sub $md11 $expm] $md12 $md21 [supercomplex sub $md22 $expm]]
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
    set t_ab [supercomplex inv $a11]
    set r_ab [supercomplex mul $t_ab $a21]
    set r_ba [supercomplex neg [supercomplex mul $t_ab $a12]]
    set t_ba [supercomplex add $a22 [supercomplex mul $a21 $r_ba]]
    set r_ab [supercomplex toRTpi $r_ab]
    set r_ba [supercomplex toRTpi $r_ba]
    set t_ab [supercomplex toRTpi $t_ab]
    set t_ba [supercomplex toRTpi $t_ba]
    return [list $r_ab $r_ba $t_ab $t_ba]
}

proc vectPropre {mvp} {
    if {[llength $mvp] != 4} {
	error "bad matrix"
    }
    foreach {mvp11 mvp12 mvp21 mvp22} $mvp {}
    set vp1 [supercomplex toRTpi $mvp11]
    set vp2 [supercomplex toRTpi $mvp12]
    # Choix de la normalisation : différence = 2
    set t [supercomplex div 2.0 [supercomplex sub $vp1 $vp2]]
    set vp1 [supercomplex mul $t $vp1]
    set vp2 [supercomplex mul $t $vp2]
    set vp1 [supercomplex toXY $vp1]
    set vp2 [supercomplex toXY $vp2]
    return [list $vp1 $vp2]
}

proc qq {} {
    set $kappayNCarre [supercomplex mul $kappayN $kappayN]
    set kappax0N [supercomplex sqrt [complexes::sub 1.0 $kappayNCarre]]
    set kappax1N [supercomplex sqrt [complexes::sub $eps1 $kappayNCarre]]
    set kappax2N [supercomplex sqrt [complexes::sub $eps2 $kappayNCarre]]
    # reflexion TM 0 sur 1 ou 0 sur 2
    set rpi1 [supercomplex div $kappax1M [complexes::mul $eps1 $kappax0N]]
    set rpi2 [supercomplex div $kappax1M [complexes::mul $eps2 $kappax0N]]
    set rhoSurTau_x1 [supercomplex realMul 0.5 [supercomplex sub 1.0 $rpi1]]
    set rhoSurTau_x2 [supercomplex realMul 0.5 [supercomplex sub 1.0 $rpi2]]
    set unSurTau_x1 [supercomplex realMul 0.5 [supercomplex add 1.0 $rpi1]]
    set unSurTau_x2 [supercomplex realMul 0.5 [supercomplex add 1.0 $rpi2]]
    set rho_x1 [supercomplex div $rhoSurTau_x1 $unSurTau_x1]
    set rho_x2 [supercomplex div $rhoSurTau_x2 $unSurTau_x2]
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
	set adet [supercomplex module [::m22c::det $mvp]]
	if {$adet > $maxDet} {
	    set maxDet $adet
	}
	foreach {alp alm} [vectPropre $mvp] {}
	set kappayNcarre [supercomplex mul $kappayN $kappayN]
	set pix0 [supercomplex sqrt [supercomplex sub 1.0 $kappayNcarre]]
	if {$polar == "TE"} {
	    set pix1 [supercomplex sqrt [supercomplex sub $eps1 $kappayNcarre]]
	    set pix2 [supercomplex sqrt [supercomplex sub $eps2 $kappayNcarre]]
	} elseif {$polar == "TM"} {
	    set pix1 [supercomplex div [supercomplex sqrt [supercomplex sub $eps1 $kappayNcarre]] $eps1]
	    set pix2 [supercomplex div [supercomplex sqrt [supercomplex sub $eps2 $kappayNcarre]] $eps2]
	} else {error "bad polar \"$polar\""}
	set rpix1 [supercomplex div $pix0 $pix1]
	set rpix2 [supercomplex div $pix0 $pix2]
	set rhoSurTau_x1 [supercomplex realMul 0.5 [supercomplex sub 1.0 $rpix1]]
	set rhoSurTau_x2 [supercomplex realMul 0.5 [supercomplex sub 1.0 $rpix2]]
	set unSurTau_x1 [supercomplex realMul 0.5 [supercomplex add 1.0 $rpix1]]
	set unSurTau_x2 [supercomplex realMul 0.5 [supercomplex add 1.0 $rpix2]]
	lappend ptA1p [supercomplex add [supercomplex mul $unSurTau_x1 $alp] [supercomplex mul  $rhoSurTau_x1 $alm]]
	lappend ptA1m [supercomplex add [supercomplex mul $unSurTau_x1 $alm] [supercomplex mul  $rhoSurTau_x1 $alp]]
	lappend ptA2p [supercomplex add [supercomplex mul $unSurTau_x2 $alp] [supercomplex mul  $rhoSurTau_x2 $alm]]
	lappend ptA2m [supercomplex add [supercomplex mul $unSurTau_x2 $alm] [supercomplex mul  $rhoSurTau_x2 $alp]]
    }
    puts stderr "maxDet = $maxDet"
    return [list $ptA1p $ptA1m $ptA2p $ptA2m]
}


proc bigMatrix {polar eps1 eps2 d1N d2N kx0N racines} {

    set rara [list]
    foreach z $racines {
	lappend rara [list [supercomplex re $z] [supercomplex im $z]]
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
set eps1 [supercomplex create xy 12.5254 0.5593]
set eps2 [supercomplex create xy -140.4 3.555]

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
    set d1 [supercomplex mul $c11 $c22]
    set d2 [supercomplex mul $c12 $c21]
}
foreach {p1 pX pY pZ} $m1qA {
    set p1 [supercomplex toRTpi $p1]
    set pY [supercomplex toRTpi $pY]
    set pZ [supercomplex toRTpi $pZ]
    set p1Carre [supercomplex mul $p1 $p1]
    set pYCarre [supercomplex mul $pY $pY]
    set pZCarre [supercomplex mul $pZ $pZ]
    set pVCarre [supercomplex add $pYCarre $pZCarre]
    puts [supercomplex sub $p1Carre $pVCarre]
}

::pauli::det $m1q
::m22c::det [::pauli::pauliToCanon $m1q]

set m1iq [::pauli::inv $m1q]
::pauli::det $m1iq
::m22c::det [::pauli::pauliToCanon $m1iq]


set m1i [::m22c::inv $m1]

}
