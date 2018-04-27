source [file join [file dirname [info script]] piano.tcl]

set CALCUL sparams::EtalonOuvert

set fichier /home/asdex/A/data/G000106/G000106.0/hyper/63A5x17/0mA0V.spt
# set fichier ~/Z/hbt.spt

set GO 0

# set tcl_traceExec 2

readFichier $fichier


proc sparams::EtalonOuvert {&s &PMOD omega} {
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

    set tmp [blas::vector create double -length $nelems]

    set s11 [blas::subvector create 1 4 $nelems from s]
    set s12 [blas::subvector create 2 4 $nelems from s]
    set s21 [blas::subvector create 3 4 $nelems from s]
    set s22 [blas::subvector create 4 4 $nelems from s]
    
    blas::zcopy $Un   s11
    blas::zcopy $Zero s12
    blas::zcopy $Zero s21
    blas::zcopy $Un   s22
    
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

    sparams::SofLine stmp $PMOD(Zrel) [expr {$PMOD(nL)/299792458.}] $omega

    # 22255 return

    sparams::ScombR s $stmp

    # 23156 return

    sparams::ScombL $stmp s

    # 24070 return

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

set PMOD(Z0) 50
set PMOD(Zrel) 1
set PMOD(nL) 450e-6
set PMOD(Cp) 0
set PMOD(Rp) 0
set PMOD(Rb) 0
set PMOD(RbS) 0
set PMOD(CbS) 0
set PMOD(Lb) 0
set PMOD(Re) 0
set PMOD(ReS) 0
set PMOD(CeS) 0
set PMOD(Le) 0
set PMOD(cc_ext) 0.e-15
set PMOD(Rc) 10000
set PMOD(RcS) 0
set PMOD(CcS) 0
set PMOD(Lc) 0
set PMOD(CcSbis) 0
set PMOD(RcSbis) 0
set PMOD(ce_ext) 0.e-15

set PMODMIN(Zrel) 0.7
set PMODMIN(nL) 0
set PMODMIN(Cp) 0
set PMODMIN(Rp) 0
set PMODMIN(Rb) 0
set PMODMIN(RbS) 0
set PMODMIN(CbS) 0
set PMODMIN(Lb) 0
set PMODMIN(Re) 0
set PMODMIN(ReS) 0
set PMODMIN(CeS) 0
set PMODMIN(Le) 0
set PMODMIN(Ro) 100
set PMODMIN(cc) 0
set PMODMIN(cc_ext) 0
set PMODMIN(Rc) 0
set PMODMIN(RcS) 0
set PMODMIN(CcS) 0
set PMODMIN(Lc) 0
set PMODMIN(alpha0) 0.95
set PMODMIN(taue1) -2e-12
set PMODMIN(tauc1) 0e-12
set PMODMIN(taue2) -1e-11
set PMODMIN(tauc2) -1e-11
set PMODMIN(CcSbis) 0
set PMODMIN(RcSbis) 0
set PMODMIN(ce) 0
set PMODMIN(ce_ext) 0.e-15

set PMODMAX(Zrel) 1.3
set PMODMAX(nL) 800e-6
set PMODMAX(Cp) 100e-15
set PMODMAX(Rp) 10
set PMODMAX(rb) 10
set PMODMAX(Rb) 10
set PMODMAX(RbS) 100
set PMODMAX(CbS) 1e-12
set PMODMAX(Lb) 1e-12
set PMODMAX(re) 100
set PMODMAX(Re) 10
set PMODMAX(ReS) 100
set PMODMAX(CeS) 1e-12
set PMODMAX(Le) 1e-12
set PMODMAX(Ro) 100000.
set PMODMAX(cc) 50e-15
set PMODMAX(cc_ext) 50e-15
set PMODMAX(Rc) 20000
set PMODMAX(RcS) 100
set PMODMAX(CcS) 1e-12
set PMODMAX(Lc) 1e-12
set PMODMAX(alpha0) 1
set PMODMAX(taue1) 2e-12
set PMODMAX(tauc1) 2e-12
set PMODMAX(taue2) 1e-11
set PMODMAX(tauc2) 1e-11
set PMODMAX(CcSbis) 1e-12
set PMODMAX(RcSbis) 100
set PMODMAX(ce) 500e-15
set PMODMAX(ce_ext) 100e-15


foreach p {s11 s12 s21 s22 z11 z12 z21 z22 h11 h12 h21 h22} {
    set fb [frame .b.choix1.f_$p -borderwidth 4 -relief sunken]
    pack $fb -side left
    foreach diese {{} #1 #2} {
        pack [createChoice $fb $p$diese]
    }
}

foreach p {b_s11 b_s12 b_s21 b_s22 b_z11 b_z12 b_z21 b_z22} {
    set fb [frame .b.choix2.f_$p -borderwidth 4 -relief sunken]
    pack $fb -side left
    foreach diese {{} #1 #2} {
        pack [createChoice $fb $p$diese]
    }
}

foreach p {} {
    set fb [frame .b.choix3.f_$p -borderwidth 4 -relief sunken]
    pack $fb -side left
    foreach diese {{} #1 #2} {
        pack [createChoice $fb $p$diese]
    }
}

foreach p [array names PMOD] {
    set PMOD0($p) $PMOD($p)
}

set lg [list]
foreach p {nL Zrel Rp Cp cc_ext ce_ext} {
    set s [superscale .b.fs $p]
    lappend lg $s
    set SPMOD($s) $p
}
eval grid configure $lg

set lg [list]
foreach p {Re Le ReS CeS Rb Lb RbS CbS Rc Lc RcS CcS RcSbis CcSbis} {
    set s [superscale .b.fs $p]
    lappend lg $s
    set SPMOD($s) $p
}
eval grid configure $lg

set LAST $s

# dimension 

set mnelems [blas::vector length $mf]
set vnelems [blas::vector length $vf]


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

proc plotout {} {
    global mf vf vs 2M_PI PMOD PMOD0 CALCUL
    global plot_mzero plot_h21_mod plot_vh21_mod

    set mnelems [blas::vector length $mf]
    set vnelems [blas::vector length $vf]
    set s [blas::vector create doublecomplex -length [expr {4*$mnelems}]]
    set sb [blas::vector create doublecomplex -length [expr {4*$mnelems}]]
    set momega [blas::vector create double -length $mnelems]
    set vomega [blas::vector create double -length $vnelems]
    blas::daxpy ${2M_PI} $mf momega
    blas::daxpy ${2M_PI} $vf vomega
    
    $CALCUL s PMOD $momega
    $CALCUL sb PMOD0 $momega
    
    set h $s
    sparams::transform HfromS h

    set hb $sb
    sparams::transform HfromS hb

    set vh $vs
    sparams::transform HfromS vh

    set z $s
    sparams::transform ZfromS z

    set zb $sb
    sparams::transform ZfromS zb

    set vz $vs
    sparams::transform ZfromS vz

    set s11 [v11 $s]
    set s12 [v12 $s]
    set s21 [v21 $s]
    set s22 [v22 $s]
    set sb11 [v11 $sb]
    set sb12 [v12 $sb]
    set sb21 [v21 $sb]
    set sb22 [v22 $sb]
    set vs11 [v11 $vs]
    set vs12 [v12 $vs]
    set vs21 [v21 $vs]
    set vs22 [v22 $vs]

    set h11 [v11 $h]
    set h12 [v12 $h]
    set h21 [v21 $h]
    set h22 [v22 $h]
    set hb11 [v11 $hb]
    set hb12 [v12 $hb]
    set hb21 [v21 $hb]
    set hb22 [v22 $hb]
    set vh11 [v11 $vh]
    set vh12 [v12 $vh]
    set vh21 [v21 $vh]
    set vh22 [v22 $vh]

    set z11 [v11 $z]
    set z12 [v12 $z]
    set z21 [v21 $z]
    set z22 [v22 $z]
    set zb11 [v11 $zb]
    set zb12 [v12 $zb]
    set zb21 [v21 $zb]
    set zb22 [v22 $zb]
    set vz11 [v11 $vz]
    set vz12 [v12 $vz]
    set vz21 [v21 $vz]
    set vz22 [v22 $vz]

    # on calcule en Base commune

    set b_s [sparams::SexchangeBE $s]
    set b_sb [sparams::SexchangeBE $sb]
    set vb_s [sparams::SexchangeBE $vs]

    set b_z $b_s
    sparams::transform ZfromS b_z

    set b_zb $b_sb
    sparams::transform ZfromS b_zb

    set vb_z $vb_s
    sparams::transform ZfromS vb_z

    set b_s11 [v11 $b_s]
    set b_s12 [v12 $b_s]
    set b_s21 [v21 $b_s]
    set b_s22 [v22 $b_s]
    set b_sb11 [v11 $b_sb]
    set b_sb12 [v12 $b_sb]
    set b_sb21 [v21 $b_sb]
    set b_sb22 [v22 $b_sb]
    set vb_s11 [v11 $vb_s]
    set vb_s12 [v12 $vb_s]
    set vb_s21 [v21 $vb_s]
    set vb_s22 [v22 $vb_s]

    set b_z11 [v11 $b_z]
    set b_z12 [v12 $b_z]
    set b_z21 [v21 $b_z]
    set b_z22 [v22 $b_z]
    set b_zb11 [v11 $b_zb]
    set b_zb12 [v12 $b_zb]
    set b_zb21 [v21 $b_zb]
    set b_zb22 [v22 $b_zb]
    set vb_z11 [v11 $vb_z]
    set vb_z12 [v12 $vb_z]
    set vb_z21 [v21 $vb_z]
    set vb_z22 [v22 $vb_z]


    foreach diese {{} #1 #2} {

        toplo s11$diese $s11 $sb11 $vs11
        toplo s12$diese $s12 $sb12 $vs12
        toplo s21$diese $s21 $sb21 $vs21
        toplo s22$diese $s22 $sb22 $vs22
        
        toplo h11$diese $h11 $hb11 $vh11
        toplo h12$diese $h12 $hb12 $vh12
        toplo h21$diese $h21 $hb21 $vh21
        toplo h22$diese $h22 $hb22 $vh22
        
        toplo z11$diese $z11 $zb11 $vz11
        toplo z12$diese $z12 $zb12 $vz12
        toplo z21$diese $z21 $zb21 $vz21
        toplo z22$diese $z22 $zb22 $vz22
 
        toplo b_s11$diese $b_s11 $b_sb11 $vb_s11
        toplo b_s12$diese $b_s12 $b_sb12 $vb_s12
        toplo b_s21$diese $b_s21 $b_sb21 $vb_s21
        toplo b_s22$diese $b_s22 $b_sb22 $vb_s22
        
        toplo b_z11$diese $b_z11 $b_zb11 $vb_z11
        toplo b_z12$diese $b_z12 $b_zb12 $vb_z12
        toplo b_z21$diese $b_z21 $b_zb21 $vb_z21
        toplo b_z22$diese $b_z22 $b_zb22 $vb_z22
    }
}
