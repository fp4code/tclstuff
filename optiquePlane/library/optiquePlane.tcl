package provide optiquePlane 0.1

package require complexes
package require pauli

# unité ky : k0
# unité d : lambda

set PI [expr 4.0*atan(1.0)]
set 2PI [expr 2.0*$PI]

proc efficaciteDeDiffraction {h d nA nB incidence} {
    global PI
    set epsA [complexes::mul $nA $nA]
    set epsB [complexes::mul $nB $nB]
    
    set ky [expr cos($incidence*($PI/180.0))]
    set kyky [complexes::mul $ky $ky]
    
    set kxA0 [complexes::sqrt [complexes::sub $epsA $kyky]]
    set kxB0 [complexes::sqrt [complexes::sub $epsB $kyky]]

    set kR [expr 2.0*$PI/$d]
    set ky1 [complexes::sub $ky $kR]
    set ky1ky1 [complexes::mul $ky1 $ky1]
    
    set kxA1 [complexes::sqrt [complexes::sub $epsA $ky1ky1]]
    set kxB1 [complexes::sqrt [complexes::sub $epsB $ky1ky1]]
    ...
    
}


# l'argument ky est ky/k0
# l'argument eta est k0*d
proc trancheNue {eps eta ky polar} {
    global 2PI
    set ky2 [complexes::mul $ky $ky]
    set kxM2 [complexes::sub $eps $ky2]
    set kxM [complexes::sqrt $kxM2]
    set arg [complexes::realMul $eta $kxM]
    set uI [complexes::cos $arg]
    set uX 0.0
    set kx02 [complexes::sub 1.0 $ky2]
    set kx0 [complexes::sqrt $kx02]
    if {$polar == "TE"} {
        set denom $kx0
    } elseif {$polar == "TM"} {
        set denom [complexes::mul $eps $kx0]
    } else {
        error "polar $polar ni TE ni TM"
    }
    set q [complexes::mul $kxM [complexes::inv $denom]]
    set qInv [complexes::inv $q]
    set sin [complexes::sin $arg]
    set msins2 [complexes::realMul -0.5 $sin]
    set uY [complexes::sub $qInv $q]
    set uY [complexes::mul $uY $msins2]
    set uZ [complexes::add $qInv $q]
    set uZ [complexes::mul $uZ $msins2]
    set uZ [complexes::iMul $uZ]
    return [list $uI $uX $uY $uZ]
}

proc interfaceVideMateriau {eps ky polar} {
    global 2PI
    set ky2 [complexes::mul $ky $ky]
    set kxM2 [complexes::sub $eps $ky2]
    set kxM [complexes::sqrt $kxM2]
    set uY 0.0
    set uZ 0.0
    set kx02 [complexes::sub 1.0 $ky2]
    set kx0 [complexes::sqrt $kx02]
    if {$polar == "TE"} {
        set denom $kx0
    } elseif {$polar == "TM"} {
        set denom [complexes::mul $eps $kx0]
    } else {
        error "polar $polar ni TE ni TM"
    }
    set q [complexes::mul $kxM [complexes::inv $denom]]
    set uI [complexes::add 1.0 $q]
    set uI [complexes::realMul 0.5 $uI]
    set uX [complexes::sub 1.0 $q]
    set uX [complexes::realMul 0.5 $uX]
    return [list $uI $uX $uY $uZ]
}

# retourne E et B*c

proc champs-TE {eps ky etat} {
    foreach {a+ a-} $etat {}
    set kx [complexes::mul $ky $ky]
    set kx [complexes::sub $eps $kx]
    set kx [complexes::sqrt $kx]
    set ez [complexes::add ${a-} ${a+}]
    set bx [complexes::mul $ez $ky]
    set by [complexes::sub ${a-} ${a+}]
    set by [complexes::mul $by $kx]
    return [list [list 0.0 0.0 $ez] [list $bx $by 0.0]]
} 

proc champs-TM {eps ky etat} {
    foreach {a+ a-} $etat {}
    set kx [complexes::mul $ky $ky]
    set kx [complexes::sub $eps $kx]
    set kx [complexes::sqrt $kx]
    set unsmeps [complexes::inv $eps]
    set unsmeps [complexes::neg $unsmeps]
    set kxf [complexes::mul $unsmeps $kx]
    set kyf [complexes::mul $unsmeps $ky]
    set bz [complexes::add ${a-} ${a+}]
    set ex [complexes::mul $bz $kyf]
    set ey [complexes::sub ${a-} ${a+}]
    set ey [complexes::mul $ey $kxf]
    return [list [list $ex $ey 0.0] [list 0.0 0.0 $bz]]
} 

proc modulesCarres {champs} {
    foreach {e b} $champs {}
    foreach {ex ey ez} $e {}
    foreach {bx by bz} $b {}
    set ee [expr {[complexes::moduleCarre $ex] + [complexes::moduleCarre $ey] + [complexes::moduleCarre $ez]}]
    set bb [expr {[complexes::moduleCarre $bx] + [complexes::moduleCarre $by] + [complexes::moduleCarre $bz]}]
    return [list $ee $bb]
}


proc rab {pauli} {
    if {[llength $pauli] != 4} {
        error "On attend la liste des 4 valeurs de la matrice"
    }
    foreach {uI uX uY uZ} $pauli {}
    set uY [complexes::iMul $uY]
    set num [complexes::add $uX $uY]
    set denom [complexes::add $uI $uZ]
    return [complexes::mul $num [complexes::inv $denom]]
}

proc rba {pauli} {
    if {[llength $pauli] != 4} {
        error "On attend la liste des 4 valeurs de la matrice"
    }
    foreach {uI uX uY uZ} $pauli {}
    set uX [complexes::realMul -1.0 $uX]
    set uY [complexes::iMul $uY]
    set num [complexes::add $uX $uY]
    set denom [complexes::add $uI $uZ]
    return [complexes::mul $num [complexes::inv $denom]]
}

proc tab {pauli} {
    if {[llength $pauli] != 4} {
        error "On attend la liste des 4 valeurs de la matrice"
    }
    foreach {uI uX uY uZ} $pauli {}
    set denom [complexes::add $uI $uZ]
    return [complexes::inv $denom]
}

proc tba {pauli} {
    if {[llength $pauli] != 4} {
        error "On attend la liste des 4 valeurs de la matrice"
    }
    foreach {uI uX uY uZ} $pauli {}
    set denom [complexes::add $uI $uZ]
    set num [pauli::det $pauli]
    return [complexes::mul $num [complexes::inv $denom]]
}


set te [trancheNue 2.0 0.01 0.1 TE]
set tm [trancheNue 2.0 0.01 0.1 TM]
set rte1 [rab $te]
set rte2 [rba $te]
set rtm1 [rab $tm]
set rtm2 [rba $tm]
set tte1 [tab $te]
set tte2 [tba $te]
set ttm1 [tab $tm]
set ttm2 [tba $tm]
puts [complexes::sub $rte1 $rte2]
puts [complexes::sub $rtm1 $rtm2]
puts [complexes::sub $tte1 $tte2]
puts [complexes::sub $ttm1 $ttm2]
set Rte [complexes::moduleCarre $rte1]
set Tte [complexes::moduleCarre $tte2]
set Ate [expr {1.0 - $Rte - $Tte}]
set Rtm [complexes::moduleCarre $rtm1]
set Ttm [complexes::moduleCarre $ttm2]
set Atm [expr {1.0 - $Rtm - $Ttm}]

proc absorption {eps d ky polar} {
    set tranche [trancheNue $eps $d $ky $polar]
    set r [rab $tranche]
    set t [tab $tranche]
    set R [complexes::moduleCarre $r]
    set T [complexes::moduleCarre $t]
    set A [expr {1.0 - $R - $T}]
    return $A
}

proc coucheMinceDansLeVide {eps d type} {

    global 2PI
    
    foreach {taq alpha beta} [complexes::toXY $eps] {}
    
    set abs0 [expr {$beta*$2PI*$d}]
    set indice [expr {sqrt($alpha)}]

    set eabs2inv [expr {1.0/[complexes::moduleCarre $eps]}]

    puts "eps = $alpha + i*$beta"
    puts "d = $d*2*PI*lambda"
    set iBrewster [expr {atan($indice)}]
    puts "Brewster : cost = [expr {cos($iBrewster)}], degrés = [expr {$iBrewster*360.0/$2PI}]"
    puts ""

    if {$type == "élaboré"} {
        puts "degrés R        R(inf.)   T         A        A(mince) A(rel)    ee       bb        R        R(inf.)   T         A        A(mince) A(rel)    ee       bb     "
    } else {
        puts "degrés      R        T        A              R        T        A"
##############11.5  TE : 8.32e-04 9.99e-01 6.40e-05  TM : 7.61e-04 9.99e-01 6.15e-05
    }
    for {set cost 0.01} {$cost > 0.0} {set cost [expr {$cost - 0.0001}]} {
        set ky [expr {sqrt (1.0 - $cost*$cost)}]
        if {$cost == 1.0} {
            set iAngle 1e-6
        } else {
            set iAngle [expr {acos($cost)}]
        }
        set rAngle [expr {asin(sin($iAngle)/$indice)}]
    
        set tre [trancheNue $eps $d $ky TE]
        set re [rab $tre]
        set te [tab $tre]
        set Re [complexes::moduleCarre $re]
        set ReFormulaire [expr {sin($iAngle-$rAngle)/sin($iAngle+$rAngle)}]
        set ReFormulaire [expr {$ReFormulaire*$ReFormulaire}]
        set Te [complexes::moduleCarre $te]
        set Ae [expr {1.0 - $Re - $Te}]
        set AeDirect [expr {$abs0/($cost+$abs0)}]
        set interfaceTE [interfaceVideMateriau $eps $ky TE]
        set interfaceTEInv [pauli::inv $interfaceTE]
        set etatTE [pauli::mulVect $interfaceTEInv [list 1.0 $re]]
        set champsTE [champs-TE $eps $ky $etatTE]
        foreach {eeTE bbTE} [modulesCarres $champsTE] {}
        set AeRel [expr {$AeDirect*$cost/$eeTE}]
    
        set trm [trancheNue $eps $d $ky TM]
        set rm [rab $trm]
        set tm [tab $trm]
        set Rm [complexes::moduleCarre $rm]
        set RmFormulaire [expr {tan($iAngle-$rAngle)/tan($iAngle+$rAngle)}]
        set RmFormulaire [expr {$RmFormulaire*$RmFormulaire}]
        set Tm [complexes::moduleCarre $tm]
        set Am [expr {1.0 - $Rm - $Tm}]
        set coco [expr {($eabs2inv + (1.0 - $eabs2inv)*$cost*$cost)*$abs0}]
        set AmDirect [expr {$coco/($cost+$coco)}]
        set interfaceTM [interfaceVideMateriau $eps $ky TM]
        set interfaceTMInv [pauli::inv $interfaceTM]
        set etatTM [pauli::mulVect $interfaceTMInv [list 1.0 $rm]]
        set champsTM [champs-TM $eps $ky $etatTM]
        foreach {eeTM bbTM} [modulesCarres $champsTM] {}
        set AmRel [expr {$AmDirect*$cost/$eeTM}]

        if {$type == "élaboré"} {
            puts "[format %4.1f [expr {360.0*$iAngle/$2PI}]] \
                   [format %8.2e $Re] [format %8.2e $ReFormulaire]  [format %8.2e $Te]  [format %8.2e $Ae] [format %8.2e $AeDirect] [format %8.2e $AeRel]  [format %8.2e $eeTE] [format %8.2e $bbTE] \
                   [format %8.2e $Rm] [format %8.2e $RmFormulaire]  [format %8.2e $Tm]  [format %8.2e $Am] [format %8.2e $AmDirect] [format %8.2e $AmRel]  [format %8.2e $eeTM] [format %8.2e $bbTM]"
        } else {
            puts "[format %4.1f [expr {360.0*$iAngle/$2PI}]] \
                   TE : [format %8.2e $Re] [format %8.2e $Te] [format %8.2e $Ae] \
                   TM : [format %8.2e $Rm] [format %8.2e $Tm] [format %8.2e $Am]"
        }
    }
}

proc coucheMinceDansLeVideAbsTEBoucle {} {
    uplevel {
        set y [expr {sqrt (1.0 - $x*$x)}]
        if {[catch {trancheNue $eps $eta $y TE} tre]} {
            set AeFormat "        "
        } else {
            set re [rab $tre]
            set te [tab $tre]
            set Re [complexes::moduleCarre $re]
            set Te [complexes::moduleCarre $te]
            set Ae [expr {1.0 - $Re - $Te}]
            set AeFormat [format %8.2e $Ae]
        }
        set AeDirect [expr {$beta*$eta*$x/($x*($x+$beta*$eta)+0.25*($beta*$beta+($alpha-1.0)*($alpha-1.0))*$eta*$eta)}]
        set AeDirectApproche1 [expr {$beta*$eta/($x + $beta*$eta)}]
        set AeDirectApproche0 [expr {$beta*$eta/$x}]
        puts "[format %8.2e $x] $AeFormat [format %8.2e $AeDirect] [format %8.2e $AeDirectApproche1] [format %8.2e $AeDirectApproche0]"
    }
}

proc coucheMinceDansLeVideAbsTE {eps eta} {

    global 2PI
    
    foreach {taq alpha beta} [complexes::toXY $eps] {}
    
    set indice [expr {sqrt($alpha)}]
    
    puts "eps = $alpha + i*$beta"
    puts "d = $eta*lambda/2PI"
    set iBrewster [expr {atan($indice)}]
    puts "Brewster : cost = [expr {cos($iBrewster)}], degrés = [expr {$iBrewster*360.0/$2PI}]"
    puts ""

    for {set x 1.0} {$x > 0.1} {set x [expr {$x - 0.01}]} {
        coucheMinceDansLeVideAbsTEBoucle
    }
    for {set x 0.1} {$x > 0.01} {set x [expr {$x - 0.001}]} {
        coucheMinceDansLeVideAbsTEBoucle
    }
    for {set x 0.01} {$x > 0.001} {set x [expr {$x - 0.0001}]} {
        coucheMinceDansLeVideAbsTEBoucle
    }
    for {set x 0.001} {$x > 0.0001} {set x [expr {$x - 0.00001}]} {
        coucheMinceDansLeVideAbsTEBoucle
    }
    for {set x 0.0001} {$x > 0.00001} {set x [expr {$x - 0.000001}]} {
        coucheMinceDansLeVideAbsTEBoucle
    }
    for {set x 0.00001} {$x > 0.000001} {set x [expr {$x - 0.0000001}]} {
        coucheMinceDansLeVideAbsTEBoucle
    }
    for {set x 0.000001} {$x > 0.0000001} {set x [expr {$x - 0.00000001}]} {
        coucheMinceDansLeVideAbsTEBoucle
    }
}

set eps [complexes::newXY 10.0 0.1]
set eta 10000
set eta 0.001
set eps [complexes::newXY 10.0 0.1]
set eta 0.01

# coucheMinceDansLeVide $eps $eta élaboré
# coucheMinceDansLeVide $eps $eta simple

# coucheMinceDansLeVideAbsTE $eps $eta
