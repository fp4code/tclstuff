set rien {

        set Z {ComplexXY -9.85 0.15}

	foreach {f f1} [::zerosComplexes::eqvptm 1 $eps1 $eps2 $d1N $d2N $kx0N $Z] {}
	set dz [::complexes::div\
		[::complexes::newXY [expr {-[::complexes::re $f]}] 0.0]\
		$f1]
	set dzm [::complexes::module $dz]
	if {$dzm > $dl} {
	    error "rattrapage trop grand"
	}
	puts "$dz $Z -> $f $f1"
	set Z [::complexes::add $Z $dz]
}

set rien {
proc beginZoom {wname x y} {
    set F [winfo parent $wname]
    upvar #0 graphPriv$F G
    
    set G(b1Start_X) [$wname canvasx $x]
    set G(b1Start_Y) [$wname canvasy $y]
}

proc bind_zoom {F} {
    upvar #0 graphPriv$F G
    
    bind $F.c <Button-1> [namespace code {beginZoom %W %x %y}]
    bind $F.c <Button1-Motion> [namespace code {winZoom %W %x %y}]
    bind $F.c <ButtonRelease-1> [namespace code {zoom %W}]
}

proc winZoom {wname x y} {
    set F [winfo parent $wname]
    upvar #0 graphPriv$F G
    
    set x [$wname canvasx $x]
    set y [$wname canvasy $y]
    $F.c delete zoomrect
    $F.c create rectangle $G(b1Start_X) $G(b1Start_Y) $x $y -tags zoomrect
}

proc zoom {wname} {
    set F [winfo parent $wname]
    upvar #0 graphPriv$F G
    set bb [$F.c coords zoomrect] ;# les coords sont réarangées
    $F.c delete zoomrect
    puts $bb
    recadre $F $bb
}

proc recadre {F bb} {
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
    if {abs($fx) < abs($fy)} {
	set f $fx
    } else {
	set f $fy
    }
    set xmin [expr $xmin*$f]
    set xmax [expr $xmax*$f]
    set ymin [expr $ymin*$f]
    set ymax [expr $ymax*$f]
    $F.c scale all 0 0 $f $f
}


bind_zoom .f
}

proc zp2 {} {
    global ZOOM XNm XNp YNm YNp
    .f.c scale all 0 0 2. 2.
    set ZOOM [expr {2.0*$ZOOM}]
    foreach {c1 c2} [.f.c xview] {}
    set x [expr {0.75*$c1 + 0.25*$c2}]
    foreach {c1 c2} [.f.c yview] {}
    set y [expr {0.75*$c1 + 0.25*$c2}]
    .f.c configure -scrollregion [list [expr {2.0*$XNm*$ZOOM}] [expr {-2.0*$YNp*$ZOOM}] [expr {2.0*$XNp*$ZOOM}] [expr {-2.0*$YNm*$ZOOM}]]
    .f.c xview moveto $x
    .f.c yview moveto $y
}

proc zs2 {} {
    global ZOOM XNm XNp YNm YNp
    .f.c scale all 0 0 0.5 0.5
    set ZOOM [expr {0.5*$ZOOM}]
    foreach {c1 c2} [.f.c xview] {}
    set x [expr {1.5*$c1 - 0.5*$c2}]
    foreach {c1 c2} [.f.c yview] {}
    set y [expr {1.5*$c1 - 0.5*$c2}]
    .f.c configure -scrollregion [list [expr {2.0*$XNm*$ZOOM}] [expr {-2.0*$YNp*$ZOOM}] [expr {2.0*$XNp*$ZOOM}] [expr {-2.0*$YNm*$ZOOM}]]
    .f.c xview moveto $x
    .f.c yview moveto $y
}
