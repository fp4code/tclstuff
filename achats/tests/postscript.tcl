font create normal -family times -size 12
font create italic -family times -size 10 -slant italic
font create bold -family times -size 10 -weight bold
set PSFONT(normal) {Times-Roman 12}
set PSFONT(italic) {Times-Italic 10}
set PSFONT(bold) {Times-Bold 10}

font create title -family times -size 16 -weight bold
set PSFONT(title) {Times 16}

set LS(normal) [font metrics normal -linespace]
set LS(title)  [font metrics title -linespace]
set AS(title)  [font metrics title -ascent]
set DS(title)  [font metrics title -descent]

canvas .c -width 900 -height 640
pack .c

.c delete all

proc putHText {canvas font text} {
    global CURSORX CURSORY
    set item [$canvas create text $CURSORX $CURSORY -anchor sw -font $font -text $text]
    incr CURSORX [font measure $font $text]
    foreach {x1 y1 x2 y2} [$canvas bbox $item] {}
    $canvas create line $x1 $y1 $x2 $y1
    $canvas create line $x1 $y2 $x2 $y2
    $canvas create line $x1 $y1 $x1 $y2
    $canvas create line $x2 $y1 $x2 $y2
    return [list $item [$canvas bbox $item]]
}


.c delete all

set CURSORX 20
set CURSORY 20

putHText .c normal {L.P.N.}
incr CURSORY 10
putHText .c normal {zxlkjzxd asdkjasdfklj}


proc printall {l} {
    .c delete all
    for {set li 0} {$li < 880} {incr li 15} {
        for {set co 0} {$co < 640} {incr co 8} {
            .c create text $co $li -text $l
        }
    }
}

button .b
pack .b
tkwait visibility .b
set popo [.c postscript -fontmap PSFONT -file /tmp/popo]
exec pageview /tmp/popo
