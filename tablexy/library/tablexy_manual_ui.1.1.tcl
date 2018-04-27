package require aligned 1.1
package provide tablexy_manual 1.1

proc aligned::isoc {x} {
    return [expr int($x / sqrt(3.0))]
}

proc aligned::poly {win u1 u2 tag} {
    
    set v1 [aligned::isoc $u1]
    set v2 [aligned::isoc $u2]
    
    incr u1 1
    incr u2 -1
    incr v1 0
    incr v2 -1
    
    $win create polygon $u1 $v1 $u2 $v2 $u2 -$v2 $u1 -$v1\
            -outline black -fill {} -tag [list x+$tag DEPL]
    $win create polygon $v1 $u1 $v2 $u2 -$v2 $u2 -$v1 $u1\
            -outline black -fill {} -tag [list y-$tag DEPL]
    $win create polygon -$u1 -$v1 -$u2 -$v2 -$u2 $v2 -$u1 $v1\
            -outline black -fill {} -tag [list x-$tag DEPL]
    $win create polygon -$v1 -$u1 -$v2 -$u2 $v2 -$u2 $v1 -$u1\
            -outline black -fill {} -tag [list y+$tag DEPL]
    
    incr u1 -1
    incr v1 2
    incr u2 -2
    incr v2 2
    
    $win create polygon $u1 $v1 $u2 $v2 $v2 $u2 $v1 $u1\
            -outline black -fill {} -tag [list x+${tag}y-$tag DEPL]
    $win create polygon -$u1 $v1 -$u2 $v2 -$v2 $u2 -$v1 $u1\
            -outline black -fill {} -tag [list x-${tag}y-$tag DEPL]
    $win create polygon -$u1 -$v1 -$u2 -$v2 -$v2 -$u2 -$v1 -$u1\
            -outline black -fill {} -tag [list x-${tag}y+$tag DEPL]
    $win create polygon $u1 -$v1 $u2 -$v2 $v2 -$u2 $v1 -$u1\
            -outline black -fill {} -tag [list x+${tag}y+$tag DEPL]
}

proc aligned::tablexy_manual_ui {machine} {
    upvar #0 $machine tablexy
    set root .${machine}_manual_ui
    global aligned::TMUINFO

    set aligned::TMUINFO {mieux: flèches + [Shift] ou [Control][+Alt][+Meta]}

    if {[winfo exists $root]} {
        wm deiconify $root
        raise $root
        return
    } else {
        toplevel $root
        wm geometry $root +0+180
    }
    
    set bm [label $root.message -relief sunken -anchor w]
    set dir  [canvas $root.directions -relief sunken -bd 3 -width 219 -height 219]
    aide::ui_minihelp $bm $dir $aligned::TMUINFO
            
    set list [frame $root.list -relief sunken -bd 3]
    set div  [frame $root.divers]
    
    label $root.lala -text "$machine : alignement"
    grid configure $root.lala -
    grid configure $dir $list -sticky n
    grid configure ^ $div -sticky we
    grid configure $bm - -sticky we
    
    $dir create polygon 28 6 38 0 28 -6
    $dir create polygon 6 28 0 38 -6 28
    $dir create polygon -28 6 -38 0 -28 -6
    $dir create polygon 6 -28 0 -38 -6 -28
    
    poly $dir 10 50 10
    poly $dir 50 70 100
    poly $dir 70 90 1000
    poly $dir 90 110 10000
    # DANGER : on espère que les tags sont ordonnés en liste
    
    $dir bind DEPL <Button> [namespace code "manual_moveOnTag $machine %W"]
    $dir bind DEPL <Enter> {
        %W itemconfigure current -fill brown
        [winfo parent %W].message configure -text [lindex [%W gettags current] 0]
    }
    $dir bind DEPL <Leave> {
        %W itemconfigure current -fill {}
        [winfo parent %W].message configure -text $aligned::TMUINFO
    }
    
    $dir move all 113 113
    
    bind $root <Control-Alt-Meta-KeyPress-Right> [namespace code "manual_move $machine x+10000"]
    bind $root <Control-Alt-Meta-KeyPress-Up>    [namespace code "manual_move $machine y+10000"]
    bind $root <Control-Alt-Meta-KeyPress-Left>  [namespace code "manual_move $machine x-10000"]
    bind $root <Control-Alt-Meta-KeyPress-Down>  [namespace code "manual_move $machine y-10000"]
    bind $root <Control-Alt-KeyPress-Right> [namespace code "manual_move $machine x+1000"]
    bind $root <Control-Alt-KeyPress-Up>    [namespace code "manual_move $machine y+1000"]
    bind $root <Control-Alt-KeyPress-Left>  [namespace code "manual_move $machine x-1000"]
    bind $root <Control-Alt-KeyPress-Down>  [namespace code "manual_move $machine y-1000"]
    bind $root <Control-KeyPress-Right> [namespace code "manual_move $machine x+100"]
    bind $root <Control-KeyPress-Up>    [namespace code "manual_move $machine y+100"]
    bind $root <Control-KeyPress-Left>  [namespace code "manual_move $machine x-100"]
    bind $root <Control-KeyPress-Down>  [namespace code "manual_move $machine y-100"]
    bind $root <Shift-KeyPress-Right> [namespace code "manual_move $machine x+1"]
    bind $root <Shift-KeyPress-Up>    [namespace code "manual_move $machine y+1"]
    bind $root <Shift-KeyPress-Left>  [namespace code "manual_move $machine x-1"]
    bind $root <Shift-KeyPress-Down>  [namespace code "manual_move $machine y-1"]
    bind $root <KeyPress-Right> [namespace code "manual_move $machine x+10"]
    bind $root <KeyPress-Up>    [namespace code "manual_move $machine y+10"]
    bind $root <KeyPress-Left>  [namespace code "manual_move $machine x-10"]
    bind $root <KeyPress-Down>  [namespace code "manual_move $machine y-10"]
    bind $root <Shift-KeyPress-Right> [namespace code "manual_move $machine x+1"]
    bind $root <Shift-KeyPress-Up>    [namespace code "manual_move $machine y+1"]
    bind $root <Shift-KeyPress-Left>  [namespace code "manual_move $machine x-1"]
    bind $root <Shift-KeyPress-Down>  [namespace code "manual_move $machine y-1"]
    bind $root <KeyPress> {bell}
    bind $root <Control-Alt-KeyPress-Meta_L> {;}
    bind $root <Control-KeyPress-Alt_L> {;}
    bind $root <KeyPress-Control_L> {;}
    bind $root <KeyPress-Shift_L> {;}
   
    button $list.pt \
            -command "::aligned::corrigeIciTranslation $machine" \
            -text {translate}
    aide::ui_minihelp $bm $list.pt {pointage exact ici, pas de changement de l'angle}
    
    button $list.p \
            -command "::aligned::corrigeIci $machine" \
            -text {pointe}
    aide::ui_minihelp $bm $list.p {ajoute un pointage ici}
    
    button $list.rf \
            -command "::isometrie::removeFirst $tablexy(iso)"\
            -text {remove first}
    aide::ui_minihelp $bm $list.rf {enlève le premier pointage}
    
    button $list.rw \
            -command "::isometrie::removeWorst $tablexy(iso)"\
            -text {remove worst}
    aide::ui_minihelp $bm $list.rw {enlève le plus mauvais pointage}
    
    button $list.rl \
            -command "::isometrie::removeLast $tablexy(iso)"\
            -text {remove last}
    aide::ui_minihelp $bm $list.rl {enlève le dernier pointage}
    
    button $list.pd \
            -command "::isometrie::printDist $tablexy(iso)" \
            -text {print dist.}
    aide::ui_minihelp $bm $list.pd {affiche la distribution des pointages}
    
    foreach b {pt p rf rw rl pd} {
        grid $list.$b -sticky we
    }
    
    button $div.m \
            -command "$tablexy(manual) $machine" \
            -text manual
    aide::ui_minihelp $bm $div.m {passe la tc en mode manuel}
    
    button $div.close \
            -command "destroy $root" \
            -text close
    grid $div.m $div.close
    
    aide::nondocumente $root
}

proc aligned::manual_move {machine v} {
    set c0 [string index $v 0]
    set reste [string range $v 1 end]
    if {$c0 == "x"} {
        set c1 [string first "y" $reste]
        if {$c1 >= 0} {
            incr c1 -1
            set x [string range $reste 0 $c1]
            incr c1 2
            set y [string range $reste $c1 end]
        } else {
            set x $reste
            set y 0
        }
    } else {
        set x 0
        set y $reste
    }
    puts "$x $y"
    aligned::unaligned_moveRelRaw $machine $x $y
}

proc aligned::manual_moveOnTag {machine win} {
    manual_move $machine [lindex [$win gettags current] 0]
}


proc aligned::unaligned_moveRel {name x y} {
    upvar #0 $name tablexy
    $tablexy(moveTo) $name [expr $tablexy(xTheoUnaligned) + $x] \
            [expr $tablexy(yTheoUnaligned) + $y]
}

proc aligned::unaligned_moveRelRaw {name x y} {
    upvar #0 $name tablexy
    $tablexy(moveToRaw) $name [expr $tablexy(xTheoUnaligned) + $x] \
            [expr $tablexy(yTheoUnaligned) + $y]
}

