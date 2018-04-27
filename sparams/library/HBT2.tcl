package require hyperpiano
package provide hyperHBT 1.0

proc sparams::HBT {&s &PMOD omega} {
    upvar ${&s} s
    upvar ${&PMOD} PMOD
    global 2M_PI

    if {[blas::vector type $omega] != "double"} {
        return -code error "omega should be a \"blas::vector double\""
    }

    set unsurZ0 [expr {1.0/$PMOD(Z0)}]

    set nelems [blas::vector length $omega]
    set Zero [blas::vector create doublecomplex -length $nelems]
    blas::mathsvop Zero *rscal 0.0
    set Un $Zero
    blas::mathsvop Un +rscal 1.0

# Il est plus court de créer ces vecteurs que de les transmettre par adresse

    set f1  [blas::vector create doublecomplex -length $nelems]
    set f2  [blas::vector create doublecomplex -length $nelems]
    set f3  [blas::vector create doublecomplex -length $nelems]
    set stmp  [blas::vector create doublecomplex -length [expr {4*$nelems}]]
    set tmp  [blas::vector create double -length $nelems]

#    upvar ${&f1} f1
#    upvar ${&f2} f2
#    upvar ${&f3} f3
#    upvar ${&stmp} stmp

    blas::zcopy $Un f3
    #
    blas::dcopy $omega tmp
    blas::mathsvop tmp *scal  $PMOD(taue2)
    blas::mathsvop tmp *      $tmp
    blas::mathsvop f3   +r    $tmp
    #
    blas::dcopy $omega tmp
    blas::mathsvop tmp *scal  [expr {-$PMOD(taue1)}]
    blas::mathsvop f3  +i     $tmp
    blas::mathsvop f3  *rscal [expr {double($PMOD(Z0))/double($PMOD(re))}]

    blas::zcopy $Un f2
    #
    blas::dcopy $omega tmp
    blas::mathsvop tmp *scal  $PMOD(tauc2)
    blas::mathsvop tmp *      $tmp
    blas::mathsvop f2  +r     $tmp
    #
    blas::::dcopy $omega tmp
    blas::mathsvop  tmp *scal  [expr {-$PMOD(tauc1)}]
    blas::mathsvop  f2  +i     $tmp
    blas::mathsvop  f2  *rscal [expr {double($PMOD(alpha0))*double($PMOD(Z0))/double($PMOD(re))}]

    blas::zcopy $Zero f1
    blas::::dcopy $omega tmp
    blas::mathsvop  tmp *scal [expr {double($PMOD(Z0))*double($PMOD(cc))}]
    blas::mathsvop  f1 +rscal [expr {double($PMOD(Z0))/double($PMOD(Ro))}]
    blas::mathsvop  f1 +i     $tmp 

    set info {
        f1 = Z0/Ro + i*omega*Z0*cc
        f2 = ((omega*tauc2)^2 - i*omega*tauc1* + 1)*alpha0*Z0/re
        f3 = ((omega*taue2)^2 - i*omega*taue1 + 1)*Z0/re

        y11 = f3 - f2 + f1
        y12 = -f1
        y21 = f2 - f1
        y22 = f1

        ib = (f3 - f2 + f1)*vbe - f1*vce = (f3 - f2)*vbe - f1*vcb
        ic = (f2 - f1)*vbe + f1*vce = f2*vbe + f1*vcb
        -ie = ib + ic = f3*vbe
        ic = f2*vbe + f1*vcb

        f1 = y22 = -y12
        f2 = y21+y22
        f3 = y11+y21
    }


    # m est y

    set m11 [blas::subvector create 1 4 $nelems from stmp]
    set m12 [blas::subvector create 2 4 $nelems from stmp]
    set m21 [blas::subvector create 3 4 $nelems from stmp]
    set m22 [blas::subvector create 4 4 $nelems from stmp]
    
    blas::zcopy $f2 m21
    blas::mathsvop m21 - $f1
    
    blas::zcopy $f1 m22
    
    blas::zcopy $f1 m12
    blas::mathsvop m12 *rscal -1.0
    
    blas::zcopy $f3 m11
    blas::mathsvop m11 - $m21
    
    sparams::transform SfromY stmp
    blas::zcopy $stmp s

    ####################################
    ## résistance de base interne: rb ##
    ####################################

    blas::zcopy $Zero f1
    blas::zcopy $Zero f2
    blas::zcopy $Zero f3

    blas::mathsvop f1 +rscal [expr {double($PMOD(rb))*$unsurZ0}]

    sparams::SwithZ s $f1 $f2 $f3
    
    ###################
    ## ce_ext cc_ext ##
    ###################
    
    # 8300 return

    blas::zcopy $Zero f1
    blas::zcopy $Zero f2
    blas::zcopy $Zero f3

    blas::dcopy $omega tmp
    blas::mathsvop tmp *scal  [expr {$PMOD(Z0)*$PMOD(ce_ext)}]    
    blas::mathsvop f2 +i $tmp

    blas::dcopy $omega tmp
    blas::mathsvop tmp *scal  [expr {$PMOD(Z0)*$PMOD(cc_ext)}]    
    blas::mathsvop f3 +i $tmp

    sparams::SwithY s $f2 $f1 $f3
  
    #######################
    ## Rb + (RbS//CbS) Lb Rc+(RcS//CcS)+(RcSbis//CcSbis)  Lc Re + (ReS//CeS) Le ##
    #######################

    # 14400 return

    blas::zcopy $Zero f1
    blas::zcopy $Zero f2
    blas::zcopy $Zero f3

    sparams::z+R//C f1 tmp $omega $PMOD(RbS) $PMOD(CbS)
    sparams::z+R+L f1 tmp $omega $PMOD(Rb) $PMOD(Lb)
    blas::mathsvop f1 *rscal $unsurZ0
    
    sparams::z+R//C f2 tmp $omega $PMOD(RcS) $PMOD(CcS)
    sparams::z+R+L f2 tmp $omega $PMOD(Rc) $PMOD(Lc)
    blas::mathsvop f2 *rscal $unsurZ0

    sparams::z+R//C f3 tmp $omega $PMOD(ReS) $PMOD(CeS)
    sparams::z+R+L f3 tmp $omega $PMOD(Re) $PMOD(Le)
    blas::mathsvop f3 *rscal $unsurZ0

    sparams::SwithZ s $f1 $f2 $f3
    
    # 21759 return

    #######################
    ## Ligne
    #######################

    sparams::SofLine stmp $PMOD(Zrel) [expr {$PMOD(nL)/299792458.}] $omega

    # 22255 return

    sparams::ScombR s $stmp

    # 23156 return

    sparams::ScombL $stmp s

    # 24070 return

    ####################################
    ## Rskin ##
    ####################################

    blas::zcopy $Zero f1
    blas::zcopy $Zero f2
    blas::zcopy $Zero f3

    blas::dcopy $omega tmp
    blas::mathsvop tmp sqrt
    blas::mathsvop tmp *scal [expr {$PMOD(Rskin)*$unsurZ0}]
    blas::mathsvop f1 +r $tmp
    blas::zcopy $f1 f2

    sparams::SwithZ s $f1 $f2 $f3

    ##################################
    ## Cp ##
    ##################################

    blas::zcopy $Zero f1
    blas::zcopy $Zero f2
    blas::zcopy $Zero f3

    blas::dcopy $omega tmp
    blas::mathsvop tmp *scal  [expr {$PMOD(Z0)*$PMOD(Cp)}]    
    blas::mathsvop f1 +i $tmp
    blas::zcopy $f1 f2

    sparams::SwithY s $f2 $f1 $f3

    ####################################
    ## Rp ##
    ####################################

    blas::mathsvop f1 *rscal 0.0
    blas::mathsvop f1 +rscal [expr {double($PMOD(Rp))*$unsurZ0}]
    blas::zcopy $f1 f2
    blas::mathsvop f3 *rscal 0.0

    sparams::SwithZ s $f1 $f2 $f3
}

proc sparams::alpha {omega zce zcc} {
    global PMOD

    set nelems [blas::vector length $omega]
    set tmp  [blas::vector create double -length $nelems]

    # a2 = 1 + i*omega*re*ce
    blas::dcopy $omega tmp
    blas::mathsvop tmp *scal [expr {$PMOD(ce)*$PMOD(re)}]
    set a2 [blas::vector create doublecomplex -length [blas::vector length $omega]]
    blas::mathsvop a2 +rscal 1.0
    blas::mathsvop a2 +i $tmp
    
    # a1 = zcc -Rc + i*omega*Lc/Z0
    blas::dcopy $omega tmp 
    blas::mathsvop tmp *scal [expr {$PMOD(Lc)/$PMOD(Z0)}]
    set a1 [blas::vector create doublecomplex -length [blas::vector length $omega]]
    blas::mathsvop a1 +rscal [expr {-$PMOD(Rc)/$PMOD(Z0)}]
    blas::mathsvop a1 +i $tmp
    blas::mathsvop a1 + $zcc

    # alpha = zce*a2/a1
    set alpha $zce
    blas::mathsvop alpha / $a1
    blas::mathsvop alpha * $a2

    # zce*(1 + i*omega*re*ce)/(zcc - (Rc - i*Lc*omega)/Z0)
    # zce*(1 + i*omega*re*ce)/(zcc - Rc/Z0 +*Lc*omega/Z0)

    return $alpha
}

proc sparams::alphaTrue {s omega &PMOD} {
    upvar ${&PMOD} PMOD
    global 2M_PI

    if {[blas::vector type $omega] != "double"} {
        return -code error "omega should be a \"blas::vector double\""
    }

    set unsurZ0 [expr {1.0/$PMOD(Z0)}]

    set nelems [blas::vector length $omega]
    set Zero [blas::vector create doublecomplex -length $nelems]
    blas::mathsvop Zero *rscal 0.0
    set Un $Zero
    blas::mathsvop Un +rscal 1.0

# Il est plus court de créer ces vecteurs que de les transmettre par adresse

    set f1  [blas::vector create doublecomplex -length $nelems]
    set f1b  [blas::vector create doublecomplex -length $nelems]
    set f2  [blas::vector create doublecomplex -length $nelems]
    set f3  [blas::vector create doublecomplex -length $nelems]
    set stmp  [blas::vector create doublecomplex -length [expr {4*$nelems}]]
    set tmp  [blas::vector create double -length $nelems]

    ####################################
    ## Rp ##
    ####################################

    blas::mathsvop f1 *rscal 0.0
    blas::mathsvop f1 +rscal [expr {-double($PMOD(Rp))*$unsurZ0}]
    blas::zcopy $f1 f2
    blas::mathsvop f3 *rscal 0.0

    sparams::SwithZ s $f1 $f2 $f3

    ##################################
    ## Cp ##
    ##################################

    blas::zcopy $Zero f1
    blas::zcopy $Zero f2
    blas::zcopy $Zero f3

    blas::dcopy $omega tmp
    blas::mathsvop tmp *scal  [expr {-$PMOD(Z0)*$PMOD(Cp)}]    
    blas::mathsvop f1 +i $tmp
    blas::zcopy $f1 f2

    sparams::SwithY s $f2 $f1 $f3

    ####################################
    ## Rskin ##
    ####################################

    blas::zcopy $Zero f1
    blas::zcopy $Zero f2
    blas::zcopy $Zero f3

    blas::dcopy $omega tmp
    blas::mathsvop tmp sqrt
    blas::mathsvop tmp *scal [expr {-$PMOD(Rskin)*$unsurZ0}]
    blas::mathsvop f1 +r $tmp
    blas::zcopy $f1 f2

    sparams::SwithZ s $f1 $f2 $f3

    #######################
    ## Ligne
    #######################

    sparams::SofLine stmp $PMOD(Zrel) [expr {-$PMOD(nL)/299792458.}] $omega

    sparams::ScombR s $stmp
    sparams::ScombL $stmp s

    #######################
    ## Rb + (RbS//CbS) Lb Rc+(RcS//CcS)+(RcSbis//CcSbis)  Lc Re + (ReS//CeS) Le ##
    #######################

    # 14400 return

    blas::zcopy $Zero f1
    blas::zcopy $Zero f2
    blas::zcopy $Zero f3

    sparams::z+R//C f1 tmp $omega $PMOD(RbS) $PMOD(CbS)
    sparams::z+R+L f1 tmp $omega $PMOD(Rb) $PMOD(Lb)
    blas::mathsvop f1 *rscal [expr {-$unsurZ0}]
    
    sparams::z+R//C f2 tmp $omega $PMOD(RcS) $PMOD(CcS)
    sparams::z+R+L f2 tmp $omega $PMOD(Rc) $PMOD(Lc)
    blas::mathsvop f2 *rscal [expr {-$unsurZ0}]

    sparams::z+R//C f3 tmp $omega $PMOD(ReS) $PMOD(CeS)
    sparams::z+R+L f3 tmp $omega $PMOD(Re) $PMOD(Le)
    blas::mathsvop f3 *rscal [expr {-$unsurZ0}]

    sparams::SwithZ s $f1 $f2 $f3
    
    ###################
    ## ce_ext cc_ext ##
    ###################
    
    # 8300 return

    blas::zcopy $Zero f1
    blas::zcopy $Zero f2
    blas::zcopy $Zero f3

    blas::dcopy $omega tmp
    blas::mathsvop tmp *scal  [expr {-$PMOD(Z0)*$PMOD(ce_ext)}]    
    blas::mathsvop f2 +i $tmp

    blas::dcopy $omega tmp
    blas::mathsvop tmp *scal  [expr {-$PMOD(Z0)*$PMOD(cc_ext)}]    
    blas::mathsvop f3 +i $tmp

    sparams::SwithY s $f2 $f1 $f3

    ####################################
    ## résistance de base interne: rb ##
    ####################################

    blas::zcopy $Zero f1
    blas::zcopy $Zero f2
    blas::zcopy $Zero f3

    blas::mathsvop f1 +rscal [expr {-double($PMOD(rb))*$unsurZ0}]

    sparams::SwithZ s $f1 $f2 $f3
    
    sparams::transform YfromS s
        
    set y11 [blas::subvector create 1 4 $nelems from s]
    set y12 [blas::subvector create 2 4 $nelems from s]
    set y21 [blas::subvector create 3 4 $nelems from s]
    set y22 [blas::subvector create 4 4 $nelems from s]
    
    blas::zcopy $y22 f1
    blas::zcopy $y12 f1b
    blas::mathsvop f1b *rscal -1.0
    blas::zcopy $y21 f2
    blas::mathsvop f2 + $y22
    blas::zcopy $y11 f3
    blas::mathsvop f3 + $y21
    
    return [list $f1 $f1b $f3 $f2]
}

proc sparams::U_mason {s11 s12 s21 s22} {
    
    set dt $s11
    blas::mathsvop dt * $s22        ;# dt = s11*s22
    set ztmp $s12              
    blas::mathsvop ztmp * $s21      ;# dtmp = s12*s21
    blas::mathsvop dt - $ztmp       ;# dt = s11*s22 - s12*s21
    
    set k [blas::vector create double -length [blas::vector length $s11]]
    set dtmp [blas::vector create double -length [blas::vector length $s11]]
    blas::mathsvop k mod2 $dt       ;# k = |dt|^2
    blas::mathsvop k +scal 1.0      ;# k = |dt|^2 + 1
    blas::mathsvop dtmp mod2 $s11   ;# dtmp = |s11|^2
    blas::mathsvop k - $dtmp        ;# k = |dt|^2 + 1 - |s11|^2
    blas::mathsvop dtmp mod2 $s22   ;# dtmp = |s22|^2
    blas::mathsvop k - $dtmp        ;# k = |dt|^2 + 1 - |s11|^2 - |s22|^2
    set ztmp $s12
    blas::mathsvop ztmp * $s21      ;# ztmp = s12*s21
    blas::mathsvop dtmp mod2 $ztmp  ;# dtmp = |s12*s21|^2
    blas::mathsvop dtmp sqrt        ;# dtmp = |s12*s21|
    blas::mathsvop dtmp *scal 2.0   ;# dtmp = 2*|s12*s21|
    blas::mathsvop k / $dtmp        ;# k = (|dt|^2 + 1 - |s11|^2 - |s22|^2)/(2*|s12*s21|)
    set rt $s21
    blas::mathsvop rt / $s12;       ;# rt = s21/s12
    set rtm1 $rt
    blas::mathsvop rtm1 +rscal -1.0 ;# rtm1 = s21/s12 - 1
    set U_mason [blas::vector create double -length [blas::vector length $s11]]
    blas::mathsvop U_mason mod2 $rtm1 ;# U_mason = |rtm1|^2
    blas::mathsvop U_mason *scal 0.5  ;# U_mason = 0.5*|rtm1|^2
    blas::mathsvop dtmp mod2 $rt      ;# dtmp = |rt|^2
    blas::mathsvop dtmp sqrt          ;# dtmp = |rt|
    blas::mathsvop dtmp * $k          ;# dtmp = |rt|*k
    blas::mathsvop dtmp - [blas::math re $rt] ;# dtmp = |rt|*k - Re(rt)
    blas::mathsvop U_mason / $dtmp    ;# U_mason = 0.5*|rtm1|^2/(|rt|*k - Re(rt))
    return $U_mason
}


proc sparams::U_masonBis {z11 z12 z21 z22} {
    
    set ztmp [blas::vector create doublecomplex -length [blas::vector length $z11]]
    set ztmp $z21              
    blas::mathsvop ztmp - $z12

    set mason [blas::vector create double -length [blas::vector length $z11]]
    blas::mathsvop mason mod2 $ztmp
    blas::mathsvop mason *scal 0.25
    set dtmp [blas::math re $z11]
    blas::mathsvop dtmp * [blas::math re $z22]
    set dtmp2 [blas::math re $z12]
    blas::mathsvop dtmp2 * [blas::math re $z21]
    blas::mathsvop dtmp - $dtmp2
    blas::mathsvop mason / $dtmp
    return $mason
}

proc sparams::U_masonTer {h11 h12 h21 h22} {
    
    set ztmp [blas::vector create doublecomplex -length [blas::vector length $h11]]
    set ztmp $h21              
    blas::mathsvop ztmp + $h12

    set mason [blas::vector create double -length [blas::vector length $h11]]
    blas::mathsvop mason mod2 $ztmp
    blas::mathsvop mason *scal 0.25
    set dtmp [blas::math re $h11]
    blas::mathsvop dtmp * [blas::math re $h22]
    set dtmp2 [blas::math im $h12]
    blas::mathsvop dtmp2 * [blas::math im $h21]
    blas::mathsvop dtmp + $dtmp2
    blas::mathsvop mason / $dtmp
    return $mason
}

proc sparams::SexchangeBE {s} {

# BUGBUG BUG BUG blas::subvector create ... from sn garde le lien avec s
#    set sn $s

    set sn [blas::vector create doublecomplex -length [blas::vector length $s]]

    set n [expr {[blas::vector length $s]/4}]

    set s11 [blas::subvector create 1 4 $n from s]
    set s12 [blas::subvector create 2 4 $n from s]
    set s21 [blas::subvector create 3 4 $n from s]
    set s22 [blas::subvector create 4 4 $n from s]

    set s11n [blas::subvector create 1 4 $n from sn]
    set s12n [blas::subvector create 2 4 $n from sn]
    set s21n [blas::subvector create 3 4 $n from sn]
    set s22n [blas::subvector create 4 4 $n from sn]

    blas::zcopy $s11 s11n
    blas::zcopy $s21 s12n ;# sic
    blas::zcopy $s12 s21n ;# sic
    blas::zcopy $s22 s22n

    blas::mathsvop s11n *rscal -1.0
    blas::mathsvop s12n *rscal -1.0
    blas::mathsvop s21n *rscal -1.0
    blas::mathsvop s22n *rscal -1.0

    blas::mathsvop s11n +rscal -1.0
    blas::mathsvop s12n +rscal 2.0
    blas::mathsvop s21n +rscal 2.0
    blas::mathsvop s22n +rscal 1.0

# BUGBUG BUG BUG blas::subvector create ... from sn garde le lien avec s
#    set det $s11n
#    set tmp $s12n

    set det [blas::vector create doublecomplex -length $n]
    set tmp [blas::vector create doublecomplex -length $n]
    blas::zcopy $s11n det
    blas::zcopy $s12n tmp

    blas::mathsvop det * $s22n
    blas::mathsvop tmp * $s21n
    blas::mathsvop det - $tmp
    blas::mathsvop det inverse
    blas::mathsvop det *rscal 4.0

    blas::mathsvop s11n * $det
    blas::mathsvop s12n * $det
    blas::mathsvop s21n * $det
    blas::mathsvop s22n * $det

    blas::mathsvop s11n +rscal -1.0
    blas::mathsvop s12n +rscal 2.0
    blas::mathsvop s21n +rscal 2.0
    blas::mathsvop s22n +rscal 1.0

    return $sn
}


proc bigCalc {prefix} {
    global PMOD
    upvar ${prefix}s s

    set h $s
    sparams::transform HfromS h

    set z $s
    sparams::transform ZfromS z

    upvar ${prefix}s11 s11
    upvar ${prefix}s12 s12
    upvar ${prefix}s21 s21
    upvar ${prefix}s22 s22
    set s11  [v11 $s]
    set s12  [v12 $s]
    set s21  [v21 $s]
    set s22  [v22 $s]

    upvar ${prefix}h11 h11
    upvar ${prefix}h12 h12
    upvar ${prefix}h21 h21
    upvar ${prefix}h22 h22
    set h11  [v11 $h]
    set h12  [v12 $h]
    set h21  [v21 $h]
    set h22  [v22 $h]

    upvar ${prefix}z11 z11
    upvar ${prefix}z12 z12
    upvar ${prefix}z21 z21
    upvar ${prefix}z22 z22
    set z11  [v11 $z]
    set z12  [v12 $z]
    set z21  [v21 $z]
    set z22  [v22 $z]

    # on calcule en Base commune

    set Bs [sparams::SexchangeBE $s]

    set Bh $Bs
    sparams::transform HfromS Bh

    set Bz $Bs
    sparams::transform ZfromS Bz


    upvar ${prefix}Bs11 Bs11
    upvar ${prefix}Bs12 Bs12
    upvar ${prefix}Bs21 Bs21
    upvar ${prefix}Bs22 Bs22
    set Bs11  [v11 $Bs]
    set Bs12  [v12 $Bs]
    set Bs21  [v21 $Bs]
    set Bs22  [v22 $Bs]

    upvar ${prefix}Bh11 Bh11
    upvar ${prefix}Bh12 Bh12
    upvar ${prefix}Bh21 Bh21
    upvar ${prefix}Bh22 Bh22
    set Bh11  [v11 $Bh]
    set Bh12  [v12 $Bh]
    set Bh21  [v21 $Bh]
    set Bh22  [v22 $Bh]

    upvar ${prefix}Bz11 Bz11
    upvar ${prefix}Bz12 Bz12
    upvar ${prefix}Bz21 Bz21
    upvar ${prefix}Bz22 Bz22
    set Bz11  [v11 $Bz]
    set Bz12  [v12 $Bz]
    set Bz21  [v21 $Bz]
    set Bz22  [v22 $Bz]

    upvar ${prefix}zb zb
    set zb $Bz12
    blas::mathsvop zb *rscal $PMOD(Z0)

    upvar ${prefix}ze ze
    set ze $Bz11
    blas::mathsvop ze - $Bz12
    blas::mathsvop ze *rscal $PMOD(Z0)

    upvar ${prefix}zce zce
    set zce $Bz21
    blas::mathsvop zce - $Bz12
    blas::mathsvop zce *rscal $PMOD(Z0)

    upvar ${prefix}zcc zcc
    set zcc $Bz22
    blas::mathsvop zcc - $Bz12
    blas::mathsvop zcc *rscal $PMOD(Z0)

    upvar ${prefix}1/zcc 1/zcc
    set 1/zcc $zcc
    blas::mathsvop 1/zcc inverse

    upvar ${prefix}omega omega
    upvar ${prefix}alpha alpha
    set alpha [sparams::alpha $omega $zce $zcc]

    upvar ${prefix}gc gc
    upvar ${prefix}gcbis gcbis
    upvar ${prefix}fe fe
    upvar ${prefix}fc fc
    upvar ${prefix}fcmfe fcmfe
    foreach {gc gcbis fe fc} [sparams::alphaTrue $s $omega PMOD] break

    set fcmfe $fc
    blas::mathsvop fc - $fe

    upvar ${prefix}U U
    set U [sparams::U_mason $s11 $s12 $s21 $s22]


#    set UBis [sparams::U_masonBis $z11 $z12 $z21 $z22]

    upvar ${prefix}RbCbc RbCbc
    set RbCbc $h21
    set tmp $U
    blas::mathsvop tmp sqrt
    blas::mathsvop RbCbc /r $tmp

#    set UTer [sparams::U_masonTer $h11 $h12 $h21 $h22]
set rien {

    # Utile, mais style CRAPOTEUX CRAPOTEUX CRAPOTEUX CRAPOTEUX CRAPOTEUX
    # ligne défalquée (et effet de peau)

    upvar ${prefix}omega omega

    set unsurZ0 [expr {1.0/$PMOD(Z0)}]

    set nelems [blas::vector length $omega]
    set Zero [blas::vector create doublecomplex -length $nelems]
    blas::mathsvop Zero *rscal 0.0
    set Un $Zero
    blas::mathsvop Un +rscal 1.0

    set f1  [blas::vector create doublecomplex -length $nelems]
    set f2  [blas::vector create doublecomplex -length $nelems]
    set f3  [blas::vector create doublecomplex -length $nelems]
    set stmp  [blas::vector create doublecomplex -length [expr {4*$nelems}]]
    set tmp  [blas::vector create double -length $nelems]

    set sD $s

    blas::zcopy $Zero f1
    blas::zcopy $Zero f2
    blas::zcopy $Zero f3

    blas::dcopy $omega tmp
    blas::mathsvop tmp sqrt
    blas::mathsvop tmp *scal [expr {-$PMOD(Rskin)*$unsurZ0}]
    blas::mathsvop f1 +r $tmp
    blas::zcopy $f1 f2

    sparams::SwithZ sD $f1 $f2 $f3

    sparams::SofLine stmp $PMOD(Zrel) [expr {-$PMOD(nL)/299792458.}] $omega
    sparams::ScombL $stmp sD
    sparams::ScombR sD $stmp
  
    upvar ${prefix}s11D s11D
    upvar ${prefix}s12D s12D
    upvar ${prefix}s21D s21D
    upvar ${prefix}s22D s22D
    set s11D  [v11 $sD]
    set s12D  [v12 $sD]
    set s21D  [v21 $sD]
    set s22D  [v22 $sD]

    set hD $sD
    sparams::transform HfromS hD

    upvar ${prefix}h11D h11D
    upvar ${prefix}h12D h12D
    upvar ${prefix}h21D h21D
    upvar ${prefix}h22D h22D
    set h11D  [v11 $hD]
    set h12D  [v12 $hD]
    set h21D  [v21 $hD]
    set h22D  [v22 $hD]

    upvar ${prefix}UD UD
    set UD [sparams::U_mason $s11D $s12D $s21D $s22D]

    if {$prefix == "Exp_"} {
        upvar ${prefix}f f
        global fichier
        puts "# $fichier"
        puts "# défalqué de ligne nL=$PMOD(nL), Zrel=$PMOD(Zrel), Rskin=$PMOD(Rskin)"
        puts "# f h21 U"
        foreach ef [lrange $f 1 end] eh21 [lrange [21mod $nelems $hD] 1 end] eU [lrange $UD 1 end] {
            puts "$ef $eh21 [expr {10.*log10($eU)}]"
        } 
    }
}

}

set PT 0

proc plotout {} {
    global Mod_f Exp_f Exp_s 2M_PI PMOD PMOD0 CALCUL
#    global plot_mzero plot_h21_mod plot_vh21_mod

global PT
incr PT
#puts stderr "plotout $PT"

    set Mod_nelems [blas::vector length $Mod_f]
    set Mod_omega [blas::vector create double -length $Mod_nelems]
    blas::daxpy ${2M_PI} $Mod_f Mod_omega
    set Mod_s [blas::vector create doublecomplex -length [expr {4*$Mod_nelems}]]

    set Mod0_nelems $Mod_nelems
    set Mod0_omega $Mod_omega
    set Mod0_s [blas::vector create doublecomplex -length [expr {4*$Mod_nelems}]]

    set Exp_nelems [blas::vector length $Exp_f]
    set Exp_omega [blas::vector create double -length $Exp_nelems]
    blas::daxpy ${2M_PI} $Exp_f Exp_omega
    
    $CALCUL Mod_s PMOD $Mod_omega
    $CALCUL Mod0_s PMOD0 $Mod0_omega
    
    bigCalc Mod_
    bigCalc Mod0_
    bigCalc Exp_

    foreach diese {{} #1 #2} {

        toplor U$diese U
#        toplor UBis$diese UBis
        # toplor UTer$diese UTer
        
        foreach x {s11 s12 s21 s22 h11 h12 h21 h22 z11 z12 z21 z22 zb ze zce zcc 1/zcc alpha gc gcbis fe fc fcmfe RbCbc} {
            toplo $x$diese $x
        }
        foreach x {Bs11 Bs12 Bs21 Bs22 Bh11 Bh12 Bh21 Bh22 Bz11 Bz12 Bz21 Bz22} {
            toplo $x$diese $x
        }
        # toplor UD$diese UD
        # toplo h21D$diese h21D

    }
}
