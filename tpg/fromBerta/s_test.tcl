namespace eval tpg {

proc test {nom w l} {
    set ws2 [expr $w/2]
    set ls2 [expr $l/2]

  # titane #1
    setLayer 1
    Struct::new ${nom}_1
    brc $ws2 $ls2
  
  # mesa d'isolation de l'émetteur
    setLayer 3
    Struct::new ${nom}_3
    set c [Chemin::new      [expr -$ws2 -  100] [expr  $ls2 + 110]]
    Chemin::appendPoint c E [expr -$ws2 -  150] [expr  $ls2 + 110]
    Chemin::appendPoint c E [expr -$ws2 -  330] [expr       + 600]
    Chemin::appendPoint c E [expr -$ws2 - 1330] [expr       + 600]
    Chemin::appendPoint c E [expr -$ws2 - 1330] [expr       - 600]
    Chemin::appendPoint c E [expr -$ws2 -  330] [expr       - 600]
    Chemin::appendPoint c E [expr -$ws2 -  150] [expr -$ls2 - 110]
    Chemin::appendPoint c E [expr -$ws2 -  100] [expr -$ls2 - 110]
    Chemin::appendPoint c I [expr -$ws2 -  100] [expr -$ls2 -  30]
    Chemin::appendPoint c E [expr -$ws2 -  100] [expr  $ls2 +  30]
    Chemin::appendPoint c I [expr -$ws2 -  100] [expr  $ls2 + 110]
    bfc $c

    set c2 $c ;# pour le niveau 4

    set c [Chemin::new      [expr  $ws2 -  30] [expr  $ls2 + 110]]
    Chemin::appendPoint c E [expr -$ws2 - 100] [expr  $ls2 + 110]
    Chemin::appendPoint c I [expr -$ws2 - 100] [expr  $ls2 +  30]
    Chemin::appendPoint c E [expr -$ws2 +  30] [expr  $ls2 +  30]
    Chemin::appendPoint c E [expr -$ws2 +  30] [expr -$ls2 -  30]
    Chemin::appendPoint c E [expr -$ws2 - 100] [expr -$ls2 -  30]
    Chemin::appendPoint c I [expr -$ws2 - 100] [expr -$ls2 - 110]
    Chemin::appendPoint c E [expr  $ws2 -  30] [expr -$ls2 - 110]
    Chemin::appendPoint c E [expr  $ws2 -  30] [expr  $ls2 + 110]
    bfc $c
   
    set c1 $c ;# pour le niveau 4

  # Contacts ohmiques
    setLayer 4
    Struct::new ${nom}_4
    bfc [Chemin::empated -20 $c2]
    bfc [Chemin::empated -20 $c1]

  # Arches de pont
    setLayer 5
    Struct::new ${nom}_5
    if {$l >= 200} {
        set c [Chemin::new      [expr  $ws2 + 150] [expr  $ls2 + 195]]
        Chemin::appendPoint c E [expr -$ws2 -  20] [expr  $ls2 + 195]
        Chemin::appendPoint c E [expr -$ws2 -  20] [expr  $ls2 -   5]
        Chemin::appendPoint c E [expr  $ws2 -  50] [expr  $ls2 -   5]
        Chemin::appendPoint c E [expr  $ws2 -  50] [expr -$ls2 +   5]
        Chemin::appendPoint c E [expr -$ws2 -  20] [expr -$ls2 +   5]
        Chemin::appendPoint c E [expr -$ws2 -  20] [expr -$ls2 - 195]
        Chemin::appendPoint c E [expr  $ws2 + 150] [expr -$ls2 - 195]
        Chemin::appendPoint c E [expr  $ws2 + 150] [expr  $ls2 + 195]
        bfc $c
    } else {
 puts $nom
        set c [Chemin::new      [expr  $ws2 +  20] [expr  $ls2 + 195]]
        Chemin::appendPoint c E [expr -$ws2 -  20] [expr  $ls2 + 195]
        Chemin::appendPoint c E [expr -$ws2 -  20] [expr  $ls2 -   5]
        Chemin::appendPoint c E [expr  $ws2 +  20] [expr  $ls2 -   5]
        Chemin::appendPoint c E [expr  $ws2 +  20] [expr  $ls2 + 195]
        bfc $c
        set c [Chemin::new      [expr  $ws2 +  20] [expr -$ls2 +   5]]
        Chemin::appendPoint c E [expr -$ws2 -  20] [expr -$ls2 +   5]
        Chemin::appendPoint c E [expr -$ws2 -  20] [expr -$ls2 - 195]
        Chemin::appendPoint c E [expr  $ws2 +  20] [expr -$ls2 - 195]
        Chemin::appendPoint c E [expr  $ws2 +  20] [expr -$ls2 +   5]
        bfc $c
    }

  # Sorties de contacts
    setLayer 6
    Struct::new ${nom}_6
      # émetteur
        set c [Chemin::new      [expr -$ws2 -  150] [expr  $ls2 + 110]]
        Chemin::appendPoint c E [expr -$ws2 -  330] [expr       + 600]
        Chemin::appendPoint c E [expr -$ws2 - 1330] [expr       + 600]
        Chemin::appendPoint c E [expr -$ws2 - 1330] [expr       - 600]
        Chemin::appendPoint c E [expr -$ws2 -  330] [expr       - 600]
        Chemin::appendPoint c E [expr -$ws2 -  150] [expr -$ls2 - 110]
        Chemin::appendPoint c E [expr -$ws2 -  150] [expr  $ls2 + 110]
        bfc [Chemin::empated -40 $c]
      # base
        set c [Chemin::new      [expr       + 550] [expr       + 1250]]
        Chemin::appendPoint c I [expr       - 550] [expr       + 1250]
        Chemin::appendPoint c E [expr       - 550] [expr  $ls2 +  250]
        Chemin::appendPoint c E [expr -$ws2      ] [expr  $ls2 +  200]
        Chemin::appendPoint c E [expr -$ws2 + 100] [expr  $ls2       ]
        Chemin::appendPoint c E [expr -$ws2 + 100] [expr -$ls2       ]
        Chemin::appendPoint c E [expr -$ws2      ] [expr -$ls2 -  250]
        Chemin::appendPoint c E [expr       - 550] [expr -$ls2 -  250]
        Chemin::appendPoint c E [expr       - 550] [expr       - 1250]
        Chemin::appendPoint c I [expr       + 550] [expr       - 1250]
        Chemin::appendPoint c E [expr       + 550] [expr -$ls2 -  250]
        Chemin::appendPoint c E [expr  $ws2      ] [expr -$ls2 -  200]
        Chemin::appendPoint c E [expr  $ws2 - 100] [expr -$ls2       ]
        Chemin::appendPoint c E [expr  $ws2 - 100] [expr  $ls2       ]
        Chemin::appendPoint c E [expr  $ws2      ] [expr  $ls2 +  200]
        Chemin::appendPoint c E [expr       + 550] [expr  $ls2 +  250]
        Chemin::appendPoint c E [expr       + 550] [expr       + 1250]
        bfc $c
      # complément électrode base du haut
        if {$l == 500} {
            boundary {x=550 y=1250;^450;<1100;v450;I>1100;}
        } elseif {$l == 200} {
            boundary {x=550 y=1250;I<1100;Ev300;I>1100;E^300;}
        }
        if {$l >= 200} {
            set c [Chemin::new      [expr $ws2 + 1260] [expr       + 600]]
            Chemin::appendPoint c E [expr $ws2 +  210] [expr       + 600]
            Chemin::appendPoint c E [expr $ws2 +  175] [expr  $ls2 -  50]
            Chemin::appendPoint c I [expr $ws2 -  100] [expr  $ls2 -  50]
            Chemin::appendPoint c I [expr $ws2 -  100] [expr -$ls2 +  50]
            Chemin::appendPoint c E [expr $ws2 +  175] [expr -$ls2 +  50]
            Chemin::appendPoint c E [expr $ws2 +  210] [expr       - 600]
            Chemin::appendPoint c E [expr $ws2 + 1260] [expr       - 600]
            Chemin::appendPoint c E [expr $ws2 + 1260] [expr       + 600]
            bfc $c
        }
}

foreach {l w} {5 100 10 100 20 100 35 100 50 100 75 100 100 100} {
    set nom test${l}x${w}
    test $nom [expr $w*10] [expr $l*10]
    Struct::new $nom
    foreach i {1 3 4 5 6} {
        sref ${nom}_$i 0 0
    }
#    displayWinStruct $nom 0.5
}

Struct::new test_tot
 sref test100x100 0     0
 sref test5x100 0  2500
 sref test75x100 0  5000
 sref test50x100 0  7500
 sref test10x100 0 -2500
 sref test35x100 0 -5000
 sref test20x100 0 -7500

Struct::transforme rotation90 test_tot 999

# displayWinStruct test_tot 0.1
 

}
