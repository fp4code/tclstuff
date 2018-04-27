set c .c
destroy $c
canvas $c -width 200 -height 200 -borderwidth 5 -highlightthickness 2
grid configure $c -sticky news
grid columnconfigure . 0 -weight 1
grid rowconfigure . 0 -weight 1   

winfo width $c   ;# 1 
winfo height $c  ;# 1
update ;# essentiel
winfo width $c   ;# 214 
winfo height $c  ;# 214
$c cget -width   ;# 200
$c cget -height  ;# 200

canvas .c2 -width 250 -height 10
grid configure .c2 -sticky news

update           ;# precaution
winfo width $c   ;# 252 
winfo height $c  ;# 214
$c cget -width   ;# 200
$c cget -height  ;# 200

# $c configure -borderwidth 0

# seule façon sérieuse je crois de déterminer xmax et ymax

set xmin0 0
set ymin0 0
set marge [expr {[$c cget -borderwidth] + [$c cget -highlightthickness]}]
set xmax0 [expr {[winfo width $c] - 2*$marge - 1}]
set ymax0 [expr {[winfo height $c] - 2*$marge - 1}]

set xmin $xmin0
set ymin $ymin0
set xmax $xmax0
set ymax $ymax0

    $c create line $xmin $ymin $xmax $ymin -fill black -width 0
    $c create line $xmax $ymin $xmax $ymax -fill black -width 0
    $c create line $xmax $ymax $xmin $ymax -fill black -width 0
    $c create line $xmin $ymax $xmin $ymin -fill black -width 0


set xmin [expr {$xmin0 - 1}]
set ymin [expr {$ymin0 - 1}]
set xmax [expr {$xmax0 + 1}]
set ymax [expr {$ymax0 + 1}]

    $c create line $xmin $ymin $xmax $ymin -fill red -width 0
    $c create line $xmax $ymin $xmax $ymax -fill red -width 0
    $c create line $xmax $ymax $xmin $ymax -fill red -width 0
    $c create line $xmin $ymax $xmin $ymin -fill red -width 0

set xmin [expr {$xmin0 + 1}]
set ymin [expr {$ymin0 + 1}]
set xmax [expr {$xmax0 - 1}]
set ymax [expr {$ymax0 - 1}]

    $c create line $xmin $ymin $xmax $ymin -fill blue -width 0
    $c create line $xmax $ymin $xmax $ymax -fill blue -width 0
    $c create line $xmax $ymax $xmin $ymax -fill blue -width 0
    $c create line $xmin $ymax $xmin $ymin -fill blue -width 0


# commence en 7 = $marge



if {0} {
    $c xview moveto 0
    $c yview moveto 0

    # commence maintenant en 0

    # irreversible !!
    # Sans doute parce qu'il nest pas sérieux de ne pas donner de scrollregion

    $c xview moveto 1
    $c yview moveto 1
} else {
    $c configure -scrollregion [list $xmin0 $ymin0 $xmax0 $ymax0]
}

bind $c <Configure> {reconfigureWinCanvas %W}

proc reconfigureWinCanvas {c} {
    puts [$c configure -scrollregion]
}
