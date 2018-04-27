# Mesures des epaisseurs : base, emetteur, mesa d'isolation
# ===========================================================

namespace eval tpg {
Struct::new epais_2
    setLayer 2                              ;# Depot de titane #2
    brc 600 550

Struct::new epais_3
    setLayer 3                              ;# Mesa d'isolation emetteur
    brc 1000 650
    
Struct::new epais_7
    setLayer 7
    set c [Chemin::newFromString \
       {x=-700 y=-600;>1400;^600;I<400;Ev400;<600;^400;<400;v600;}]
    bfc $c
    Chemin::transform c miroir.axex
    bfc $c

Struct::new epais
sref epais_2 2250 1100
sref epais_2 2250 2900
sref epais_3 2250 1100
sref epais_3 2250 2900
sref epais_7 2250 2900

# displayWinStruct epais 0.1

}

