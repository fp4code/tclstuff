package require fidev
package require complexes

set freq 1e10

# de Spiegel, IEEE TED 42, 6 1995

proc ::sparams::simul {h21_0_db freq} {
    set Cbc_tot 17.0e-15
    set a        1.2

    set Re       3.0
    set Ree      7.0

    set taud     0.56e-12

    set Cbe    100.0e-15

    set Rc       4.0
    set Lc     106.0e-12

    set Rb_in   42.0
    set Rb_ex    7.0

    set Le     108.0e-12
    set Lb      94.e-12

    set R0       1.0e6

    set Cbc_in [expr {$Cbc_tot/(1.0+$a)}]
    set Cbc_ex [expr {$Cbc_in*$a}]

    set PI 3.14159265358979323846
    set omega [expr {2*$PI*$freq}] 

    set beta [expr {pow(10.0, $h21_0_db/20.)}]
    set alpha0 [expr {((1+($Ree+$Re+$Rc)/$R0)*$beta - ($Ree+$Re)/$R0) / (1.0 + $beta)}]
    
    set alpha [complexes::newXY $alpha0 [expr {-$alpha0*$omega*$taud}]]
    set alpha_p [complexes::div $alpha [complexes::newXY 1.0 [expr {$omega*$Re*$Cbe}]]]
    set Z1 $Rb_in
    set Z2 [complexes::div $R0 [complexes::newXY 1.0 [expr {$omega*$R0*$Cbc_in}]]] 
    set Z3 [complexes::add\
	    [complexes::newXY $Ree [expr {$omega*$Le}]]\
	    [complexes::div $Re [complexes::newXY 1.0 [expr {$omega*$Re*$Cbe}]]]]

    set Z11_in [complexes::add $Z1 $Z3]
    set Z12_in $Z3
    set Z21_in [complexes::sub $Z3 [complexes::mul $alpha_p $Z2]]
    set Z22_in [complexes::add $Z3 [complexes::mul $Z2 [complexes::sub 1.0 $alpha_p]]]

    set r [complexes::mul [complexes::newXY 0 [expr {$omega*$Cbc_ex}]] [complexes::add $Rb_in $Z2]]
    
    set usupr [complexes::inv [complexes::add 1.0 $r]]
    
    set bigsum [complexes::add\
	           [complexes::mul $r $Z3]\
	           [complexes::mul\
		       [complexes::newXY 0 [expr {$omega*$Rb_in*$Cbc_ex}]]\
		       [complexes::mul $Z2 [complexes::sub 1.0 $alpha_p]]]]

    set Z11 [complexes::add\
                [complexes::mul $usupr [complexes::add $Z11_in $bigsum]]\
                [complexes::newXY $Rb_ex [expr {$omega*$Lb}]]]
    set Z22 [complexes::add\
                [complexes::mul $usupr [complexes::add $Z22_in $bigsum]]\
                [complexes::newXY $Rc    [expr {$omega*$Lc}]]]
    set Z12 [complexes::mul $usupr [complexes::add $Z12_in $bigsum]]
    set Z21 [complexes::mul $usupr [complexes::add $Z21_in $bigsum]]

    return [list $Z11 $Z12 $Z21 $Z22]
}
