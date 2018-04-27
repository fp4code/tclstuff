# RCS: @(#) $Id: sparams.tcl,v 1.3 2002/06/25 13:06:20 fab Exp $

package require fidev
package require complexes 1.1
package require blas 1.0

package provide sparams 0.1

set toTest {
    tclsh
    package require fidev
    package require sparams
    sparams::testFormules
}

namespace eval sparams {
#    variable un [complexes::newXY 1.0 0.0]
}

source [file join [file dirname [info script]] formules_directes_from_hp.tcl]
source [file join [file dirname [info script]] printForGnuplot.tcl]

    #########################
    # formules simplifiéees #
    #########################

proc sparams::genericTransform {m11 m12 m21 m22} {

    set m11 [complexes::add 1.0 $m11]
    set m22 [complexes::add 1.0 $m22]

    set tmp [complexes::realMul 2.0 [complexes::inv [sparams::det $m11 $m12 $m21 $m22]]]

    set m11 [complexes::mul $tmp $m11]
    set m12 [complexes::mul $tmp $m12]
    set m21 [complexes::mul $tmp $m21]
    set m22 [complexes::mul $tmp $m22]

    set tmp $m11
    set m11 $m22
    set m22 $tmp

    set m11 [complexes::sub $m11 1.0]
    set m22 [complexes::sub $m22 1.0]

    return [list $m11 $m12 $m21 $m22]
}

    #####
    # H #
    #####

proc sparams::HfromS {s11 s12 s21 s22} {
    return [sparams::genericTransform    [complexes::neg $s11] $s12 [complexes::neg $s21] $s22]
}

proc sparams::SfromH {h11 h12 h21 h22} {
    foreach {s11 s12 s21 s22} [sparams::genericTransform $h11 $h12 $h21 $h22] {}
    return [list                         [complexes::neg $s11] $s12 [complexes::neg $s21] $s22]
}

    #####
    # G #
    #####

proc sparams::GfromS {s11 s12 s21 s22} {
    return [sparams::genericTransform    $s11 [complexes::neg $s12] $s21 [complexes::neg $s22]]
}

proc sparams::SfromG {g11 g12 g21 g22} {
    foreach {s11 s12 s21 s22} [sparams::genericTransform $g11 $g12 $g21 $g22] {}
    return [list                         $s11 [complexes::neg $s12] $s21 [complexes::neg $s22]]
}

    #####
    # Z #
    #####

proc sparams::ZfromS {s11 s12 s21 s22} {
    return [sparams::genericTransform    [complexes::neg $s11] $s12 $s21 [complexes::neg $s22]]
}

proc sparams::SfromZ {z11 z12 z21 z22} {
    foreach {s11 s12 s21 s22} [sparams::genericTransform $z11 $z12 $z21 $z22] {}
    return [list                         [complexes::neg $s11] $s12 $s21 [complexes::neg $s22]]
}

    #####
    # Y #
    #####

proc sparams::YfromS {s11 s12 s21 s22} {
    return [sparams::genericTransform    $s11 [complexes::neg $s12] [complexes::neg $s21] $s22]
}

proc sparams::SfromY {y11 y12 y21 y22} {
    foreach {s11 s12 s21 s22} [sparams::genericTransform $y11 $y12 $y21 $y22] {}
    return [list	                 $s11 [complexes::neg $s12] [complexes::neg $s21] $s22]
}

    ##############################################################
    # echange 10 20 <-> 01 21 (emetteur commun <-> base commune) #
    ##############################################################

proc sparams::HexchangeBE {h11 h12 h21 h22} {

    set umh12 [complexes::sub 1.0 $h12] ; unset h12
    set uph21 [complexes::add 1.0 $h21] ; unset h21

# FAUX bien que la matrice passe le test slef-inverse
# set tmp [complexes::inv [sparams::det $h11 $umh12 $uph21 $h22]]
set tmp [complexes::inv [complexes::add [complexes::mul $h11 $h22] [complexes::mul $umh12 $uph21]]]    

    set h11 [complexes::mul $tmp $h11]
    set umh12 [complexes::mul $tmp $umh12]
    set uph21 [complexes::mul $tmp $uph21]
    set h22 [complexes::mul $tmp $h22]

    set tmp $umh12
    set umh12 $uph21
    set uph21 $tmp

    set h12 [complexes::sub 1.0 $umh12]
    set h21 [complexes::sub $uph21 1.0]

    return [list $h11 $h12 $h21 $h22]
}


    ###############
    # utilitaires #
    ###############

# determinant

proc sparams::det {s11 s12 s21 s22} {
    return [complexes::sub [complexes::mul $s11 $s22] [complexes::mul $s12 $s21]]
}

# produit de matrices

proc sparams::prodMat {a11 a12 a21 a22 b11 b12 b21 b22} {
    set c11 [complexes::add [complexes::mul $a11 $b11] [complexes::mul $a12 $b21]]
    set c12 [complexes::add [complexes::mul $a11 $b12] [complexes::mul $a12 $b22]]
    set c21 [complexes::add [complexes::mul $a21 $b11] [complexes::mul $a22 $b21]]
    set c22 [complexes::add [complexes::mul $a21 $b12] [complexes::mul $a22 $b22]]

    return [list $c11 $c12 $c21 $c22]
}

    #########
    # tests #
    #########

proc r {} {
    return [expr {rand()}]
}

proc printMat {nom a11 a12 a21 a22} {
    puts "${nom}11 -> [format %10.6g [complexes::re $a11]] [format %10.6g [complexes::im $a11]]"
    puts "${nom}12 -> [format %10.6g [complexes::re $a12]] [format %10.6g [complexes::im $a12]]"
    puts "${nom}21 -> [format %10.6g [complexes::re $a21]] [format %10.6g [complexes::im $a21]]"
    puts "${nom}22 -> [format %10.6g [complexes::re $a22]] [format %10.6g [complexes::im $a22]]"
}

proc printErr {oper prefix} {
    upvar ${prefix}11 x11
    upvar ${prefix}12 x12
    upvar ${prefix}21 x21
    upvar ${prefix}22 x22
    upvar ${prefix}11n x11n
    upvar ${prefix}12n x12n
    upvar ${prefix}21n x21n
    upvar ${prefix}22n x22n

    set e11 [format %8.1e [complexes::module [complexes::sub $x11n $x11]]]
    set e12 [format %8.1e [complexes::module [complexes::sub $x12n $x12]]]
    set e21 [format %8.1e [complexes::module [complexes::sub $x21n $x21]]]
    set e22 [format %8.1e [complexes::module [complexes::sub $x22n $x22]]]

    set warning ""
    foreach e [list $e11 $e12 $e21 $e22] {
	if {abs($e) > 1.e-15} {
	    set warning " WARNING"
	}
    }

    puts "[format %8s $oper] $e11$e12$e21$e22$warning"
}

proc sparams::testFormules {} {
    for {set i 0} {$i<1} {incr i} {
	puts {}
	
	################################
	# cohérence s->x->s et x->s->x #
        ################################
	
	set s11 [complexes::newXY [r] [r]]
	set s12 [complexes::newXY [r] [r]]
	set s21 [complexes::newXY [r] [r]]
	set s22 [complexes::newXY [r] [r]]
	
	foreach {h11 h12 h21 h22} [sparams::HfromS $s11 $s12 $s21 $s22] {}
	foreach {s11n s12n s21n s22n} [sparams::SfromH $h11 $h12 $h21 $h22] {}
	printErr s->h->s s
	
	foreach {z11 z12 z21 z22} [sparams::ZfromS $s11 $s12 $s21 $s22] {}
	foreach {s11n s12n s21n s22n} [sparams::SfromZ $z11 $z12 $z21 $z22] {}
	printErr s->z->s s
	
	foreach {y11 y12 y21 y22} [sparams::YfromS $s11 $s12 $s21 $s22] {}
	foreach {s11n s12n s21n s22n} [sparams::SfromY $y11 $y12 $y21 $y22] {}
	printErr s->y->s s
	
	set h11 [complexes::newXY [r] [r]]
	set h12 [complexes::newXY [r] [r]]
	set h21 [complexes::newXY [r] [r]]
	set h22 [complexes::newXY [r] [r]]
	
	foreach {s11 s12 s21 s22} [sparams::SfromH $h11 $h12 $h21 $h22] {}
	foreach {h11n h12n h21n h22n} [sparams::HfromS $s11 $s12 $s21 $s22] {}
	printErr h->s->h h
	
	set z11 [complexes::newXY [r] [r]]
	set z12 [complexes::newXY [r] [r]]
	set z21 [complexes::newXY [r] [r]]
	set z22 [complexes::newXY [r] [r]]
	
	foreach {s11 s12 s21 s22} [sparams::SfromZ $z11 $z12 $z21 $z22] {}
	foreach {z11n z12n z21n z22n} [sparams::ZfromS $s11 $s12 $s21 $s22] {}
	printErr z->s->z z
	
	set y11 [complexes::newXY [r] [r]]
	set y12 [complexes::newXY [r] [r]]
	set y21 [complexes::newXY [r] [r]]
	set y22 [complexes::newXY [r] [r]]
	
	foreach {s11 s12 s21 s22} [sparams::SfromY $y11 $y12 $y21 $y22] {}
	foreach {y11n y12n y21n y22n} [sparams::YfromS $s11 $s12 $s21 $s22] {}
	printErr y->s->y y

	#####################################################
	# cohérence des expressions directes et simplifiées #
	#####################################################

	set s11 [complexes::newXY [r] [r]]
	set s12 [complexes::newXY [r] [r]]
	set s21 [complexes::newXY [r] [r]]
	set s22 [complexes::newXY [r] [r]]
	
	foreach {h11 h12 h21 h22} [sparams::HfromS $s11 $s12 $s21 $s22] {}
	foreach {h11n h12n h21n h22n} [sparams::HfromSdirect $s11 $s12 $s21 $s22] {}
	printErr direct_h h

	foreach {g11 g12 g21 g22} [sparams::GfromS $s11 $s12 $s21 $s22] {}

	foreach {z11 z12 z21 z22} [sparams::ZfromS $s11 $s12 $s21 $s22] {}
	foreach {z11n z12n z21n z22n} [sparams::ZfromSdirect $s11 $s12 $s21 $s22] {}
	printErr direct_z z

	foreach {y11 y12 y21 y22} [sparams::YfromS $s11 $s12 $s21 $s22] {}
	foreach {y11n y12n y21n y22n} [sparams::YfromSdirect $s11 $s12 $s21 $s22] {}
	printErr direct_y y

	#######################################
        # cohérence h*g = g*h = z*y = y*z = 1 #
	#######################################

	foreach {u11 u12 u21 u22} {1.0 0.0 0.0 1.0} {}
	
	foreach {u11n u12n u21n u22n} [sparams::prodMat $y11 $y12 $y21 $y22 $z11 $z12 $z21 $z22] {}
	printErr y*z u

	printMat y $y11 $y12 $y21 $y22
	printMat z $z11 $z12 $z21 $z22
	printMat un $u11n $u12n $u21n $u22n
	printMat u $u11 $u12 $u21 $u22

	foreach {u11n u12n u21n u22n} [sparams::prodMat $z11 $z12 $z21 $z22 $y11 $y12 $y21 $y22] {}
	printErr z*y u

	foreach {u11n u12n u21n u22n} [sparams::prodMat $g11 $g12 $g21 $g22 $h11 $h12 $h21 $h22] {}
	printErr g*h u

	foreach {u11n u12n u21n u22n} [sparams::prodMat $h11 $h12 $h21 $h22 $g11 $g12 $g21 $g22] {}
	printErr h*g u

# n'a pas été capable de voir une erreur sur le dénominateur
	foreach {h11n h12n h21n h22n} [sparams::HexchangeBE $h11 $h12 $h21 $h22] {}
	foreach {h11n h12n h21n h22n} [sparams::HexchangeBE $h11n $h12n $h21n $h22n] {}
	printErr be_bc h
    }
}

proc sparams::OfromE {s11 s12 s21 s22 e1 e2} {
    set o1 [complexes::add [complexes::mul $s11 $e1] [complexes::mul $s12 $e2]]
    set o2 [complexes::add [complexes::mul $s21 $e1] [complexes::mul $s22 $e2]]
    return [list $o1 $o2]
}

proc sparams::Umax_fab {s11 s12 s21 s22} {
    set m11 [complexes::moduleCarre $s11]
    set m12 [complexes::moduleCarre $s12]
    set m21 [complexes::moduleCarre $s21]
    set m22 [complexes::moduleCarre $s22]
    
    set s11s22 [complexes::mul $s11 $s22]
    set s12s21 [complexes::mul $s12 $s21]
    set rere [complexes::re [complexes::mul $s11s22 [complexes::conj $s12s21]]]

    set B2 [expr {$m11*$m12 + $m21*$m22 + 2.0*$rere}]
    set AmC [expr {$m11 + $m21 - $m12 - $m22}]
    set ApC [expr {$m11 + $m21 + $m12 + $m22}]
    return [expr {0.5*($ApC + sqrt(4.0*$B2 + $AmC*$AmC))}]
}

proc sparams::Gp_sze {s11 s12 s21 s22} {
    set mc11 [complexes::moduleCarre $s11]
    set mc12 [complexes::moduleCarre $s12]
    set mc21 [complexes::moduleCarre $s21]
    set mc22 [complexes::moduleCarre $s22]

    return [expr {($mc21/(1.0 - $mc11))}]
}

proc sparams::KRollet_sze {s11 s12 s21 s22} {
    set mc11 [complexes::moduleCarre $s11]
    set mc12 [complexes::moduleCarre $s12]
    set mc21 [complexes::moduleCarre $s21]
    set mc22 [complexes::moduleCarre $s22]
    set delta [sparams::det $s11 $s12 $s21 $s22]
    set mcd [complexes::moduleCarre $delta]
    return [expr {(1.0 + $mcd - $mc11 - $mc22)/(2.0*sqrt($mc12*$mc21))}]
}

# a verifier
proc sparams::Gmax_ramzi {s11 s12 s21 s22} {

    set sos [complexes::div $s21 $s12]
    set msos [complexes::module $sos]
    set num [complexes::moduleCarre [complexes::sub $sos 1.0]]
    set K [sparams::KRollet_sze $s11 $s12 $s21 $s22]
    set rsos [complexes::re $sos]
    return [expr {$num/(2.0*($K*$msos - $rsos))}]
}

proc sparams::U_sze {s11 s12 s21 s22} {
    set mc11 [complexes::moduleCarre $s11]
    set mc12 [complexes::moduleCarre $s12]
    set mc21 [complexes::moduleCarre $s21]
    set mc22 [complexes::moduleCarre $s22]

    return [expr {sqrt($mc11*$mc12*$mc21*$mc22)/((1.0 - $mc11)*(1.0 - $mc22))}]
}

# a verifier
proc sparams::U_prasad {s11 s12 s21 s22} {
    foreach {h11 h12 h21 h22} [sparams::HfromS $s11 $s12 $s21 $s22] {}
    set num [complexes::moduleCarre [complexes::add $h21 [complexes::conj $h12]]]
    set rh11 [complexes::re $h11]
    set rh22 [complexes::re $h22]

    return [expr {$num/(4.0*$rh11*$rh22)}]
}

# a verifier
proc sparams::Gamax_sze {s11 s12 s21 s22} {

    set sos [complexes::div $s21 $s12]
    set msos [complexes::module $sos]
    set K [sparams::KRollet_sze $s11 $s12 $s21 $s22]
    return [expr {$msos*($K + sqrt($K*$K - 1.0))}]
}

# a verifier
proc sparams::MAG_ramzi {s11 s12 s21 s22} {

    set sos [complexes::div $s21 $s12]
    set msos [complexes::module $sos]
    set K [sparams::KRollet_sze $s11 $s12 $s21 $s22]

    set mc11 [complexes::moduleCarre $s11]
    set mc22 [complexes::moduleCarre $s22]
    set delta [sparams::det $s11 $s12 $s21 $s22]
    set mcd [complexes::moduleCarre $delta]
    set sign [expr {1.0 + $mc11 - $mc22 - $mcd}]
    if {$sign < 0.0} {
	set sign -1.0
    } else {
#	puts stderr "ATTENTION : ramzi et sze difèrent : $sign>=0"
	if {$sign > 0.0} {
	    set sign 1.0
	}
    }

    return [expr {$msos*($K - $sign*sqrt($K*$K - 1.0))}]
}

proc sparams::U_mason {s11 s12 s21 s22} {
    foreach {z11 z12 z21 z22} [sparams::ZfromS $s11 $s12 $s21 $s22] {}
    set r11 [complexes::re $z11]
    set r12 [complexes::re $z12]
    set r21 [complexes::re $z21]
    set r22 [complexes::re $z22]
    set num [complexes::moduleCarre [complexes::sub $z21 $z12]]
    set U_mason [expr {$num/(4.0*($r11*$r22 - $r12*$r21))}]
puts [list $s11 $s12 $s21 $s22 $z11 $z12 $z21 $z22 $U_mason]
    return $U_mason
}

proc sparams::readCNET {fV s11V s12V s21V s22V l} {
    upvar $fV f
    upvar $s11V s11
    upvar $s12V s12
    upvar $s21V s21
    upvar $s22V s22

    if {[llength $l] != 9} {
	error "la liste n'a pas 9 éléments : \"$l\""
    }

    set f [lindex $l 0]
    set s11 [complexes::newRTpi [lindex $l 1] [expr {[lindex $l 2]/180.}]]
    set s12 [complexes::newRTpi [lindex $l 5] [expr {[lindex $l 6]/180.}]]
    set s21 [complexes::newRTpi [lindex $l 3] [expr {[lindex $l 4]/180.}]]
    set s22 [complexes::newRTpi [lindex $l 7] [expr {[lindex $l 8]/180.}]]
}

proc testUmaxFab {} {

proc sparams::etaForUmax_fab {s11 s12 s21 s22} {
    set mc11 [complexes::moduleCarre $s11]
    set mc12 [complexes::moduleCarre $s12]
    set mc21 [complexes::moduleCarre $s21]
    set mc22 [complexes::moduleCarre $s22]
    
    set T1 [complexes::mul [complexes::conj $s11] $s12]
    set T2 [complexes::mul [complexes::conj $s21] $s22]
    set Braw [complexes::add $T1 $T2]
    set B [complexes::module $Braw]

    set CmA [expr {-$mc11 - $mc21 + $mc12 + $mc22}]
    set CmAs2B [expr {0.5*($CmA/$B)}]

    set eta [expr {$CmAs2B + sqrt(1.0 + $CmAs2B*$CmAs2B)}]
    
    set arg [complexes::arg [complexes::conj $Braw]]

    return [complexes::newRTpi $eta $arg]
}

# on envoie 1 en e1 et e2  e2
proc sparams::gainTotalFab_v0 {s11 s12 s21 s22 e2} {
    set e1 1.0
    foreach {o1 o2} [sparams::OfromE $s11 $s12 $s21 $s22 $e1 $e2] {}
    set pe1 [complexes::moduleCarre $e1]
    set pe2 [complexes::moduleCarre $e2]
    set po1 [complexes::moduleCarre $o1]
    set po2 [complexes::moduleCarre $o2]
    return [expr {($po1 + $po2)/($pe1 + $pe2)}]
}

proc sparams::gainTotalFab_v1 {s11 s12 s21 s22 eta} {
    set m11 [complexes::moduleCarre $s11]
    set m12 [complexes::moduleCarre $s12]
    set m21 [complexes::moduleCarre $s21]
    set m22 [complexes::moduleCarre $s22]

    set meta [complexes::module $eta]
    set meta2 [expr {$meta*$meta}] 

    set T1 [complexes::mul [complexes::conj $s11] $s12]
    set T2 [complexes::mul [complexes::conj $s21] $s22]
    set B [complexes::add $T1 $T2]
    set B [complexes::module $B]

    return [expr {($m11 + $m21 + ($m12 + $m22)*$meta2 + 2.0*$meta*$B)/(1.0+$meta2)}]
}

    set s11 [complexes::newXY [r] [r]]
    set s12 [complexes::newXY [r] [r]]
    set s21 [complexes::newXY [r] [r]]
    set s22 [complexes::newXY [r] [r]]
    

    puts "umax    = [sparams::Umax_fab $s11 $s12 $s21 $s22]"

    set eta [sparams::etaForUmax_fab $s11 $s12 $s21 $s22]

    puts "umax_v0 = [sparams::gainTotalFab_v0 $s11 $s12 $s21 $s22 $eta]"
    puts "umax_v1 = [sparams::gainTotalFab_v1 $s11 $s12 $s21 $s22 $eta]"

    puts "umax+du = [sparams::gainTotalFab_v0 $s11 $s12 $s21 $s22 [complexes::add $eta [complexes::newXY 1e-4 0.0]]]"
    puts "umax+du = [sparams::gainTotalFab_v0 $s11 $s12 $s21 $s22 [complexes::add $eta [complexes::newXY -1e-4 0.0]]]"
    puts "umax+du = [sparams::gainTotalFab_v0 $s11 $s12 $s21 $s22 [complexes::add $eta [complexes::newXY 0.0 1e-4]]]"
    puts "umax+du = [sparams::gainTotalFab_v0 $s11 $s12 $s21 $s22 [complexes::add $eta [complexes::newXY 0.0 -1e-4]]]"
}

proc sparams::allGains {gVar s11 s12 s21 s22} {
    upvar $gVar g
    foreach o {Umax_fab Gp_sze KRollet_sze Gmax_ramzi U_sze U_prasad Gamax_sze MAG_ramzi U_mason} {
#	puts $o
	set g($o) [sparams::$o $s11 $s12 $s21 $s22]
    }
}

set essais {

set ll {5.E+8	.131597	-14.405	6.02611	174.674	.006413	2.37193	.865896	.219418
1.E+9	.134551	-27.378	5.89515	169.833	.006326	4.63077	.874623	-1.2049
1.5E+9	.139980	-39.559	5.79065	165.121	.006346	10.8240	.875828	-2.0636
2.E+9	.148025	-49.883	5.65916	160.763	.006523	15.0015	.876227	-2.8020
2.5E+9	.156567	-59.346	5.54069	156.571	.006651	19.6779	.878021	-3.6090
3.E+9	.166652	-67.261	5.37990	152.582	.006817	23.0531	.877347	-4.4096
3.5E+9	.177451	-74.454	5.21911	148.822	.007141	27.1886	.879335	-5.2331
4.E+9	.187907	-80.857	5.06983	145.295	.007479	30.8515	.879225	-6.0428
4.5E+9	.198590	-86.497	4.90370	141.911	.007918	33.3756	.878379	-6.8332
5.E+9	.208391	-91.388	4.75258	138.825	.008321	34.8746	.880450	-7.5884
5.5E+9	.218047	-96.033	4.58500	135.763	.008831	36.9676	.879748	-8.3824
6.E+9	.227176	-100.08	4.44646	132.943	.009278	37.6003	.882165	-9.2880
6.5E+9	.236545	-103.71	4.29636	130.363	.009778	39.6646	.879615	-10.019
7.E+9	.245483	-107.06	4.15720	127.845	.010186	40.6474	.880932	-10.806
7.5E+9	.254530	-110.07	4.02314	125.490	.010787	41.3115	.880696	-11.686
8.E+9	.263110	-113.02	3.89700	123.228	.011270	41.0864	.879301	-12.454
8.5E+9	.271636	-115.59	3.77847	120.993	.011774	41.6808	.877785	-13.348
9.E+9	.279284	-118.11	3.66335	119.049	.012337	41.6320	.878049	-14.045
9.5E+9	.286655	-120.50	3.55361	116.999	.012779	41.4616	.875977	-14.959
1.E+10	.294282	-122.78	3.44672	115.105	.013319	41.1865	.874158	-15.725
1.05E+10	.300880	-124.98	3.35463	113.245	.013838	40.7173	.872839	-16.519
1.1E+10	.307940	-126.87	3.25963	111.472	.014310	40.5487	.873399	-17.153
1.15E+10	.314913	-128.84	3.17190	109.826	.014571	39.5729	.869536	-17.984
1.2E+10	.321295	-130.74	3.08947	108.153	.014993	38.9644	.867438	-18.707
1.25E+10	.327339	-132.47	3.01302	106.530	.015367	37.9197	.866017	-19.375
1.3E+10	.333054	-134.16	2.93546	104.820	.015538	37.2741	.865956	-20.154
1.35E+10	.339532	-135.83	2.85483	103.487	.015893	36.6685	.860156	-20.709
1.4E+10	.337953	-138.09	2.78705	101.905	.016009	35.8880	.861037	-21.389
1.45E+10	.346891	-138.43	2.72618	100.515	.016108	35.7187	.861725	-21.946
1.5E+10	.353039	-139.99	2.65837	99.1841	.016399	35.5435	.860305	-22.494
1.6E+10	.362962	-142.79	2.54473	96.5146	.016651	35.0562	.860859	-23.992
1.7E+10	.373040	-145.38	2.43806	93.9403	.017005	35.4096	.860876	-25.341
1.8E+10	.383650	-147.67	2.34227	91.3754	.017479	35.2739	.861141	-26.832
1.9E+10	.392740	-150.05	2.25602	89.0207	.017775	34.5885	.859172	-28.215
2.E+10	.399254	-152.45	2.17827	86.4942	.018158	34.7332	.854836	-29.668
2.1E+10	.411158	-155.10	2.10178	84.1670	.018561	34.1241	.852085	-30.943
2.2E+10	.420093	-157.36	2.03355	81.9068	.019210	34.5768	.848201	-32.273
2.3E+10	.429214	-159.55	1.97313	79.6288	.020098	33.0219	.847618	-33.529
2.4E+10	.433552	-162.36	1.91276	77.1683	.020430	30.8420	.848424	-34.775
2.5E+10	.439849	-165.12	1.84810	74.8061	.020891	27.1258	.847232	-36.139
2.6E+10	.433233	-167.83	1.78537	72.3678	.020369	23.1494	.848729	-37.490
2.7E+10	.424484	-167.89	1.71271	70.2633	.018756	20.4217	.846030	-38.616
2.8E+10	.445366	-169.70	1.67016	68.8343	.016866	24.2522	.846312	-39.716
2.9E+10	.445979	-171.20	1.62742	66.9236	.016235	27.8905	.844265	-41.201
3.E+10	.448490	-172.09	1.59015	65.0281	.016374	31.6157	.843713	-42.723
3.1E+10	.462055	-173.93	1.55765	62.9203	.016820	34.7654	.845150	-44.053
3.2E+10	.464623	-175.43	1.51068	60.8851	.017452	37.3820	.839833	-45.142
3.3E+10	.455661	-178.13	1.46666	58.2590	.018460	37.5434	.843826	-46.242
3.4E+10	.438755	-178.74	1.38307	57.2868	.020050	38.7356	.845395	-47.545
3.5E+10	.464756	-179.03	1.34147	58.1506	.019254	38.6175	.843886	-48.901
3.6E+10	.465905	-179.29	1.38610	60.1907	.020848	38.4816	.846055	-50.076
3.7E+10	.511652	179.595	1.44339	54.6099	.020483	34.1415	.844917	-51.983
3.8E+10	.526972	174.493	1.40432	52.0911	.020724	37.8027	.846482	-53.087
3.9E+10	.523096	174.126	1.38819	47.8627	.020851	37.7508	.846046	-54.383
4.E+10	.557009	169.105	1.34328	44.2881	.021796	41.2482	.843570	-55.768
4.1E+10	.526599	168.688	1.28867	42.5696	.022626	38.1923	.834344	-56.566
4.2E+10	.532197	166.934	1.25763	40.5857	.022197	37.6757	.833079	-57.022
4.3E+10	.529350	164.881	1.22655	39.3099	.024382	38.8921	.840685	-58.606
4.4E+10	.529073	163.751	1.19338	37.1447	.024818	33.2841	.836252	-60.078
4.5E+10	.529563	159.821	1.17597	35.5885	.023936	29.9058	.845412	-60.984
4.6E+10	.537547	158.417	1.14969	33.8756	.022627	21.4106	.830875	-63.204
4.7E+10	.536552	158.512	1.14407	31.5613	.019091	20.7706	.836501	-63.944
4.8E+10	.521257	154.515	1.11568	28.5637	.021203	33.5963	.828078	-66.793
4.9E+10	.508151	154.338	1.06478	27.5308	.016844	10.8322	.812251	-65.927
5.E+10	.507427	152.997	1.05023	27.5192	.007894	20.8596	.821979	-66.181
5.1E+10	.507982	152.704	1.04519	26.5591	.011307	62.5878	.834759	-66.710
5.2E+10	.511612	155.061	1.02614	25.8873	.023742	97.5103	.837218	-67.647
5.3E+10	.505325	151.157	1.03689	23.3926	.028011	79.9964	.862022	-69.250
5.4E+10	.560833	152.967	1.01749	22.3764	.035003	72.2193	.860270	-69.881
5.5E+10	.558341	149.708	1.02576	20.0502	.037339	61.8481	.867838	-71.681
5.6E+10	.584434	148.299	.994061	18.6234	.040565	49.7824	.854767	-72.175
5.7E+10	.573881	145.775	.992214	17.0963	.039886	47.9367	.873242	-72.247
5.8E+10	.569671	142.889	.994482	14.6751	.037088	36.2389	.887623	-74.129
5.9E+10	.555856	140.462	1.00448	12.5180	.037015	31.1344	.913292	-76.422
6.E+10	.572634	138.932	.966263	9.34134	.036238	28.5962	.909395	-78.944
6.1E+10	.574910	138.995	.951863	8.74021	.030437	27.5542	.907867	-79.474
6.2E+10	.578175	140.097	.939297	6.60674	.024384	29.2634	.890929	-81.881
6.3E+10	.578796	134.698	.921233	2.56576	.022631	12.0889	.888058	-83.342
6.4E+10	.585419	138.890	.913756	3.05241	.023906	16.9671	.883697	-84.294
6.5E+10	.538265	130.418	.878411	-.48425	.024399	13.8097	.887056	-86.203}

    set l {4.E+10 .557009 169.105 1.34328 44.2881 .021796 41.2482 .843570 -55.768}
    set l {3.E+10	.448490	-172.09	1.59015	65.0281	.016374	31.6157	.843713	-42.723}
    set l {3.e10        .44849 -172.09 1.59015 65.0281 .016374 31.6157 .843713 -42.723}

	sparams::readCNET f s11 s12 s21 s22 $l

    foreach {z11 z12 z21 z22} [sparams::ZfromS $s11 $s12 $s21 $s22] {}
    foreach {y11 y12 y21 y22} [sparams::YfromS $s11 $s12 $s21 $s22] {}
    printMat z $z11 $z12 $z21 $z22
    printMat y $y11 $y12 $y21 $y22

    foreach {u11n u12n u21n u22n} [sparams::prodMat $y11 $y12 $y21 $y22 $z11 $z12 $z21 $z22] {}
    printErr y*z u
    
    printMat y $y11 $y12 $y21 $y22
    printMat z $z11 $z12 $z21 $z22
    printMat un $u11n $u12n $u21n $u22n
    printMat u $u11 $u12 $u21 $u22
    
    foreach l [split $ll \n] {
	sparams::readCNET f s11 s12 s21 s22 $ll
	sparams::allGains g $s11 $s12 $s21 $s22
	
	puts "\n $f"
	parray g
    }
}

