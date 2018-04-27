# (C) CNRS/LPN (FP) 2001.03.20
# (C) CNRS/LPN (FP) 2001.04.13
# (C) CNRS/LPN (FP) 2001.04.17  utilisation de blas::vector create -copy ...

package require fidev
package require superTable
package require blasObj
package require dblas1
package require zblas1
package require blasmath
package require slatec

package require sparams2
package require hsplot

package require port3_nl2opt

package provide hyperpiano 1.0

set FONT "-b&h-lucidatypewriter-medium-r-normal-sans-9-*-*-*-*-*-iso8859-1"
option add *Font $FONT

proc readFichier {fichier} {
    global Exp_f Mod_f Exp_s

    set nomDeTable "*Sparams"
    catch {unset array}
    set indexes [::superTable::fileToTable array $fichier nomDeTable {}]

    set lignes [lindex $indexes 0]
    set colonnes [lindex $indexes 1]
    
    set Exp_f [list]
    set Exp_s [list]
    set nelems 0
    foreach li $lignes {
        lappend Exp_f [::superTable::getCell array $li freq]
        lappend Exp_s [::superTable::getCell array $li s11_r] [::superTable::getCell array $li s11_i]\
                [::superTable::getCell array $li s12_r] [::superTable::getCell array $li s12_i]\
                [::superTable::getCell array $li s21_r] [::superTable::getCell array $li s21_i]\
                [::superTable::getCell array $li s22_r] [::superTable::getCell array $li s22_i]
        incr nelems
    }
    
    set Mod_f $Exp_f
    for {set ff 75} {$ff < 200} {incr ff 25} {
        lappend Mod_f [expr {$ff*1e9}]
    }
    for {set ff 200} {$ff <= 1000} {incr ff 25} {
        lappend Mod_f [expr {$ff*1e9}]
    }
    
    set Exp_f [blas::vector create double $Exp_f]
    set Mod_f [blas::vector create double $Mod_f]
    set Exp_s [blas::vector create doublecomplex $Exp_s]
    
    plotout
}

namespace eval sparams {}
set M_PI [expr {4.0*atan(1.0)}]
set 2M_PI [expr {2.0*$M_PI}]

proc sparams::z+R//C {&z &tmp omega R C} {
    upvar ${&z} z
    upvar ${&tmp} tmp
    blas::dcopy $omega tmp
    blas::mathsvop tmp *scal [expr {$R*$C}]
    blas::mathsvop z +i $tmp
    blas::mathsvop z +rscal 1.0
    blas::mathsvop z inverse
    blas::mathsvop z *rscal $R
}

proc sparams::z+R+L {&z &tmp omega R L} {
    upvar ${&z} z
    upvar ${&tmp} tmp
    blas::dcopy $omega tmp
    blas::mathsvop tmp *scal $L
    blas::mathsvop z +i $tmp
    blas::mathsvop z +rscal $R
}

proc superscale {frame var} {
    set f [frame $frame._$var -relief groove -borderwidth 2]
    global PMOD PMODMIN PMODMAX PMOD0
    label $f.f -text $var
    entry $f.e0 -textvariable PMOD0($var) -justify right -width 9
    bind $f.e0 <KeyPress-Return> "entry0Update %W $var \$GO"
    bind $f.e0 <KeyPress-KP_Enter> "entry0Update %W $var \$GO"
    bind $f.e0 <Leave> "entry0Update %W $var \$GO"
#    entry $f.e1 -textvariable _private$f.e1 -justify right -width 9
    button $f.b0 -text "x" -command "set PMOD($var) \[set PMOD0($var)\]; entryUpdate $f.e $var \$GO"
    button $f.b1 -text "v" -command "set PMOD0($var) \[set PMOD($var)\]; entry0Update $f.e0 $var \$GO"
    button $f.plus -text + -command "sensitivity $f $var 0.5"
    button $f.moins -text - -command "sensitivity $f $var 2"
    entry $f.e -textvariable PMOD($var) -justify right -width 9
    bind $f.e <KeyPress-Return> "entryUpdate %W $var \$GO"
    bind $f.e <KeyPress-KP_Enter> "entryUpdate %W $var \$GO"
    bind $f.e <Leave> "entryUpdate %W $var \$GO"
    entry $f.max -textvariable PMODMAX($var) -justify right -width 9
    entry $f.min -textvariable PMODMIN($var) -justify right -width 9
    bind $f.max <KeyPress-Return> "bornesUpdate $f $var"
    bind $f.max <KeyPress-KP_Enter> "bornesUpdate $f $var"
    bind $f.max <Leave> "bornesUpdate $f $var"
    bind $f.min <KeyPress-Return> "bornesUpdate $f $var"
    bind $f.min <KeyPress-KP_Enter> "bornesUpdate $f $var"
    bind $f.min <Leave> "bornesUpdate $f $var"
    scale $f.s -showvalue 0 -variable SCALE($var)
    $f.s set [theoreticalScalePos $f.s $var]
    $f.s configure -command [list scaleUpdate $f.s $var] -repeatdelay 0 ;# commande longue => rebond
    checkbutton $f.fit -text fit -variable PMODFIT($var)
    pack $f.f $f.e0 $f.e -side top
    pack $f.fit -side top -fill x
    pack $f.max -side top
    pack $f.min -side bottom
    pack $f.s -side right
    pack $f.b0 $f.b1 $f.plus $f.moins
    return $f
}

proc scaleUpdate {scale var val} {
    global PMOD SPMOD GO PMODMIN PMODMAX PMOD0 SCALE

    set f [winfo parent $scale]
    if {![info exists PMODMIN($var)] || [catch {expr {1.0*$PMODMIN($var)}}]} {
        puts stderr "set PMODMIN($var) 0"
        set PMODMIN($var) 0
    }
    if {![info exists PMODMAX($var)] || [catch {expr {1.0*$PMODMAX($var)}}]} {
        puts stderr "set PMODMAX($var) 0"
        set PMODMAX($var) 0
    }
    set PMOD($var) [expr {($PMODMIN($var)-$PMODMAX($var))*($val/100.) + $PMODMAX($var)}]

    if {$GO > 0} {
        plotout
    }
}

proc theoreticalScalePos {entry var} {
    global PMOD PMODMIN PMODMAX SCALE
    if {$PMOD($var) > $PMODMAX($var)} {
        set PMODMAX($var) $PMOD($var)
    }
    if {$PMOD($var) < $PMODMIN($var)} {
        set PMODMIN($var) $PMOD($var)
    }

    set SCALE($var) [expr {100.*($PMOD($var)-$PMODMAX($var))/($PMODMIN($var)-$PMODMAX($var))}]
    # puts stderr "scale $PMOD($var) -> $SCALE($var)"
    return $SCALE($var)

    # abandonné:
    set ns [expr {round($ns)}]
    set nmax [expr {$PMOD($var) + $ns*($PMODMAX($var) -$PMODMIN($var))/100.}]
    set nmin [expr {$PMODMIN($var) + ($nmax-$PMODMAX($var))}]
    set PMODMIN($var) $nmin
    set PMODMAX($var) $nmax
    return $ns
}

proc entryUpdate {entry var go} {
    set f [winfo parent $entry]
#    puts stderr "entryUpdate $var"
    theoreticalScalePos $entry $var
#    $f.s set [theoreticalScalePos $entry $var]
    if {$go > 0} {
        plotout
    }
    # return 1
}

proc entry0Update {entry var go} {
    if {$go > 0} {
        plotout
    }
}

proc bornesUpdate {f var} {
    global PMOD PMODMIN PMODMAX
    set ns [expr {round(100.*($PMOD($var) - $PMODMAX($var))/($PMODMIN($var)-$PMODMAX($var)))}]
    $f.s set $ns    
}

proc sensitivity {f var fact} {
    global PMOD PMODMIN PMODMAX
    set demi [expr {0.5*($PMODMAX($var) - $PMODMIN($var))*$fact}]
    set PMODMIN($var) [expr {$PMOD($var) - $demi}]
    set PMODMAX($var) [expr {$PMOD($var) + $demi}]
    $f.s set 50   
}

frame .b
pack .b

frame .b.f0 -borderwidth 4 -relief sunken
frame .b.f1 -borderwidth 4 -relief sunken
frame .b.fs -borderwidth 4 -relief sunken
frame .b.choix1
frame .b.choix2
frame .b.choix3
frame .b.choix4
pack .b.f0 .b.f1 .b.fs  .b.choix1 .b.choix2 .b.choix3 .b.choix4 -fill x

button .b.f1.x -text xxx -command fullx
button .b.f1.v -text vvv -command fullv
button .b.f1.fs -text "full select" -command "fullSelect 1"
button .b.f1.fds -text "full deselect" -command "fullSelect 0"
button .b.f1.fitIni -text FitIni -command fitIni
button .b.f1.fitStep -text FitStep -command {fitStep 1}
button .b.f1.fitAll -text FitAll -command fitAll
button .b.f1.dumpAll -text DumpAll -command dumpAllInDir
button .b.f1.reloadAll -text ReloadAll -command reloadAllInDir

entry .b.f1.facd -textvariable FACD
pack .b.f1.x .b.f1.v .b.f1.fs .b.f1.fds .b.f1.fitIni .b.f1.fitStep .b.f1.fitAll .b.f1.facd -side left

pack .b.f1.reloadAll .b.f1.dumpAll  -side right

button .b.f0.b -text file -command choixFile
label .b.f0.l -textvariable fichier

pack .b.f0.b .b.f0.l -side left

proc choixFile {} {
    global fichier
    set fichier [tk_getOpenFile -initialdir [file dirname $fichier]]
    readFichier $fichier
}

proc raiseOrDestroy {cb immediate} {
    set var [varFromWidget $cb]
    global CHOICE CHOICE_ACTUAL GO
    if {$CHOICE($var)} {
        incr GO
        if {![winfo exists .param_$var]} {
            createTopWin $var
        }
        if {$immediate} {
            plotout
        }
        raise .param_$var
        set CHOICE_ACTUAL $cb
        after idle [list focus $cb]
    } else {
        destroy .param_$var
        incr GO -1
        if {$GO < 0} {set GO 0} ;# patch après reloadAll
    }
}

proc raiseChoice {cb} {
    global CHOICE_ACTUAL
    if {[winfo exists CHOICE_ACTUAL]} {
        $CHOICE_ACTUAL configure -state normal
    }
    set var [varFromWidget $cb]
#    $cb configure -state active
    if {[winfo exists .param_$var]} {
        wm deiconify .param_$var
        raise .param_$var
        set CHOICE_ACTUAL $cb
    }
    focus $cb
}

proc raiseNext {&CHOICE_NP cb} {
    upvar #0 ${&CHOICE_NP} CHOICE_NP
    global CHOICE_ACTUAL

    set watchdog $CHOICE_ACTUAL
    $CHOICE_ACTUAL configure -state normal
    set cb $CHOICE_ACTUAL

    while {[set cb $CHOICE_NP($cb)] != $watchdog} {
        set var [varFromWidget $cb]
        if {[winfo exists .param_$var]} {
            $cb configure -state active
            wm deiconify .param_$var
            raise .param_$var
            set CHOICE_ACTUAL $cb
            return
        }
   }
}

proc fullSelect {x} {
    global CHOICES CHOICE
    foreach cb $CHOICES {
        if {$x != $CHOICE([varFromWidget $cb])} {
            set CHOICE([varFromWidget $cb]) $x 
            raiseOrDestroy $cb 0 ;# mettre 0 et revoir plotout
        }
    }
    if {$x} {
        plotout
    }
}

proc fullplot {var Mod_n Exp_n} {
    upvar #0 plot_${var} plot

    set c [canvas .param_$var.c -height 800 -width 300 -cursor dotbox]
    pack .param_$var.c

    set plot(x1a) [blas::vector create short -length [expr {2*$Mod_n}]]
    set plot(y1a) [blas::vector create short -length [expr {2*$Mod_n}]]
    set plot(m1a) [blas::vector create short -length [expr {2*$Mod_n}]]
    set plot(d1a) [blas::vector create short -length [expr {2*$Mod_n}]]
    set plot(x1b) [blas::vector create short -length [expr {2*$Mod_n}]]
    set plot(y1b) [blas::vector create short -length [expr {2*$Mod_n}]]
    set plot(m1b) [blas::vector create short -length [expr {2*$Mod_n}]]
    set plot(d1b) [blas::vector create short -length [expr {2*$Mod_n}]]
    set plot(x2) [blas::vector create short -length [expr {2*$Exp_n}]]
    set plot(y2) [blas::vector create short -length [expr {2*$Exp_n}]]
    set plot(m2) [blas::vector create short -length [expr {2*$Exp_n}]]
    set plot(d2) [blas::vector create short -length [expr {2*$Exp_n}]]
    set plot(x_0) [blas::vector create short -length 4]
    set plot(y_0) [blas::vector create short -length 4]
    set plot(m_0) [blas::vector create short -length 4]
    set plot(d_0) [blas::vector create short -length 4]


    createHsplotEtTuttiQuanti 1 $c $var x 25 25 
    createHsplotEtTuttiQuanti 1 $c $var y 25 200
    createHsplotEtTuttiQuanti 1 $c $var m 25 375
    createHsplotEtTuttiQuanti 1 $c $var d 25 550 
}


proc fullplotr {var Mod_n Exp_n} {
    upvar #0 plot_${var} plot

    set c [canvas .param_$var.c -height 400 -width 300]
    pack .param_$var.c

    set plot(f1a) [blas::vector create short -length [expr {2*$Mod_n}]]
    set plot(f1b) [blas::vector create short -length [expr {2*$Mod_n}]]
    set plot(f2) [blas::vector create short -length [expr {2*$Exp_n}]]
    set plot(f_0) [blas::vector create short -length 4]
    set plot(mf1a) [blas::vector create short -length [expr {2*$Mod_n}]]
    set plot(mf1b) [blas::vector create short -length [expr {2*$Mod_n}]]
    set plot(mf2) [blas::vector create short -length [expr {2*$Exp_n}]]
    set plot(mf_0) [blas::vector create short -length 4]

    createHsplotEtTuttiQuanti 1 $c $var f 25 25 
    createHsplotEtTuttiQuanti 1 $c $var mf 25 200
}

set HsplotQUOI(x) "Re"
set HsplotQUOI(y) "Im"
set HsplotQUOI(m) "dB"
set HsplotQUOI(mf) "dB"
set HsplotQUOI(d) "deg"
set HsplotQUOI(f) "racine"

proc createHsplotEtTuttiQuanti {typ c var t x y} {
    global HsplotQUOI
    upvar #0 commonCtx_${var} G

    set width 180
    set height 150

    if {$typ == 1} {
        set h_0 [$c create hsplot $x $y [expr {$x+$width}] [expr {$y+$height}] -xyblas plot_${var}(${t}_0) -fill black -width 0]
        set h2 [$c create hsplot $x $y [expr {$x+$width}] [expr {$y+$height}] -xyblas plot_${var}(${t}2) -fill green -width 3]
        set h1a [$c create hsplot $x $y [expr {$x+$width}] [expr {$y+$height}] -xyblas plot_${var}(${t}1a) -fill red -width 0]
        set h1b [$c create hsplot $x $y [expr {$x+$width}] [expr {$y+$height}] -xyblas plot_${var}(${t}1b) -fill blue -width 0]
        set h $h1b
        set G(items) [list $h1a $h1b $h2 $h_0]
    } elseif {$typ == 2} {
        set h_0 [$c create hsplot $x $y [expr {$x+$width}] [expr {$y+$height}] -xyblas plot_${var}(${t}_0) -fill black -width 0]
        set h_1 [$c create hsplot $x $y [expr {$x+$width}] [expr {$y+$height}] -xyblas plot_${var}(${t}_1) -fill black -width 0]
        set h2a [$c create hsplot $x $y [expr {$x+$width}] [expr {$y+$height}] -xyblas plot_${var}(${t}2a) -fill red -width 0]
        set h2b [$c create hsplot $x $y [expr {$x+$width}] [expr {$y+$height}] -xyblas plot_${var}(${t}2b) -fill blue -width 0]
        set h $h2b
        set G(items) [list $h2a $h2b $h_0 $h_1]
    }
    set G(canvas) $c
    $c bind $h <Motion> "putcoords $c $h $var $t %x %y"
    $c bind $h <Enter> "enterHsplot $c"
    $c bind $h <Leave> "leaveHsplot $c"
    set f [frame $c.f_$t]

    label $f.quoi -text $HsplotQUOI($t)
    checkbutton $f.hold -text "Hold" -anchor w -variable commonCtx_${var}(hold,$t) -command [list holdHsplot $var $t]
    button $f.zs2 -text zs2 -anchor w -command [list zs2Hsplot $var $t]
    checkbutton $f.fit -text "Fit" -anchor w -variable commonCtx_${var}(fit,$t)

    radiobutton $f.lin -text "lin" -anchor w -variable commonCtx_${var}(xlinlog,$t) -value lin -command [list linlogPlot $var $t tolin]
    radiobutton $f.log -text "log" -anchor w -variable commonCtx_${var}(xlinlog,$t) -value log -command [list linlogPlot $var $t tolog]

    radiobutton $f.exp -text "Exp" -anchor w -variable commonCtx_${var}(frange,$t) -value "Exp" -command [list frangePlot $var $t]
    radiobutton $f.extr -text "Mod" -anchor w -variable commonCtx_${var}(frange,$t) -value "Mod" -command [list frangePlot $var $t]

    grid configure $f.quoi - -sticky news
    grid configure $f.fit - -sticky news
    grid configure $f.hold $f.zs2 -sticky news
    grid configure $f.lin $f.log -sticky news
    grid configure $f.exp $f.extr -sticky news

    set if [$c create window [expr {$x+$width}] $y -window $f -anchor nw]
    # la dénomination des events est étrange
    $c bind $h <ButtonPress-1> [list b1PressHsplot $c $h $var $t %x %y]
    $c bind $h <Button1-Motion> [list b1MotionHsplot $c $h $var $t %x %y]
    $c bind $h <ButtonRelease-1> [list b1ReleaseHsplot $c $h $var $t %x %y]
    # bindtags $win [concat [bindtags $win] rWM] ;# pour ne pas propager aux sous-widgets

}

proc holdHsplot {var t} {
    upvar #0 commonCtx_${var} G
    if {$G(hold,$t) == 0} {
        plotout
    }
}

proc frangePlot {var t} {
    plotout
}

proc linlogPlot {var t linlog} {
    upvar #0 commonCtx_${var} G
    if {$G(xlastlinlog,$t) == $G(xlinlog,$t)} {
        return
    }
    switch $linlog {
        tolin {
            if {$G(xlastlinlog,$t) != "log"} {
                return -code error "linlogPlot \"$G(xlastlinlog,$t)\" -> \"$linlog\""
            }
            set G(xmin,$t) [expr {pow(10.,$G(xmin,$t))}]
            set G(xmax,$t) [expr {pow(10.,$G(xmax,$t))}]
        }
        tolog {
            if {$G(xlastlinlog,$t) != "lin"} {
                return -code error "linlogPlot \"$G(xlastlinlog,$t)\" -> \"$linlog\""
            }
            if {$G(xmin,$t) <= 0.0} {
                set G(xmin,$t) 0.0 ;# f = 1 Hz
            } else {
                set G(xmin,$t) [expr {log10($G(xmin,$t))}]
            }
            set G(xmax,$t) [expr {log10($G(xmax,$t))}]
        }
        default {return -code error "linlogPlot : option \"$linlog\" inconnue"}
    }
    set G(xlastlinlog,$t) $G(xlinlog,$t)
    plotout
}

proc b1PressHsplot {c h var t x y} {
    beginZoomHsplot $c $h $var $t $x $y
}

proc beginZoomHsplot {c h var t x y} {
    upvar #0 commonCtx_${var} G
    set x [$c canvasx $x]
    set y [$c canvasy $y]
    set G(xZoomIni) $x
    set G(yZoomIni) $y
}

proc b1MotionHsplot {c h var t x y} {
    winZoomHsplot $c $h $var $t $x $y
}

proc winZoomHsplot {c h var t x y} {
    upvar #0 commonCtx_${var} G
    set x [$c canvasx $x]
    set y [$c canvasy $y]
    $c delete zoomrect
    $c create rectangle $G(xZoomIni) $G(yZoomIni) $x $y -tags zoomrect
}

proc b1ReleaseHsplot {c h var t x y} {
    zoomHsplot $c $h $var $t
}

proc zoomHsplot {c h var t} {
    upvar #0 commonCtx_${var} G
    set bb [$c coords zoomrect] ;# les coords sont réarangées
    $c delete zoomrect
    if {$bb == {}} {
        return
    }
    foreach {xminP yminP xmaxP ymaxP} $bb {}
    foreach {xmin ymax} [userCoordsNoLog $c $h $var $t $xminP $yminP] break
    foreach {xmax ymin} [userCoordsNoLog $c $h $var $t $xmaxP $ymaxP] break
    set G(xmin,$t) $xmin
    set G(xmax,$t) $xmax
    set G(ymin,$t) $ymin
    set G(ymax,$t) $ymax
    set G(hold,$t) 1
    plotout
}

proc zs2Hsplot {var t} {
    upvar #0 commonCtx_${var} G
    set xmin $G(xmin,$t)
    set xmax $G(xmax,$t)
    set ymin $G(ymin,$t)
    set ymax $G(ymax,$t)
    set dx [expr {0.5*($xmax-$xmin)}]
    set dy [expr {0.5*($ymax-$ymin)}]
    set G(xmin,$t) [expr {$xmin - $dx}] 
    set G(xmax,$t) [expr {$xmax + $dx}]
    set G(ymin,$t) [expr {$ymin - $dy}]
    set G(ymax,$t) [expr {$ymax + $dy}]
    set G(hold,$t) 1
    parray G
    plotout
} 

proc enterHsplot {c} {
    $c configure -cursor dotbox
}

proc leaveHsplot {c} {
    $c delete coords
    $c configure -cursor {}
}

proc userCoordsNoLog {c h var t xP yP} {
    set x [$c canvasx $xP]
    set y [$c canvasy $yP]
    foreach {x1 y1 x2 y2} [$c coords $h] {break}

    upvar #0 commonCtx_${var} G
    
    set vx [expr {($G(xmax,$t)*($x-$x1) + $G(xmin,$t)*($x2-$x))/($x2-$x1)}]
    set vy [expr {($G(ymin,$t)*($y-$y1) + $G(ymax,$t)*($y2-$y))/($y2-$y1)}]
 
    return [list $vx $vy]
}

proc userCoords {c h var t xP yP} {
    foreach {vx vy} [userCoordsNoLog $c $h $var $t $xP $yP] break

    upvar #0 commonCtx_${var} G

    switch $G(xlinlog,$t) {
        lin {}
        log {set vx [expr {pow(10., $vx)}]}
        sqr {if {$vx < 0.0} {set vx NaN} else {set vx [expr {sqrt($vx)}]}}
    }
    switch $G(ylinlog,$t) {
        lin {}
        log {set vy [expr {pow(10., $vy)}]}
        sqr {if {$vy < 0.0} {set vy NaN} else {set vy [expr {sqrt($vy)}]}}
    }
    return [list $vx $vy]
}


proc putcoords {c h var t xP yP} {
    $c delete coords

    foreach {vx vy} [userCoords $c $h $var $t $xP $yP] break

    # 3 lignes de redite
    set x [$c canvasx $xP]
    set y [$c canvasy $yP]
    foreach {x1 y1 x2 y2} [$c coords $h] {break}
#    set xpos [expr {$x + 5 + 20.*($x-$x1)/($x1-$x2)}]
    set xpos 30
    $c create text $xpos [expr {$y-8}] -text [format %.3g $vy] -tag coords -state disabled -anchor sw
    $c create text $xpos [expr {$y+11}] -text [format %.3g $vx] -tag coords -state disabled -anchor nw

}

proc createTopWin {var} {
    global Mod_f Exp_f
    upvar #0 commonCtx_${var} G

    set Mod_n [blas::vector length $Mod_f]
    set Exp_n [blas::vector length $Exp_f]

    toplevel .param_$var
    wm geometry .param_$var +10+0
    $G(proc) $var $Mod_n $Exp_n
}

proc calcplo {suffix sv} {
    global M_PI

    upvar x${suffix} x
    set x [blas::math re $sv]

    upvar y${suffix} y
    set y [blas::math im $sv]

    set n [blas::vector length $sv]
    set ierr [blas::vector create long -length $n]
    set z [blas::vector create doublecomplex -length $n]
    if {[catch {blas::slatec zlog $sv z ierr}]} {
        global errorInfo
        # return -code error [list $suffix $errorInfo]
        global Exp_f
        #puts stderr [list $suffix $errorInfo $ierr $Exp_f $sv]
        puts stderr [list $suffix $errorInfo]
    }
    
    upvar m${suffix} m
    set m [blas::math re $z]
    blas::mathsvop m *scal [expr {20./log(10.)}]

    upvar d${suffix} d
    set d [blas::math im $z]
    blas::mathsvop d *scal [expr {180/$M_PI}]
    blas::mathsvop d continuousModulo 360.0
}

proc calcplor {suffix sv} {
    global M_PI

    upvar f${suffix} f
    set f $sv
    blas::mathsvop f sqrt ;# RACINE !!!

    upvar mf${suffix} mf
    set mf $f
    blas::mathsvop mf log10
    blas::mathsvop mf *scal 20.
}

proc toplo {var v} {
    global CHOICE
    global Mod_f Exp_f
    upvar Mod_$v sv1a
    upvar Mod0_$v sv1b
    upvar Exp_$v sv2

    upvar #0 commonCtx_${var} G
    set G(proc) fullplot

    if {!$CHOICE($var)} {
        return
    }

    global M_PI

    upvar #0 plot_${var} plot

    set zero {double 0. 0.}
    set f_0 [list double [lindex $Mod_f 1] [lindex $Mod_f end]]
    set Mod_n [blas::vector length $Mod_f]
    set Exp_n [blas::vector length $Exp_f]

    if {![winfo exists .param_$var]} {
        createTopWin $var
    }

    calcplo 1a $sv1a
    calcplo 1b $sv1b
    calcplo 2 $sv2

    set xmin_Exp [minofblas $Exp_f]
    set xmax_Exp [maxofblas $Exp_f]
    set xmin_Mod [minofblas $Exp_f $Mod_f]
    set xmax_Mod [maxofblas $Exp_f $Mod_f]

    if {$G(hold,x)} {
        set xmin {}
        set xmax {}
        set ymin {}
        set ymax {}
    } else {
        if {![info exists G(frange,x)] || $G(frange,x) == {}} {
            set G(frange,x) Exp
        }
        switch $G(frange,x) {
            Exp {
                set xmin $xmin_Exp
                set xmax $xmax_Exp
                set ymin [minofblas $x2]
                set ymax [maxofblas $x2]
            }
            Mod {
                set xmin $xmin_Mod
                set xmax $xmax_Mod
                set ymin [minofblas $x1a $x2]
                set ymax [maxofblas $x1a $x2]
            }
            default {
                return -code error "bad frange  G(frange,x) = \"$G(frange,x)\""
            }
        }
    }

    plotACurveLogLin $var x _0 $f_0 $xmin $xmax $zero $ymin $ymax
    plotACurveLogLin $var x 1a $Mod_f $xmin $xmax $x1a $ymin $ymax
    plotACurveLogLin $var x 1b $Mod_f $xmin $xmax $x1b $ymin $ymax
    plotACurveLogLin $var x 2 $Exp_f $xmin $xmax $x2 $ymin $ymax

    if {$G(hold,y)} {
        set xmin {}
        set xmax {}
        set ymin {}
        set ymax {}
    } else {
        if {![info exists G(frange,y)] || $G(frange,y) == {}} {
            set G(frange,y) Exp
        }
        switch $G(frange,y) {
            Exp {
                set xmin $xmin_Exp
                set xmax $xmax_Exp
                set ymin [minofblas $y2]
                set ymax [maxofblas $y2]
            }
            Mod {
                set xmin $xmin_Mod
                set xmax $xmax_Mod
                set ymin [minofblas $y1a $y2]
                set ymax [maxofblas $y1a $y2]
            }
            default {
                return -code error "bad frange  G(frange,y) = \"$G(frange,y)\""
            }
        }
    }

    plotACurveLogLin $var y _0 $f_0 $xmin $xmax $zero $ymin $ymax
    plotACurveLogLin $var y 1a $Mod_f $xmin $xmax $y1a $ymin $ymax
    plotACurveLogLin $var y 1b $Mod_f $xmin $xmax $y1b $ymin $ymax
    plotACurveLogLin $var y 2 $Exp_f $xmin $xmax $y2 $ymin $ymax
    
    if {$G(hold,m)} {
        set xmin {}
        set xmax {}
        set ymin {}
        set ymax {}
    } else {
        if {![info exists G(frange,m)] || $G(frange,m) == {}} {
            set G(frange,m) Exp
        }
        switch $G(frange,m) {
            Exp {
                set xmin $xmin_Exp
                set xmax $xmax_Exp
                set ymin [minofblas $m2]
                set ymax [maxofblas $m2]
            }
            Mod {
                set xmin $xmin_Mod
                set xmax $xmax_Mod
                set ymin [minofblas $m1a $m2]
                set ymax [maxofblas $m1a $m2]
            }
            default {
                return -code error "bad frange G(frange,m) = \"$G(frange,m)\""
            }
        }
    }

    plotACurveLogLin $var m _0 $f_0 $xmin $xmax $zero $ymin $ymax
    plotACurveLogLin $var m 1a $Mod_f $xmin $xmax $m1a $ymin $ymax
    plotACurveLogLin $var m 1b $Mod_f $xmin $xmax $m1b $ymin $ymax
    plotACurveLogLin $var m 2 $Exp_f $xmin $xmax $m2 $ymin $ymax
    
    if {$G(hold,d)} {
        set xmin {}
        set xmax {}
        set ymin {}
        set ymax {}
    } else {
        if {![info exists G(frange,d)] || $G(frange,d) == {}} {
            set G(frange,d) Exp
        }
        switch $G(frange,d) {
            Exp {
                set xmin $xmin_Exp
                set xmax $xmax_Exp
                set ymin [minofblas $d2]
                set ymax [maxofblas $d2]
            }
            Mod {
                set xmin $xmin_Mod
                set xmax $xmax_Mod
                set ymin [minofblas $d1a $d2]
                set ymax [maxofblas $d1a $d2]
            }
            default {
                return -code error "bad frange  G(frange,d) = \"$G(frange,d)""
            }
        }
    }
    plotACurveLogLin $var d _0 $f_0 $xmin $xmax $zero $ymin $ymax
    plotACurveLogLin $var d 1a $Mod_f $xmin $xmax $d1a $ymin $ymax
    plotACurveLogLin $var d 1b $Mod_f $xmin $xmax $d1b $ymin $ymax
    plotACurveLogLin $var d 2 $Exp_f $xmin $xmax $d2 $ymin $ymax
}

proc toplor {var v} {
    global CHOICE
    global Mod_f Exp_f
    upvar Mod_$v sv1a
    upvar Mod0_$v sv1b
    upvar Exp_$v sv2

    upvar #0 commonCtx_${var} G

    set G(proc) fullplotr

    if {!$CHOICE($var)} {
        return
    }

    global M_PI

    upvar #0 plot_${var} plot

    set zero {double 0. 0.}
    set f_0 [list double [lindex $Mod_f 1] [lindex $Mod_f end]]
    set Mod_n [blas::vector length $Mod_f]
    set Exp_n [blas::vector length $Exp_f]

    if {![winfo exists .param_$var]} {
        createTopWin $var
    }

    calcplor 1a $sv1a
    calcplor 1b $sv1b
    calcplor 2 $sv2

    set xmin_Exp [minofblas $Exp_f]
    set xmax_Exp [maxofblas $Exp_f]
    set xmin_Mod [minofblas $Exp_f $Mod_f]
    set xmax_Mod [maxofblas $Exp_f $Mod_f]

    if {$G(hold,f)} {
        set xmin {}
        set xmax {}
        set ymin {}
        set ymax {}
    } else {
        if {![info exists G(frange,f)] || $G(frange,f) == {}} {
            set G(frange,f) Exp
        }
        switch $G(frange,f) {
            Exp {
                set xmin $xmin_Exp
                set xmax $xmax_Exp
                set ymin [minofblas $f2]
                set ymax [maxofblas $f2]
            }
            Mod {
                set xmin $xmin_Mod
                set xmax $xmax_Mod
                set ymin [minofblas $f1a $f2]
                set ymax [maxofblas $f1a $f2]
            }
            default {
                return -code error "bad frange  G(frange,f) = \"$G(frange,f)\""
            }
        }
    }

    if {[catch expr {$ymin}]} {
        set ymin -1e99
    }
    if {[catch expr {$ymax}]} {
        set ymax 1e99
    }

    plotACurveLogLin $var f _0 $f_0 $xmin $xmax $zero $ymin $ymax
    plotACurveLogLin $var f 1a $Mod_f $xmin $xmax $f1a $ymin $ymax
    plotACurveLogLin $var f 1b $Mod_f $xmin $xmax $f1b $ymin $ymax
    plotACurveLogLin $var f 2 $Exp_f $xmin $xmax $f2 $ymin $ymax

    if {$G(hold,mf)} {
        set xmin {}
        set xmax {}
        set ymin {}
        set ymax {}
    } else {
        if {![info exists G(frange,mf)] || $G(frange,mf) == {}} {
            set G(frange,mf) Exp
        }
        switch $G(frange,mf) {
            Exp {
                set xmin $xmin_Exp
                set xmax $xmax_Exp
                set ymin [minofblas $mf2]
                set ymax [maxofblas $mf2]
            }
            Mod {
                set xmin $xmin_Mod
                set xmax $xmax_Mod
                set ymin [minofblas $mf1a $mf2]
                set ymax [maxofblas $mf1a $mf2]
            }
            default {
                return -code error "bad frange G(frange,mf) = \"$G(frange,mf)\""
            }
        }
    }

#    if {$ymin < -10} {
#        set ymin -10
#    }

    if {[catch expr {$ymin}]} {
        set ymin -100
    } else {
        puts  stderr "ymin = $ymin"
    }
    if {[catch expr {$ymax}]} {
        set ymax 100
    }

    plotACurveLogLin $var mf _0 $f_0 $xmin $xmax $zero $ymin $ymax
    plotACurveLogLin $var mf 1a $Mod_f $xmin $xmax $mf1a $ymin $ymax
    plotACurveLogLin $var mf 1b $Mod_f $xmin $xmax $mf1b $ymin $ymax
    plotACurveLogLin $var mf 2 $Exp_f $xmin $xmax $mf2 $ymin $ymax
}

proc v11 {x} {
    set l [blas::vector length $x]
    if {$l % 4} {
        return -code error "not a 2x2 matrix"
    }
    return [blas::vector create -copy [blas::subvector create 1 4 [expr {$l/4}] $x]]
}

proc v12 {x} {
    set l [blas::vector length $x]
    if {$l % 4} {
        return -code error "not a 2x2 matrix"
    }
    return [blas::vector create -copy [blas::subvector create 2 4 [expr {$l/4}] $x]]
}

proc v21 {x} {
    set l [blas::vector length $x]
    if {$l % 4} {
        return -code error "not a 2x2 matrix"
    }
    return [blas::vector create -copy [blas::subvector create 3 4 [expr {$l/4}] $x]]
}

proc v22 {x} {
    set l [blas::vector length $x]
    if {$l % 4} {
        return -code error "not a 2x2 matrix"
    }
    return [blas::vector create -copy [blas::subvector create 4 4 [expr {$l/4}] $x]]
}

proc plotACurveLogLin {var t suffix x xmin xmax y ymin ymax} {

    upvar #0 commonCtx_${var} G

    set xyplotName plot_${var}(${t}${suffix})
    upvar #0 $xyplotName xyplot

    if {![info exists G(xlinlog,$t)] || $G(xlinlog,$t) == {}} {
        set G(xlinlog,$t) lin
    }
    if {![info exists G(xlastlinlog,$t)] || $G(xlastlinlog,$t) == {}} {
        set G(xlastlinlog,$t) $G(xlinlog,$t)
    }
    if {![info exists G(ylinlog,$t)] || $G(xlinlog,$t) == {}} {
        set G(ylinlog,$t) lin
    }

    if {$G(hold,$t)} {
        set xmin $G(xmin,$t)
        set xmax $G(xmax,$t)        
        if {$G(xlinlog,$t) == "log"} {
            set xmin [expr {pow(10.,$xmin)}]
            set xmax [expr {pow(10.,$xmax)}]
        }
        set ymin $G(ymin,$t)
        set ymax $G(ymax,$t)
    } else {
        set G(xmin,$t) $xmin
        set G(xmax,$t) $xmax
        if {$G(xlinlog,$t) == "log"} {
            set G(xmin,$t) [expr {log10($G(xmin,$t))}]
            set G(xmax,$t) [expr {log10($G(xmax,$t))}]
        }
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

    if {$G(xlinlog,$t) == "log"} {
        blas::mathsvop x log10
        set xmin [expr {log10($xmin)}]
        set xmax [expr {log10($xmax)}]
    }

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

proc minofblas {args} {
    set min [blas::mathop min [lindex $args 0]]
    foreach dsv [lrange $args 1 end] {
        set new [blas::mathop min $dsv]
        if {$new < $min} {
            set min $new
        }
    }
    return $min
}

proc maxofblas {args} {
    set max [blas::mathop max [lindex $args 0]]
    foreach dsv [lrange $args 1 end] {
        set new [blas::mathop max $dsv]
        if {$new > $max} {
            set max $new
        }
    }
    return $max
}

proc 21mod {nelems x} {
    
    set ierr [blas::vector create long -length $nelems]
    set xl [blas::vector create doublecomplex -length $nelems]
    blas::slatec zlog [blas::subvector create 3 4 $nelems $x] xl ierr 
    set 21mod [blas::vector create double -length $nelems]
    blas::daxpy [expr {20./log(10.)}] [blas::math re $xl] 21mod
    return $21mod
}

proc ploplo {cursor val} {
    global PMOD
    set PMOD($cursor) [expr {$val*1e-14}]
    plotout
}

set rien {
set cursors {\
          X_cursor
          arrow
          based_arrow_down
          based_arrow_up
          boat
          bogosity
          bottom_left_corner
          bottom_right_corner
          bottom_side
          bottom_tee
          box_spiral
          center_ptr
          circle
          clock
          coffee_mug
          cross
          cross_reverse
          crosshair
          diamond_cross
          dot
          dotbox
          double_arrow
          draft_large
          draft_small
          draped_box
          exchange
          fleur
          gobbler
          gumby
          hand1
          hand2
          heart
          icon
          iron_cross
          left_ptr
          left_side
          left_tee
          leftbutton
          ll_angle
          lr_angle
          man
          middlebutton
          mouse
          pencil
          pirate
          plus
          question_arrow
          right_ptr
          right_side
          right_tee
          rightbutton
          rtl_logo
          sailboat
          sb_down_arrow
          sb_h_double_arrow
          sb_left_arrow
          sb_right_arrow
          sb_up_arrow
          sb_v_double_arrow
          shuttle
          sizing
          spider
          spraycan
          star
          target
          tcross
          top_left_arrow
          top_left_corner
          top_right_corner
          top_side
          top_tee
          trek
          ul_angle
          umbrella
          ur_angle
          watch
          xterm}

proc cc {l} {
    set c [lindex $l 0]
    set l [lrange $l 1 end]
    puts $c
    .c configure -cursor $c
    after 1000 [list cc $l]
}

cc $cursors
}


proc varFromWidget {s} {
    return [string range [lindex [split $s .] end] 1 end]
}

proc putstatus {} {
    foreach s [winfo children .b.fs] {
        set var [varFromWidget $s]
        puts -nonewline $var
        foreach vName {e0 e min max} {
            set $vName [format %.3g [$s.$vName get]]
            puts -nonewline " [set $vName]"
        }
        puts {}
    }
}

proc fullx {} {
    global PMOD PMOD0
    foreach s [winfo children .b.fs] {
        set var [varFromWidget $s]
        set PMOD($var) $PMOD0($var)
        entryUpdate $s.e $var 0
    }
    plotout
}

proc fullv {} {
    global PMOD PMOD0
    foreach s [winfo children .b.fs] {
        set var [varFromWidget $s]
        set PMOD0($var) $PMOD($var)
        entryUpdate $s.e0 $var 0
    }
    plotout
}

set NCHOICE 0

proc createChoice {f var} {
    global CHOICE_NEXT CHOICE_PREVIOUS CHOICE_FIRST CHOICE_LAST NCHOICE
    global CHOICE
    set cb $f._$var
    checkbutton $cb -text $var -command "raiseOrDestroy $cb 1" -variable CHOICE($var) -width 6 -anchor w -takefocus 1
    if {$NCHOICE == 0} {
        set CHOICE_FIRST $cb
        set CHOICE_LAST $cb
        set CHOICE_NEXT($cb) $cb
        set CHOICE_PREVIOUS($cb) $cb
    } else {
        set CHOICE_NEXT($CHOICE_LAST) $cb
        set CHOICE_NEXT($cb) $CHOICE_FIRST
        set CHOICE_PREVIOUS($cb) $CHOICE_LAST
        set CHOICE_PREVIOUS($CHOICE_FIRST) $cb
        set CHOICE_LAST $cb
    }
    incr NCHOICE

    bind $cb <Enter> "raiseChoice $cb"
    bind $cb <KeyPress-Right> "raiseNext CHOICE_NEXT $cb"
    bind $cb <KeyPress-Left> "raiseNext CHOICE_PREVIOUS $cb"
    return $cb
}


source [file join [file dirname [info script]] fit.tcl]
source [file join [file dirname [info script]] dumpall.tcl]
