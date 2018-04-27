
# Un dispo situé ligne "li" et colonne "co" est affecté d'un tag LliCco
# "li" et "co" sont des nombres décimaux de deux chiffres
#
# L00C00 L00C01 L00C02 ...
# L01C00 L01C01 L01C02 ...
# L02C00 L02C01 L02C02 ...
# ...

proc tag2li {tag} {
    return [stringutils::stripzeros [string range $tag 1 2]]
}

proc tag2co {tag} {
    return [stringutils::stripzeros [string range $tag 4 5]]
}

proc lico2tag {li co} {
    return L[format %02d $li]C[format %02d $co]
}

#####

#namespace eval carteDispo {



proc canvSetx {pl args} {
    eval $pl.c xview $args
    eval $pl.ex xview $args
}

proc canvSety {pl args} {
    eval $pl.c yview $args
    eval $pl.ey yview $args
}

proc scma_xy {pl madrag x y} {
    $pl.ex scan $madrag $x 0
    $pl.ey scan $madrag 0 $y
    $pl.c scan $madrag $x $y
}

proc scma_x {pl madrag x} {
    $pl.ex scan $madrag $x 0
    $pl.c scan $madrag $x 0
}

proc scma_y {pl madrag y} {
    $pl.ey scan $madrag 0 $y
    $pl.c scan $madrag 0 $y
}

proc clickMesure pl {
    set tags [$pl.c gettags current]
    set mes [lindex $tags 0]
    if {$mes == "current"} {
        set mes [lindex $tags 1] 
    }
    focus $pl.c
    setPosCour $pl $mes
}

proc setPosCour {pl tag} {
    global ASDEX
    recadre $pl $tag 
    if {[info exists ASDEX(PosCour)]} {
        $pl.c itemconfigure $ASDEX(PosCour) -fill black
    }
    set ASDEX(PosCour) $tag
    $pl.c itemconfigure $ASDEX(PosCour) -fill red
    
    affiche  $tag  
    
    return $ASDEX(PosCour)
}

proc nextPosRight {pl pos} {
    global ASDEX
    set Typ $ASDEX(Typ)
    set li [tag2li $pos]
    set co [expr [tag2co $pos] +1]
    set fini 0
    for {} {$co<=$ASDEX(BrutC:comax,$Typ)} {incr co} {
        set tata [$pl.c gettags [lico2tag $li $co]]
        if {$tata != {}} {
            set fini 1
            break
        }
    }
    if {$fini} {
        return [setPosCour $pl $tata]
    }
    for {incr li} {$li<=$ASDEX(BrutC:limax,$Typ)} {incr li} {
        for {set co $ASDEX(BrutC:comin,$Typ)} {$co<=$ASDEX(BrutC:comax,$Typ)} {incr co} {
            set tata [$pl.c gettags [lico2tag $li $co]]
            if {$tata != {}} {
                set fini 1
                break
            }
        }
        if {$fini} {
            break
        }
    }
    if {$fini} {
        return [setPosCour $pl $tata]
    }
    bell
}

proc nextPosLeft {pl pos} {
    global ASDEX
    set Typ $ASDEX(Typ)
    set li [tag2li $pos]
puts "pos = $pos"
    set co [expr [tag2co $pos] -1]
    set fini 0
    for {} {$co>=$ASDEX(BrutC:comin,$Typ)} {incr co -1} {
        set tata [$pl.c gettags [lico2tag $li $co]]
        if {$tata != {}} {
            set fini 1
            break
        }
    }
    if {$fini} {
        return [setPosCour $pl $tata]
    }
    for {incr li -1} {$li>=$ASDEX(BrutC:limin,$Typ)} {incr li -1} {
        for {set co $ASDEX(BrutC:comax,$Typ)} {$co>=$ASDEX(BrutC:comin,$Typ)} {incr co -1} {
            set tata [$pl.c gettags [lico2tag $li $co]]
            if {$tata != {}} {
                set fini 1
                break
            }
        }
        if {$fini} {
            break
        }
    }
    if {$fini} {
        return [setPosCour $pl $tata]
    }
    bell
}

proc recadre {pl tag} {
    global ASDEX
    set xy [$pl.c coords $tag]
    set xydims [$pl.c cget -scrollregion]

    set x [lindex $xy 0]
    set xwmin [lindex $xydims 0]
    set xdim [expr [lindex $xydims 2]-$xwmin+1]
    set xlims [$pl.c xview]
    set xmin [expr [lindex $xlims 0]*$xdim+$xwmin]
    set xmax [expr [lindex $xlims 1]*$xdim+$xwmin]
    set xwin [expr $xmax - $xmin + 1]
    if {$x<$xmin+0.5*$ASDEX(plx)} {
        set frac [expr ($x-0.5*$xwin-$xwmin)/$xdim]
        if {$frac < 0} {
            set frac 0
        }
        $pl.c xview moveto $frac
        $pl.ex xview moveto $frac
    } elseif {$x>$xmax-0.5*$ASDEX(plx)} {
        set frac [expr ($x-0.5*$xwin-$xwmin)/$xdim]
        if {(1-$frac)*$xdim < $xwin} {
            set frac [expr 1-$xwin/$xdim]
        }
        $pl.c xview moveto $frac
        $pl.ex xview moveto $frac
    }

    set y [lindex $xy 1]
    set ywmin [lindex $xydims 1]
    set ydim [expr [lindex $xydims 3]- $ywmin +1]
    set ylims [$pl.c yview]
    set ymin [expr [lindex $ylims 0]*$ydim+$ywmin]
    set ymax [expr [lindex $ylims 1]*$ydim+$ywmin]
    set ywin [expr $ymax - $ymin + 1]
    if {$y<$ymin+0.5*$ASDEX(ply)} {
        set frac [expr ($y-0.5*$ywin-$ywmin)/$ydim]
        puts "ywin=$ywin, ydim=$ydim, y=$y, frac=$frac"
        if {$frac < 0} {
            set frac 0
        }
        $pl.c yview moveto $frac
        $pl.ey yview moveto $frac
    } elseif {$y>$ymax-0.5*$ASDEX(ply)} {
        set frac [expr ($y-0.5*$ywin-$ywmin)/$ydim]
        if {(1-$frac)*$ydim < $ywin} {
            set frac [expr 1-$ywin/$ydim]
        }
        $pl.c yview moveto $frac
        $pl.ey yview moveto $frac
    }
}

proc nextPosUp {pl pos} {
    global ASDEX
    set Typ $ASDEX(Typ)
    set li [expr [tag2li $pos] -1]
    set co [tag2co $pos]
    set fini 0
    for {} {$li>=$ASDEX(BrutC:limin,$Typ)} {incr li -1} {
        if {[$pl.c gettags [lico2tag $li $co]] != {}} {
            set fini 1
            break
        }
    }
    if {$fini} {
        return [setPosCour $pl [lico2tag $li $co]]
    }
    bell
}

proc nextPosDown {pl pos} {
    global ASDEX
    set Typ $ASDEX(Typ)
    set li [expr [tag2li $pos] +1]
    set co [tag2co $pos]
    set fini 0
    for {} {$li<=$ASDEX(BrutC:limax,$Typ)} {incr li} {
        if {[$pl.c gettags [lico2tag $li $co]] != {}} {
            set fini 1
            break
        }
    }
    if {$fini} {
        return [setPosCour $pl [lico2tag $li $co]]
    }
    bell
}

proc nextPosReturn {pl pos} {
    global ASDEX
    set Typ $ASDEX(Typ)
    set li [expr [tag2li $pos]+1]
    set co [expr $ASDEX(BrutC:comin,$Typ)-1]
    nextPosRight $pl [lico2tag $li $co]
}

proc newCarte {pl} {
    global ASDEX
    scrollbar $pl.hscroll -orient horizontal -command "canvSetx $pl"
    pack $pl.hscroll -expand yes -side bottom -fill x

    scrollbar $pl.vscroll -orient vertical -command "canvSety $pl"
    pack $pl.vscroll -side right -fill y

# Attention l'ordre de création est important pour la visibilité
    frame $pl.1 -height 20
    pack $pl.1 -fill x -side top

    canvas $pl.exy -relief sunken -borderwidth 2 -height 20 -width 20
    pack $pl.exy -in $pl.1 -side left

    canvas $pl.ex -relief sunken -borderwidth 2 -height 20
    pack $pl.ex -in $pl.1 -fill x

    canvas $pl.ey -relief sunken -borderwidth 2 -width 20
    pack $pl.ey -side left

    canvas $pl.c -relief sunken -borderwidth 2\
        -xscrollcommand "$pl.hscroll set" \
        -yscrollcommand "$pl.vscroll set"
    pack $pl.c -expand yes -fill both

    bind $pl.c <2> "scma_xy $pl mark %x %y"
    bind $pl.c <B2-Motion> "scma_xy $pl dragto %x %y"


    bind $pl.ex <2> "scma_x $pl mark %x"
    bind $pl.ex <B2-Motion> "scma_x $pl dragto %x"

    bind $pl.ey <2> "scma_y $pl mark %y"
    bind $pl.ey <B2-Motion> "scma_y $pl dragto %y"
    $pl.c bind all <1> "clickMesure $pl"

    set ASDEX(PosCour) {}

    foreach key {Right Left Up Down Return} {
        bind $pl.c <KeyPress-$key> {
            nextPos%K [winfo parent %W] $ASDEX(PosCour)
        }
    }
}





#}
