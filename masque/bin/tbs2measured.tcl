#!/bin/sh
# the next line restarts using expect \
exec wish "$0" "$@"

# paquetages nécessaires

package require fidev
package require fidev_zinzout
package require tbs2
package require superTable

# procédure de trace dans le canvas

proc displayProc {canvas args} {
    upvar #0 ::fidev::zinzout::[winfo parent $canvas] G
    global ::tbs2::contourMasque

    # tableau des bons
    
    global GOOD

    # parray G
    # puts $args

    $canvas delete all

    # trace du contour

    set contour [list]
    foreach {x y} $::tbs2::contourMasque {
        lappend contour [expr {$G(echelle)*$x}] [expr {-$G(echelle)*$y}]
    }
    $canvas create line $contour -fill green

    # balayage des blocs

    foreach bloc $::tbs2::blocTbs {
        set xb [expr {[string index $bloc 1]*2000.}]
        set yb [expr {-[string index $bloc 0]*2000.}]
        set xb1 [expr {$G(echelle)*($xb-200.)}]
        set xb2 [expr {$G(echelle)*($xb+1700.)}]
        set yb1 [expr {-$G(echelle)*($yb+500.)}]
        set yb2 [expr {-$G(echelle)*($yb-1400.)}]

        # en dehors du bloc -> terminé pour lui

        if {$xb1 > $G(xmaxP)} continue
        if {$yb1 > $G(ymaxP)} continue
        if {$xb2 < $G(xminP)} continue
        if {$yb2 < $G(yminP)} continue

        # contour du bloc

        $canvas create rectangle $xb1 $yb1 $xb2 $yb2 -outline red

        # échelle trop petite -> terminé pour le bloc

        if {$G(echelle) < 0.01} continue

        # coordonnées lico du bloc

        $canvas create text [expr {$xb1 + 2}] [expr {$yb1 + 2}]\
                -text $bloc -anchor nw -fill red -font fonfon

        # balayage des dispos

        foreach ABC {A B C} {
            foreach dispo {8x27 5x10 5x54 5x7 5x40 6x20 5x17 7x45} {
                
                # nom symbolique
                
                set symDes $bloc$ABC$dispo
                
                # position en microns
                
                foreach {x y} [::tbs2::symDesToPos $symDes] {}
                
                # position en pixels
                
                set x [expr {$G(echelle)*$x}]
                set y [expr {-$G(echelle)*$y}]
                
                if {[info exists GOOD($symDes)]} {
                    
                    # si le dispo est classé comme bon, on trace un rectangle,
                    # avec les caractéristiques données dans GOOD($symDes)
                    
                    set x1 [expr {$x - 200*$G(echelle)}]
                    set x2 [expr {$x + 200*$G(echelle)}]
                    set y1 [expr {$y - 100*$G(echelle)}]
                    set y2 [expr {$y + 100*$G(echelle)}]
                    eval [list $canvas create rectangle $x1 $y1 $x2 $y2\
                            -tag [list good $symDes [string range $symDes 3 end]]]\
                            $GOOD($symDes)
                    
                    # si l'échelle n'est pas trop petite, on trace le nom du dispo
                    
                    if {$G(echelle) > 0.04} {
                        $canvas create text $x $y -text [string range $symDes 3 end] -anchor center -font fonfon
                    }
                } else {
                    
                    # si le dispo n'est pas bon, on trace une croix
                    
                    set x1 [expr {$x - 1}]
                    set x2 [expr {$x + 1}]
                    set y1 [expr {$y - 1}]
                    set y2 [expr {$y + 1}]
                    $canvas create line $x1 $y1 $x2 $y2 -capstyle projecting
                    $canvas create line $x1 $y2 $x2 $y1 -capstyle projecting
                }
            }
        }
    }
}   

# procédure de clic dans le canvas

proc actionSelect {canvas x y} {
    set echelle [::fidev::zinzout::getScale $canvas]
    set xx [expr [$canvas canvasx $x]/$echelle]
    set yy [expr [$canvas canvasy $y]/$echelle]
    set x1 [$canvas canvasx [expr $x - 2]]
    set y1 [$canvas canvasy [expr $y - 2]]
    set x2 [$canvas canvasx [expr $x + 2]]
    set y2 [$canvas canvasy [expr $y + 2]]
    set elems [$canvas find overlapping $x1 $y1 $x2 $y2]
    foreach e $elems {
        puts [$canvas gettags $e]
    }
}

# vérification des arguments

if {$argc < 2} {
    puts stderr "syntaxe: $argv0 fichier_mparams.spt ...fichiers..."
    exit 22
}

# lecture de mparams...tcl

source [lindex $argv 0]

#  (élimination de ".spt")

set lili [list]
foreach dir [lrange $argv 1 end] {
    eval lappend lili [file rootname [file tail $dir]]
}

foreach li $lili {
    set GOOD($li) [list -fill green -outline green]
}

# création du canvas interactif

font create fonfon -size 8 -family {lucida sans}
::fidev::zinzout::create . displayProc {} -actionSelect actionSelect -scale 0.02 -xCenter 8000. -yCenter -8000. -width 600 -height 600




