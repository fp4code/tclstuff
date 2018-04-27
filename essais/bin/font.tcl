canvas .c -width 800 -height 400
pack .c

font create f10 -family times -size 10
font create f8 -family times -size 8
font create f7 -family times -size 7
font create f6 -family times -size 6

proc putHText {canvas font text} {
    global CURSORX CURSORY
    puts stderr "[font metrics $font] = $font"
    set item [$canvas create text $CURSORX $CURSORY -anchor sw -font $font -text $text]
    incr CURSORX [font measure $font $text]
    foreach {x1 y1 x2 y2} [$canvas bbox $item] {}
    $canvas create line $x1 $y1 $x2 $y1
    $canvas create line $x1 $y2 $x2 $y2
    $canvas create line $x1 $y1 $x1 $y2
    $canvas create line $x2 $y1 $x2 $y2
    return [list $item [$canvas bbox $item]]
}


set CURSORX 20
set CURSORY 20

putHText .c f10 {Blabla blabla blabla...}
set CURSORX 20
incr CURSORY 20
putHText .c f8 {Blabla blabla blabla...}
set CURSORX 20
incr CURSORY 20
putHText .c f7 {Blabla blabla blabla...}
set CURSORX 20
incr CURSORY 20
putHText .c f6 {Blabla blabla blabla...}
set CURSORX 20
incr CURSORY 20
putHText .c {-adobe-times-medium-r-normal--8-80-75-75-p-44-iso8859-1} {Blabla blabla blabla...}

set CURSORX 20
incr CURSORY 20
putHText .c {-adobe-times-medium-r-normal--8-*-*-*-*-*-iso88559-*} {Blabla blabla blabla...}

set CURSORX 20
incr CURSORY 20
putHText .c {-adobe-times-medium-r-normal--6-*-*-*-*-*-iso88559-*} {Blabla blabla blabla...}

set CURSORX 20
incr CURSORY 20
putHText .c {-adobe-times-medium-r-normal--5-*-*-*-*-*-iso88559-*} {Blabla blabla blabla...}
