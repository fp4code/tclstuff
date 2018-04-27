set FACD 1000.

proc fitIni {} {
    global CHOICE Exp_f  Exp_omega Exp_s 2M_PI
    global Fit
    global PMODFIT PMODORDER PMOD PMODMIN PMODMAX FACD

    # deviendront des vecteurs à la fin
    set Fit(x) [list]
    set Fit(b) [list]
    set Fit(d) [list]
    set Fit(lfits) [list]
    set Fit(vfits) [list]

    set Exp_omega [blas::vector create double -length [blas::vector length $Exp_f]]
    blas::daxpy ${2M_PI} $Exp_f Exp_omega

    set lfits [list]
    bigCalc Exp_
    foreach commonCtxName [info globals commonCtx_*] {
        upvar #0 $commonCtxName commonCtx
        set var [string range $commonCtxName 10 end] ;# 10 == [string length "commonCtx_"]
        set fits [array names commonCtx "fit,*"]
        foreach fit $fits {
            # Il faut que deux boutons soient enclenchés:
            if {$CHOICE($var) && $commonCtx($fit)} {
                set t [string range $fit 4 end] ;# 4 ==  [string length "fit,"]
                set xmin $commonCtx(xmin,$t)
                set xmax $commonCtx(xmax,$t)
                set xlinlog $commonCtx(xlinlog,$t)
                switch $xlinlog {
                    lin {}
                    log {
                        set xmin [expr {pow(10, $xmin)}]
                        set xmax [expr {pow(10, $xmax)}]
                    }
                    default {
                        return -code error "unknown xlinlog \"$xlinlog\""
                    }
                }
                set ymin $commonCtx(ymin,$t)
                set ymax $commonCtx(ymax,$t)
                set ylinlog $commonCtx(ylinlog,$t)
                switch $ylinlog {
                    lin {}
                    log {
                        set ymin [expr {pow(10, $ymin)}]
                        set ymax [expr {pow(10, $ymax)}]
                    }
                    default {
                        return -code error "unknown ylinlog \"$ylinlog\""
                    }
                }
                # calcul des bornes à partir de la courbe visible
                # Les fréquences sont supposées ordonnées
                foreach {ixmin ixmax} [blas::mathop connexBounds $Exp_f $xmin $xmax] break
                
                set id [string first # $var]
                if {$id >= 0} {
                    set svar [string range $var 0 [expr {$id -1 }]]
                } else {
                    set svar $var
                }
                if {![info exists ${t}_${var}]} {
                    if {$t == "x" || $t == "y" || $t == "m" || $t == "d"} {
                        calcplo _$var [set Exp_${svar}]
                    } elseif {$t == "f" || $t == "mf"} {
                        calcplor _$var [set Exp_${svar}]
                    } else {
                        return -code error "bad type \"$t\""
                    }
                }
                
                set nelems [expr {1 + $ixmax - $ixmin}]
                set sv [blas::subvector create $ixmin 1 $nelems [set ${t}_$var]]

                if {[catch {foreach {iymin iymax} [blas::mathop connexBounds $sv $ymin $ymax] break} message]} {
                    return -code error "$var $t -> $message"
                }
                set imin [expr {$ixmin + $iymin - 1}]
                set imax [expr {$ixmin + $iymax - $iymin}]

                puts "* $var $t $xmin $xmax $ymin $ymax -> $ixmin $ixmax $iymin $iymax -> $imin $imax"

                lappend lfits $var $t $imin $imax $ymin $ymax
            }
        }
    }
    set pmodfit [list]
    foreach pmod $PMODORDER {
        if {[info exists PMODFIT($pmod)] && $PMODFIT($pmod)} {
            lappend pmodfit $pmod
        }
    }
    foreach pmod $pmodfit {
        lappend Fit(vfits) $pmod
        lappend Fit(x) $PMOD($pmod)
        lappend Fit(b) $PMODMIN($pmod) $PMODMAX($pmod)
        lappend Fit(d) [expr {1.0/$PMODMAX($pmod)/double($FACD)}]
    }

    set Fit(x) [blas::vector create double $Fit(x)]
    set Fit(b) [blas::vector create double $Fit(b)]
    set Fit(d) [blas::vector create double $Fit(d)]
    set p [blas::vector length $Fit(x)]
    set liv [expr {59 + $p}]
    set lv [expr {77 + ($p*($p+23))/2}]
    set Fit(alg) 2
    set Fit(iv) [blas::vector create long -length $liv]
    set Fit(v) [blas::vector create double -length $lv]
    port3::divset $Fit(alg) Fit(iv) Fit(v)

    set Fit(lfits) $lfits
    puts stderr "[lindex $Fit(iv) 1], x = $Fit(x)"
}

proc fitStep {pt} {
    global Fit
    global Exp_f  Exp_omega Exp_s PMOD CALCUL 2M_PI
    global Exp_omega
    set Fit_f $Exp_f
    set Fit_omega $Exp_omega

    set Fit_s [blas::vector create doublecomplex -length [expr {4*[blas::vector length $Fit_omega]}]]
    $CALCUL Fit_s PMOD $Fit_omega
   
    bigCalc Exp_
    bigCalc Fit_

    set fx [expr {0.0}]
    set nfx [expr {0}]
    
    foreach {var t imin imax ymin ymax} $Fit(lfits) {
        set nelems [expr {$imax - $imin + 1}]
        if {$nelems <= 0} {
            return -code error "imin = $imin >= imax = $imax pour $var $t $ymin $ymax"
        }

        set id [string first # $var]
        if {$id >= 0} {
            set svar [string range $var 0 [expr {$id -1 }]]
        } else {
            set svar $var
        }

        if {$t == "f" || $t == "mf"} {
            set expr [blas::vector create double -length $nelems]
            set fitr [blas::vector create double -length $nelems]
            blas::dcopy [blas::subvector create $imin 1 $nelems [set Exp_${svar}]] expr
            blas::dcopy [blas::subvector create $imin 1 $nelems [set Fit_${svar}]] fitr
        } else {
            set exp [blas::vector create doublecomplex -length $nelems]
            set fit [blas::vector create doublecomplex -length $nelems]
            blas::zcopy [blas::subvector create $imin 1 $nelems [set Exp_${svar}]] exp
            blas::zcopy [blas::subvector create $imin 1 $nelems [set Fit_${svar}]] fit
        }

        switch $t {
            "x" {
                set x_Exp_$var [blas::math re $exp]
                set x_Fit_$var [blas::math re $fit]
            }
            "y" {
                set y_Exp_$var [blas::math im $exp]
                set y_Fit_$var [blas::math im $fit]
            }
            "m" {
                # pas économique
                set ierr [blas::vector create long -length $nelems]
                set z [blas::vector create doublecomplex -length $nelems]

                blas::slatec zlog $exp z ierr
                set m_Exp_$var [blas::math re $z]
                blas::mathsvop m_Exp_$var *scal [expr {20./log(10.)}]

                blas::slatec zlog $fit z ierr
                set m_Fit_$var [blas::math re $z]
                blas::mathsvop m_Fit_$var *scal [expr {20./log(10.)}]
            }
            "d" {
                # pas économique
                set ierr [blas::vector create long -length $nelems]
                set z [blas::vector create doublecomplex -length $nelems]

                blas::slatec zlog $exp z ierr
                set d_Exp_$var [blas::math im $z]
                blas::mathsvop d_Exp_$var *scal [expr {360./$2M_PI}]
                blas::mathsvop d_Exp_$var continuousModulo 360.0

                blas::slatec zlog $fit z ierr
                set d_Fit_$var [blas::math im $z]
                blas::mathsvop d_Fit_$var *scal [expr {360./$2M_PI}]
                blas::mathsvop d_Fit_$var continuousModulo 360.0
            }
            "f" {
                set f_Exp_$var $expr
                blas::mathsvop f_Exp_$var sqrt
                set f_Fit_$var $fitr
                blas::mathsvop f_Fit_$var sqrt
            }
            "mf" {
                set mf_Exp_$var $expr
                blas::mathsvop mf_Exp_$var log10
                blas::mathsvop mf_Exp_$var *scal 10.
                set mf_Fit_$var $fitr
                blas::mathsvop mf_Fit_$var log10
                blas::mathsvop mf_Fit_$var *scal 10.
            }
            default {
                return -code error "switch: bad type \"$t\""
            }
        }

    
        set tmp [set ${t}_Fit_$var]
        blas::mathsvop tmp - [set ${t}_Exp_$var]

        set norme [blas::dnrm2 $tmp]
        if {[catch {expr {$norme/($ymax - $ymin)}} nn]} {
            puts stderr "ERREUR $var $t: $norme/($ymax -$ymin) ($nn)"
            set n2 1e30 ;# arbitraire
        } else {
            set n2 [expr {$nn*$nn/double($nelems)}]
            if {0 && $var == "s12" && $t == "x"} {
                puts stderr "$var $t -> $nn*$nn/double($nelems) = $n2"
                puts stderr "exp = $exp"
                puts stderr "tmp = $tmp"
            } 
        }
       
        set N2($var:$t) $n2
        set fx [expr {$fx + $n2}]
        incr nfx
    }

    if {0} {
        foreach v [lsort -command {sortnorm N2} [array names N2]] {
            puts "[format %10s $v] [expr {sqrt($N2($v))}]"
        }
    }

    set fx [expr {sqrt($fx/$nfx)}]

    puts -nonewline stderr "FX = $fx"
    
    port3::drmnfb $Fit(b) $Fit(d) $fx Fit(iv) Fit(v) Fit(x)
    puts stderr ", iv(1) = [lindex $Fit(iv) 1]"
    # x = $Fit(x)"

    foreach var $Fit(vfits) x [lrange $Fit(x) 1 end] {
        set xx [format %.4g $x]
        if {$PMOD($var) != $xx} {
            puts stderr "### $var -> $xx"
            set PMOD($var) $xx
        }
    }
    
    if {$pt} {
        plotout
    }

    return [lindex $Fit(iv) 1]
}

proc fitAll {} {
    set ff 1
    while {$ff == 1 || $ff == 2} {
        set ff [fitStep 0]
    }
    bell ; bell
    plotout
}

proc sortnorm {NORMEname v1 v2} {
    upvar $NORMEname N2
    set v [expr {$N2($v1) - $N2($v2)}]
    if {$v < 0} {return -1}
    if {$v > 0} {return 1}
    return 0
}
