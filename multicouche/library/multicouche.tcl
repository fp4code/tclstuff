#!/usr/local/bin/tclsh

# RCS: @(#) $Id: multicouche.tcl,v 1.3 2002/06/25 08:42:56 fab Exp $

puts KO
package require fidev
package require trig_sun
puts [expr cospi(-1.0)]
puts OK

package require fidev
package require blas
package require complexes
package require m22c
package require trig_sun


namespace eval multicouche {
    variable PI [expr {4.0*atan(1.0)}]
    variable DEUXPI [expr {2.0*$PI}]

}

fidev_load ../src/Tcl/multicouche/libtclmulticouche multicouche

proc ::multicouche::propagateur_1 {polar epsA leps lrdN epsB kParaN} {
    kPerpN

} 

proc ::multicouche::Pinterface {p1 p2} {
    set t [::complexes::realMul 0.5 [::complexes::div $p2 $p1]]
    set tp [::complexes::add 0.5 $t]
    set tm [::complexes::sub 0.5 $t]
    return [list $tp $tm $tm $tp]
}

proc ::multicouche::Pintervalle {krdN} {
    variable PI
    set mod [expr exp(-2.0*$PI*[::complexes::im $krdN])]
    # ATTENTION, multiplier par 2 avant xxxpi
    set argN [expr {2.0*[::complexes::re $krdN]}]
    set tp [::complexes::newXY [expr {$mod*cospi($argN)}] [expr {$mod*sinpi($argN)}]]
    return [list [::complexes::inv $tp] 0.0 0.0 $tp]
}

proc ::multicouche::Sinterface {p1 p2} {
    set t [::complexes::inv [::complexes::add $p1 $p2]]
    set r12 [::complexes::mul [::complexes::sub $p1 $p2] $t]
    set r21 [::complexes::neg $r12]
    set deux_t [::complexes::realMul 2.0 $t]
    set t12 [::complexes::mul $p1 $deux_t]
    set t21 [::complexes::mul $p2 $deux_t]
    return [list $r12 $t21 $t12 $r21]
}

proc ::multicouche::Sintervalle {krdN} {
    variable PI
    # ATTENTION, multiplier par 2 avant xxxpi
    set krdN_fois2 [::complexes::realMul 2.0 $krdN]
    unset krdN
    set t [::complexes::realMul [expr exp(-$PI*[::complexes::im $krdN_fois2])] [::complexes::newRTpi 1.0 [::complexes::re $krdN_fois2]]]
    return [list 0.0 $t $t 0.0]
}

proc printS {s} {
    set list [list]
    foreach c $s {
	lappend list [::complexes::toRTpi $c]
    }
    puts $list
}

# epaisseursN normalisées à lambda
# kN normalisées à 2pi/lambda
# produit normalisé à 2pi
proc ::multicouche::empilement {polar l_epsilon l_epaisseurN kParaN} {
    # l_epsilon    : liste des permittivités diélectriques relatives
    # l_epaisseurN : liste des épaisseurs, divisées par lambda. Le premier et le dernier éléments sont nuls (milieux infinis) ou non
    # l_krdN        : liste des produits de la composante perpendiculaire de k par l'épaisseur, divisés par pi
    # l_p          : liste des p (kPerp (TE)  ou kPerp/epsilon (TM))
    # l_P          : liste des propagateurs interface et milieux

    set N [llength $l_epsilon]
    if {$N != [llength $l_epaisseurN]} {
	error "listes lepsilon et lepaisseurN de longueurs différentes"
    }
    set Nmax [expr {$N-1}] ;# les milieux 0 et Nmax sont les milieux infinis

#    set v_eps [::blas::newVector doublecomplex $lepsilon]
#    set v_rdN [::blas::newVector double $lepaisseurN]

    set l_krdN [list]
    set l_p [list]
    set kParaNcarre [::complexes::mul $kParaN $kParaN]
    if {$polar == "TE"} {
	foreach eps $l_epsilon rdN $l_epaisseurN {
	    set kN [::complexes::sqrt [::complexes::sub $eps $kParaNcarre]]
	    lappend l_krdN [::complexes::realMul $rdN $kN]
	    lappend l_p $kN
	}
    } elseif {$polar == "TM"} {
	foreach eps $l_epsilon rdN $l_epaisseurN {
	    set kN [::complexes::sqrt [::complexes::sub $eps $kParaNcarre]]
	    lappend l_krdN [::complexes::realMul $rdN $kN]
	    lappend l_p [::complexes::div $kN $eps]
	}
    } else {error "polar == \"$polar\""}
    
    set P [list 1.0 0.0 0.0 1.0]
    set S [list 0.0 1.0 1.0 0.0]
    set l_S [list]
    set i $Nmax
    if {[lindex $l_epaisseurN $i] != 0.0} {
	set P [::m22c::mul $P [::multicouche::Pintervalle [lindex $l_krdN $i]]]
	set S [::multicouche::scomb [::multicouche::Sintervalle [lindex $l_krdN $i]] $S]
    }
    # puts {}
    # printS [::multicouche::SfromP $P]
    # printS $S
    for {set im1 [expr {$i-1}]} {$im1 >= 0} {incr im1 -1; incr i -1} {
	# puts [list $im1 $i [lindex $l_p $im1] [lindex $l_p $i]]
	set P [::m22c::mul [::multicouche::Pinterface [lindex $l_p $im1] [lindex $l_p $i]] $P]
	set S [::multicouche::scomb [::multicouche::Sinterface [lindex $l_p $im1] [lindex $l_p $i]] $S]
	# puts {xxx}
	# printS [::multicouche::SfromP [::multicouche::Pinterface [lindex $l_p $im1] [lindex $l_p $i]]]
	# printS [::multicouche::Sinterface [lindex $l_p $im1] [lindex $l_p $i]]

	# puts {}
	# printS [::multicouche::SfromP $P]
	# printS $S
	if {$im1 != 0 || [lindex $l_epaisseurN $im1] != 0.0} {
	    set P [::m22c::mul [::multicouche::Pintervalle [lindex $l_krdN $im1]] $P]
	    set S [::multicouche::scomb [::multicouche::Sintervalle [lindex $l_krdN $im1]] $S]
	} 
	# puts {}
	# printS [::multicouche::SfromP $P]
	# printS $S
    }
    # puts [list $im1 $i [lindex $l_p $im1] [lindex $l_p $i]]

    return [list $P $S]
   
}

# combinaison de matrices S
proc ::multicouche::scomb {ab bc} {
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

proc ::multicouche::PfromS {s} {
    if {[llength $s] != 4} {
	error "bad argum"
    }
    foreach {rab tba tab rba} $s {}
    if {[::complexes::module $tab] == 0.0} {
	set ppp 1.e300
    } else {
	set ppp [::complexes::inv $tab]
    }
    set ppm [::complexes::neg [::complexes::mul $ppp $rba]]
    set pmp [::complexes::mul $rab $ppp]
    set pmm [::complexes::add $tba [complexes::mul $rab $ppm]]
    return [list $ppp $ppm $pmp $pmm]
}

proc ::multicouche::SfromP {p} {
    if {[llength $p] != 4} {
	error "bad argum"
    }
    foreach {ppp ppm pmp pmm} $p {}
    set tab [::complexes::inv $ppp]
    set rab [::complexes::mul $pmp $tab]
    set rba [::complexes::neg [::complexes::mul $tab $ppm]]
    set tba [::complexes::add $pmm [::complexes::mul $pmp $rba]]
    return [list $rab $tba $tab $rba]
}


proc test {} {
    puts "verif de scomb, PfromS, SfromP"
    proc randc {} {
	return [::complexes::newXY [expr {rand()}] [expr {rand()}]]
    }
    
    proc maxerr {a} {
	set max 0.0
	foreach c $a {
	    set mc [::complexes::module $c]
	    if {$mc > $max} {
		set max $mc
	    }
	}
	return $max
    }

    set sun [list 0.0 1.0 1.0 0.0] 

    set sab [list [randc] [randc] [randc] [randc]]
    set sbc [list [randc] [randc] [randc] [randc]]

    set sac [::multicouche::scomb $sab $sbc]

    set diff [::m22c::sub $sab [::multicouche::scomb $sun $sab]]
    puts [maxerr $diff]
    set diff [::m22c::sub $sab [::multicouche::scomb $sab $sun]]
    puts [maxerr $diff]

    set pab [::multicouche::PfromS $sab]
    set pbc [::multicouche::PfromS $sbc]
    set pac [::m22c::mul $pab $pbc]

    set sab2 [::multicouche::SfromP $pab]
    set diff1 [::m22c::sub $sab $sab2]
    puts [maxerr $diff1]

    set sac2 [::multicouche::SfromP $pac]
    set diff2 [::m22c::sub $sac $sac2]
    puts [maxerr $diff2]

    set pac2 [::multicouche::PfromS $sac]
    set diff3 [::m22c::sub $pac $pac2]
    puts [maxerr $diff3]

}

set mou 0
if {$mou} {

    # transition molle
    set l_epsilon [list]
    set l_epaisseurN [list]
    set epsilonA 1.0
    set epsilonB 2.0
    set Ni 100
    set epaisseurN 0.01
    set kParaN 0.0
    set depsilon [expr {double($epsilonB - $epsilonA)/($Ni+1)}]
    
    lappend l_epsilon $epsilonA
    lappend l_epaisseurN 0.0
    for {set i 1} {$i <= $Ni} {incr i} {
	lappend l_epsilon [expr {$epsilonA + $i*$depsilon}]
	lappend l_epaisseurN $epaisseurN
    }
    lappend l_epsilon $epsilonB
    lappend l_epaisseurN 0.0
    
    foreach {rab tba tab rba} [::multicouche::empilement TM $l_epsilon $l_epaisseurN $kParaN] {}
    
    puts [::multicouche::empilement TE $l_epsilon $l_epaisseurN $kParaN]
    puts [::multicouche::empilement TM $l_epsilon $l_epaisseurN $kParaN]
}

    # simple interface

set l_epaisseurN [list 0.0 0.0]
set l_epsilon [list 1.0 2.25]
# puts \nSIMPLE
# puts [::multicouche::empilement TE $l_epsilon $l_epaisseurN 0.0]

    # reseau metal/GaAs

set rdN [expr {0.075/0.8}]
set epsilon1m [::complexes::newXY -32.797 0.458]
set epsilon1sc [::complexes::newXY 13.435 0.589]
set l_epaisseurN [list $rdN $rdN 0.0]
set l_epsilon [list $epsilon1sc $epsilon1m $epsilon1sc]
set ky [::complexes::newXY 41.7756 1.50667]
set lambda 0.8
set k0 [expr {8.0*atan(1.0)/$lambda}]
set kyN [::complexes::realMul [expr {1.0/$k0}] $ky]
puts "kyN = $kyN"

proc zero {polar l_epsilon l_epaisseurN coskx0d kyN} {

    foreach {P S} [::multicouche::empilement TM $l_epsilon $l_epaisseurN $kyN] {}
    
    # puts {}
    # puts "det(P) = [::m22c::det $P]"
    set P2 [::multicouche::PfromS $S]
    # puts "det(P2) = [::m22c::det $P2]"
    set S2 [::multicouche::SfromP $P]
    # printS $S2
    # printS $S
    
    # pseudo-périodicité incidence normale
    
    foreach {r12 t21 t12 r21} $S {}
    # puts "reciprocité S : 1.0 = [::complexes::div $t12 $t21]"
    foreach {r12_2 t21_2 t12_2 r21_2} $S2 {}
    # puts "reciprocité S2 : 1.0 = [::complexes::div $t12_2 $t21_2]"
    set rr [::complexes::mul $r12 $r21]
    set rrm1 [::complexes::sub $rr 1.0]
    set tmtm [::complexes::mul $t21 $t12]
    puts "rr = $rr"
    puts "rrm1 = $rrm1"
    puts "tmtm = $tmtm"
    set div [::complexes::div $rrm1 $tmtm]
    set zero [::complexes::add $div [expr {-1.0 + 2.0*$coskx0d}]]
    puts "$kyN -> $zero"
    
    foreach {p11 p12 p21 p22} $P {}
    set d1 [::complexes::mul [::complexes::sub $p11 1.0] [::complexes::sub $p22 1.0]]
    set d2 [::complexes::mul $p12 $p21]
    # puts "d1 = $d1"
    # puts "d2 = $d2"
    # puts "zero = [::complexes::sub $d1 $d2]"
    return $zero
}

set kyN0 [::complexes::newXY 5.31903416562 0.191834599772]

zero TM $l_epsilon $l_epaisseurN 1.0  $kyN0
set kyN [::complexes::newXY 15 0.0] 
zero TM $l_epsilon $l_epaisseurN 1.0 $kyN

#                     zero = ComplexXY -164014277.136 2756132.24867

set kyN [::complexes::newXY 15 0.2] 
zero TM $l_epsilon $l_epaisseurN 1.0 $kyN


zero TM $l_epsilon $l_epaisseurN 1.0 [::complexes::newXY 5.31903416562 0.191834599772]
zero TM $l_epsilon $l_epaisseurN 1.0 [::complexes::newXY 5.31903416562 0.20]
zero TM $l_epsilon $l_epaisseurN 1.0 [::complexes::newXY 5.31903416562 0.18]
zero TM $l_epsilon $l_epaisseurN 1.0 [::complexes::newXY 5.31903416562 0.17]

zero TM $l_epsilon $l_epaisseurN 1.0 [::complexes::newXY 8.0 -0.953]
zero TM $l_epsilon $l_epaisseurN 1.0 [::complexes::newXY 8.0 -2.141]
zero TM $l_epsilon $l_epaisseurN 1.0 [::complexes::newXY 8.0 -3.484]

set l_y [list]
set l_z [list]
for {set y -3.5} {$y < 0} {set y [expr {$y+0.1}]} {
    lappend l_y $y
    lappend l_z [::complexes::arg [zero TM $l_epsilon $l_epaisseurN 1.0 [::complexes::newXY 8.0 $y]]]
}

proc newkyN {polar l_epsilon l_epaisseurN coskx0d kyN1 kyN2} {
    set z1 [zero polar $l_epsilon $l_epaisseurN $coskx0d $kyN1]
    set z2 [zero polar $l_epsilon $l_epaisseurN $coskx0d $kyN2]
    return [::complexes::div [::complexes::sub [::complexes::mul $z1 $kyN2] [::complexes::mul $z2 $kyN1]] [::complexes::sub $z1 $z2]]

}

set kyN1 [::complexes::newXY 5.31903416562 0.19]
set kyN2 [::complexes::newXY 5.31903416562 0.191834599772]

newkyN TM $l_epsilon $l_epaisseurN 1.0 $kyN1 $kyN2

set kyN1 [::complexes::newXY 4.07316407933 0.219560609397]
set kyN2 [::complexes::newXY 4.07316407933 0.22]

newkyN TM $l_epsilon $l_epaisseurN 1.0 $kyN1 $kyN2

proc bicouche {epsilon1m epsilon1sc rdMN rdSN kx0dN kyN} {

# Vérif des étapes du calcul des zéros

    set kMN [::complexes::sqrt [::complexes::sub $epsilon1m [::complexes::mul $kyN $kyN]]]
    set kSN [::complexes::sqrt [::complexes::sub $epsilon1sc [::complexes::mul $kyN $kyN]]]
    set pM [::complexes::div $kMN $epsilon1m]
    set pS [::complexes::div $kSN $epsilon1sc]
    set kMdMN [::complexes::mul $kMN $rdMN]
    set kSdSN [::complexes::mul $kSN $rdSN]
    
    
    set SMS [::multicouche::Sinterface $pM $pS]
    set SSM [::multicouche::Sinterface $pS $pM]
    
    set x [::complexes::div $pM $pS]
    
    set inv [::complexes::inv [::complexes::add 1.0 $x]]
    set rSM [::complexes::mul $inv [::complexes::sub 1.0 $x]]
    set rMS [::complexes::neg $rSM]
    set tSM [::complexes::realMul 2.0 $inv]
    set tMS [::complexes::mul $x $tSM]
    
    set SMS_direct [list $rMS $tSM $tMS $rSM] 
    set SSM_direct [list $rSM $tMS $tSM $rMS] 
    
    package require m22c
    
    puts [::m22c::sub $SMS $SMS_direct]
    puts [::m22c::sub $SSM $SSM_direct]
    
    set SMM [::multicouche::Sintervalle $kMdMN]
    set SSS [::multicouche::Sintervalle $kSdSN]
    
    set SMMS [::multicouche::scomb $SMM $SMS]
    set SSSM [::multicouche::scomb $SSS $SSM]
    
    set DEUXPI [expr {8.0*atan(1.0)}]
    
    set eM [::complexes::exp [::complexes::iMul [::complexes::realMul $DEUXPI $kMdMN]]]
    set eS [::complexes::exp [::complexes::iMul [::complexes::realMul $DEUXPI $kSdSN]]]
    set eM_carre [::complexes::mul $eM $eM]
    set eS_carre [::complexes::mul $eS $eS]
    
    set SMMS_direct [list\
	    [::complexes::mul $eM_carre $rMS] [::complexes::mul $eM $tSM]\
	    [::complexes::mul $eM $tMS] $rSM]
    set SSSM_direct [list\
	    [::complexes::mul $eS_carre $rSM] [::complexes::mul $eS $tMS]\
	    [::complexes::mul $eS $tSM] $rMS]
    
    puts [m22c::sub $SMMS $SMMS_direct]
    puts [m22c::sub $SSSM $SSSM_direct]
    
    set SSSMMS [::multicouche::scomb $SSSM $SMMS]
    
    # ATTENTION, multiplier par 2 avant xxxpi
    set misinM [::complexes::neg [::complexes::iMul [::complexes::sinpi [::complexes::realMul 2.0 $kMdMN]]]]
    set cosM [::complexes::cospi [::complexes::realMul 2.0 $kMdMN]]
    
    # premier calcul
    
    set x_fois2 [::complexes::realMul 2.0 $x]
    set x_carre [::complexes::mul $x $x]
    set inv [::complexes::inv [::complexes::add [::complexes::mul [::complexes::add 1.0 $x_carre] $misinM]\
	    [::complexes::mul $x_fois2 $cosM]]]
    set r21 [::complexes::mul $inv [::complexes::mul $misinM [::complexes::sub 1.0 $x_carre]]]
    set r12 [::complexes::mul $eS_carre $r21]
    set t [::complexes::mul $inv [complexes::mul $eS $x_fois2]]
    
    set SSSMMS_direct [list $r12 $t $t $r21]
    puts "diff SSSMMS = [::m22c::sub $SSSMMS $SSSMMS_direct]"
    set SSSMMS_multi [lindex [::multicouche::empilement TM [list $epsilon1sc $epsilon1m $epsilon1sc] [list $rdSN $rdMN 0] $kyN] 1]
    puts "diff SSSMMS_multi = [::m22c::sub $SSSMMS $SSSMMS_multi]"
    
    # second calcul
    
    set x_fois2 [::complexes::realMul 2.0 $x]
    set x_carre [::complexes::mul $x $x]
    set ksi [::complexes::div $x_fois2 [::complexes::add [::complexes::mul [::complexes::add 1.0 $x_carre] $misinM]\
	    [::complexes::mul $x_fois2 $cosM]]]
    set r21 [::complexes::mul $rSM [::complexes::sub 1.0 [::complexes::mul $ksi $eM]]]
    set r12 [::complexes::mul $eS_carre $r21]
    set t [::complexes::mul $ksi $eS]
    set SSSMMS_direct [list $r12 $t $t $r21]
    puts [::m22c::sub $SSSMMS $SSSMMS_direct]
    
    # troisieme calcul
    
    unset misinM
    # ATTENTION, multiplier par 2 avant xxxpi
    set isinM [::complexes::iMul [::complexes::sinpi [::complexes::realMul 2.0 $kMdMN]]]
    set x_isinMsur2 [::complexes::realMul 0.5 [::complexes::mul $isinM $x]]
    set x_inv_isinMsur2 [::complexes::realMul 0.5 [::complexes::div $isinM $x]]
    set ksi [::complexes::inv  [::complexes::sub $cosM [::complexes::add $x_isinMsur2 $x_inv_isinMsur2]]]
    set r21 [::complexes::mul $ksi [::complexes::sub $x_isinMsur2 $x_inv_isinMsur2]]
    set r12 [::complexes::mul $eS_carre $r21]
    set t [::complexes::mul $ksi $eS]
    set SSSMMS_direct [list $r12 $t $t $r21]
    puts [::m22c::sub $SSSMMS $SSSMMS_direct]
    
    
    # fonction zero directe
    
    # ATTENTION, multiplier par 2 avant xxxpi
    set zero_direct [::complexes::add [expr {2.0*$kx0dN}]\
	    [::complexes::sub\
	      [::complexes::mul\
                [::complexes::mul\
                  [::complexes::sinpi [::complexes::realMul 2.0 $kMdMN]]\
                  [::complexes::sinpi [::complexes::realMul 2.0 $kSdSN]]\
                ]\
                [::complexes::realMul 0.5 [::complexes::add $x [::complexes::inv $x]]]\
              ]\
	      [::complexes::mul\
                [::complexes::cospi [::complexes::realMul 2.0 $kMdMN]]\
                [::complexes::cospi [::complexes::realMul 2.0 $kSdSN]]\
	      ]\
	    ]]
    set eE [::complexes::exp [::complexes::realMul $DEUXPI $kx0dN]]
    foreach {r12 t21 t12 r21} $SSSMMS {}
    set T [::complexes::realMul 0.5 [::complexes::add $t12 $t12]]
    puts "diff = [::complexes::sub $T $t12]"
    set zero_directBis [::complexes::sub\
	    [::complexes::cospi [::complexes::realMul 2.0 $kx0dN]]\
	    [::complexes::realMul 0.5\
	      [::complexes::add\
	        [::complexes::div\
                  [::complexes::sub 1.0 [::complexes::mul $r12 $r21]]\
		  $T] $T]]]
    set vise [list 0.0 [::complexes::inv $eE] $eE 0.0]
    set zero [::m22c::det [::m22c::sub $SSSMMS $vise]]
    set zero_Bis [::complexes::div $zero [::complexes::realMul 2.0 $T]]

    puts "SSSMMS = [::m22c::toRTpi $SSSMMS]"

    puts "zero_direct = [::complexes::toRTpi $zero_direct]"
    puts "zero_Bis = [::complexes::toRTpi $zero_Bis]"
    puts "zero_directBis = [::complexes::toRTpi $zero_directBis]"

    return [list $zero_Bis $SSSMMS]
    return $zero_direct 
}

set rdMN $rdN
set rdSN $rdN
set kx0dN 0.0

bicouche $epsilon1m $epsilon1sc $rdMN $rdSN $kx0dN $kyN0

proc newkyNbicouche {epsilon1m epsilon1sc rdMN rdSN kx0dN kyN1 kyN2} {
    set z1 [lindex [bicouche $epsilon1m $epsilon1sc $rdMN $rdSN $kx0dN $kyN1] 0]
    set z2 [lindex [bicouche $epsilon1m $epsilon1sc $rdMN $rdSN $kx0dN $kyN2] 0]
    set denom [::complexes::toRTpi [::complexes::sub $z1 $z2]]
    if {[::complexes::module $denom] == 0.0} {
	puts stderr "********Convergence atteinte"
    }
    return [::complexes::div [::complexes::sub [::complexes::mul $z1 $kyN2] [::complexes::mul $z2 $kyN1]] $denom]

}

set kyN1 [::complexes::newXY 5.0 0.1]
set kyN2 [::complexes::newXY 5.0 0.2]

set kyN1 [newkyNbicouche $epsilon1m $epsilon1sc $rdMN $rdSN $kx0dN $kyN1 $kyN2]
set kyN2 [newkyNbicouche $epsilon1m $epsilon1sc $rdMN $rdSN $kx0dN $kyN1 $kyN2]

# converge vers 
# ComplexXY 5.31903416562 0.191834599772


bicouche $epsilon1m $epsilon1sc $rdMN $rdSN $kx0dN $kyN1
set SSSMMS_multi [lindex [::multicouche::empilement TM [list $epsilon1sc $epsilon1m $epsilon1sc] [list $rdSN $rdMN 0] $kyN1] 1]

set essai_pour_scilab {
set kyN [::complexes::newXY 5.31903416562 0.191834599772]
set polar TM
set l_epsilon [list $epsilon1sc $epsilon1m $epsilon1sc]
set l_epaisseurN [list 0 $rdMN 0]
set kParaN $kyN
set SMMS [lindex [::multicouche::empilement $polar $l_epsilon $l_epaisseurN $kParaN] 1]
proc txy {l} {foreach e $l {puts [::complexes::toXY $e]}}
txy $SMMS
# ComplexXY 10.75884281 1.27497741962
ComplexXY -1.13525938444 -0.202993074155
ComplexXY -1.13525938444 -0.202993074155
ComplexXY 10.75884281 1.27497741962


set eps [lindex $l_epsilon 0]
set rdN [lindex $l_epaisseurN 0]

set eps [lindex $l_epsilon 1]
set rdN [lindex $l_epaisseurN 1]

}

package require eqvp 0.1
::zerosComplexes::eqvp 0 TM $epsilon1m $epsilon1sc $rdMN $rdSN 0.0 $kyN1

foreach {r12 t21 t12 r21} [lindex [bicouche $epsilon1m $epsilon1sc $rdMN $rdSN $kx0dN $kyN0] 1] {}

set rr [::complexes::mul $r12 $r21]
set tt [::complexes::mul $t12 $t21]
set umrr [::complexes::sub 1.0 $rr]
set num [::complexes::add $umrr $tt]
set terme [::complexes::div $num [::complexes::realMul 2.0 $t12]]
#set zero [::complexes::sub [expr {cospi(2.0*$kx0dN)}] $terme]

puts KO2
# puts [expr {cospi(-1.0)}]
puts OK2

