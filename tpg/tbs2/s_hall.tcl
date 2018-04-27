# Croix de Van der Pauw
# ======================

namespace eval tpg {

  Struct::new hall_emet_3                        ;# Mesa d'isolation emetteur
   setLayer 3
    brc 500 500

  Struct::new hall_emet_4                        ;# Contacts ohmiques
   setLayer 4
    set c [Chemin::rectangleCentre 28 28]
    Chemin::transform2 c rotation 45
    Chemin::translate c 500 500
    bfc $c
    Chemin::translate c -1000 0
    bfc $c
    Chemin::translate c 0 -1000
    bfc $c
    Chemin::translate c 1000 0
    bfc $c

  Struct::new hall_emet_6
   setLayer 6
    set c [Chemin::newFromString \
        {x=500 y=430;x=570 y=500;x=1500;y=1000;x=500;y=570;x=430 y=500;x=500 y=430;}]
    bfc $c
    Chemin::transform c miroir.axey
    bfc $c
    Chemin::transform c miroir.axex
    bfc $c
    Chemin::transform c miroir.axey
    bfc $c

  Struct::new hall_base_2              ;# Depot de titane #2 -> mesa de base
   setLayer 2
    set c [Chemin::newFromString \
      {x=460 y=500;<920;<40v40;v920;>40v40;>920;>40^40;^920;<40^40;}]
    bfc $c

  Struct::new hall_base_4               ;# Contacts ohmiques
   setLayer 4
    set c [Chemin::rectangleCentre 20 40]
    Chemin::transform2 c rotation 45
    Chemin::translate c 480 480
    bfc $c
    Chemin::translate c -960 -960
    bfc $c
    Chemin::transform c rotation90
    bfc $c
    Chemin::translate c -960 960
    bfc $c

  Struct::new hall_base_5                 ;# Arches de pont
   setLayer 5
   set c [Chemin::rectangleCentre 50 75]
    Chemin::transform2 c rotation 45
    Chemin::translate c 507 507
    bfc $c
    Chemin::translate c -1014 -1014
    bfc $c
    Chemin::transform c rotation90
    bfc $c
    Chemin::translate c -1014 1014
    bfc $c

  Struct::new hall_base_6                   ;# Sortie de contacts
   setLayer 6
    set c [Chemin::newFromString \
        {x=-75 y=-30;>150;I^60;E<150;v60;}]
    Chemin::transform2 c rotation 45
    Chemin::translate c 507 507
    bfc $c
    Chemin::transform c miroir.axey
    bfc $c
    Chemin::transform c miroir.axex
    bfc $c
    Chemin::transform c miroir.axey
    bfc $c
    set c [Chemin::newFromString \
        {x=1500 y=1000;x=540;y=580;Ix=580 y=540;Ex=1500;y=1000;}]
    bfc $c
    Chemin::transform c miroir.axey
    bfc $c
    Chemin::transform c miroir.axex
    bfc $c
    Chemin::transform c miroir.axey
    bfc $c

  Struct::new hall_base
    sref hall_base_2 0 0
    sref hall_base_4 0 0
    sref hall_base_5 0 0
    sref hall_base_6 0 0

Struct::new hall_emet
    sref hall_emet_3 0 0
    sref hall_emet_4 0 0
    sref hall_emet_6 0 0


# displayWinStruct hall_base 0.1

# displayWinStruct hall_emet 0.1
}
