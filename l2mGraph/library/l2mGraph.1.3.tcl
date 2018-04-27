package require l2mGraphTicks 1.2

#####################################
# calculs sur listes de coordonnées #
#####################################

namespace eval l2mGraph {
    variable graphPriv_graphs {}
    namespace export createGraph
}

source [file join [file dirname [info script]] l2mGraphBindings.tcl]

set HELP(l2mGraph::UserToCanvas) {
    retourne une liste de coordonnées (abscisse ou bien ordonnée)
    "canvas" doubles
    calculées à partir d'une liste de coordonnées "user" $luser
    $scale est le nom de l'échelle (x, y, x1 ou y1)
    F est le nom du graphique.
    Variables globales :
    ${graphPriv$F}(scaleIsLog_$scale) contient la nature log ou lin
    ${graphPriv$F}(scaleFact_$scale) contient le facteur d'échelle
    ${graphPriv$F}(scalePan_$scale) contient le décalage canvas.
}

proc l2mGraph::UserToCanvas {F scale luser {islog {}}} {
    upvar #0 graphPriv$F G
    
    if {$islog == {}} {
	set islog $G(scaleIsLog_$scale)
    }
    
    set lcanvas {}
    
    if {$islog == 0} {
	set p $G(scalePan_$scale)
	set f $G(scaleFact_$scale)
	foreach u $luser {
	    lappend lcanvas [expr double($u)*double($f) + double($p)]
	}
    } else {
	set p $G(scaleLogPan_$scale)
	set f $G(scaleLogFact_$scale)
	foreach u $luser {
	    lappend lcanvas [expr log10($u)*double($f) + double($p)]
	}
    }
    return $lcanvas
}

set HELP(l2mGraph::UserToCanvas) {
    Cf. CanvasToUser
}
proc l2mGraph::CanvasToUser {F scale lcanvas {islog {}}} {
    upvar #0 graphPriv$F G
    
    if {$islog == {}} {
	set islog $G(scaleIsLog_$scale)
    }
    
    set luser {}
    
    if {$G(scaleIsLog_$scale) == 0} {
	set p $G(scalePan_$scale)
	set f [expr 1.0/$G(scaleFact_$scale)]
	foreach c $lcanvas {
	    lappend luser [expr (double($c) - double($p))*$f]
	}
    } else {
	set p $G(scaleLogPan_$scale)
	set f [expr 1.0/$G(scaleLogFact_$scale)]
	foreach c $lcanvas {
	    lappend luser [expr pow(10.,(double($c) - double($p))*$f)]
	}
    }
    return $luser
}

#########
# ticks #
#########

set HELP(l2mGraph::createTicks) {
    crée une liste de ticks
}
proc l2mGraph::createTicks {F scale min max sizeMinDiv} {
    upvar #0 graphPriv$F G
    if {$G(scaleIsLog_$scale) == 0} {
	set ticks [createLinTicks $min $max [expr abs($G(scaleFact_$scale))] 5]
    } else {
	set ticks [createLogTicks $min $max [expr abs($G(scaleLogFact_$scale))] 5]
    }
    return $ticks
}

##########
# scales #
##########

set HELP(l2mGraph::createScale) {
}

proc l2mGraph::createScale {F scale min max} {
    upvar #0 graphPriv$F G
    
    $F.$scale delete ticks
    set ticks [createTicks $F $scale $min $max 5]
    set ticks0 [lindex $ticks 0]
    set labels [CreateTickLabels $F $scale $ticks0]
    set min [UserToCanvas $F $scale $min]
    set max [UserToCanvas $F $scale $max]
    
    switch $scale {
	x  {
	    $F.$scale create line $min 0 $max 0 -tags ticks
	    plotXTicks $F $scale $ticks0           ticks 0 6
	    plotXTicks $F $scale [lindex $ticks 1] ticks 0 4
	    plotXTicks $F $scale [lindex $ticks 2] ticks 0 2
	    plotXTickLabels $F.$scale $F $scale $ticks0 $labels ticks 7 n $G(scaleFont_font)
	}
	x1 {
	    $F.$scale create line $min 0 $max 0 -tags ticks
	    plotXTicks $F $scale $ticks0           ticks 0 -6
	    plotXTicks $F $scale [lindex $ticks 1] ticks 0 -4
	    plotXTicks $F $scale [lindex $ticks 2] ticks 0 -2
	    plotXTickLabels $F.$scale $F $scale $ticks0 $labels ticks -7 s $G(scaleFont_font)
	    $F.$scale move ticks 0 [expr $G(scaleWidth_x1) - 2]
	}
	y {
	    $F.$scale create line 0 $min 0 $max -tags ticks
	    plotYTicks $F $scale $ticks0           ticks -6 0
	    plotYTicks $F $scale [lindex $ticks 1] ticks -4 0
	    plotYTicks $F $scale [lindex $ticks 2] ticks -2 0
	    set w [plotYTickLabels $F.$scale $F $scale $ticks0 $labels ticks -7 e $G(scaleFont_font)]
	    set G(scaleWidth_$scale) [expr $w + 10]
	    $F.$scale move ticks [expr $G(scaleWidth_$scale) - 2] 0
	    configureGraphCanvas $F
	}
	y1 {
	    $F.$scale create line 0 $min 0 $max -tags ticks
	    plotYTicks $F $scale $ticks0           ticks 0 6
	    plotYTicks $F $scale [lindex $ticks 1] ticks 0 4
	    plotYTicks $F $scale [lindex $ticks 2] ticks 0 2
	    set w [plotYTickLabels $F.$scale $F $scale $ticks0 $labels ticks 7 w $G(scaleFont_font)]
	    set G(scaleWidth_$scale) [expr $w + 10]
	    configureGraphCanvas $F
	}
    }
    #    $F.y itemconfigure ticks -fill red
}        

proc l2mGraph::createVisibleScale_X {F scale} {
    set minmax [list 0 [expr [$F.c cget -width] -1]]
    set minmax [CanvasToUser $F $scale $minmax]
    createScale $F $scale [lindex $minmax 0] [lindex $minmax 1]
}

proc l2mGraph::createVisibleScale_Y {F scale} {
    set minmax [list [expr [$F.c cget -height] -1] 0]
    set minmax [CanvasToUser $F $scale $minmax]
    createScale $F $scale [lindex $minmax 0] [lindex $minmax 1]
}

proc l2mGraph::createVisibleScale {F scale} {
    if {[string match x* $scale]} {
	createVisibleScale_X $F $scale
    } elseif {[string match y* $scale]} {
	createVisibleScale_Y $F $scale
    } else {
	error "createVisibleScale $F $scale : scale doit être x* ou y*"
    }
}

#######################
# changements log/lin #
#######################

set HELP(l2mGraph::toLog) {

}

proc l2mGraph::toLog {F scale} {
    upvar #0 graphPriv$F G
    if {$G(scaleIsLog_$scale) == 1} {
	return
    }
    set objs [$F.c find withtag $scale]
    set p $G(scalePan_$scale)
    set f [expr 1.0/$G(scaleFact_$scale)]
    set pl $G(scaleLogPan_$scale)
    set fl $G(scaleLogFact_$scale)
    if {[string match x* $scale]} {
	foreach o $objs {
	    set coords [$F.c coords $o]
	    set ncoords {}
	    foreach {x y} $coords {
		set x [expr log10((double($x) - double($p))*$f)*$fl + $pl]
		lappend ncoords $x $y
	    }
	    eval $F.c coords $o $ncoords
	}
    } elseif {[string match y* $scale]} {
	foreach o $objs {
	    set coords [$F.c coords $o]
	    set ncoords {}
	    foreach {x y} $coords {
		set y [expr log10((double($y) - double($p))*$f)*$fl + $pl]
		lappend ncoords $x $y
	    }
	    eval $F.c coords $o $ncoords
	}
    } else {
	return
    }
    set G(scaleIsLog_$scale) 1
    createVisibleScale $F $scale
}

set HELP(l2mGraph::toLin) {
}

proc l2mGraph::toLin {F scale} {
    upvar #0 graphPriv$F G
    if {$G(scaleIsLog_$scale) == 0} {
	return
    }
    set objs [$F.c find withtag $scale]
    set p $G(scaleLogPan_$scale)
    set f [expr 1.0/$G(scaleLogFact_$scale)]
    set pl $G(scalePan_$scale)
    set fl $G(scaleFact_$scale)
    if {[string match x* $scale]} {
	foreach o $objs {
	    set coords [$F.c coords $o]
	    set ncoords {}
	    foreach {x y} $coords {
		set x [expr pow(10.,(double($x) - double($p))*$f)*$fl + $pl]
		lappend ncoords $x $y
	    }
	    eval $F.c coords $o $ncoords
	}
    } elseif {[string match y* $scale]} {
	foreach o $objs {
	    set coords [$F.c coords $o]
	    set ncoords {}
	    foreach {x y} $coords {
		set y [expr pow(10.,(double($y) - double($p))*$f)*$fl + $pl]
		lappend ncoords $x $y
	    }
	    eval $F.c coords $o $ncoords
	}
    } else {
	return
    }
    set G(scaleIsLog_$scale) 0
    createVisibleScale $F $scale
}

###################

set HELP(l2mGraph::configureGraphCanvas) {
}

proc l2mGraph::configureGraphCanvas {F {width {}} {height {}}} {
    upvar #0 graphPriv$F G
    if {$width == {}} {
	set width [$F cget -width]
    } else {
	$F configure -width $width
    }
    if {$height == {}} {
	set height [$F cget -height]
    } else {
	$F configure -height $height
    }
    
    set width  [expr $width - 2*[$F cget -borderwidth]]
    set height [expr $height - 2*[$F cget -borderwidth]]
    
    set h [expr $height - $G(scaleWidth_x) - $G(scaleWidth_x1) -2*$G(BW) - 2]
    set w [expr $width  - $G(scaleWidth_y) - $G(scaleWidth_y1) -2*$G(BW) - 2]
    
    $F.c configure -borderwidth $G(BW)
    $F.c configure -width       $w
    $F.c configure -height      $h
    place configure $F.c -x [expr $G(scaleWidth_y)] -y [expr $G(scaleWidth_x1)]
    
    if {$G(scaleWidth_x)>0} {
	$F.x configure -borderwidth $G(BWs)
	$F.x configure -width $w
	$F.x configure -height [expr $G(scaleWidth_x) - 2*$G(BWs) -1]
	place configure $F.x  -x [expr $G(scaleWidth_y)]  -y [expr $height - $G(scaleWidth_x) -1]
    } else {
	place forget $F.x
    }
    
    if {$G(scaleWidth_x1)>0} {
	$F.x1 configure -borderwidth $G(BWs)
	$F.x1 configure -width $w
	$F.x1 configure -height [expr $G(scaleWidth_x1) - 2*$G(BWs) -1]
	place configure $F.x1 -x [expr $G(scaleWidth_y)] -y 0
    } else {
	place forget $F.x1
    }
    
    if {$G(scaleWidth_y)>0} {
	$F.y configure -borderwidth $G(BWs)
	$F.y configure -width [expr $G(scaleWidth_y) - 2*$G(BWs) -1]
	$F.y configure -height $h
	place configure $F.y -x 0 -y [expr $G(scaleWidth_x1)]
    } else {
	place forget $F.y
    }
    
    if {$G(scaleWidth_y1)>0} {
	$F.y1 configure -borderwidth $G(BWs)
	$F.y1 configure -width [expr $G(scaleWidth_y1) - 2*$G(BWs) -1]
	$F.y1 configure -height $h
	place configure $F.y1  -x [expr $width - $G(scaleWidth_y1) -1]  -y [expr $G(scaleWidth_x1)]
    } else {
	place forget $F.y1
    }
}

set HELP(l2mGraph::fullview) {
}

proc l2mGraph::fullview {F tags} {
    fullview2 $F $tags
    #    fullview1 $F $tags
}

proc l2mGraph::fullview1 {F tags} {
    #    configureGraphCanvas $F ;# pour être sur que les échelles rentrent
    set bb [eval $F.c bbox $tags]
    puts "fullview _ $bb"
    set xmin [expr [lindex $bb 0] + 1]
    set ymin [expr [lindex $bb 1] + 1]
    set xmax [expr [lindex $bb 2] - 1]
    set ymax [expr [lindex $bb 3] - 1]
    recadre $F [list $xmin $ymin $xmax $ymax]
}

proc l2mGraph::fullview2.bad {F tags} {
    # A REVOIR    
    set xmin 1e308
    set xmax -1e308
    set ymin 1e308
    set ymax -1e308
    set xminCanvas 1e308
    set xmaxCanvas -1e308
    set yminCanvas 1e308
    set ymaxCanvas -1e308
    foreach scale $tags {
	if {$scale == "x" || $scale == "x1"} {
	    set objs [eval $F.c find withtag $scale]
	    foreach o $objs {
		set coords [eval $F.c coords $o]
		foreach {x y} $coords {
		    if {$x < $xmin} {
			set xmin $x
		    }
		    if {$x > $xmax} {
			set xmax $x
		    }
		}
	    }
	    puts -nonewline "$scale : $xmin $xmax -> "
	    set xmin [UserToCanvas $F $scale $xmin]
	    set xmax [UserToCanvas $F $scale $xmax]
	    puts "$xmin $xmax"
	    if {$xmin < $xminCanvas} {
		set xminCanvas $xmin
	    }
	    if {$xmax > $xmaxCanvas} {
		set xmaxCanvas $xmax
	    }
	} elseif {$scale == "y" || $scale == "y1"} {
	    set objs [eval $F.c find withtag $scale]
	    foreach o $objs {
		set coords [eval $F.c coords $o]
		foreach {x y} $coords {
		    if {$y < $ymin} {
			set ymin $y
		    }
		    if {$y > $ymax} {
			set ymax $y
		    }
		}
	    }
	    puts -nonewline "$scale : $ymin $ymax -> "
	    set ymin [UserToCanvas $F $scale $ymin]
	    set ymax [UserToCanvas $F $scale $ymax]
	    puts "$ymin $ymax"
	    if {$ymin < $yminCanvas} {
		set yminCanvas $ymin
	    }
	    if {$ymax > $ymaxCanvas} {
		set ymaxCanvas $ymax
	    }
	} else {
	    tkerror "fullview2 : tag incorrect (doit être x, y, x1 ou y1)"
	    
	}
    }
    if {$xminCanvas > $xmaxCanvas} {
	set xminCanvas 0
	set xmaxCanvas [expr [$F.c cget -width] - 1]
    }
    if {$yminCanvas > $ymaxCanvas} {
	set yminCanvas 0
	set ymaxCanvas [expr [$F.c cget -height] - 1]
    }
    recadre $F [list $xminCanvas $yminCanvas $xmaxCanvas $ymaxCanvas]
}

proc l2mGraph::fullview2 {F tag} {
    # A REVOIR    
    set xmin 1e308
    set xmax -1e308
    set ymin 1e308
    set ymax -1e308
    set objs [eval $F.c find withtag $tag]
    foreach o $objs {
	set coords [eval $F.c coords $o]
	foreach {x y} $coords {
	    if {$x < $xmin} {
		set xmin $x
	    }
	    if {$x > $xmax} {
		set xmax $x
	    }
	    if {$y < $ymin} {
		set ymin $y
	    }
	    if {$y > $ymax} {
		set ymax $y
	    }
	}
    }
    recadre $F [list $xmin $ymin $xmax $ymax]
}

set HELP(l2mGraph::plotSimple) {
    ajoute à un l2mGraph $F
    une liste de points donnés par la liste des x $xlist
    et la liste des y $ylist
    L' échelle de contrôle x ou x1 est donnée par $xscale
    L' échelle de contrôle y ou y1 est donnée par $yscale
    Ce qui est tracé est affublé des tags de la liste $tags,
    en plus des tags $xscale $yscale et plot.
    si un élément de xlist ou ylist est une liste (normalement de deux ou trois)
    les barres d'erreur sont tracées.
}

proc l2mGraph::plotSimple {F xl yl xscale yscale tags} {
    upvar #0 graphPriv$F G
    if {[info commands insertInList] != {}} {
	insertInList $F $tags
    }
    set tags [concat $tags $xscale $yscale plot]
    
    set xlp [UserToCanvas $F $xscale $xl]
    set ylp [UserToCanvas $F $yscale $yl]
    
    set oldxp [lindex $xlp 0]
    set oldyp [lindex $ylp 0]
    
    foreach xp [lrange $xlp 1 end] yp [lrange $ylp 1 end] {
	if {$xp == {} || $yp == {}} {
	    break
	}
puts [list $F.c create line $oldxp $oldyp $xp $yp -tags $tags -width 0]
	$F.c create line $oldxp $oldyp $xp $yp -tags $tags -width 0
	set oldxp $xp
	set oldyp $yp
    }
}

proc l2mGraph::plotWithErrors {F xlist ylist xscale yscale tags} {
    upvar #0 graphPriv$F G
    set tags [concat $tags $xscale $yscale plot]
    set yl {}
    set xl {}
    
    foreach x $xlist y $ylist {
	if {$x == {} || $y == {}} {
	    break
	}
	set xy [cadreErreur $F $x $y $xscale $yscale $tags]
	lappend xl [lindex $xy 0]
	lappend yl [lindex $xy 1]
    }
    plotSimple $F $xl $yl $xscale $yscale tags
}

proc l2mGraph::plotXTickLabels {winScale F scale xl ll tag y anchor font} {
    set xpmin 0
    set xpmax [expr [$winScale cget -width] -1]
    set xpl [UserToCanvas $F $scale $xl]
    
    foreach xp $xpl label $ll {
	set ws2 [expr ([font measure $font "a"]*[string length $label]+1)/2]
	#        if {$xp+$ws2>$xpmax}
	if {$xp>$xpmax} {
	    break
	}
	#        if {$xp-$ws2>$xpmin}
	if {$xp>=$xpmin} {
	    $winScale create text $xp $y  -text $label -anchor $anchor -tags $tag  -font $font
	    set xpmin [expr $xp+$ws2+5] ;# 5 ARBITRAIRE
	}
    }
}

proc l2mGraph::plotYTickLabels {winScale F scale yl ll tag x anchor font} {
    
    set ypl [UserToCanvas $F $scale $yl]
    set maxWidth 0
    
    foreach yp $ypl label $ll  {
	set w [expr [font measure $font "a"]*[string length $label]]
	if {$w > $maxWidth} {
	    set maxWidth $w
	}
	$winScale create text $x $yp -text $label -anchor $anchor -tags $tag -font $font
    }
    return $maxWidth
}

proc l2mGraph::plotXTicks {F scale xl tag y1 y2} {
    set xlp [UserToCanvas $F $scale $xl]
    
    foreach x $xlp {
	$F.$scale create line $x $y1 $x $y2 -tags $tag
    }
}

proc l2mGraph::plotYTicks {F scale yl tag x1 x2} {
    set ylp [UserToCanvas $F $scale $yl]
    foreach y $ylp {
	$F.$scale create line $x1 $y $x2 $y -tags $tag
    }
}

proc l2mGraph::recadre {F bb} {
    puts "recadre : $bb"
    if {$bb == {}} {
	return
    }
    upvar #0 graphPriv$F G
    set width [$F.c cget -width]
    set height [$F.c cget -height]
    set xmin [lindex $bb 0]
    set ymin [lindex $bb 1]
    set xmax [lindex $bb 2]
    set ymax [lindex $bb 3]
    set fx [expr double($width-1)/double($xmax - $xmin)]
    set fy [expr double($height-1)/double($ymax - $ymin)]
    set xmin [expr $xmin*$fx]
    set xmax [expr $xmax*$fx]
    set ymin [expr $ymin*$fy]
    set ymax [expr $ymax*$fy]
    set dx [expr -$xmin]
    set dy [expr -$ymin]
    scaleRecadre $F x  $fx $dx
    scaleRecadre $F x1 $fx $dx
    scaleRecadre $F y  $fy $dy
    scaleRecadre $F y1 $fy $dy
    $F.c scale x 0 0 $fx 1
    $F.c scale x1 0 0 $fx 1
    $F.c scale y 0 0 1 $fy
    $F.c scale y1 0 0 1 $fy
    $F.c move plot $dx $dy
    $F.x delete ticks
    $F.y delete ticks
    $F.x1 delete ticks
    $F.y1 delete ticks
    update
    createVisibleScale_X $F x
    update
    createVisibleScale_Y $F y
    update
    createVisibleScale_X $F x1
    update
    createVisibleScale_Y $F y1
    update
}

proc l2mGraph::winZoom {wname x y} {
    set F [winfo parent $wname]
    upvar #0 graphPriv$F G
    
    $F.c delete zoomrect
    $F.c create rectangle $G(b1Start_X) $G(b1Start_Y) $x $y -tags zoomrect
}

proc l2mGraph::zoom {wname} {
    set F [winfo parent $wname]
    upvar #0 graphPriv$F G
    set bb [$F.c coords zoomrect] ;# les coords sont réarangées
    $F.c delete zoomrect
    puts $bb
    recadre $F $bb
}

proc l2mGraph::zoomX {wname} {
    set F [winfo parent $wname]
    upvar #0 graphPriv$F G
    set bb [$F.c coords zoomrect] ;# les coords sont réarangées
    $F.c delete zoomrect
    
    recadre $F [list [lindex $bb 0] 0 \
	    [lindex $bb 2] [$wname cget -height]]
}

proc l2mGraph::zoomY {wname} {
    set F [winfo parent $wname]
    upvar #0 graphPriv$F G
    set bb [$F.c coords zoomrect] ;# les coords sont réarangées
    $F.c delete zoomrect
    
    recadre $F [list 0 [lindex $bb 1]\
	    [$wname cget -width] [lindex $bb 3] ]
}

proc l2mGraph::resetCanvasCoords {canvas} {
    $canvas configure -scrollregion {0 0 0 0}
    $canvas xview moveto 0
    $canvas yview moveto 0
}

proc l2mGraph::testLabels {F} {
    upvar #0 graphPriv$F G
    frame $F.labels -borderwidth 3 -relief ridge
    place configure $F.labels -in $F.c -anchor ne -relx 1.0 -rely 0.0 
    bind $F.labels <Button-1> [namespace code {
	upvar #0 graphPriv[winfo parent %W] G
	set G(b1Start_X) %X
	set G(b1Start_Y) %Y
    }]
    bind $F.labels <Button1-Motion> [namespace code {
	set F [winfo parent %W]
	upvar #0 graphPriv$F G
	set dx [expr %X - $G(b1Start_X)]
	set dy [expr %Y - $G(b1Start_Y)]
	set G(b1Start_X) %X
	set G(b1Start_Y) %Y
	incr G(labelPos_X) $dx
	incr G(labelPos_Y) $dy
	place configure %W -x $G(labelPos_X) -y $G(labelPos_Y)
    }]
    label $F.labels.toto -text toto
    pack $F.labels.toto
}
	
set HELP(l2mGraph::resetCanvasCoords) {
    Cette commande permet de rendre visible les pixels du canvas $canvas
    0..$width-1 0..$height-1
    au lieu de 1..$width 1..$height ou autre
}


proc l2mGraph::createGraph {F} {
    upvar #0 graphPriv$F G
    variable graphPriv_graphs
    
    if {[winfo exists $F]} {
	error "widget $F already exists"
    }
    
    frame $F -width 300 -height 200 -borderwidth 10 -relief sunken
    bind $F <Destroy> [namespace code {
	unset graphPriv%W
	set i [lsearch ${graphPriv_graphs} %W]
	set graphPriv_graphs [lreplace ${graphPriv_graphs} $i $i]
    }]
	
    lappend graphPriv_graphs $F
	
    foreach c {c x x1 y y1} {
	canvas $F.$c
	resetCanvasCoords $F.$c
    }
    set G(BW) 0
    set G(scaleWidth_x) 30
    set G(scaleWidth_y) 50
    set G(scaleWidth_x1) 30
    set G(scaleWidth_y1) 50
    set G(scaleIsLog_x) 0
    set G(scaleIsLog_x1) 0
    set G(scaleIsLog_y) 0
}

proc l2mGraph::panScale_X {wscale x} {
    set F [winfo parent $wscale]
    set name [winfo name $wscale]
    upvar #0 graphPriv$F G
    set dx [expr $x - $G(b1Start_X)]
    set G(b1Start_X) $x
    scalePanIncr $F $name $dx
    $wscale move ticks $dx 0
    $F.c move $name $dx 0
}

proc l2mGraph::panScale_Y {wscale y} {
    set F [winfo parent $wscale]
    set name [winfo name $wscale]
    upvar #0 graphPriv$F G
    set dy [expr $y - $G(b1Start_Y)]
    set G(b1Start_Y) $y
    scalePanIncr $F $name $dy
    $wscale move ticks 0 $dy
    $F.c move $name 0 $dy
    
}



proc l2mGraph::cadreErreur {F xl yl xscale yscale tags} {
    upvar #0 graphPriv$F G
    lappend tags errs
    set WS2 2        ;# ARBITRAIRE
    set WS2 0
    set nx [llength $xl]
    set ny [llength $yl]
    if {$nx > 1} {
	set xpmin [UserToCanvas $F $xscale [lindex $xl 0]]
	set xpmax [UserToCanvas $F $xscale [lindex $xl end]]
	set ns2 [expr $nx/2]
	if {($nx % 2)!=0} {
	    set x [lindex $xl $ns2]
	} else {
	    set x [expr ([lindex $xl $ns2]+[lindex $xl [expr $ns2 -1]])/2.0]
	}
    } else {
	set xp [UserToCanvas $F $xscale $xl]
	set xpmin [expr $xp - $WS2]
	set xpmax [expr $xp + $WS2]
	set x $xl    
    }
    if {$ny > 1} {
	set ypmin [UserToCanvas $F $yscale [lindex $yl 0]]
	set ypmax [UserToCanvas $F $yscale [lindex $yl end]]
	set ns2 [expr $ny/2]
	if {($ny % 2)!=0} {
	    set y [lindex $yl $ns2]
	} else {
	    set y [expr ([lindex $yl $ns2]+[lindex $yl [expr $ns2 -1]])/2.0]
	}
    } else {
	set yp [UserToCanvas $F $yscale $yl]
	set ypmin [expr $yp - $WS2]
	set ypmax [expr $yp + $WS2]
	set y $yl    
    }
    
    set xlp [UserToCanvas $F $xscale $xl]
    set ylp [UserToCanvas $F $yscale $yl]
    
    foreach xp $xlp {
	$F.c create line $xp $ypmin $xp $ypmax -tags $tags -width 0
    }
    foreach yp $ylp {
	$F.c create line $xpmin $yp $xpmax $yp -tags $tags -width 0
    }
    return [list $x $y]
}

proc l2mGraph::plotWithErrors {F xlist ylist xscale yscale tags} {
    upvar #0 graphPriv$F G
    set tags [concat $tags $xscale $yscale plot]
    set yl {}
    set xl {}
    
    foreach x $xlist y $ylist {
	if {$x == {} || $y == {}} {
	    break
	}
	set xy [cadreErreur $F $x $y $xscale $yscale $tags]
	lappend xl [lindex $xy 0]
	lappend yl [lindex $xy 1]
    }
    plotSimple $F $xl $yl $xscale $yscale tags
}

proc l2mGraph::plotXTickLabels {winScale F scale xl ll tag y anchor font} {
    set xpmin 0
    set xpmax [expr [$winScale cget -width] -1]
    set xpl [UserToCanvas $F $scale $xl]
    
    foreach xp $xpl label $ll {
	set ws2 [expr ([font measure $font "a"]*[string length $label]+1)/2]
	#        if {$xp+$ws2>$xpmax}
	if {$xp>$xpmax} {
	    break
	}
	#        if {$xp-$ws2>$xpmin}
	if {$xp>=$xpmin} {
	    $winScale create text $xp $y  -text $label -anchor $anchor -tags $tag  -font $font
	    set xpmin [expr $xp+$ws2+5] ;# 5 ARBITRAIRE
	}
    }
}

proc l2mGraph::plotYTickLabels {winScale F scale yl ll tag x anchor font} {
    
    set ypl [UserToCanvas $F $scale $yl]
    set maxWidth 0
    
    foreach yp $ypl label $ll  {
	set w [expr [font measure $font "a"]*[string length $label]]
	if {$w > $maxWidth} {
	    set maxWidth $w
	}
	$winScale create text $x $yp -text $label -anchor $anchor -tags $tag -font $font
    }
    return $maxWidth
}

proc l2mGraph::plotXTicks {F scale xl tag y1 y2} {
    set xlp [UserToCanvas $F $scale $xl]
    
    foreach x $xlp {
	$F.$scale create line $x $y1 $x $y2 -tags $tag
    }
}

proc l2mGraph::plotYTicks {F scale yl tag x1 x2} {
    set ylp [UserToCanvas $F $scale $yl]
    foreach y $ylp {
	$F.$scale create line $x1 $y $x2 $y -tags $tag
    }
}

proc l2mGraph::recadre {F bb} {
    puts "recadre : $bb"
    if {$bb == {}} {
	return
    }
    upvar #0 graphPriv$F G
    set width [$F.c cget -width]
    set height [$F.c cget -height]
    set xmin [lindex $bb 0]
    set ymin [lindex $bb 1]
    set xmax [lindex $bb 2]
    set ymax [lindex $bb 3]
    set fx [expr double($width-1)/double($xmax - $xmin)]
    set fy [expr double($height-1)/double($ymax - $ymin)]
    set xmin [expr $xmin*$fx]
    set xmax [expr $xmax*$fx]
    set ymin [expr $ymin*$fy]
    set ymax [expr $ymax*$fy]
    set dx [expr -$xmin]
    set dy [expr -$ymin]
    scaleRecadre $F x  $fx $dx
    scaleRecadre $F x1 $fx $dx
    scaleRecadre $F y  $fy $dy
    scaleRecadre $F y1 $fy $dy
    $F.c scale x 0 0 $fx 1
    $F.c scale x1 0 0 $fx 1
    $F.c scale y 0 0 1 $fy
    $F.c scale y1 0 0 1 $fy
    $F.c move plot $dx $dy
    $F.x delete ticks
    $F.y delete ticks
    $F.x1 delete ticks
    $F.y1 delete ticks
    update
    createVisibleScale_X $F x
    update
    createVisibleScale_Y $F y
    update
    createVisibleScale_X $F x1
    update
    createVisibleScale_Y $F y1
    update
}

proc l2mGraph::winZoom {wname x y} {
    set F [winfo parent $wname]
    upvar #0 graphPriv$F G
    
    $F.c delete zoomrect
    $F.c create rectangle $G(b1Start_X) $G(b1Start_Y) $x $y -tags zoomrect
}

proc l2mGraph::zoom {wname} {
    set F [winfo parent $wname]
    upvar #0 graphPriv$F G
    set bb [$F.c coords zoomrect] ;# les coords sont réarangées
    $F.c delete zoomrect
    puts $bb
    recadre $F $bb
}

proc l2mGraph::zoomX {wname} {
    set F [winfo parent $wname]
    upvar #0 graphPriv$F G
    set bb [$F.c coords zoomrect] ;# les coords sont réarangées
    $F.c delete zoomrect
    
    recadre $F [list [lindex $bb 0] 0 \
	    [lindex $bb 2] [$wname cget -height]]
}

proc l2mGraph::zoomY {wname} {
    set F [winfo parent $wname]
    upvar #0 graphPriv$F G
    set bb [$F.c coords zoomrect] ;# les coords sont réarangées
    $F.c delete zoomrect
    
    recadre $F [list 0 [lindex $bb 1]\
	    [$wname cget -width] [lindex $bb 3] ]
}

proc l2mGraph::resetCanvasCoords {canvas} {
    $canvas configure -scrollregion {0 0 0 0}
    $canvas xview moveto 0
    $canvas yview moveto 0
}

proc l2mGraph::testLabels {F} {
    upvar #0 graphPriv$F G
    frame $F.labels -borderwidth 3 -relief ridge
    place configure $F.labels -in $F.c -anchor ne -relx 1.0 -rely 0.0 
    bind $F.labels <Button-1> [namespace code {
	upvar #0 graphPriv[winfo parent %W] G
	set G(b1Start_X) %X
	set G(b1Start_Y) %Y
    }]
    bind $F.labels <Button1-Motion> [namespace code {
	set F [winfo parent %W]
	upvar #0 graphPriv$F G
	set dx [expr %X - $G(b1Start_X)]
	set dy [expr %Y - $G(b1Start_Y)]
	set G(b1Start_X) %X
	set G(b1Start_Y) %Y
	incr G(labelPos_X) $dx
	incr G(labelPos_Y) $dy
	place configure %W -x $G(labelPos_X) -y $G(labelPos_Y)
    }]
    label $F.labels.toto -text toto
    pack $F.labels.toto
}
	
set HELP(l2mGraph::resetCanvasCoords) {
    Cette commande permet de rendre visible les pixels du canvas $canvas
    0..$width-1 0..$height-1
    au lieu de 1..$width 1..$height ou autre
}


set HELP(l2mGraph::createGraph) {

BW borderwidth
BWs borderwidth of scales
labelPos_X 
)      = 0
graphPriv.g1(labelPos_Y)      = 0
graphPriv.g1(scaleFact_x)     = 193.0
graphPriv.g1(scaleFact_x1)    = 193.0
graphPriv.g1(scaleFact_y)     = -7.0
graphPriv.g1(scaleFact_y1)    = -7.0
graphPriv.g1(scaleFont_font)  = font1
graphPriv.g1(scaleIsLog_x)    = 0
graphPriv.g1(scaleIsLog_x1)   = 0
graphPriv.g1(scaleIsLog_y)    = 0
graphPriv.g1(scaleIsLog_y1)   = 0
graphPriv.g1(scaleLogFact_x)  = 20
graphPriv.g1(scaleLogFact_x1) = 20
graphPriv.g1(scaleLogFact_y)  = -20
graphPriv.g1(scaleLogFact_y1) = -20
graphPriv.g1(scaleLogPan_x)   = 0
graphPriv.g1(scaleLogPan_x1)  = 0
graphPriv.g1(scaleLogPan_y)   = 0
graphPriv.g1(scaleLogPan_y1)  = 0
graphPriv.g1(scalePan_x)      = 0.0
graphPriv.g1(scalePan_x1)     = 0.0
graphPriv.g1(scalePan_y)      = 140.0
graphPriv.g1(scalePan_y1)     = 140.0
graphPriv.g1(scaleWidth_x)    = 30
graphPriv.g1(scaleWidth_x1)   = 30
graphPriv.g1(scaleWidth_y)    = 24
graphPriv.g1(scaleWidth_y1)   = 24

}


proc l2mGraph::createGraph {F} {
    upvar #0 graphPriv$F G
    variable graphPriv_graphs
    
    if {[winfo exists $F]} {
	error "widget $F already exists"
    }
    
    frame $F -width 300 -height 200 -borderwidth 2 -relief sunken
    bind $F <Destroy> [namespace code {
	unset graphPriv%W
	set i [lsearch ${graphPriv_graphs} %W]
	set graphPriv_graphs [lreplace ${graphPriv_graphs} $i $i]
    }]
	
    lappend graphPriv_graphs $F
	
    foreach c {c x x1 y y1} {
	canvas $F.$c
	resetCanvasCoords $F.$c
    }
    set G(BW) 0
    set G(scaleWidth_x) 30
    set G(scaleWidth_y) 50
    set G(scaleWidth_x1) 30
    set G(scaleWidth_y1) 50
    set G(scaleIsLog_x) 0
    set G(scaleIsLog_x1) 0
    set G(scaleIsLog_y) 0
    set G(scaleIsLog_y1) 0
    set G(scalePan_x) 0
    set G(scalePan_y) 0
    set G(scalePan_x1) 0
    set G(scalePan_y1) 0
    set G(scaleLogPan_x) 0
    set G(scaleLogPan_y) 0
    set G(scaleLogPan_x1) 0
    set G(scaleLogPan_y1) 0
    set G(scaleFact_x) 10
    set G(scaleFact_y) -10
    set G(scaleFact_x1) 10
    set G(scaleFact_y1) -10
    set G(scaleLogFact_x) 20
    set G(scaleLogFact_y) -20
    set G(scaleLogFact_x1) 20
    set G(scaleLogFact_y1) -20
    set G(labelPos_X) 0
    set G(labelPos_Y) 0
    set G(scaleFont_font) [font create -family fixed -size 10]
    
    set G(BWs) 0
    bind $F <Configure> [namespace code "configureGraphCanvas %W %w %h"]
    return $F
}

proc l2mGraph::CreateTickLabels {F scale liste} {
    upvar #0 graphPriv$F G
    if {[llength $liste] == 0} {
	return
    }
    if {[llength $liste] == 1} {
	return [format %g $liste]
    }
    if {$G(scaleIsLog_$scale) == 1} {
	set retlist {}
	set format %g ;# A REVOIR
	foreach x $liste  {
	    lappend retlist [format $format $x]
	}
	return $retlist
    }
    set epsilon 0.001
    set diff [expr [lindex $liste 1]-[lindex $liste 0]]
    set chiffre [expr int(floor(log10($diff)+$epsilon))]
    set retlist {}
    if {$chiffre<=0} {
	set chiffre [expr -$chiffre]
	set format %.${chiffre}f
	foreach x $liste  {
	    lappend retlist [format $format $x]
	}
    } else {
	set format %g ;# A REVOIR
	foreach x $liste  {
	    lappend retlist [format $format $x]
	}
    }
    return $retlist
}

proc l2mGraph::CreateTickLabels {F scale liste} {
    upvar #0 graphPriv$F G
    if {[llength $liste] == 0} {
	return
    }
    if {[llength $liste] == 1} {
	return [format %g $liste]
    }
    if {$G(scaleIsLog_$scale) == 1} {
	set retlist {}
	set format %g ;# A REVOIR
	foreach x $liste  {
	    lappend retlist [format $format $x]
	}
	return $retlist
    }
    set epsilon 0.001
    set diff [expr [lindex $liste 1]-[lindex $liste 0]]
    set chiffre [expr int(floor(log10($diff)+$epsilon))]
    set retlist {}
    if {$chiffre<=0} {
	set chiffre [expr -$chiffre]
	set format %.${chiffre}f
	foreach x $liste  {
	    lappend retlist [format $format $x]
	}
    } else {
	set format %g ;# A REVOIR
	foreach x $liste  {
	    lappend retlist [format $format $x]
	}
    }
    return $retlist
}


