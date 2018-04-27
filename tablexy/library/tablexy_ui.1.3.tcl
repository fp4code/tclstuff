package provide tablexy 1.3
package require aligned 1.1

# 4 février 2002 (FP) 1.3   "incr" supprimé, les coords. sont réelles

proc aligned::videTo0 {aName args} {
    upvar #0 $aName array
    foreach elem $args {
        if {$array($elem) == {}} {
            set array($elem) 0
        } else {
            set array($elem) [expr $array($elem)]
        }
    }
}

proc aligned::movToEntry {machine} {
    upvar #0 $machine aligned
    aligned::videTo0 $machine xTheo yTheo
    aligned::moveTo $machine $aligned(xTheo) $aligned(yTheo)
}

proc aligned::hereIsGood {machine} {
    aligned::videTo0 $machine xTheo yTheo
    aligned::corrigeIciTranslation $machine
}

proc aligned::tablexy_ui {machine specialFrameCmd} {
    upvar #0 $machine aligned
    upvar #0 private.$machine tc
    global AsdexTclDir
    
    set tc(dx) 100
    set tc(dy) 100
    
    set root .${machine}_ui
    
    # this treats "." as a special case
    
    if {$root == "."} {
        set b ""
    } else {
        set b $root
    }
    

    $specialFrameCmd $b.sf $machine

    set bm [label $b.message -relief sunken -anchor w]
    set d [frame $b.divers]
    
    button $d.c \
            -command ${machine}_on \
            -text contact
    aide::ui_minihelp $bm $d.c {contact échantillon/pointes}
    
    button $d.s \
            -command ${machine}_off \
            -text separ.
    aide::ui_minihelp $bm $d.s {séparation échantillon/pointes}
    
    label $b.lx \
            -text x:
    entry $b.ex \
            -textvariable ${machine}(xTheo) \
            -justify right
    aide::ui_minihelp $bm $b.ex {abscisse en microns}
    
    label $b.ly \
            -text y:
    entry $b.ey \
            -textvariable ${machine}(yTheo) \
            -justify right
    aide::ui_minihelp $bm $b.ey {ordonnée en microns}
    
    label $b.ldx \
            -text dx:
    entry $b.edx \
            -textvariable private.${machine}(dx) \
            -justify right
    
    label $b.ldy \
            -text dy:
    entry $b.edy \
            -textvariable private.${machine}(dy) \
            -justify right
    
    frame $b.m
    button $b.m.mt -command [namespace code "movToEntry $machine"]
    $b.m.mt configure -bitmap @$AsdexTclDir/bitmaps/absolu.xbm
    aide::ui_minihelp $bm $b.m.mt {mouvement absolu}
    
    button $b.m.nw -command [namespace code "movRel $machine -1  1"]
    button $b.m.n  -command [namespace code "movRel $machine  0  1"]
    button $b.m.ne -command [namespace code "movRel $machine  1  1"]
    button $b.m.w  -command [namespace code "movRel $machine -1  0"]
    button $b.m.e  -command [namespace code "movRel $machine  1  0"]
    button $b.m.sw -command [namespace code "movRel $machine -1 -1"]
    button $b.m.s  -command [namespace code "movRel $machine  0 -1"]
    button $b.m.se -command [namespace code "movRel $machine  1 -1"]
    foreach ddd {nw n ne w e sw s se} {
        $b.m.$ddd configure -bitmap @$AsdexTclDir/bitmaps/$ddd.xbm
        aide::ui_minihelp $bm $b.m.$ddd "mouvement relatif $ddd"
    }
    
    
    bind $b.m.mt <Control-Alt-Meta-KeyPress-Right> [namespace code "aligned_move $machine x+10000"]
    bind $b.m.mt <Control-Alt-Meta-KeyPress-Up>    [namespace code "aligned_move $machine y+10000"]
    bind $b.m.mt <Control-Alt-Meta-KeyPress-Left>  [namespace code "aligned_move $machine x-10000"]
    bind $b.m.mt <Control-Alt-Meta-KeyPress-Down>  [namespace code "aligned_move $machine y-10000"]
    bind $b.m.mt <Control-Alt-KeyPress-Right> [namespace code "aligned_move $machine x+1000"]
    bind $b.m.mt <Control-Alt-KeyPress-Up>    [namespace code "aligned_move $machine y+1000"]
    bind $b.m.mt <Control-Alt-KeyPress-Left>  [namespace code "aligned_move $machine x-1000"]
    bind $b.m.mt <Control-Alt-KeyPress-Down>  [namespace code "aligned_move $machine y-1000"]
    bind $b.m.mt <Control-KeyPress-Right> [namespace code "aligned_move $machine x+100"]
    bind $b.m.mt <Control-KeyPress-Up>    [namespace code "aligned_move $machine y+100"]
    bind $b.m.mt <Control-KeyPress-Left>  [namespace code "aligned_move $machine x-100"]
    bind $b.m.mt <Control-KeyPress-Down>  [namespace code "aligned_move $machine y-100"]
    bind $b.m.mt <KeyPress-Right> [namespace code "aligned_move $machine x+10"]
    bind $b.m.mt <KeyPress-Up>    [namespace code "aligned_move $machine y+10"]
    bind $b.m.mt <KeyPress-Left>  [namespace code "aligned_move $machine x-10"]
    bind $b.m.mt <KeyPress-Down>  [namespace code "aligned_move $machine y-10"]
    bind $b.m.mt <KeyPress> {bell}
    bind $b.m.mt <Control-Alt-KeyPress-Meta_L> {;}
    bind $b.m.mt <Control-KeyPress-Alt_L> {;}
    bind $b.m.mt <KeyPress-Control_L> {;}
    
    button $b.ep \
            -command [namespace code "hereIsGood $machine"] \
            -text {expected pos.}
    aide::ui_minihelp $bm $b.ep {déclare la position affichée comme position en cours}
    
    button $b.sc -text "save alig."
    $b.sc configure -command [namespace code "savAlig $aligned(iso)"]
    aide::ui_minihelp $bm $b.sc {sauve les paramètres d'alignement}
    button $b.lc -text "load alig."
    $b.lc configure -command [namespace code "loadAlign $aligned(iso)"]
    aide::ui_minihelp $bm $b.lc {charge les paramètres d'alignement}
    
    button $d.al \
            -text aligne \
            -command [namespace code "package require tablexy_manual 1.1\ntablexy_manual_ui $machine"]
    
    button $d.close \
            -command "destroy $root" \
            -text close
    
    button $b.ici -text ici -command [namespace code "textpos $machine"]
    
    grid $b.sf        -      -      -       -     -sticky news
    grid $b.ep        -     $b.lx  $b.ex  $b.m    -sticky news
    grid   ^          ^     $b.ly  $b.ey    ^     -sticky news   
    grid $b.sc      $b.lc $b.ldx $b.edx     ^     -sticky news
    grid   ^          ^   $b.ldy $b.edy     ^     -sticky news
    grid $b.divers    -     -      -      $b.ici -sticky news
    grid $b.message   -     -      -        ^    -sticky news

#    grid configure $b.m $b.ep -sticky ewns
    
    grid $b.m.nw $b.m.n  $b.m.ne -sticky ewns
    grid $b.m.w  $b.m.mt $b.m.e  -sticky ewns
    grid $b.m.sw $b.m.s  $b.m.se -sticky ewns
    
    pack $d.c $d.s -side left
    pack $d.close -side right
    pack $d.al -side top
}

proc aligned::movRel {machine dx dy} {
    upvar #0 $machine aligned
    upvar #0 private.$machine tc
    videTo0 $machine xTheo yTheo
    videTo0 private.$machine dx dy
    set aligned(xTheo) [expr {$aligned(xTheo) + $tc(dx)*$dx}]
    set aligned(yTheo) [expr {$aligned(yTheo) + $tc(dy)*$dy}]
    moveTo $machine $aligned(xTheo) $aligned(yTheo)
}

proc aligned_move {machine v} {
    upvar #0 $machine aligned
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
    set aligned(xTheo) [expr {$aligned(xTheo) + $x}]
    set aligned(yTheo) [expr {$aligned(yTheo) + $y}]
    moveTo $machine $aligned(xTheo) $aligned(yTheo)
}

proc aligned::loadAlign {isoName} {
    global ASDEXDATA
    upvar #0 $isoName iso
    set fifi [open $ASDEXDATA(rootData)/$ASDEXDATA(echantillon)/alignement.dat r]
    set iso(corr) [gets $fifi]
    isometrie::evalueTransform iso
    close $fifi
}
    
proc aligned::savAlig {isoName} {
    global ASDEXDATA
    upvar #0 $isoName iso
    set corr $iso(corr)
    set fifi [open $ASDEXDATA(rootData)/$ASDEXDATA(echantillon)/alignement.dat w]
    puts $fifi $corr
    close $fifi
}

proc aligned::textpos {machine} {
    upvar #0 $machine aligned
    set root .${machine}_ui
    set win $root.toptext 
    if {![winfo exists $win]} {
	toplevel $win
	text $win.txt -width 16
	pack $win.txt
    }
    $win.txt insert end "[format %7d $aligned(xTheo)] [format %7d $aligned(yTheo)]\\\n"
}