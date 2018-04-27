proc l2mGraph::beginPan {wname x y} {
    set F [winfo parent $wname]
    upvar #0 graphPriv$F G
    
    set G(b1Start_X) $x
    set G(b1Start_Y) $y
}

proc l2mGraph::beginZoom {wname x y} {
    set F [winfo parent $wname]
    upvar #0 graphPriv$F G
    
    set G(b1Start_X) $x
    set G(b1Start_Y) $y
}

proc l2mGraph::bind_fullview1 {F} {
    bind $F.c  <Button-1> [namespace code {fullview1 [winfo parent %W] all}]
    bind $F.c  <Button1-Motion> {}
    bind $F.c  <ButtonRelease-1> {}
}

proc l2mGraph::bind_fullview2 {F} {
    bind $F.c  <Button-1> [namespace code {fullview2 [winfo parent %W] all}]
    bind $F.c  <Button1-Motion> {}
    bind $F.c  <ButtonRelease-1> {}
}

proc l2mGraph::bind_pan {F} {
    upvar #0 graphPriv$F G
    
    bind $F.x  <Button-1> [namespace code {beginPan %W %x %y}]
    bind $F.x1 <Button-1> [namespace code {beginPan %W %x %y}]
    bind $F.y  <Button-1> [namespace code {beginPan %W %x %y}]
    bind $F.y1 <Button-1> [namespace code {beginPan %W %x %y}]
    bind $F.c  <Button-1> [namespace code {beginPan %W %x %y}]
    bind $F.x  <Button1-Motion> [namespace code {panScale_X %W %x}]
    bind $F.x1 <Button1-Motion> [namespace code {panScale_X %W %x}]
    bind $F.y  <Button1-Motion> [namespace code {panScale_Y %W %y}]
    bind $F.y1 <Button1-Motion> [namespace code {panScale_Y %W %y}]
    bind $F.c  <Button1-Motion> [namespace code {panC %W %x %y}]
    bind $F.x  <ButtonRelease-1> [namespace code {
	createVisibleScale_X [winfo parent %W] x
    }]
    bind $F.x1 <ButtonRelease-1> [namespace code {
	createVisibleScale_X [winfo parent %W] x1
    }]
    bind $F.y  <ButtonRelease-1> [namespace code {
	createVisibleScale_Y [winfo parent %W] y
    }]
    bind $F.y1  <ButtonRelease-1> [namespace code {
	createVisibleScale_Y [winfo parent %W] y1
    }]
    bind $F.c <ButtonRelease-1> [namespace code {
	createVisibleScale_X [winfo parent %W] x
	createVisibleScale_Y [winfo parent %W] y
	createVisibleScale_X [winfo parent %W] x1
	createVisibleScale_Y [winfo parent %W] y1
    }]
}
		    
proc l2mGraph::bind_zoom {F} {
    upvar #0 graphPriv$F G
    
    bind $F.c <Button-1> [namespace code {beginZoom %W %x %y}]
    bind $F.c <Button1-Motion> [namespace code {winZoom %W %x %y}]
    bind $F.c <ButtonRelease-1> [namespace code {zoom %W}]
}

proc l2mGraph::bind_zoomX {F} {
    upvar #0 graphPriv$F G
    
    bind $F.c <Button-1> [namespace code {beginZoom %W %x %y}]
    bind $F.c <Button1-Motion> [namespace code {winZoom %W %x %y}]
    bind $F.c <ButtonRelease-1> [namespace code {zoomX %W}]
}

proc l2mGraph::bind_zoomY {F} {
    upvar #0 graphPriv$F G
    
    bind $F.c <Button-1> [namespace code {beginZoom %W %x %y}]
    bind $F.c <Button1-Motion> [namespace code {winZoom %W %x %y}]
    bind $F.c <ButtonRelease-1> [namespace code {zoomY %W}]
}

proc l2mGraph::bind_zm2 {F} {
    upvar #0 graphPriv$F G
    
    puts bind_zm2
    bind $F.c <Button-1> [namespace code {
	set width [%W cget -width]
	set height [%W cget -height]
	puts recadre
	recadre [winfo parent %W] \
		[list [expr -0.5*$width] [expr -0.5*$height] \
		[expr 1.5*$width] [expr 1.5*$height]]
    }]
    bind $F.c <Button1-Motion> {}
    bind $F.c <ButtonRelease-1> {}
}
    
proc l2mGraph::bind_zm2X {F} {
    upvar #0 graphPriv$F G
    
    bind $F.c <Button-1> [namespace code {
	set width [%W cget -width]
	set height [%W cget -height]
	recadre [winfo parent %W] \
		[list [expr -0.5*$width] 0 \
		[expr 1.5*$width] $height]
    }]
    bind $F.c <Button1-Motion> {}
    bind $F.c <ButtonRelease-1> {}
}
    
proc l2mGraph::bind_zm2Y {F} {
    upvar #0 graphPriv$F G
    
    bind $F.c <Button-1> [namespace code {
	set width [%W cget -width]
	set height [%W cget -height]
	recadre [winfo parent %W] \
		[list 0 [expr -0.5*$height] \
		$width [expr 1.5*$height]]
    }]
    bind $F.c <Button1-Motion> {}
    bind $F.c <ButtonRelease-1> {}
}
    
    
proc l2mGraph::scalePanIncr {F scale incr} {
    upvar #0 graphPriv$F G
    if {$G(scaleIsLog_$scale) == 0} {
	set G(scalePan_$scale) [expr $G(scalePan_$scale) + $incr]
    } else {
	set G(scaleLogPan_$scale) [expr $G(scaleLogPan_$scale) + $incr]
    }
}

proc l2mGraph::scaleRecadre {F scale fact incr} {
    upvar #0 graphPriv$F G
    if {$G(scaleIsLog_$scale) == 0} {
	set G(scaleFact_$scale) [expr $G(scaleFact_$scale) * $fact]
	set G(scalePan_$scale) [expr $G(scalePan_$scale)*$fact+$incr]
    } else {
	set G(scaleLogFact_$scale) [expr $G(scaleLogFact_$scale) * $fact]
	set G(scaleLogPan_$scale) [expr $G(scaleLogPan_$scale)*$fact+$incr]
    }
}

proc l2mGraph::panC {wscale x y} {
    set F [winfo parent $wscale]
    upvar #0 graphPriv$F G
    set dx [expr $x - $G(b1Start_X)]
    set dy [expr $y - $G(b1Start_Y)]
    set G(b1Start_X) $x
    set G(b1Start_Y) $y
    scalePanIncr $F x  $dx
    scalePanIncr $F x1 $dx
    scalePanIncr $F y  $dy
    scalePanIncr $F y1 $dy
    $F.c move plot $dx $dy
    $F.x move ticks $dx 0
    $F.x1 move ticks $dx 0
    $F.y move ticks 0 $dy
    $F.y1 move ticks 0 $dy
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
