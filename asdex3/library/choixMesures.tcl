proc choixMesures {typ} {
    global ASDEX
    if {$ASDEX(dataVersion) == 3} {
        choixMesuresV3 $typ
    } elseif {$ASDEX(dataVersion) == 2} {
        choixMesuresV2 $typ
    }
}

proc choixMesuresV3 {typ} {
    global ASDEX
    set ASDEX(Typ) $typ
parray ASDEX
    set repertoire [lindex $ASDEX(Mesure) 1]
    set nature [lindex $ASDEX(Mesure) 0]
    
    if {$nature == "tbs2 tbs mesures"} {
        source $ASDEX(dirData)/$ASDEX(Plaque)/$ASDEX(Dispo)/mparams.tbs2_tbs.tcl
    }
}
