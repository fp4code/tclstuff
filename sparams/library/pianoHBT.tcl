package provide hyperpianoHBT 0.1

package require dblas1

set HsplotQUOI(Ar) "Ar"
set HsplotQUOI(Ai) "Ai"
set HsplotQUOI(Br) "gamo"
set HsplotQUOI(Bi) "cc"
set HsplotQUOI(Cr) "gm"
set HsplotQUOI(Ci) "tauD"
set HsplotQUOI(Dr) "alpha0"
set HsplotQUOI(Di) "tauN"

proc plotACurveK {var t suffix x xmin xmax y ymin ymax} {

    upvar #0 commonCtx_${var} G

    set xyplotName plot_${var}(${t}${suffix})
    upvar #0 $xyplotName xyplot

    set G(xlinlog,$t) "sqr"
    set G(ylinlog,$t) "lin"

    if {$G(hold,$t)} {
        set xmin $G(xmin,$t)
        set xmax $G(xmax,$t)        
# sqrt
        set ymin $G(ymin,$t)
        set ymax $G(ymax,$t)
    } else {
        set G(xmin,$t) $xmin
        set G(xmax,$t) $xmax
# sqrt
        set G(ymin,$t) $ymin
        set G(ymax,$t) $ymax
    }

    if {$ymin < -1e20} {
        set ymin -1e20
        set G(ymin,$t) $ymin
    }
    if {$ymax > 1e20} {
        set ymax 1e20
        set G(ymax,$t) $ymax
    }

    set nelems [expr {[blas::vector length $xyplot]/2}]
    
    set xp [blas::subvector create 1 2 $nelems from xyplot]
    set yp [blas::subvector create 2 2 $nelems from xyplot]

# sqrt

    foreach {x1 y1 x2 y2} [$G(canvas) coords [lindex $G(items) 0]] break

    set ax [expr {($x2 - $x1)/($xmax - $xmin)}]
    if {[catch {expr {($y1 - $y2)/($ymax - $ymin)}} ay]} {
        global errorInfo
        return -code error [list "$var $t -> ($y1 - $y2)/($ymax - $ymin)" $errorInfo]
    }
    set bx [expr {-$ax*$xmin}]
    set by [expr {-$ay*$ymax}]
    
    blas::mathsvop x *scal $ax
    blas::mathsvop x +scal $bx
    blas::mathsvop y *scal $ay
    blas::mathsvop y +scal $by
    
    blas::mathsvop xp <-double $x
    blas::mathsvop yp <-double $y
    
    blas::mathsvop xp ddiff
    blas::mathsvop yp ddiff

    set xyplot $xyplot
}



proc createHsplotEtTuttiQuantiK {c var t x y} {
    global HsplotQUOI
    upvar #0 commonCtx_${var} G

    set width 180
    set height 150

    set h_0 [$c create hsplot $x $y [expr {$x+$width}] [expr {$y+$height}] -xyblas plot_${var}(${t}_0) -fill black -width 0]
    set h_1 [$c create hsplot $x $y [expr {$x+$width}] [expr {$y+$height}] -xyblas plot_${var}(${t}_1) -fill black -width 0]
    set h2a [$c create hsplot $x $y [expr {$x+$width}] [expr {$y+$height}] -xyblas plot_${var}(${t}2a) -fill red -width 0]
    set h2b [$c create hsplot $x $y [expr {$x+$width}] [expr {$y+$height}] -xyblas plot_${var}(${t}2b) -fill blue -width 0]
    set h $h2b
    set G(items) [list $h2a $h2b $h_0 $h_1]
    set G(canvas) $c
    $c bind $h <Motion> "putcoords $c $h $var $t %x %y"
    $c bind $h <Enter> "enterHsplot $c"
    $c bind $h <Leave> "leaveHsplot $c"
    set f [frame $c.f_$t]

    label $f.quoi -text $HsplotQUOI($t)
    label $f.val2a -textvariable commonCtx_${var}(val2a,$t)
    label $f.val2b -textvariable commonCtx_${var}(val2b,$t)

    checkbutton $f.hold -text "Hold" -anchor w -variable commonCtx_${var}(hold,$t) -command [list holdHsplot $var $t]
    button $f.zs2 -text zs2 -anchor w -command [list zs2Hsplot $var $t]
    checkbutton $f.fit -text "Fit" -anchor w -variable commonCtx_${var}(fit,$t)

    grid configure $f.quoi - -sticky news
    grid configure $f.val2a - -sticky news
    grid configure $f.val2b - -sticky news
    grid configure $f.fit - -sticky news
    grid configure $f.hold $f.zs2 -sticky news

    set if [$c create window [expr {$x+$width}] $y -window $f -anchor nw]
    # la dénomination des events est étrange
    $c bind $h <ButtonPress-1> [list b1PressHsplot $c $h $var $t %x %y]
    $c bind $h <Button1-Motion> [list b1MotionHsplot $c $h $var $t %x %y]
    $c bind $h <ButtonRelease-1> [list b1ReleaseHsplot $c $h $var $t %x %y]
    # bindtags $win [concat [bindtags $win] rWM] ;# pour ne pas propager aux sous-widgets

}


proc fullplotk {var dummy Exp_n} {
    upvar #0 plot_${var} plot

    set c [canvas .param_$var.c -height 800 -width 600]
    pack .param_$var.c

    set y 10
    foreach l {A B C D} {
        set x 10
        foreach ri {r i} {
            set plot(${l}${ri}2a) [blas::vector create short -length [expr {2*$Exp_n}]]
            set plot(${l}${ri}2b) [blas::vector create short -length [expr {2*$Exp_n}]]
            set plot(${l}${ri}_0) [blas::vector create short -length 4]
            set plot(${l}${ri}_1) [blas::vector create short -length 4]
            createHsplotEtTuttiQuantiK $c $var $l$ri $x $y
            incr x 300
        }
        incr y 200
    }
}

proc calcplok {suffix kA kB kC kD f Z0 &Q} {
    global 2M_PI
    upvar ${&Q} Q

    set n [::blas::vector length $f]
    set omega [::blas::vector create -copy $f]
    blas::mathsvop omega *scal ${2M_PI}

    upvar Ar${suffix} Ar
    set Ar [blas::math re $kA]

    upvar Ai${suffix} Ai
    set Ai [blas::math im $kA]

    upvar Br${suffix} Br
    set Br [blas::math re $kB]
    set tmp [blas::math dscalop mean $Br]
    set Q(gamo) [expr {$tmp/$Z0}]
    blas::mathsvop Br *scal [expr {1.0/$tmp}]

    upvar Bi${suffix} Bi
    set Bi [blas::math im $kB]
    blas::mathsvop Bi / $omega
    set tmp [blas::math dscalop mean $Bi]
    set Q(cc) [expr {$tmp/$Z0}]
    blas::mathsvop Bi *scal [expr {1.0/$tmp}]

    upvar Cr${suffix} Cr
    set Cr [blas::math re $kC]
    set tmp [blas::math dscalop mean $Cr]
    set Q(gm) [expr {$tmp/$Z0}]
    blas::mathsvop Cr *scal [expr {1.0/$tmp}]

    upvar Ci${suffix} Ci
    set Ci [blas::math im $kC]
    blas::mathsvop Ci / $omega
    set tmp [blas::math dscalop mean $Ci]
    set Q(tauD) [expr {$tmp/($Z0*$Q(gm))}]
    blas::mathsvop Ci *scal [expr {1.0/$tmp}]

    upvar Dr${suffix} Dr
    set Dr [blas::math re $kD]
    set tmp [blas::math dscalop mean $Dr]
    set Q(alpha0) [expr {-$tmp/($Z0*$Q(gm))}]
    blas::mathsvop Dr *scal [expr {1.0/$tmp}]

    upvar Di${suffix} Di
    set Di [blas::math im $kD]
    blas::mathsvop Di / $omega
    set tmp [blas::math dscalop mean $Di]
    set Q(tauN) [expr {$tmp/(-$Z0*$Q(alpha0)*$Q(gm))}]
    blas::mathsvop Di *scal [expr {1.0/$tmp}]    

    puts stderr $suffix
    puts stderr {}
    parray Q

    global HsplotQUOI commonCtx_k
    foreach l {B C D} {
        foreach ri {r i} {
            set t $l$ri
            set vName $HsplotQUOI($t)
            set commonCtx_k(val${suffix},$t) [format %.3g $Q($vName)]
        }
    }
}

proc toplok {var &k Z0 &Q} {
    global CHOICE
    global Mod_f Exp_f
    upvar Exp_${&k}A kA_2a
    upvar Exp_${&k}B kB_2a
    upvar Exp_${&k}C kC_2a
    upvar Exp_${&k}D kD_2a
    upvar Exp0_${&k}A kA_2b
    upvar Exp0_${&k}B kB_2b
    upvar Exp0_${&k}C kC_2b
    upvar Exp0_${&k}D kD_2b
    # upvar ${&Q} Q

    upvar #0 commonCtx_${var} G
    set G(proc) fullplotk

    if {!$CHOICE($var)} {
        return
    }

    upvar #0 plot_${var} plot

    set Exp_f2 $Exp_f
    blas::mathsvop Exp_f2 * $Exp_f

    set zero [blas::vector create double {0. 0.}]
    set un   [blas::vector create double {1. 1.}]
#    set f_0 [blas::vector create double [list [lindex $Exp_f2 1] [lindex $Exp_f2 end]]]
    set f_0 [blas::vector create double [list 0.0 [lindex $Exp_f2 end]]]
    set f_1 $f_0

    if {![winfo exists .param_$var]} {
        puts stderr createTopWin
        createTopWin $var
    }

    calcplok 2a $kA_2a $kB_2a $kC_2a $kD_2a $Exp_f $Z0 Q
    calcplok 2b $kA_2b $kB_2b $kC_2b $kD_2b $Exp_f $Z0 Q

    set xmin_Exp [minofblas $Exp_f2]
    set xmax_Exp [maxofblas $Exp_f2]

    if {$G(hold,Ar)} {
        set xmin {}
        set xmax {}
        set ymin {}
        set ymax {}
    } else {
        set xmin $xmin_Exp
        set xmax $xmax_Exp
        set ymin [minofblas $Ar2b]
        set ymax [maxofblas $Ar2b]
    }

    plotACurveK $var Ar _0 $f_0    $xmin $xmax $zero $ymin $ymax
    plotACurveK $var Ar _1 $f_1    $xmin $xmax $un   $ymin $ymax
    plotACurveK $var Ar 2a $Exp_f2 $xmin $xmax $Ar2a $ymin $ymax
    plotACurveK $var Ar 2b $Exp_f2 $xmin $xmax $Ar2b $ymin $ymax

    if {$G(hold,Ai)} {
        set xmin {}
        set xmax {}
        set ymin {}
        set ymax {}
    } else {
        set xmin $xmin_Exp
        set xmax $xmax_Exp
        set ymin [minofblas $Ai2b]
        set ymax [maxofblas $Ai2b]
    }

    plotACurveK $var Ai _0 $f_0 $xmin $xmax $zero $ymin $ymax
    plotACurveK $var Ai _1 $f_1 $xmin $xmax $un   $ymin $ymax
    plotACurveK $var Ai 2a $Exp_f2 $xmin $xmax $Ai2a $ymin $ymax
    plotACurveK $var Ai 2b $Exp_f2 $xmin $xmax $Ai2b $ymin $ymax

    if {$G(hold,Br)} {
        set xmin {}
        set xmax {}
        set ymin {}
        set ymax {}
    } else {
        set xmin $xmin_Exp
        set xmax $xmax_Exp
        set ymin [minofblas $Br2b]
        set ymax [maxofblas $Br2b]
    }

    plotACurveK $var Br _0 $f_0 $xmin $xmax $zero $ymin $ymax
    plotACurveK $var Br _1 $f_1 $xmin $xmax $un   $ymin $ymax
    plotACurveK $var Br 2a $Exp_f2 $xmin $xmax $Br2a $ymin $ymax
    plotACurveK $var Br 2b $Exp_f2 $xmin $xmax $Br2b $ymin $ymax

    if {$G(hold,Bi)} {
        set xmin {}
        set xmax {}
        set ymin {}
        set ymax {}
    } else {
        set xmin $xmin_Exp
        set xmax $xmax_Exp
        set ymin [minofblas $Bi2b]
        set ymax [maxofblas $Bi2b]
    }

    plotACurveK $var Bi _0 $f_0 $xmin $xmax $zero $ymin $ymax
    plotACurveK $var Bi _1 $f_1 $xmin $xmax $un   $ymin $ymax
    plotACurveK $var Bi 2a $Exp_f2 $xmin $xmax $Bi2a $ymin $ymax
    plotACurveK $var Bi 2b $Exp_f2 $xmin $xmax $Bi2b $ymin $ymax

    if {$G(hold,Cr)} {
        set xmin {}
        set xmax {}
        set ymin {}
        set ymax {}
    } else {
        set xmin $xmin_Exp
        set xmax $xmax_Exp
        set ymin [minofblas $Cr2b]
        set ymax [maxofblas $Cr2b]
    }

    plotACurveK $var Cr _0 $f_0 $xmin $xmax $zero $ymin $ymax
    plotACurveK $var Cr _1 $f_1 $xmin $xmax $un   $ymin $ymax
    plotACurveK $var Cr 2a $Exp_f2 $xmin $xmax $Cr2a $ymin $ymax
    plotACurveK $var Cr 2b $Exp_f2 $xmin $xmax $Cr2b $ymin $ymax

    if {$G(hold,Ci)} {
        set xmin {}
        set xmax {}
        set ymin {}
        set ymax {}
    } else {
        set xmin $xmin_Exp
        set xmax $xmax_Exp
        set ymin [minofblas $Ci2b]
        set ymax [maxofblas $Ci2b]
    }

    plotACurveK $var Ci _0 $f_0 $xmin $xmax $zero $ymin $ymax
    plotACurveK $var Ci _1 $f_1 $xmin $xmax $un   $ymin $ymax
    plotACurveK $var Ci 2a $Exp_f2 $xmin $xmax $Ci2a $ymin $ymax
    plotACurveK $var Ci 2b $Exp_f2 $xmin $xmax $Ci2b $ymin $ymax

    if {$G(hold,Dr)} {
        set xmin {}
        set xmax {}
        set ymin {}
        set ymax {}
    } else {
        set xmin $xmin_Exp
        set xmax $xmax_Exp
        set ymin [minofblas $Dr2b]
        set ymax [maxofblas $Dr2b]
    }

    plotACurveK $var Dr _0 $f_0 $xmin $xmax $zero $ymin $ymax
    plotACurveK $var Dr _1 $f_1 $xmin $xmax $un   $ymin $ymax
    plotACurveK $var Dr 2a $Exp_f2 $xmin $xmax $Dr2a $ymin $ymax
    plotACurveK $var Dr 2b $Exp_f2 $xmin $xmax $Dr2b $ymin $ymax

    if {$G(hold,Di)} {
        set xmin {}
        set xmax {}
        set ymin {}
        set ymax {}
    } else {
        set xmin $xmin_Exp
        set xmax $xmax_Exp
        set ymin [minofblas $Di2b]
        set ymax [maxofblas $Di2b]
    }

    plotACurveK $var Di _0 $f_0 $xmin $xmax $zero $ymin $ymax
    plotACurveK $var Di _1 $f_1 $xmin $xmax $un   $ymin $ymax
    plotACurveK $var Di 2a $Exp_f2 $xmin $xmax $Di2a $ymin $ymax
    plotACurveK $var Di 2b $Exp_f2 $xmin $xmax $Di2b $ymin $ymax
}

