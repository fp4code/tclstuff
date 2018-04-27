set tcl_traceExec 0

canvas .c

pack .c -fill both -expand 1

canvas .cj

pack .cj -fill both -expand 1

set Help(lintersect) {
    Retourne l'ensemble intersection des deux ensembles $l1 et $l2.
    Plus efficace que lintersect.old
    Suggestion de Andreas Mayer <amayer@fzi.de>   1997/07/16
}
proc lintersect {list1 list2} {
    set intersection {}

    foreach element $list1 {
        set flag($element) {}
    }

    foreach element $list2 {
        if {[info exists flag($element)]} {
          lappend intersection $element
        }
    }

    return $intersection
}

set Help(lintersect.old) {
    Retourne l'ensemble intersection des deux ensembles $l1 et $l2.
    Les listes l1 et l2 sont des ensembles et ne doivent donc pas avoir chacune de doublon.
}

proc lintersect.old {l1 l2} {
    set l1 [lsort $l1]
    set l2 [lsort $l2]
    # les listes sont triées
    if {[string compare [lindex $l1 end] [lindex $l2 end]] < 0} {
        set la $l1
        set lb $l2
    } else {
        set la $l2
        set lb $l1
    }
    # (condition 1) Le dernier élément de $lb est supérieur ou égal au dernier élément de $la
    set retour {}
    # la liste de retour est initialisée
    set i 0
    # l'index de balayage de lb est initialisé
    foreach e $la {
       while {[set comp [string compare [lindex $lb $i] $e]] < 0} {
           incr i
       }
       # $i est l'indice du premier élément immédiatement supérieur ou égal à $e
       # Il existe toujours parce que l'on a la condition 1
       if {$comp == 0} {
           lappend retour $e
       }
       # la liste de retour est complétée si $e est en commun
    }
    return $retour
}


proc mparams:translate.old {canvas dx dy tagOrId} {
    if {[string match {[1-9*]} $tagOrId]} {
        set objs $tagOrId
    } else {
        set objs [$canvas find withtag $tagOrId]
    }
    foreach obj $objs {
        set coords [$canvas coords $obj]
        set newCoords {}
        foreach {x y} $coords {
            lappend newCoords [expr ($x + $dx)]
            lappend newCoords [expr ($y + $dy)]
        }
        eval $canvas coords $obj $newCoords
    }
}
proc mparams:yRenverse.old {canvas tagOrId} {
    if {[string match {[1-9*]} $tagOrId]} {
        set objs $tagOrId
    } else {
        set objs [$canvas find withtag $tagOrId]
    }
    foreach obj $objs {
        set coords [$canvas coords $obj]
        set newCoords {}
        foreach {x y} $coords {
            lappend newCoords $x
            lappend newCoords [expr -$y]
        }
        eval $canvas coords $obj $newCoords
    }
}

proc mparams:echelle {canvas scale tagOrId} {
#    set coords [$canvas cget -scrollregion]
#    set newCoords {}
#    foreach c $coords {
#        lappend newCoords [expr $c * $scale]
#    }
#    $canvas configure -scrollregion $newCoords
    $canvas configure -scrollregion [$canvas bbox all]
    if {[string match {[1-9*]} $tagOrId]} {
        set objs $tagOrId
    } else {
        set objs [$canvas find withtag $tagOrId]
    }
    foreach obj $objs {
        set coords [$canvas coords $obj]
        set newCoords {}
        foreach c $coords {
            lappend newCoords [expr $c * $scale]
        }
        eval $canvas coords $obj $newCoords
    }
    scrollConfAll $canvas 20
}

proc poly {canvas echelle coords args} {
    set newCoords {}
    foreach {x y} $coords {
        lappend newCoords [expr $echelle*$x]
        lappend newCoords [expr -$echelle*$y]
    }
    eval $canvas create polygon $newCoords $args
}

proc rect {canvas echelle x1 y1 x2 y2 args} {
    set newCoords {}
    eval $canvas create rectangle [expr $echelle*$x1] [expr -$echelle*$y1] [expr $echelle*$x2] [expr -$echelle*$y2]$newCoords $args
}

proc pad50 {mparamsName dx dy x y tags} {

    upvar $mparamsName mparams

    set x1 [expr $x+$dx]
    set y1 [expr $y+$dy]
    set x2 [expr $x+$dx+50]
    set y2 [expr $y+$dy+50]
#    poly $mparams(canvas0) $mparams(echelle0) [list $x1 $y1 $x2 $y1 $x2 $y2 $x1 $y2] -tags $tags -fill gold
    rect $mparams(canvas0) $mparams(echelle0) $x1 $y1 $x2 $y2 -tags $tags -fill gold -outline {}
}

proc rectangle {mparamsName dx dy x1 y1 x2 y2 tags} {

    upvar $mparamsName mparams

    set x1 [expr $x1+$dx]
    set y1 [expr $y1+$dy]
    set x2 [expr $x2+$dx]
    set y2 [expr $y2+$dy]
    rect $mparams(canvas0) $mparams(echelle0) $x1 $y1 $x2 $y2 -tags $tags -fill {} -outline black
}

proc outline {mparamsName dx dy x1 y1 x2 y2 tags} {

    upvar $mparamsName mparams

    lappend tags Outline
    set x1 [expr $x1+$dx]
    set y1 [expr $y1+$dy]
    set x2 [expr $x2+$dx]
    set y2 [expr $y2+$dy]
    set coords [list $x1 $y1 $x2 $y1 $x2 $y2 $x1 $y2]
#    poly $mparams(canvas0) $mparams(echelle0) $coords -tags $tags -fill {} -outline black
#    poly $mparams(canvas1) $mparams(echelle1) $coords -tags $tags -fill {} -outline black
    rect $mparams(canvas0) $mparams(echelle0) $x1 $y1 $x2 $y2 -tags $tags -fill {} -outline black
    rect $mparams(canvas1) $mparams(echelle1) $x1 $y1 $x2 $y2 -tags $tags -fill {} -outline black
}

proc dispo {mparamsName dx dy x1 y1 x2 y2 tags} {

    upvar $mparamsName mparams

    set x1_0 [expr $mparams(echelle0)*($x1+$dx)+2]
    set y1_0 [expr -$mparams(echelle0)*($y1+$dy)-2]
    set x2_0 [expr $mparams(echelle0)*($x2+$dx)-2]
    set y2_0 [expr -$mparams(echelle0)*($y2+$dy)+2]
    set x1_1 [expr $mparams(echelle1)*($x1+$dx)+2]
    set y1_1 [expr -$mparams(echelle1)*($y1+$dy)-2]
    set x2_1 [expr $mparams(echelle1)*($x2+$dx)-2]
    set y2_1 [expr -$mparams(echelle1)*($y2+$dy)+2]
    $mparams(canvas0) create rectangle $x1_0 $y1_0 $x2_0 $y2_0 -tags $tags -fill {} -outline yellow 
# le bind merdoie
#    $mparams(canvas1) create rectangle $x1_1 $y1_1 $x2_1 $y2_1 -tags $tags -fill {} -outline yellow -fill {}
    $mparams(canvas1) create polygon $x1_1 $y1_1 $x2_1 $y1_1 $x2_1 $y2_1 $x1_1 $y2_1 -tags $tags -fill {} -outline yellow 
}


proc scrollConfAll {win marge} {
    foreach {x y x1 y1} [$win bbox all] {
        $win configure -scrollregion [list [expr $x-$marge]\
                                           [expr $y-$marge]\
                                           [expr $x1+$marge]\
                                           [expr $y1+$marge]]
    }
}



# mparams:echelle $canvas 0.1 all
# mparams:yRenverse $canvas all
# mparams:translate $canvas 20 740 all



set mparams(lastTag) -1

proc passeSur {win} {
    global mparams
    
    set base [winfo parent $win]
    if {$base == "."} {
        set base {}
    }
    set tag [lindex [$base.cj gettags current] 0]
    foreach {mparams(li) mparams(co)} [tagToLiCo $tag] {;# rien}
    selecte $base $tag
}

proc selecte {base tag} {
    global mparams

    $base.c itemconfigure $mparams(lastTag) -outline yellow
    $base.cj itemconfigure $mparams(lastTag) -outline yellow

    set mparams(lastTag) $tag
    
    $base.c itemconfigure $mparams(lastTag) -outline red
    $base.cj itemconfigure $mparams(lastTag) -outline red
    canvas_see $base.c $mparams(lastTag)
    canvas_see $base.cj $mparams(lastTag)
}

proc nextDispo {win dli dco} {
    global mparams
    if {$win == "."} {
        set base {}
    } else {
        sert base $win
    }
    set li [expr $mparams(li)+$dli]
    set co [expr $mparams(co)+$dco]
    while 1 {
        set tag [liCoToTag $li $co]
        set obj [$base.c find withtag $tag]
        if {$obj != {} && (![info exists mparams(etat:[string range $tag 6 end])] || $mparams(etat:[string range $tag 6 end]) != "invalide")} {
            break
        }
        if {$dco == 0 && \
            ( ($dli == 1 && $li < $mparams(liMax)) || \
              ($dli == -1 && $li > $mparams(liMin)))} {
            incr li $dli
            continue
        }
        if {$dli == 0 && $dco == -1} {
            if {$co > $mparams(coMin)} {
                incr co $dco
                continue
            }
            if {$li > $mparams(liMin)} {
                set co $mparams(coMax)
                incr li -1
                continue
            }
        } elseif {$dli == 0 && $dco == 1} {
            if {$co < $mparams(coMax)} {
                incr co $dco
                continue
            }
            if {$li < $mparams(liMax)} {
                set co $mparams(coMin)
                incr li 1
                continue
            }
        }
        bell
        return 0
    }
    set mparams(li) $li
    set mparams(co) $co
    selecte $base $tag
    return 1
}

.cj bind Dispo <Button> "passeSur %W"

bind . <KeyPress-Left> "nextDispo %W 0 -1"
bind . <KeyPress-Right> "nextDispo %W 0 1"
bind . <KeyPress-Up> "nextDispo %W -1 0"
bind . <KeyPress-Down> "nextDispo %W 1 0"


proc canvas_see {c item} {
    set box [$c bbox $item]
puts "$c $box"
    if {[string match {} $box]} return
    if {[string match {} [$c cget -scrollreg]]} {
        error "canvas_see : $c configure -scrollreg ... à faire"
    }
    foreach \
        {x y x1 y1} $box\
        {xvmin xvmax} [$c xview]\
        {yvmin yvmax} [$c yview]\
        {xmin ymin xmax ymax} [$c cget -scrollreg]\
    {
        if {$xvmax - $xvmin == 1.0} {
            $c xview moveto 0.0
        } else {
            set xv [expr double($x-$xmin)/double($xmax-$xmin)]
            set xv1 [expr double($x1-$xmin)/double($xmax-$xmin)]
            set xvb [expr 0.2*($xvmax-$xvmin)+$xvmin]
            set xvb1 [expr 0.8*($xvmax-$xvmin)+$xvmin]
            if {$xv < $xvb || $xv1 > $xvb1} {
                $c xview moveto [expr (0.5*($x1+$x)-$xmin)/($xmax-$xmin) - 0.5*($xvmax-$xvmin)]
            }
        }
        if {$yvmax - $yvmin == 1.0} {
            $c yview moveto 0.0
        } else {
            set yv [expr double($y-$ymin)/double($ymax-$ymin)]
            set yv1 [expr double($y1-$ymin)/double($ymax-$ymin)]
            set yvb [expr 0.2*($yvmax-$yvmin)+$yvmin]
            set yvb1 [expr 0.8*($yvmax-$yvmin)+$yvmin]
        
puts "$c $y $ymin $ymax $ymin [expr ($y-$ymin)/($ymax-$ymin)] ([$c yview]) $yv < $yvb || $yv1 > $yvb1"
            if {$yv < $yvb || $yv1 > $yvb1} {
                $c yview moveto  [expr (0.5*($y1+$y)-$ymin)/($ymax-$ymin) - 0.5*($yvmax-$yvmin)]
            }
        }
    }
}

proc invalide {tag} {
    global mparams

    if {[string range $tag 0 5] != "Dispo:"} {
        error "Bad tag"
    }
    $mparams(canvas0) itemconfigure $tag -fill red
    $mparams(canvas1) itemconfigure $tag -fill red
    set mparams(etat:[string range $tag 6 end]) invalide
}

.c delete all
.cj delete all

proc tagToLiCo {tag} {
    if {[string range $tag 0 6] != "Dispo:B" || [string range $tag 11 13] != ":SB"} {
        error "Bad tag $tag"
    }
    if {[scan [string range $tag 7 8] %d li] != 1} {
        error "Bad tag $tag"
    }
    if {[scan [string range $tag 9 10] %d co] != 1} {
        error "Bad tag $tag"
    }
    if {[scan [string range $tag 14 14] %d sli] != 1} {
        error "Bad tag $tag"
    }
    if {[scan [string range $tag 15 15] %d sco] != 1} {
        error "Bad tag $tag"
    }
    
    return [list [expr 2*$li+$sli] [expr 2*$co+$sco]]
}

proc liCoToTag {li co} {
    return Dispo:B[format %02d [expr $li/2]][format %02d [expr $co/2]]:SB[expr $li%2][expr $co%2]
}

proc mparams:danDispo {mparamsName tag dx dy} {

    upvar $mparamsName mparams

# Valeurs au pif
    dispo mparams $dx $dy 0 0 350 400 [list Dispo:$tag Dispo]
    
    set dx [expr $dx+50]
    set dy [expr $dy+85]
    
    rectangle mparams $dx $dy 0 60 250 170 [list $tag]
    rectangle mparams $dx $dy 10 70 180 160 [list $tag]

    pad50 mparams $dx $dy  10   0 [list Pad:C90 $tag]
    pad50 mparams $dx $dy  70   0 [list Pad:A00 $tag]
    pad50 mparams $dx $dy 130   0 [list Pad:C45 $tag]
    pad50 mparams $dx $dy  70  90 [list Pad:Base00 $tag]
    pad50 mparams $dx $dy 190  90 [list Pad:Collecteur00 $tag]
    pad50 mparams $dx $dy  10 180 [list Pad:A45 $tag]
    pad50 mparams $dx $dy  70 180 [list Pad:C00 $tag]
    pad50 mparams $dx $dy 130 180 [list Pad:A90 $tag]
}


proc mparams:danBloc {mparamsName tag dx dy} {

    upvar $mparamsName mparams

    outline mparams $dx $dy 0 0 700 800 $tag

    set dx0 [expr $dx]
    set dx1 [expr $dx+350]
    set dy0 [expr $dy+400]
    set dy1 [expr $dy]
    mparams:danDispo mparams $tag:SB00 $dx0 $dy0
    mparams:danDispo mparams $tag:SB01 $dx1 $dy0
    mparams:danDispo mparams $tag:SB10 $dx0 $dy1
    mparams:danDispo mparams $tag:SB11 $dx1 $dy1
}



proc mparams:danPlaque {mparamsName} {

    upvar $mparamsName mparams
    
    set cols {0 700 1400 2100 3500 4200 4900 5600}
    set ligs {6400 5600 4800 4000 2400 1600 800 0}

    set mparams(coMin) 0
    set mparams(liMin) 0
    set mparams(coMax) [expr 2*[llength $cols]]
    set mparams(liMax) [expr 2*[llength $ligs]]

    set ili 0
    foreach li $ligs {
        set ico 0
        foreach co $cols {
            mparams:danBloc mparams B[format %02d $ili][format %02d $ico] $co $li
            incr ico
        }
        incr ili
    }
}

set mparams(canvas0) .c 
set mparams(canvas1) .cj
set mparams(echelle0) 0.2
set mparams(echelle1) 0.05

mparams:danPlaque mparams
scrollConfAll .c 20
scrollConfAll .cj 20

$mparams(canvas0) itemconfigure Pad:Base00 -fill gold -outline red
$mparams(canvas0) itemconfigure Pad:Base01 -fill gold -outline red
$mparams(canvas0) itemconfigure Pad:Base10 -fill gold -outline red
$mparams(canvas0) itemconfigure Pad:Base11 -fill gold -outline red

$mparams(canvas0) itemconfigure Pad:C45 -fill gold -outline green
$mparams(canvas0) itemconfigure Pad:G45 -fill gold -outline green
$mparams(canvas0) itemconfigure Pad:D45 -fill gold -outline green
$mparams(canvas0) itemconfigure Pad:H45 -fill gold -outline green

invalide [liCoToTag 0 0]


label .l -textvariable mparams(lastTag)
pack .l


set inval {
0 1
1 1
2 4
5 6
8 8
}

