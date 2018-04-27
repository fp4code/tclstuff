#!/usr/local/bin/tclsh

package require fidev
package require complexes

# valeurs du réseau r = 0.5, d = 0.15
set epsilon1m [::complexes::newXY -32.797 0.458]
set epsilon1sc [::complexes::newXY 13.435 0.589]
# spsilon2 = 9.0
set lambda 0.8
set PI [expr {4.0*atan(1.0)}]
set k0 [expr {2.0*$PI/$lambda}]

# termes de matrice calculés par Stéphane 
# 0 correspond à l'ordre 0 dans le vide
# 1 est le premier mode dans le réseau
# 2 est l'ordre 0 dans le semiconducteur, réfléchi entièrement par le multicouche 

set r01 [::complexes::newXY  0.774654  0.0506559]                    ;# D0 -> R0
set t01 [::complexes::newXY  2.1416    0.205053]                     ;# D0 -> B0
set r21 [::complexes::newXY  0.8263431136915123 0.3381866192765766]  ;# U0 -> T0
set t21 [::complexes::newXY  0.477141666448008 0.5380125504921922]   ;# U0 -> A0

set r10 [::complexes::newXY -0.769818 -0.0828238]                    ;# A0 -> B0
set t10 [::complexes::newXY  0.184135  0.00400097]                   ;# A0 -> R0
set r12 [::complexes::newXY 0.01273955985315534 0.8647816275746102]  ;# B0 -> A0
set t12 [::complexes::newXY 0.1319393526657234 0.1280145581997857]   ;# B0 -> T0

# vecteur d'onde du premier mode de réseau

set ky [::complexes::newXY 41.7756 1.50667]

# matrices S C

set s01 [list $r01 $t10 $t01 $r10]
set s12 [list $r12 $t21 $t12 $r21]
set s21 [list $r21 $t12 $t21 $r12]
set s10 [list $r10 $t01 $t10 $r01]


# combinaison de matrices S scalaires
namespace eval scal_s {}

proc ::scal_s::comb {ab bc} {
    if {[llength $ab] != 4 || [llength $bc] != 4} {
	error "bad argums"
    }
    foreach {rab tba tab rba} $ab {}
    foreach {rbc tcb tbc rcb} $bc {}
    set inv [::complexes::inv [::complexes::sub 1.0 [::complexes::mul $rba $rbc]]]
    set nba [::complexes::mul $tba $inv]
    set nbc [::complexes::mul $tbc $inv]
    set rac [::complexes::add $rab [::complexes::mul $nba [::complexes::mul $rbc $tab]]]
    set rca [::complexes::add $rcb [::complexes::mul $nbc [::complexes::mul $rba $tcb]]]
    set tca [::complexes::mul $nba $tcb]
    set tac [::complexes::mul $nbc $tab]
    return [list $rac $tca $tac $rca]
}

# Pour un réseau infiniment fin 

foreach {r02p t20p t02p r20p} [::scal_s::comb $s01 $s12] {}

puts "verif reciprocite : 3,0 (=eps AlAs) = [complexes::div $t02p $t20p]"
puts "verif pseudo-reciprocite : [::complexes::div [::complexes::div $ky $epsilon1sc] $k0] [complexes::div $t10 $t01]"

#set t02 [::complexes::div [::complexes::mul $t01 $t12] [::complexes::sub 1.0 [::complexes::mul $r10 $r12]]]

#set t00 [::complexes::div [::complexes::mul $t01 $t10] [::complexes::sub 1.0 [::complexes::mul $r10 $r10]]]

# matrice S d'un intervalle homogène

proc sinterv {ky h} {
    set arg [::complexes::realMul $h $ky]
    set iarg [::complexes::iMul $arg]
    set rab 0.0
    set rba 0.0
    set tab [::complexes::exp $iarg]
    set tba $tab
    return [list $rab $tba $tab $rba]
}

# matrice S d'un miroir parfait d'un côté (absorbant de l'autre)

proc smiroir {eiphi} {
    return [list $eiphi 0.0 0.0 0.0]
}


# retourne l'amplitude de réflexion sur une interface ab, derrière laquelle on a un miroir tphase
# On superpose donc
#             1   -> | -> tab
#             rab <- | <- 0
# et
#             0   -> | -> X*rba
#           X*tba <- | <- X*1
# soit
#             1   -> | -> tab + X*rba
#   R = rab+X*tba <- | <- X
# avec          X = tphase*(tab + X*rba), soit X = tphase*tab/(1 - tphase*rba)
# donc          R = rab +  tphase*tab*tba/(1 - tphase*rba)
#               R = rab*(1 + ((tphase*rba)*tab*tba/(rab*rba))/(1 - tphase*rba))
#               R = rab*(1 + tphase*rba(1 - tab*tba/(rab*rba)))/(1 - tphase*rba)

proc combine {rab rba tphase ttsrr} {
    set umttsrr [::complexes::sub 1.0 $ttsrr]
    set rtp [::complexes::mul $rba $tphase]
    set t [::complexes::div [::complexes::sub 1.0 [::complexes::mul $rtp $umttsrr]] [::complexes::sub 1.0 $rtp]]
    return [::complexes::mul $rab $t]
}

proc combineWithS {s tphase} {
    foreach {rab tba tab rba} $s {}    
    set rtp [::complexes::mul $rba $tphase]
    return [::complexes::add $rab [::complexes::div [::complexes::mul $tphase [::complexes::mul $tab $tba]] \
                                                    [::complexes::sub 1.0 $rtp]]]
}



set h 0.055
# set h 2

set l_eiphi [list]
for {set i 0} {$i <= 80} {incr i} {
    set phaseN [expr {$i/40.}]
    lappend l_eiphi [::complexes::newRTpi 1.0 $phaseN]
} 
 
proc calculeR0 {h l_eiphi} {
    global ky s01 s12 r01 r10 t01 t10 r12 r21 t12 t21 

    # accélérateurs de calcul de "combine" : (t01*t10)/(r01*r10) et (t12*t21)/(r12*r21)
    
    set ttsrr01 [::complexes::div [::complexes::mul $t01 $t10] [::complexes::mul $r01 $r10]]
    set ttsrr12 [::complexes::div [::complexes::mul $t12 $t21] [::complexes::mul $r12 $r21]]
    
    set l_R12 [list]
    foreach eiphi $l_eiphi {
	lappend l_R12 [::complexes::toRTpi [combine $r12 $r21 $eiphi $ttsrr12]]
    }

    set 2kh [::complexes::realMul [expr {2.0*$h}] $ky]
    set arg [::complexes::re $2kh]
    set e2ikh  [::complexes::toRTpi [::complexes::exp [::complexes::iMul $2kh]]]
    set sinterv [sinterv $ky $h]
    
    set l_r02 [list]
    foreach eiphi $l_eiphi R12 $l_R12 {
	#    puts "$R12 [::complexes::toRTpi [lindex [::scal_s::comb $s12 [smiroir $eiphi]] 0]]"
	set R [::complexes::mul $e2ikh $R12]
	#    puts "$R [::complexes::toRTpi [lindex [::scal_s::comb [sinterv $ky $h] [::scal_s::comb $s12 [smiroir $eiphi]]] 0]]"    
	set r02 [::complexes::toRTpi [combine $r01 $r10 $R $ttsrr01]]
	#    puts "[::complexes::toRTpi $r02] [::complexes::toRTpi [lindex\
		[::scal_s::comb $s01 [::scal_s::comb [sinterv $ky $h] [::scal_s::comb $s12 [smiroir $eiphi]]]] 0]]"
	lappend l_r02 [::complexes::toRTpi $r02]
	set S [::scal_s::comb $s01 [::scal_s::comb [sinterv $ky $h] [::scal_s::comb $s12 [smiroir $eiphi]]]]
	puts "$r02 [::complexes::toRTpi [lindex $S 0]]"
    }
}

calculeR0 0.045 $l_eiphi

calculeR0 0.0 $l_eiphi

foreach eiphi $l_eiphi {
    set S [::scal_s::comb $s01 [::scal_s::comb [sinterv $ky $h] [::scal_s::comb $s12 [smiroir $eiphi]]]]
    puts [::complexes::module [lindex $S 0]]
}


set essai {
    # comparaison de calculs
    combine $r12 $r21 $eiphi $ttsrr12
    combineWithS $s12 $eiphi
    ::scal_s::comb $s12 [smiroir $eiphi]
}

