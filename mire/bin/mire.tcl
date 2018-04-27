canvas .c -width 1600 -height 1200
pack .c

set xcentre 100
set ycentre 100
set rayon 100
set pas 20
set PI [expr {atan2(0, -1.)}]

proc mire1 {rayon pas xcentre ycentre} {
    global PI
    set N [expr {360/$pas}]
    for {set i 0} {$i < $N} {incr i} {
	set dx1 [expr {$rayon*cos($pas*$i*$PI/180.)}]
	set dy1 [expr {$rayon*sin($pas*$i*$PI/180.)}]
	set dx2 [expr {$rayon*cos($pas*($i+0.5)*$PI/180.)}]
	set dy2 [expr {$rayon*sin($pas*($i+0.5)*$PI/180.)}]
	.c create polygon [list \
			       $xcentre $ycentre \
			       [expr {$xcentre + $dx1}] [expr {$ycentre + $dy1}] \
			       [expr {$xcentre + $dx2}] [expr {$ycentre + $dy2}] \
			       $xcentre $ycentre] -fill black -outline {}
    }
}

for {set y 100} {$y <1200} {incr y 200} {
    for {set x 100} {$x <1600} {incr x 200} {
	mire1 100 10 $x $y
    }
}