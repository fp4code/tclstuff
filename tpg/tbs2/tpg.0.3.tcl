package provide tpg 0.3

package require fidev
package require fidev_zinzout 1.0

puts [info globals]
puts [info script]

source Point.tcl
source Chemin.tcl
source Struct.tcl

set tcl_traceCompile 0
set tcl_traceExec 0
set DEBUG 0

        ############
        #          #
        # boundary #
        #          #
        ############

set Aide(boundary) {
    fait partie d'une structure gérée par un tableau "struct"
    - (SUPPRIME) element "B,$id" de la liste $struct(id)
    - element "$id" de la liste $struct(id,B)
    - chemin struct(B,$id)
    - valeurs struct(layer,B,$id) struct(datatype,B,$id)
    - valeurs struct(xmin,B,$id) struct(xmax,B,$id) struct(ymin,B,$id) struct(ymax,B,$id)
    - influence struct(xmin) struct(xmax) struct(ymin) struct(ymax)
}


        ############
        #          #
        #   sref   #
        #          #
        ############

set Aide(sref) {
    fait partie d'une structure gérée par un tableau "struct"
    - element "$rname" de la liste $struct(rn,S)
    - element "$id" de la liste $struct(id,S,$rname)
    - SUPPRIME element "S,$rname,$id" de la liste $struct(id)
    - coordonnees {x y} struct(S,$rname,$id)
    - valeurs des positions extrèmes de tous les sref d'une même structure
        struct(xmin,S,$rname) struct(xmax,S,$rname) struct(ymin,S,$rname) struct(ymax,S,$rname)
    - influence struct(xmin) struct(xmax) struct(ymin) struct(ymax)
}

proc ::tpg::boundary {arg} {
    global enCours 
    Struct::newBoundary $enCours(sname) [Chemin::newFromString $arg] $enCours(layer) $enCours(datatype)
}

proc ::tpg::bfc {arg} {
    global enCours 
# puts $arg
    Struct::newBoundary $enCours(sname) $arg $enCours(layer) $enCours(datatype)
}

proc ::tpg::sref {name x y} {
    global enCours 
    Struct::newSref $enCours(sname) $name $x $y
}
    
proc ::tpg::brxy {x0 y0 dx dy} {
    global enCours
    set x1 [expr $x0 + $dx]
    set y1 [expr $y0 + $dy]
    Struct::newBoundary $enCours(sname) [Chemin::new $x0 $y0 E \
                                      $x1 $y0 E \
                                      $x1 $y1 E \
                                      $x0 $y1 E \
                                      $x0 $y0] \
                                $enCours(layer) $enCours(datatype)
}

proc ::tpg::brc {xs2 ys2} {
    global enCours
    Struct::newBoundary $enCours(sname) [Chemin::rectangleCentre $xs2 $ys2] \
                                $enCours(layer) $enCours(datatype)
}


proc ::tpg::afficheBoundary {c hier sname id echelle x y} {
    upvar #0 [::fidev::zinzout::getObjwrittenVar $c] objwritten
    if {![winfo exists $c]} {
        return 0
    }
    upvar #0 S,$sname struct
    
    set chemin $struct(B,$id)
    set x1 [lindex $chemin 0]
    set y1 [lindex $chemin 1]
    set x1 [expr ($x1+$x)*$echelle]
    set y1 [expr -($y1+$y)*$echelle]
    set iseg 0
    foreach {q x2 y2} [lrange $chemin 2 end] {
        set x2 [expr ($x2+$x)*$echelle]
        set y2 [expr -($y2+$y)*$echelle]
        if {$q == "I"} {
            set color red
        } elseif {$q == "E"} {
            set color blue
        }
        $c create line $x1 $y1 $x2 $y2 -fill $color -width 0 -tags [list Boundary $id,$iseg S,$sname L,$struct(layer,B,$id) D,$struct(datatype,B,$id) Q,$q]
        incr objwritten
        if {$objwritten % 1000 == 0 && [::fidev::zinzout::winUpdate $c]} {
            return 1
        }
        set x1 $x2
        set y1 $y2
        incr iseg
    }
    return 0
}



proc ::tpg::displayWinStruct {sname echelle} {
    upvar #0 S,$sname struct

    if {[winfo exists .s:$sname]} {
        destroy .s:$sname
    }
    set win [toplevel .s:$sname]
    set c [canvas $win.c]
    set sx [scrollbar $win.sx -orient horizontal]
    set sy [scrollbar $win.sy -orient vertical]
    grid configure $sy $c
    grid configure x   $sx
    grid configure $sy -sticky ns
    grid configure $sx -sticky ew
    grid configure $c -sticky ewns
    grid columnconfigure $win 1 -weight 1
    grid rowconfigure $win 0 -weight 1
    
    
#    pack $c -fill both -expand 1
    $c create line -100000 0 100000 0 -fill yellow
    $c create line 0 -100000 0 100000 -fill yellow
    if {$struct(xmin) == {}} {
        error "structure \"$sname\" probablement vide"
    }
    set xmin $struct(xmin)
    set ymin $struct(ymin)
    set xmax $struct(xmax)
    set ymax $struct(ymax)

    set xminP [expr  $xmin * $echelle]
    set xmaxP [expr  $xmax * $echelle]
    set yminP [expr -$ymax * $echelle]
    set ymaxP [expr -$ymin * $echelle]
    $c configure -scrollregion [list [expr $xminP - 10] [expr $yminP - 10] \
                                     [expr $xmaxP + 10] [expr $ymaxP + 10]]
    $c configure -xscrollcommand "$win.sx set" -yscrollcommand "$win.sy set"
    $sx configure -command "$win.c xview"
    $sy configure -command "$win.c yview"
    $c xview moveto 0
    $c yview moveto 0
    update
    
    upvar #0 tpg::$c G
    #    if {[info exists G]} {
#        unset G
#    }
    set G(objwritten) 0
       
    
    displayStruct $c {} $sname {} $echelle 0 0  $xmin $ymin $xmax $ymax
    bind .s:$sname <Destroy> {puts "do not"}
    bind $c <ButtonPress> {tpg::cloclo %W %x %y}
#    bind $c <ButtonPress> {bpd %W %x %y}
#    bind $c <ButtonRelease> {brd %W}
    $c lower Sref
}

proc ::tpg::displayWinStruct2 {sname xCenterA yCenterA echelle {dxP 400} {dyP 400}} {
    set structName S,$sname
    upvar #0 $structName struct
puts "tpg::displayWinStruct2 $sname $xCenterA $yCenterA $echelle $dxP $dyP"

    set win .s:$sname
    
if {[winfo exists $win]} {
        raise $win
    } else {
        set win [toplevel $win]
    }
    
    set canvas [::fidev::zinzout::create $win ::tpg::displayWinProc2 $sname \
                                -actionSelect tpg::cloclo \
                                -xCenter $xCenterA \
                                -yCenter $yCenterA \
                                -scale $echelle]
    
    if {$struct(xmin) == {}} {
        error "structure \"$sname\" probablement vide"
    }
        
#    tpg::displayWinProc2 $canvas $sname
}

proc ::tpg::displayWinProc2 {canvas sname} {
    

    foreach {xmin ymin xmax ymax} [::fidev::zinzout::getLimits $canvas] {}
    set echelle [::fidev::zinzout::getScale $canvas]

puts "tpg::displayWinProc2 : $echelle $xmin $ymin $xmax $ymax"
    if {[displayStruct $canvas {} $sname {} $echelle 0 0 $xmin $ymin $xmax $ymax] != 0} {
puts "retourne 1"
        return 1
    }
    $canvas lower Sref
    return 0
}

proc ::tpg::cloclo {c x y} {
    set echelle [::fidev::zinzout::getScale $c]
    set xx [expr [$c canvasx $x]/$echelle]
    set yy [expr [$c canvasy $y]/$echelle]
    puts "    cloclo en $xx $yy"
    set x1 [$c canvasx [expr $x - 2]]
    set y1 [$c canvasy [expr $y - 2]]
    set x2 [$c canvasx [expr $x + 2]]
    set y2 [$c canvasy [expr $y + 2]]
    set elems [$c find overlapping $x1 $y1 $x2 $y2]
    puts "\n$x1 $y1 $x2 $y2 : $elems"
    foreach e $elems {
        puts "  $e : [$c gettags $e]"
    }
}

#####################################################

set enCours(layer) 0
set enCours(datatype) 0

proc setLayer {layer} {
    global enCours
    set enCours(layer) $layer
}

proc setDose {dose} {
    global datatype
    set enCours(datatype) $dose
}

proc bpd {win x y} {
    $win scan mark $x $y
    bind $win <Motion> {%W scan dragto %x %y}
}

proc brd {win} {
    bind $win <Motion> {}
}

set HELP(displayStruct) {
    affiche dans la fenetre $c la structure $sname,
    appelée depuis la hiérarchie de structures $hier.
    L'échelle est $echelle et la position relative
    de la structure est $x et $y
    La zone à dessiner est définie par $xminA $yminA $xmaxA $ymaxA
    (en coordonnées GDS-II)
}
proc tpg::displayStruct {canvas hier sname rid echelle x y xminA yminA xmaxA ymaxA} {
    upvar #0 S,$sname struct
    upvar #0 [::fidev::zinzout::getObjwrittenVar $canvas] objwritten
global DEBUG
if {$DEBUG} {
puts "-> $sname x,y=$x $y mA=$xminA $yminA $xmaxA $ymaxA $hier"
}
    
   # mise à jour de "hier"
    if {$hier == {}} {
        set hier $sname
    } else {
        append hier ,$sname,$rid
    }
   # 
    
    
    set xminR [expr $xminA - $x]
    set yminR [expr $yminA - $y]
    set xmaxR [expr $xmaxA - $x]
    set ymaxR [expr $ymaxA - $y]
    if {$DEBUG} {
puts "    mR = $xminR $yminR $xmaxR $ymaxR"
}   
    set xmin $struct(xmin)
    set ymin $struct(ymin)
    set xmax $struct(xmax)
    set ymax $struct(ymax)
    
    if {$xmax < $xminR || $ymax < $yminR || $xmaxR < $xmin || $ymaxR < $ymin} {
	if {$DEBUG} {
puts "    rien à tracer : $xmax < $xminR || $ymax < $yminR || $xmaxR < $xmin || $ymaxR < $ymin"
}
        return
    }
    
    set xminP [expr  ($x + $xmin) * $echelle]
    set yminP [expr -($y + $ymax) * $echelle]
    set xmaxP [expr  ($x + $xmax) * $echelle]
    set ymaxP [expr -($y + $ymin) * $echelle]
    $canvas create rectangle $xminP $yminP $xmaxP $ymaxP -outline brown -tags [list Outline S,$sname]

   # affichage des boundaries
    foreach id $struct(id,B) {
        set obj B,$id
        set xmin $struct(xmin,$obj)
        set ymin $struct(ymin,$obj)
        set xmax $struct(xmax,$obj)
        set ymax $struct(ymax,$obj)
        if {$xmax < $xminR || $ymax < $yminR || $xmaxR < $xmin || $ymaxR < $ymin} {
	    if {$DEBUG} {
puts "    B $id NON : $xmax < $xminR || $ymax < $yminR || $xmaxR < $xmin || $ymaxR < $ymin"
}
            continue
        }
        set xminP [expr  ($x + $xmin) * $echelle]
        set yminP [expr -($y + $ymax) * $echelle]
        set xmaxP [expr  ($x + $xmax) * $echelle]
        set ymaxP [expr -($y + $ymin) * $echelle]

       # test de la dimension d'affichage du boundary
        if {($xmaxP - $xminP > 4) && ($ymaxP - $yminP > 4)} {
          # pas trop petite : on l'affiche
	    if {$DEBUG} {
puts "    B $id afficheBoundary"
}
if {[afficheBoundary $canvas $hier $sname $id $echelle $x $y]} {
                return 1
            }
        } else {
           # trop petite : on affiche l'encombrement
	    if {$DEBUG} {
puts "    B $id encombrement"
}
            $canvas create rectangle $xminP $yminP $xmaxP $ymaxP \
                    -fill blue -tags [list Boundary $id S,$sname L,$struct(layer,$obj) D,$struct(datatype,$obj)]
           # "update" permet de reprendre la main tous les N dessins
            incr objwritten
            if {$objwritten % 1000 == 0 && [::fidev::zinzout::winUpdate $canvas]} {
                return 1
            }
        }
    }

#    foreach rname [array names struct id,S,*] { ATTENTION ne jamais laisser ce { sans } } 
#        set rname [string range $rname 5 end]
  # affichage des structures référencées
    foreach rname $struct(rn,S) {
        upvar #0 S,$rname sref
        if {$sref(xmin) == {}} {
	    if {$DEBUG} {puts "    $rname non initialisé"}
           # xmin n'est pas initialisé et les autres (ymin, xmax, ymax) non plus
           # les structures référencées n'existent donc pas actuellement,
           # on dessine seulement leur emplacement
            foreach id $struct(id,S,$rname) {
                foreach {xs ys} $struct(S,$rname,$id) {}
                if {$xs < $xminR || $ys < $yminR || $xmaxR < $xs || $ymaxR < $ys} {
                    continue
                }
                set xsP [expr  ($x + $xs) * $echelle]
                set ysP [expr -($y + $ys) * $echelle]
                $canvas create line \
                    [expr $xsP - 5] [expr -$ysP] [expr $xsP + 5] [expr -$ysP] \
                        -fill blue -tags [list Sref $id S,$sname]
                    [expr $xsP] [expr -$ysP - 5] [expr $xsP] [expr -$ysP + 5] \
                        -fill blue -tags [list Sref $id S,$sname]
               # "update" permet de reprendre la main tous les N dessins
                incr objwritten
                if {$objwritten % 1000 == 0 && [::fidev::zinzout::winUpdate $canvas]} {
                    return 1
                }
            }
        } else {
            set xsmin [expr $xminR - $sref(xmax)]
            set ysmin [expr $yminR - $sref(ymax)]
            set xsmax [expr $xmaxR - $sref(xmin)]
            set ysmax [expr $ymaxR - $sref(ymin)]
	    if {$DEBUG} {
puts "    [format %-16s $rname] : $sref(xmin) $sref(ymin) $sref(xmax) $sref(ymax)"
puts "                   R : $xminR $yminR $xmaxR $ymaxR"
puts "                 xsm : $xsmin $ysmin $xsmax $ysmax"
}
       # test de la dimension d'affichage de la structure référencée
            if {(($sref(xmax) - $sref(xmin)) * $echelle > 4) && (($sref(ymax) - $sref(ymin)) * $echelle > 4)} {
               # structure référencée assez grande : on affiche son contenu
		if {$DEBUG} {
puts "        contenu"
}
                foreach id $struct(id,S,$rname) {
                    set obj S,$rname,$id
                    foreach {xs ys} $struct(S,$rname,$id) {}
		    if {$DEBUG} {
puts "                 xs  : $xs $ys"
puts "                 x   : $x $y"
}
                   if {$xs < $xsmin || $ys < $ysmin || $xsmax < $xs || $ysmax < $ys} {
		       if {$DEBUG} {
puts "                 NON"
}
                        continue
                    }
		    if {$DEBUG} {
puts "                 OUI"
puts "                 A   : $xminA $yminA $xmaxA $ymaxA"
}
                    set xminP [expr  ($x + $xs + $sref(xmin)) * $echelle]
                    set yminP [expr -($y + $ys + $sref(ymax)) * $echelle]
                    set xmaxP [expr  ($x + $xs + $sref(xmax)) * $echelle]
                    set ymaxP [expr -($y + $ys + $sref(ymin)) * $echelle]
                    $canvas create rectangle $xminP $yminP $xmaxP $ymaxP \
                        -outline brown -tags [list Outline Sref $id S,$sname]
                    incr objwritten
                    if {$objwritten % 1000 == 0 && [::fidev::zinzout::winUpdate $canvas]} {
                        return 1
                    }
                    if {[displayStruct $canvas $hier $rname $id $echelle [expr $x + $xs] [expr $y + $ys] $xminA $yminA $xmaxA $ymaxA]} {
                        return 1
                    }
                }
            } else {
		if {$DEBUG} {
puts "        encombrement"
}
               # structure référencée s'affiche trop petite : on affiche l'encombrement
                foreach id $struct(id,S,$rname) {
                    set obj S,$rname,$id
                    foreach {xs ys} $struct(S,$rname,$id) {}
		    if {$DEBUG} {
puts "                 xs  : $xs $ys"
puts "                 x   : $x $y"
}
                    if {$xs < $xsmin || $ys < $ysmin || $xsmax < $xs || $ysmax < $ys} {
			if {$DEBUG} {puts "            NON : $xs < $xsmin || $ys < $ysmin || $xsmax < $xs || $ysmax < $ys"}
                        continue
                    }
		    if {$DEBUG} {puts "            OUI"}
                    set xminP [expr ($x + $xs + $sref(xmin)) * $echelle]
                    set yminP [expr -($y + $ys + $sref(ymax)) * $echelle]
                    set xmaxP [expr  ($x + $xs + $sref(xmax)) * $echelle]
                    set ymaxP [expr -($y + $ys + $sref(ymin)) * $echelle]
                    $canvas create rectangle $xminP $yminP $xmaxP $ymaxP \
                            -fill blue -tags [list Outline Sref $id S,$sname]
                    incr objwritten
                    if {$objwritten % 1000 == 0 && [::fidev::zinzout::winUpdate $canvas]} {
                        return 1
                    }
                }
            }
        }
    }
    return 0
}



set HELP(tpg::appendArc) {
q : qualité
ad : angle de départ
af : angle de fin
nseg : nombre de segments
x y : centre
r :rayon
}


namespace eval tpg {
    proc anneau {ri re x y ns2} {
        set c [Chemin::new [expr $x + $re] $y]
        Chemin::appendArc c E 0 180 $ns2 $x $y $re
        Chemin::appendPoint c I [expr -$ri] 0
        Chemin::appendArc c E 180 0 $ns2 $x $y $ri
        Chemin::appendPoint c I [expr $x + $re] $y
        Chemin::supprimeDoubles c
        bfc $c
        Chemin::transform c miroir.axex
        bfc $c
    }
}


namespace eval tpg::Vector {
    proc normalise {x y} {
        set mod [expr sqrt($x*$x + $y*$y)]
        if {$mod == 0.0} {
            error "vecteur nul"
        }
        return [list [expr $x/$mod] [expr $y/$mod]]
    }
    
    proc getDir {x y} {
        if {$y > 0} {
            if {$x > 0} {
                if {$x > $y} {
                    return 1
                } elseif {$x == $y} {
                    return 2
                } else {
                    return 3 
                }
            } elseif {$x == 0} {
                return 4
            } else {
                if {-$x < -$y} {
                    return 5
                } elseif {-$x == $y} {
                    return 6
                } else {
                    return 7
                }
            }
        } elseif {$y == 0} {
            if {$x > 0} {
                return 0
            } elseif {$x == 0} {
                error "Vecteur nul"
            } else {
                return 8
            }
        } else {
            if {$x < 0} {
                if {$x < $y} {
                    return 9
                } elseif {$x == $y} {
                    return 10
                } else {
                    return 11
                }
            } elseif {$x == 0} {
                return 12
            } else {
                if {$x < -$y} {
                    return 13
                } elseif {$x == -$y} {
                    return 14
                } else {
                    return 15
                }
            }
        }
    }

    proc isExactDir {dir} {
        return [expr ($dir % 2) == 0]
    }


}

puts stderr "tpg is sourced"

proc displayChemin {chemin {echelle 1}} {

    if {![winfo exists .chemins]} {
        set win [toplevel .chemins]
        set c [canvas $win.c]
        set sx [scrollbar $win.sx -orient horizontal]
        set sy [scrollbar $win.sy -orient vertical]
        grid configure $sy $c
        grid configure x   $sx
        grid configure $sy -sticky ns
        grid configure $sx -sticky ew
        grid configure $c -sticky ewns
        grid columnconfigure $win 1 -weight 1
        grid rowconfigure $win 0 -weight 1
    
        $c create line -100000 0 100000 0 -fill yellow
        $c create line 0 -100000 0 100000 -fill yellow
        $c configure -xscrollcommand "$win.sx set" -yscrollcommand "$win.sy set"
        $sx configure -command "$win.c xview"
        $sy configure -command "$win.c yview"
        bind $win <Destroy> {puts "do not"}
        bind $c <ButtonPress> {bpd %W %x %y}
        bind $c <ButtonRelease> {brd %W}
    } else {
        set win .chemins
        set c $win.c
    }

    foreach {x1 y1 x2 y2 } [tpg::Chemin::minimax $chemin] {
        set xmin [expr $x1*$echelle]
        set ymin [expr -$y2*$echelle]
        set xmax [expr $x2*$echelle]
        set ymax [expr -$y1*$echelle]
    }
    $c configure -scrollregion [list [expr $xmin - 10] [expr $ymin - 10] \
                                     [expr $xmax + 10] [expr $ymax + 10]]
    $c xview moveto 0
    $c yview moveto 0
    $c create rectangle $xmin $ymin $xmax $ymax -outline brown -tags Outline
    update
    
    set x1 [expr [lindex $chemin 0]*$echelle]
    set y1 [expr -[lindex $chemin 1]*$echelle]
    set iseg 0
    foreach {q x2 y2} [lrange $chemin 2 end] {
        set x2 [expr $x2*$echelle]
        set y2 [expr -$y2*$echelle]
        if {$q == "I"} {
            set color red
        } elseif {$q == "E"} {
            set color blue
        }
        $c create line $x1 $y1 $x2 $y2 -fill $color -width 0 -tags [list Chemin $iseg]
        set x1 $x2
        set y1 $y2
        incr iseg
    }
}

    set c [tpg::Chemin::new 100 0]                  ;# Point en bas a gauche
    tpg::Chemin::appendArc c E 180 90 30 400 0 100
    tpg::Chemin::appendPoint c I 400 400
    tpg::Chemin::appendPoint c I 100 400
    tpg::Chemin::appendArc c E 0 -90 30   0 400 100
    tpg::Chemin::appendPoint c I 0 100
    tpg::Chemin::appendArc c E 90  0 30   0   0 100
    tpg::Chemin::appendPoint c I 100 0
# puts "c=$c"
    tpg::Chemin::supprimeDoubles c


set chem [tpg::Chemin::dilated 10 $c]
set chem2 [tpg::Chemin::empated 50 $chem]

displayChemin $chem 0.1
displayChemin $chem2 0.1
