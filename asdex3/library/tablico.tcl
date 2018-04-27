
proc choixMesuresV2 {typ} {
    
    global ASDEX
    set w $ASDEX(w)
    set pl $ASDEX(pl)
    set plx $ASDEX(plx)
    set ply $ASDEX(ply)
    set ASDEX(Typ) $typ
    
    set nlu 0
    $pl.messages configure -text $nlu

    $pl.c delete all
    $pl.ex delete all
    $pl.ey delete all
    
    $pl.c configure -scrollregion "[expr $ASDEX(BrutC:comin,$typ)*$plx-$plx/2] \
                                   [expr $ASDEX(BrutC:limin,$typ)*$ply-$ply/2] \
                                   [expr $ASDEX(BrutC:comax,$typ)*$plx+$plx/2] \
                                   [expr $ASDEX(BrutC:limax,$typ)*$ply+$ply/2]"
    $pl.ex configure -scrollregion "[expr $ASDEX(BrutC:comin,$typ)*$plx-$plx/2] 0 \
                                   [expr $ASDEX(BrutC:comax,$typ)*$plx+$plx/2] 30"
    $pl.ey configure -scrollregion "0 [expr $ASDEX(BrutC:limin,$typ)*$ply-$ply/2] \
                                   30 [expr $ASDEX(BrutC:limax,$typ)*$ply+$ply/2]"
                                   
    for {set li $ASDEX(BrutC:limin,$typ)} {$li<=$ASDEX(BrutC:limax,$typ)} {incr li} {
       $pl.ey create text 15 [expr $li*$ply] -text "$li" \
                     -anchor center
    }
    for {set co $ASDEX(BrutC:comin,$typ)} {$co<=$ASDEX(BrutC:comax,$typ)} {incr co} {
       $pl.ex create text [expr $co*$plx] 15 -text "$co" \
                     -anchor center
    }
    for {set li $ASDEX(BrutC:limin,$typ)} {$li<=$ASDEX(BrutC:limax,$typ)} {incr li} {
         for {set co $ASDEX(BrutC:comin,$typ)} {$co<=$ASDEX(BrutC:comax,$typ)} {incr co} {
             set pos [format %02d $li][format %02d $co]
             if {[catch {glob ${pos}_*.$typ} fichiers]} {
             } else {
                 $pl.c create text [expr $co*$plx] [expr $li*$ply] -text "[llength $fichiers]" \
                     -anchor center -tags [lico2tag $li $co]
                 incr nlu
                 $pl.messages configure -text $nlu
                 update
             }
         }
    }
}
