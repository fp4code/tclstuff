#!/bin/sh
# \
exec wish "$0" ${1+"$@"}

# (C) CNRS/LPN (FP) 2001.03.20

package require fidev
package require hyperHBT

set CALCUL sparams::HBT

#set fichier /home/asdex/A/data/G000712/G000712.1/hyper/data/37B5x17/0p085mA1p10V.spt
set fichier /home/asdex/A/data/G000712/G000712.2/hyper2/data/54C5x17/0p010mA1V.spt
# set fichier ~/Z/hbt.spt

set GO 0

# set tcl_traceExec 2

set Q(Z0) 50

set Q(Zrel) 1
set Q(nL) 410e-6

set Q(Cp) 0
set Q(Rskin) 2.2e-6
set Q(Rp) 0
set Q(rb) 14.7
set Q(Rb) 0
set Q(RbS) 5.5
set Q(CbS) 8e-14
set Q(Lb) 0
set Q(Re) 0
set Q(ReS) 0
set Q(CeS) 0
set Q(Le) 0
set Q(cc_ext) 0.e-15
set Q(Rc) 0
set Q(RcS) 0
set Q(CcS) 0
set Q(Lc) 0
set Q(CcSbis) 0
set Q(RcSbis) 0
set Q(ce_ext) 0e-15


foreach choix {choix1 choix2 choix3} plist {
    {s11 s12 s21 s22 z11 z12 z21 z22 h11 h12 h21 h22}
    {Bs11 Bs12 Bs21 Bs22 Bz11 Bz12 Bz21 Bz22 Bh11 Bh12 Bh21 Bh22 U RbCbc}
    {zb ze zce zcc 1/zcc alpha gc gcbis fe fc fcmfe h21D UD}
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