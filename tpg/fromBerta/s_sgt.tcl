# Lignes TLM (Modele SGT) pour contacts de base
# =============================================

namespace eval tpg {

    set leChemin [Chemin::newFromString \
      {;>54;^82;>2;^28;x=152;I^8;Ex=54;y=200;x=0;y=110;>48;v20;x=0;y=0;}]
    Chemin::dilate leChemin 10

  Struct::new sgt_basecc_2                  ;# Titane #2 -> mesa court-circuit
   setLayer 2
    set c $leChemin
    bfc $c
    Chemin::transform c miroir.axey
    Chemin::translate c 3040 0
    bfc $c

  Struct::new sgt_basecc_3                  ;# Mesa isolation emetteur
   setLayer 3
    set c $leChemin
    bfc $c
    Chemin::transform c miroir.axey
    Chemin::translate c 3040 0
    bfc $c
  Struct::empate sgt_basecc_3 40

  Struct::new sgt_basecc_4                  ;# Metal court-circuit
   setLayer 4
    set c $leChemin
    bfc $c
    Chemin::transform c miroir.axey
    Chemin::translate c 3040 0
    bfc $c
  Struct::empate sgt_basecc_4 -20

  Struct::new sgt_baseccs_6                  ;# Sortie de contacts -> epais.
   setLayer 6
    brxy 40 40 460 820

  Struct::new sgt_basecc_6
   setLayer 6
    sref sgt_baseccs_6    0    0
    sref sgt_baseccs_6    0 1100
    sref sgt_baseccs_6 2500    0
    sref sgt_baseccs_6 2500 1100
    
  Struct::new sgt_baseli_2                    ;# Dépôt de Titane #2 -> isolation de la base
   setLayer 2
    brxy 0    0  15540 2000
    brxy 0 2500  15540 2000

  Struct::new sgt_baseli_3                    ;# Mesa d'isolation emetteur
   setLayer 3
    brxy -40   -40  15580 2080
    brxy -40  2460  15580 2080

    proc fantomes_b {dx interval dose} {
        setDose $dose
        set pas [expr $dx+$interval]
        set q1 [expr ((2000 - $interval) % ($dx + $interval))/2 + $interval]
        set q2 [expr (2000 - $dx - $interval)]
        for {set x $q1} {$x <= $q2} {set x [expr $x + $pas]} {
            brxy $x -20 $dx 2040
        }
        setDose 0
    }

   setLayer 4
  Struct::new fantome_b_1_5_4 ; fantomes_b  15 40 1
  Struct::new fantome_b_2_4   ; fantomes_b  20 40 2
  Struct::new fantome_b_3_4   ; fantomes_b  30 40 3
  Struct::new fantome_b_4_4   ; fantomes_b  40 40 4
  Struct::new fantome_b_6_4   ; fantomes_b  60 40 5
  Struct::new fantome_b_8_4   ; fantomes_b  80 40 6
  Struct::new fantome_b_15_4  ; fantomes_b 150 40 0
  Struct::new fantome_b_28_4  ; fantomes_b 280 40 0
  Struct::new fantome_b_60_4  ; fantomes_b 600 40 0

  Struct::new fantome_b_3s_4  ; fantomes_b  30 30 3
  Struct::new fantome_b_plein_4 ;  brxy 40 -20 2000 [expr 40 * 2 - 2040]
  
  Struct::new sgt_baseli_4                      ;# Contacts ohmiques
   setLayer 4
#    0 5000 sref sgt_basecc_4                 ;# Ligne de court-circuit
    set c0 [Chemin::rectangleXY 20 -20 500 2040]     ;# Plots contacts aiguilles
    set c $c0
                                 bfc $c 
    Chemin::translate c 2500 0 ; bfc $c
    Chemin::translate c 2500 0 ; bfc $c
    Chemin::translate c 2500 0 ; bfc $c
    Chemin::translate c 2500 0 ; bfc $c
    Chemin::translate c 2500 0 ; bfc $c
    Chemin::translate c 2500 0 ; bfc $c
    set c $c0 
    Chemin::translate c 0 2500 ; bfc $c
    Chemin::translate c 2500 0 ; bfc $c
    Chemin::translate c 2500 0 ; bfc $c
    Chemin::translate c 2500 0 ; bfc $c
    Chemin::translate c 2500 0 ; bfc $c
    Chemin::translate c 2500 0 ; bfc $c
    Chemin::translate c 2500 0 ; bfc $c

    set x 520
    set y 2500
                  sref fantome_b_1_5_4  $x $y
    incr x 2500 ; sref fantome_b_6_4    $x $y
    incr x 2500                               ;# Absence de fantome -> vide
    incr x 2500 ; sref fantome_b_28_4   $x $y
    incr x 2500 ; sref fantome_b_15_4   $x $y
    incr x 2500 ; sref fantome_b_8_4    $x $y

    set x 520
    set y 0
                  sref fantome_b_3s_4  $x $y ;# 3 special (en plus -/- a SGTLM)
    incr x 2500 ; sref fantome_b_4_4  $x $y
    incr x 2500 ; sref fantome_b_3_4  $x $y
    incr x 2500 ; sref fantome_b_plein_4  $x $y
    incr x 2500 ; sref fantome_b_60_4  $x $y
    incr x 2500 ; sref fantome_b_2_4  $x $y

  Struct::new sgt_baseli_6                   ;# Sortie de contacts -> epaiss.
   setLayer 6
#    0 0 sref sgt_basecc_6
    set c0 [Chemin::rectangleXY 40 20 460 1960] 
    set c $c0
                                 bfc $c 
    Chemin::translate c 2500 0 ; bfc $c
    Chemin::translate c 2500 0 ; bfc $c
    Chemin::translate c 2500 0 ; bfc $c
    Chemin::translate c 2500 0 ; bfc $c
    Chemin::translate c 2500 0 ; bfc $c
    Chemin::translate c 2500 0 ; bfc $c
    set c $c0 
    Chemin::translate c 0 2500 ; bfc $c
    Chemin::translate c 2500 0 ; bfc $c
    Chemin::translate c 2500 0 ; bfc $c
    Chemin::translate c 2500 0 ; bfc $c
    Chemin::translate c 2500 0 ; bfc $c
    Chemin::translate c 2500 0 ; bfc $c
    Chemin::translate c 2500 0 ; bfc $c

  Struct::new sgt_basecc
    sref sgt_basecc_2 0 0
    sref sgt_basecc_3 0 0
    sref sgt_basecc_4 0 0
    sref sgt_basecc_6 0 0
#  displayWinStruct sgt_basecc 0.1

  Struct::new sgt_baseli
    sref sgt_baseli_2 0 0
    sref sgt_baseli_3 0 0
    sref sgt_baseli_4 0 0
    sref sgt_baseli_6 0 0
#  displayWinStruct sgt_baseli 0.1

# Lignes TLM (Modele SGT) pour contacts d'emetteur
# =================================================

  Struct::new sgt_emetcc_3                         ;# Mesa isolation emetteur
   setLayer 3
    set c $leChemin
    bfc $c
    Chemin::transform c miroir.axey
    Chemin::translate c 3040 0
    bfc $c

  Struct::new sgt_emetcc_4                         ;# Metal court-circuit
   setLayer 4
    set c $leChemin
    bfc $c
    Chemin::transform c miroir.axey
    Chemin::translate c 3040 0
    bfc $c
  Struct::empate sgt_basecc_4 -20

  Struct::new sgt_emetccs_6                        ;# Sortie de contacts -> epais.
  setLayer 6
   brxy 40 40 460 820

  Struct::new sgt_emetcc_6
   setLayer 6
    sref sgt_baseccs_6    0    0
    sref sgt_baseccs_6    0 1100
    sref sgt_baseccs_6 2500    0
    sref sgt_baseccs_6 2500 1100

  Struct::new sgt_emetli_3                        ;# Mesa d'isolation emetteur
   setLayer 3
    brxy 0    0  15540 2000
    brxy 0 2500  15540 2000


    proc fantomes_e {dx interval dose} {
        setDose $dose
        set pas [expr $dx+$interval]
        set q1 [expr ((2000 - $interval) % ($dx + $interval))/2 + $interval]
        set q2 [expr (2000 - $dx - $interval)]
        for {set x $q1} {$x <= $q2} {set x [expr $x + $pas]} {
            brxy $x 20 $dx 1960
        }
        setDose 0
    }

  Struct::new fantome_e_1_5_4 ; fantomes_e  15 40 1
  Struct::new fantome_e_2_4   ; fantomes_e  20 40 2
  Struct::new fantome_e_3_4   ; fantomes_e  30 40 3
  Struct::new fantome_e_4_4   ; fantomes_e  40 40 4
  Struct::new fantome_e_6_4   ; fantomes_e  60 40 5
  Struct::new fantome_e_8_4   ; fantomes_e  80 40 6
  Struct::new fantome_e_15_4  ; fantomes_e 150 40 0
  Struct::new fantome_e_28_4  ; fantomes_e 280 40 0
  Struct::new fantome_e_60_4  ; fantomes_e 600 40 0

  Struct::new fantome_e_3s_4  ; fantomes_e  30 30 3
  Struct::new fantome_e_plein_4 ;  brxy 40 -20 2000 [expr 40 * 2 - 1960]

  Struct::new sgt_emetli_4                        ;# Contacts ohmiques
   setLayer 4
    set c0 [Chemin::rectangleXY 20 -20 500 1960]     ;# Plots contacts aiguilles
    set c $c0
                                 bfc $c 
    Chemin::translate c 2500 0 ; bfc $c
    Chemin::translate c 2500 0 ; bfc $c
    Chemin::translate c 2500 0 ; bfc $c
    Chemin::translate c 2500 0 ; bfc $c
    Chemin::translate c 2500 0 ; bfc $c
    Chemin::translate c 2500 0 ; bfc $c
    set c $c0 
    Chemin::translate c 0 2500 ; bfc $c
    Chemin::translate c 2500 0 ; bfc $c
    Chemin::translate c 2500 0 ; bfc $c
    Chemin::translate c 2500 0 ; bfc $c
    Chemin::translate c 2500 0 ; bfc $c
    Chemin::translate c 2500 0 ; bfc $c
    Chemin::translate c 2500 0 ; bfc $c

    set x 520
    set y 2500
                  sref fantome_e_1_5_4  $x $y
    incr x 2500 ; sref fantome_e_6_4    $x $y
    incr x 2500                               ;# Absence de fantome -> vide
    incr x 2500 ; sref fantome_e_28_4   $x $y
    incr x 2500 ; sref fantome_e_15_4   $x $y
    incr x 2500 ; sref fantome_e_8_4    $x $y

    set x 520
    set y 0
                  sref fantome_e_3s_4  $x $y ;# 3 special (en plus -/- a SGTLM)
    incr x 2500 ; sref fantome_e_4_4  $x $y
    incr x 2500 ; sref fantome_e_3_4  $x $y
    incr x 2500 ; sref fantome_e_plein_4  $x $y
    incr x 2500 ; sref fantome_e_60_4  $x $y
    incr x 2500 ; sref fantome_e_2_4  $x $y

  Struct::new sgt_emetli_6                        ;# Sortie de contacts -> epaiss.
   setLayer 6
    set c0 [Chemin::rectangleXY 40 40 460 1920] 
    set c $c0
                                 bfc $c 
    Chemin::translate c 2500 0 ; bfc $c
    Chemin::translate c 2500 0 ; bfc $c
    Chemin::translate c 2500 0 ; bfc $c
    Chemin::translate c 2500 0 ; bfc $c
    Chemin::translate c 2500 0 ; bfc $c
    Chemin::translate c 2500 0 ; bfc $c
    set c $c0 
    Chemin::translate c 0 2500 ; bfc $c
    Chemin::translate c 2500 0 ; bfc $c
    Chemin::translate c 2500 0 ; bfc $c
    Chemin::translate c 2500 0 ; bfc $c
    Chemin::translate c 2500 0 ; bfc $c
    Chemin::translate c 2500 0 ; bfc $c
    Chemin::translate c 2500 0 ; bfc $c

  Struct::new sgt_emetcc
    sref sgt_emetcc_3 0 0                         ;# Mesa d'isolation emetteur
    sref sgt_emetcc_4 0 0                           ;# Metal court-circuit
    sref sgt_emetcc_6 0 0                           ;# Sortie de contacts -> epaiss
#  displayWinStruct sgt_emetcc 0.1
  
  Struct::new sgt_emetli
    sref sgt_emetli_3 0 0
    sref sgt_emetli_4 0 0
    sref sgt_emetli_6 0 0
#  displayWinStruct sgt_emetli 0.1

}
