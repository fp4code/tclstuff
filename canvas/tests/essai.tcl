#!/bin/sh
# \
exec wish "$0" ${1+"$@"}

package require fidev
package require fidev_zinzout 1.0

for {set ix 0} {$ix < 100} {incr ix} {
    for {set iy 0} {$iy < 100} {incr iy} {
        set LINES(r${ix}_${iy}_1) [list [expr {200*$ix +   0}] [expr {200*$iy +   0}] [expr {200*$ix + 100}] [expr {200*$iy +   0}]]
        set LINES(r${ix}_${iy}_2) [list [expr {200*$ix + 100}] [expr {200*$iy +   0}] [expr {200*$ix + 100}] [expr {200*$iy + 100}]]  
        set LINES(r${ix}_${iy}_3) [list [expr {200*$ix + 100}] [expr {200*$iy + 100}] [expr {200*$ix +   0}] [expr {200*$iy + 100}]]  
        set LINES(r${ix}_${iy}_4) [list [expr {200*$ix +   0}] [expr {200*$iy + 100}] [expr {200*$ix +   0}] [expr {200*$iy +   0}]]
    }
}

proc trace {c argument} {
    
    global LINES

    set scale [::fidev::zinzout::getScale $c]
    foreach {xmin ymin xmax ymax} [::fidev::zinzout::getLimits $c] {}

    puts [list trace : $c $argument -> $scale $xmin $ymin $xmax $ymax]
    
    $c create line {0 0 100 100} -tag f1_1
    $c create line {100 100 100 90} -tag f1_2
    $c create line {100 100 90 100} -tag f1_3
    
    set xmin0 [expr {$xmin*$scale}]
    set ymin0 [expr {-$ymax*$scale}]
    set xmax0 [expr {$xmax*$scale}]
    set ymax0 [expr {-$ymin*$scale}]
    
    set pixel 1.0

    set xmin [expr {$xmin0}]
    set ymin [expr {$ymin0}]
    set xmax [expr {$xmax0}]
    set ymax [expr {$ymax0}]

    $c create line $xmin $ymin $xmax $ymin -fill red -width 0
    $c create line $xmax $ymin $xmax $ymax -fill red -width 0
    $c create line $xmax $ymax $xmin $ymax -fill red -width 0
    $c create line $xmin $ymax $xmin $ymin -fill red -width 0
    
    set xmin [expr {$xmin0 - $pixel}] 
    set ymin [expr {$ymin0 - $pixel}]
    set xmax [expr {$xmax0 + $pixel}]
    set ymax [expr {$ymax0 + $pixel}]

    $c create line $xmin $ymin $xmax $ymin -fill black -width 0
    $c create line $xmax $ymin $xmax $ymax -fill black -width 0
    $c create line $xmax $ymax $xmin $ymax -fill black -width 0
    $c create line $xmin $ymax $xmin $ymin -fill black -width 0

    set xmin [expr {$xmin0 + $pixel}]
    set ymin [expr {$ymin0 + $pixel}]
    set xmax [expr {$xmax0 - $pixel}]
    set ymax [expr {$ymax0 - $pixel}]

    $c create line $xmin $ymin $xmax $ymin -fill black -width 0
    $c create line $xmax $ymin $xmax $ymax -fill black -width 0
    $c create line $xmax $ymax $xmin $ymax -fill black -width 0
    $c create line $xmin $ymax $xmin $ymin -fill black -width 0

    set xmin [expr {$xmin0 + 2.0*$pixel}]
    set ymin [expr {$ymin0 + 2.0*$pixel}]
    set xmax [expr {$xmax0 - 2.0*$pixel}]
    set ymax [expr {$ymax0 - 2.0*$pixel}]

    $c create line $xmin $ymin $xmax $ymin -fill blue -width 0
    $c create line $xmax $ymin $xmax $ymax -fill blue -width 0
    $c create line $xmax $ymax $xmin $ymax -fill blue -width 0
    $c create line $xmin $ymax $xmin $ymin -fill blue -width 0

    set xmin [expr {$xmin0 + 3*$pixel}]
    set ymin [expr {$ymin0 + 3*$pixel}]
    set xmax [expr {$xmax0 - 3*$pixel}]
    set ymax [expr {$ymax0 - 3*$pixel}]

    $c create line $xmin $ymin $xmax $ymin -fill green -width 0
    $c create line $xmax $ymin $xmax $ymax -fill green -width 0
    $c create line $xmax $ymax $xmin $ymax -fill green -width 0
    $c create line $xmin $ymax $xmin $ymin -fill green -width 0

    set xmin [expr {$xmin*0.5}]
    set ymin [expr {$ymin*0.5}]
    set xmax [expr {$xmax*0.5}]
    set ymax [expr {$ymax*0.5}]

    $c create line $xmin $ymin $xmax $ymin -fill black -width 0
    $c create line $xmax $ymin $xmax $ymax -fill black -width 0
    $c create line $xmax $ymax $xmin $ymax -fill black -width 0
    $c create line $xmin $ymax $xmin $ymin -fill black -width 0

    upvar #0 [::fidev::zinzout::getObjwrittenVar $c] objwritten
    foreach tag [array names LINES] {
        set line $LINES($tag)
        set x1 [expr {$scale*[lindex $line 0]}]
        set y1 [expr {-$scale*[lindex $line 1]}]
        set x2 [expr {$scale*[lindex $line 2]}]
        set y2 [expr {-$scale*[lindex $line 3]}]

        $c create line $x1 $y1 $x2 $y2 -fill red -width 0 -tag $tag

	incr objwritten
 	if {$objwritten % 10000 == 0} {
	    puts stderr $objwritten
	    if {[::fidev::zinzout::winUpdate $c]} {
		puts stderr "STOP !"
		break
	    }
	}
    }
}

proc cloclo {c x y} {
    set echelle [::fidev::zinzout::getScale $c]
    set xx [$c canvasx $x]
    set yy [$c canvasy $y]

    puts stderr "\ncloclo $x $y -> $xx $yy"

    set xxx [expr $xx/$echelle]
    set yyy [expr -$yy/$echelle]
    puts [list cloclo $c $x $y -> $xx $yy -> $xxx $yyy]
    set x1 [$c canvasx [expr $x - 2]]
    set y1 [$c canvasy [expr $y - 2]]
    set x2 [$c canvasx [expr $x + 2]]
    set y2 [$c canvasy [expr $y + 2]]
    set elems [$c find overlapping $x1 $y1 $x2 $y2]
    puts "\ncloclo $x1 $y1 $x2 $y2 : $elems"
    foreach e $elems {
        puts [list cloclo $e : [$c itemcget $e -fill] [$c coords $e] [$c gettags $e]]
    }
}

set c [::fidev::zinzout::create . trace dummy \
                                -actionSelect cloclo \
                                -xCenter 500 \
                                -yCenter 200 \
                                -scale 0.1]

