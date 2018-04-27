

## Systeme d'aligmenent avec croix et viseur de 40 microns
## ========================================================

namespace eval tpg {

Struct::new croix40_1
setLayer 1
    set c [Chemin::newFromString \
        {;Iv350;E>50;^100;>100;^100;>100;^100;>100;^50;I<350;}]
    bfc $c
    Chemin::transform c miroir.axex
    bfc $c
    Chemin::transform c miroir.axey
    bfc $c
    Chemin::transform c miroir.axex
    bfc $c

Struct::new viseur40_1
setLayer 1
    set c [Chemin::newFromString \
        {x=450;I<100;Ev150;<100;v100;<100;v100;<150;Iv100;I>450;I^450;}]
    bfc $c
    Chemin::transform c miroir.axex
    bfc $c
    Chemin::transform c miroir.axey
    bfc $c
    Chemin::transform c miroir.axex
    bfc $c

Struct::new protege40_3
setLayer 3
    boundary {;>2000;^3000;<1000;^1000;<1000;v4000;}

Struct::new n3_viseur40_1
setLayer 3
    set c [Chemin::newFromString \
        {y=-350;Iv100;>450;^450;I<100;Ev150;<100;v100;<100;v100;<150;}]
    bfc $c
    Chemin::transform c miroir.axex
    bfc $c
    Chemin::transform c miroir.axey
    bfc $c
    Chemin::transform c miroir.axex
    bfc $c

Struct::copieAllWithPrefix n2_ viseur40_1
Struct::setLayer n2_viseur40_1 2

Struct::copieAllWithPrefix n4_ viseur40_1
Struct::setLayer n4_viseur40_1 4

Struct::copieAllWithPrefix n5_ viseur40_1
Struct::setLayer n5_viseur40_1 5

Struct::copieAllWithPrefix n6_ viseur40_1
Struct::setLayer n6_viseur40_1 6

Struct::copieAllWithPrefix n7_ viseur40_1
Struct::setLayer n7_viseur40_1 7

Struct::copieAllWithPrefix n8_ viseur40_1
Struct::setLayer n8_viseur40_1 8

Struct::copieAllWithPrefix n9_ viseur40_1
Struct::setLayer n9_viseur40_1 9

Struct::new aligne40_1
sref croix40_1  500 3500                    ;# Croix 40 pour niveau #2
sref croix40_1 1500 3500                    ;# Croix 40 pour niveau #3
sref croix40_1  500 2500                    ;# Croix 40 pour niveau #4
sref croix40_1 1500 2500                    ;# Croix 40 pour niveau #5
sref croix40_1  500 1500                    ;# Croix 40 pour niveau #6
sref croix40_1 1500 1500                    ;# Croix 40 pour niveau #7
sref croix40_1  500  500                    ;# Croix 40 pour niveau #8
sref croix40_1 1500  500                    ;# Croix 40 pour niveau #9

Struct::new aligne40_2
sref n2_viseur40_1  500 3500                ;# Viseur 40 pour niveau #2

Struct::new aligne40_3
sref n3_viseur40_1 1500 3500                ;# Viseur 40 pour niveau #3
sref protege40_3 0 0

Struct::new aligne40_4
sref n4_viseur40_1  500 2500                ;# Viseur 40 pour niveau #4

Struct::new aligne40_5
sref n5_viseur40_1 1500 2500                ;# Viseur 40 pour niveau #5

Struct::new aligne40_6
sref n6_viseur40_1  500 1500                ;# Viseur 40 pour niveau #6

Struct::new aligne40_7
sref n7_viseur40_1 1500 1500                ;# Viseur 40 pour niveau #7

Struct::new aligne40_8
sref n8_viseur40_1  500  500                ;# Viseur 40 pour niveau #8

Struct::new aligne40_9
sref n9_viseur40_1 1500  500                ;# Viseur 40 pour niveau #9

Struct::new aligne40
setLayer 0                                  ;# Niveau de debugging (a ne pas fabriquer)
    brxy 0 0 2000 4000
    sref aligne40_1 0 0
    sref aligne40_2 0 0
    sref aligne40_3 0 0
    sref aligne40_4 0 0
    sref aligne40_5 0 0
    sref aligne40_6 0 0
    sref aligne40_7 0 0
    sref aligne40_8 0 0
    sref aligne40_9 0 0

# displayWinStruct aligne40 0.1

}
