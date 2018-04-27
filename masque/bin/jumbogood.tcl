#!/bin/sh
# the next line restarts using wish \
exec wish "$0" ${1+"$@"}

# paquetages nécessaires

package require fidev
package require fidev_zinzout
package require superTable

# procédure de trace dans le canvas

proc displayProc {canvas args} {
    upvar #0 ::fidev::zinzout::[winfo parent $canvas] G
    global ::masque::contourMasque

    # tableau des bons
    
    global GOOD

    # parray G
    # puts $args

    $canvas delete all

    # trace du contour

    set contour [list]
    foreach {x y} $::masque::contourMasque {
        lappend contour [expr {$G(echelle)*$x}] [expr {-$G(echelle)*$y}]
    }
    $canvas create line $contour -fill green

    for {set co 0} {$co < 10} {incr co} {
        for {set li 0} {$li < 9} {incr li} {
            set dispo $li$co
            set symDes $li$co
            
            # position en microns
            
            foreach {x y} [::masque::symDesToPos $symDes] {}
            
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
                        -tag [list good $symDes $symDes]]\
                        $GOOD($symDes)
                
                # si l'échelle n'est pas trop petite, on trace le nom du dispo
                
                puts $G(echelle)
                if {$G(echelle) > 0.04} {
                    $canvas create text $x $y -text $symDes -anchor center -font fonfon
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

# procédure de clic dans le canvas

proc actionSelect {canvas x y} {
    set echelle [::fidev::zinzout::getScale $canvas]
    set xx [expr {[$canvas canvasx $x]/$echelle}]
    set yy [expr {[$canvas canvasy $y]/$echelle}]
    set x1 [$canvas canvasx [expr {$x - 2}]]
    set y1 [$canvas canvasy [expr {$y - 2}]]
    set x2 [$canvas canvasx [expr {$x + 2}]]
    set y2 [$canvas canvasy [expr {$y + 2}]]
    set elems [$canvas find overlapping $x1 $y1 $x2 $y2]
    foreach e $elems {
        puts [$canvas gettags $e]
    }
}

# vérification des arguments

if {$argc != 2} {
    puts stderr "syntaxe: $argv0 fichier_mparams.tcl fichier_good.spt"
    exit 22
}

# lecture de mparams...tcl

source [lindex $argv 0]

# lecture de la table, indexée pas le numéro de ligne

set name "*"
set lili [lindex [superTable::fileToTable tata [lindex $argv 1] name {}] 0]

# récupération dans la colonne "fichier" du nom de dispo (élimination de ".spt")

foreach li $lili {
    set GOOD([string range $tata([list $li fichier]) 0 end-4]) [list -fill green -outline green]
}

# création du canvas interactif

font create fonfon -size 8 -family {lucida sans}
::fidev::zinzout::create . displayProc {} -actionSelect actionSelect -scale 0.02 -xCenter 8000. -yCenter -8000. -width 600 -height 600




