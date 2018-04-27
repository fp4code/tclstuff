#!/bin/sh
# \
exec wish "$0" ${1+"$@"}

# (C) CNRS/LPN (FP) 2001.03.20
# (C) CNRS/LPN (FP) 2001.04.13

package require fidev
package require hyperHBT

set CALCUL sparams::HBT

#set fichier /home/asdex/A/data/G000712/G000712.1/hyper/data/37B5x17/0p085mA1p10V.spt
set fichier /home/asdex/A/data/G000712/G000712.2/hyper2/data/54C5x17/0p010mA1V.spt
# set fichier ~/Z/hbt.spt

set GO 0

# set tcl_traceExec 2


set PMOD(Z0) 50
set PMOD(Zrel) 1
set PMOD(nL) 410e-6
set PMOD(Cp) 0
set PMOD(Rskin) 2.2e-6
set PMOD(Rp) 0
set PMOD(rb) 14.7
set PMOD(Rb) 0
set PMOD(RbS) 5.5
set PMOD(CbS) 8e-14
set PMOD(Lb) 0
set PMOD(re) 10.125
set PMOD(Re) 0
set PMOD(ReS) 0
set PMOD(CeS) 0
set PMOD(Le) 0
set PMOD(Ro) 14250
set PMOD(cc) 11.5e-15
set PMOD(cc_ext) 0.e-15
set PMOD(Rc) 0
set PMOD(RcS) 0
set PMOD(CcS) 0
set PMOD(Lc) 4e-13
set PMOD(typAlpha) 3
set PMOD(alpha0) 0.992
set PMOD(taue1) 0.16e-12
set PMOD(tauc1) 0.9e-12
set PMOD(taue2) -1.1e-12
set PMOD(tauc2) -1e-12
set PMOD(CcSbis) 0
set PMOD(RcSbis) 0
set PMOD(ce_ext) 0.e-15
set PMOD(typPi) 0


set PMOD(CbS)       0.0
set PMOD(CcS)       0.0
set PMOD(CcSbis)    0.0
set PMOD(CeS)       0.0
set PMOD(Cp)        0
set PMOD(Lb)        0.0
set PMOD(Lc)        0.0
set PMOD(Le)        0.0
set PMOD(Rb)        10.12
set PMOD(RbS)       5.5
set PMOD(Rc)        9.793
set PMOD(RcS)       0.0
set PMOD(RcSbis)    0.0
set PMOD(Re)        0.557192
set PMOD(ReS)       21
set PMOD(Ro)        1.247e+05
set PMOD(Rp)        0.0
set PMOD(Rskin)     2.2e-06
set PMOD(Z0)        50
set PMOD(Zrel)      1.0
set PMOD(alpha0)    0.9917
set PMOD(cc)        12.83e-15
set PMOD(ce)        0.0
set PMOD(cc_ext)    0
set PMOD(ce_ext)    88.27e-15
set PMOD(nL)        0.00041
set PMOD(rb)        10.08
set PMOD(re)        26.9
set PMOD(tauc1)     1.255e-12
set PMOD(tauc2)     0.0
set PMOD(taue1)     1.99e-12
set PMOD(taue2)     0.0


set PMODMIN(CbS)       0.0
set PMODMIN(CcS)       0.0
set PMODMIN(CcSbis)    0.0
set PMODMIN(CeS)       0.0
set PMODMIN(Cp)        0.0
set PMODMIN(Lb)        0.0
set PMODMIN(Lc)        0.0
set PMODMIN(Le)        0.0
set PMODMIN(Rb)        0.0
set PMODMIN(RbS)       0.0
set PMODMIN(Rc)        0.0
set PMODMIN(RcS)       0.0
set PMODMIN(RcSbis)    0.0
set PMODMIN(Re)        0.0
set PMODMIN(ReS)       0.0
set PMODMIN(Ro)        1.e+04
set PMODMIN(Rp)        0.0
set PMODMIN(Rskin)     0.0
set PMODMIN(Zrel)      1.0
set PMODMIN(alpha0)    0.99
set PMODMIN(cc)        0.0
set PMODMIN(cc_ext)    0.0
set PMODMIN(ce_ext)    0.0
set PMODMIN(nL)        0.0003
set PMODMIN(rb)        0.0
set PMODMIN(re)        1.0
set PMODMIN(tauc1)     0.0e-12
set PMODMIN(tauc2)     0.0
set PMODMIN(taue1)     -5e-12
set PMODMIN(taue2)     0.0

set PMODMAX(CbS)       1e-12
set PMODMAX(CcS)       1e-12
set PMODMAX(CcSbis)    1e-12
set PMODMAX(CeS)       1e-12
set PMODMAX(Cp)        10e-15
set PMODMAX(Lb)        1e-12
set PMODMAX(Lc)        1e-12
set PMODMAX(Le)        1e-12
set PMODMAX(Rb)        50
set PMODMAX(RbS)       50
set PMODMAX(Rc)        50
set PMODMAX(RcS)       100
set PMODMAX(RcSbis)    100
set PMODMAX(Re)        50
set PMODMAX(ReS)       100
set PMODMAX(Ro)        2e+05
set PMODMAX(Rp)        10
set PMODMAX(Rskin)     5e-06
set PMODMAX(Zrel)      1.2
set PMODMAX(alpha0)    1.0
set PMODMAX(cc)        20e-15
set PMODMAX(cc_ext)    20e-15
set PMODMAX(ce_ext)    200e-15
set PMODMAX(nL)        0.00050
set PMODMAX(rb)        50
set PMODMAX(re)        50
set PMODMAX(tauc1)     2e-12
set PMODMAX(tauc2)     2e-12
set PMODMAX(taue1)     4e-12
set PMODMAX(taue2)     2e-12

foreach choix {choix1 choix2 choix3 choix4} plist {
    {s11 s12 s21 s22 z11 z12 z21 z22 h11 h12 h21 h22}
    {Bs11 Bs12 Bs21 Bs22 Bz11 Bz12 Bz21 Bz22 Bh11 Bh12 Bh21 Bh22 U RbCbc}
    {zb ze zce zcc 1/zcc alpha gc gcbis fe fc fcmfe h21D UD}
    {kA kB kC kD k}
} {
    foreach p $plist {
        set fb [frame .b.$choix.f_$p -borderwidth 4 -relief sunken]
        pack $fb -side left
        foreach diese {{} #1 #2} {
            set b [createChoice $fb $p$diese]
            pack $b
            if {$diese == {}} {
                lappend CHOICES $b
            }
        }
    }
}

foreach p [array names PMOD] {
    set PMOD0($p) $PMOD($p)
}

set PMODORDER [list]
set lg [list]
foreach p {alpha0 Ro cc rb re taue1 taue2 tauc1 tauc2 nL Zrel Rp Cp Rskin } {
    set s [superscale .b.fs $p]
    lappend lg $s
    lappend PMODORDER $p
    set SPMOD($s) $p
}
eval grid configure $lg

set lg [list]
foreach p {cc_ext ce_ext Re Le ReS CeS Rb Lb RbS CbS Rc Lc RcS CcS RcSbis CcSbis} {
    set s [superscale .b.fs $p]
    lappend lg $s
    lappend PMODORDER $p
    set SPMOD($s) $p
}
eval grid configure $lg

set LAST $s

# dimension 

set rien {
    set mnelems [blas::vector length $Mod_f]
    set vnelems [blas::vector length $Exp_f]
}

readFichier $fichier
# plotout ;# pour démarrer les initialisations, inclus dans readFichier