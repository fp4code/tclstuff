#!/bin/sh
# \
exec tclsh "$0" ${1+"$@"}

# (C) CNRS/LPN (FP) 2001.03.06
# des procédures sont à mettre dans library

package require fidev
package require superTable
package require blasObj
package require dblas1
package require zblas1
package require blasmath
package require slatec

package require sparams2

set M_PI [expr {4.0*atan(1.0)}]
set 2M_PI [expr {2.0*$M_PI}]

set PMOD(Z0) 50
set PMOD(Zrel) 1
set PMOD(nL) 0.00041
set PMOD(Rskin) 2.2e-6


proc readFichier {fichier} {
    upvar f f
    upvar s s

    set nomDeTable "*Sparams"
    catch {unset array}
    set indexes [::superTable::fileToTable array $fichier nomDeTable {}]

    set lignes [lindex $indexes 0]
    set colonnes [lindex $indexes 1]
    
    set f [list]
    set s [list]
    set nelems 0
    foreach li $lignes {
        lappend f [::superTable::getCell array $li freq]
        lappend s [::superTable::getCell array $li s11_r] [::superTable::getCell array $li s11_i]\
                [::superTable::getCell array $li s12_r] [::superTable::getCell array $li s12_i]\
                [::superTable::getCell array $li s21_r] [::superTable::getCell array $li s21_i]\
                [::superTable::getCell array $li s22_r] [::superTable::getCell array $li s22_i]
        incr nelems
    }
        
    set f [blas::vector create double $f]
    set s [blas::vector create doublecomplex $s]
}

proc v11 {x} {
    set l [blas::vector length $x]
    if {$l % 4} {
        return -code error "not a 2x2 matrix"
    }
    set l [expr {$l/4}]
    set v [blas::vector create [blas::vector type $x] -length $l]
    blas::zcopy [blas::subvector create 1 4 $l $x] v
    return $v
}

proc v12 {x} {
    set l [blas::vector length $x]
    if {$l % 4} {
        return -code error "not a 2x2 matrix"
    }
    set l [expr {$l/4}]
    set v [blas::vector create [blas::vector type $x] -length $l]
    blas::zcopy [blas::subvector create 2 4 $l $x] v
    return $v
}

proc v21 {x} {
    set l [blas::vector length $x]
    if {$l % 4} {
        return -code error "not a 2x2 matrix"
    }
    set l [expr {$l/4}]
    set v [blas::vector create [blas::vector type $x] -length $l]
    blas::zcopy [blas::subvector create 3 4 $l $x] v
    return $v
}

proc v22 {x} {
    set l [blas::vector length $x]
    if {$l % 4} {
        return -code error "not a 2x2 matrix"
    }
    set l [expr {$l/4}]
    set v [blas::vector create [blas::vector type $x] -length $l]
    blas::zcopy [blas::subvector create 4 4 $l $x] v
    return $v
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

proc 21mod {nelems x} {
    
    set ierr [blas::vector create long -length $nelems]
    set xl [blas::vector create doublecomplex -length $nelems]
    blas::slatec zlog [blas::subvector create 3 4 $nelems $x] xl ierr 
    set 21mod [blas::vector create double -length $nelems]
    blas::daxpy [expr {20./log(10.)}] [blas::math re $xl] 21mod
    return $21mod
}

proc clean {fichier} {
    global PMOD 2M_PI

    if {[file pathtype $fichier] != "relative"} {
        return -code error "chemin incorrect \"$fichier\", doit être relatif"
    }

    readFichier $fichier
    
    set fsplit [file split $fichier]

    set ddir [concat defalques [lrange $fsplit 0 end-1]]
    set spt [lindex $fsplit end]
    if {![regexp {^(.*)\.spt$} $spt tout radical]} {
        set radical $spt
    }
    set dfich [concat $ddir ${radical}.dat]

    file mkdir [eval file join $ddir]
    set datout [open [eval file join $dfich] w]

    # ligne défalquée (et effet de peau)

    set unsurZ0 [expr {1.0/$PMOD(Z0)}]
    
    set omega $f
    blas::mathsvop omega *scal ${2M_PI}


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

    set s11D  [v11 $sD]
    set s12D  [v12 $sD]
    set s21D  [v21 $sD]
    set s22D  [v22 $sD]

    set hD $sD
    sparams::transform HfromS hD

    set h11D  [v11 $hD]
    set h12D  [v12 $hD]
    set h21D  [v21 $hD]
    set h22D  [v22 $hD]

    set UD [sparams::U_mason $s11D $s12D $s21D $s22D]
    set U_terD [sparams::U_masonTer $h11D $h12D $h21D $h22D]

    puts $datout "# [eval file join [file split [pwd]] $fsplit]"
    puts $datout "# défalqué de ligne nL=$PMOD(nL), Zrel=$PMOD(Zrel), Rskin=$PMOD(Rskin)"
    puts $datout "#     f       h21     U"
    foreach ef [lrange $f 1 end] eh21 [lrange [21mod $nelems $hD] 1 end] eU [lrange $UD 1 end] eU_ter [lrange $U_terD 1 end] {
        # puts stderr "$eU $eU_ter"
        if {$eU < 1e-10} {
            puts stderr "Warning, Umason = $eU < 1e-10"
            set eU 1e-10
        }
        puts $datout [format "%.3e %7.2f %7.2f" $ef $eh21 [expr {10.*log10($eU)}]]
    }
    close $datout
    puts stderr "[eval file join $dfich] done"
}
# /home/asdex/A/data/G000712/G000712.2/hyper2/
set fichier data/54C5x17/0p010mA1p10V.spt

set fichiers [list]
foreach a $argv {
    set fichiers [concat $fichiers [glob -nocomplain -- $a]]
}

if {$fichiers == {}} {
    puts stderr "no file to process !"
    return
}

foreach fichier $fichiers {
    if {[catch {clean $fichier} message]} {
        puts stderr "error pour $fichier: \"$message\""
        puts stderr $errorInfo
    }
}