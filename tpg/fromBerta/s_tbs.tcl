
# Transistors Bipolaires a heterojonction
# ========================================

proc tpg::tbs {nom l w} {
    global 50ohmi 50ohme
    set margeLentillesMasqueur 50 ;# enorme !!!

    set ws2 [expr $w/2]
    set ls2 [expr $l/2]

    # Dépôt de Titane #1
    
    Struct::new ${nom}_1
    setLayer 1
    
    brc $ws2 $ls2

    # Mésa d'isolation de l'emetteur

    Struct::new ${nom}_3
    setLayer 3
    brc [expr $ws2 + 70] [expr $ls2 + 15]

    # Contacts ohmiques

    Struct::new ${nom}_4
    setLayer 4
   
    brc [expr $ws2 + 85] [expr $ls2 + 30]

    # Arches de pont

    Struct::new ${nom}_5
    setLayer 5

    set c [Chemin::new      [expr  $ws2 + 20] [expr  $ls2 -  5]]
    Chemin::appendPoint c E [expr  $ws2 + 30] [expr  $ls2 + 85]
    Chemin::appendPoint c E [expr -$ws2 - 30] [expr  $ls2 + 85]
    Chemin::appendPoint c E [expr -$ws2 - 20] [expr  $ls2 -  5]
    Chemin::appendPoint c E [expr  $ws2 + 20] [expr  $ls2 -  5]
    bfc $c

    set c [Chemin::new      [expr  $ws2 + 20]   0]
    Chemin::appendPoint c E [expr -$ws2 - 20]   0
    Chemin::appendPoint c E [expr -$ws2 - 30] -90
    Chemin::appendPoint c E [expr  $ws2 + 30] -90
    Chemin::appendPoint c E [expr  $ws2 + 20]   0
    bfc $c

    # Sorties de contacts

    Struct::new ${nom}_6
    setLayer 6
   
    set xcoupe [expr $ws2 + 45]
    set ycoupe [expr $ls2 + 80]

return

    set courbe1 [Chemin::new 50ohmi]     				;# courbe de reference

    courbe1 0 ycoupe 20000 ycoupe chemin.coupe.simple 1 = NOT
     ABORT" COUPE INCORRECTE !!!" 				# coupe de jonction y donne
     courbe1 chemin.getlast DROP TO x_raccord			# recupere x jontion
     l50/2 unites 1600 EXTERNE courbe1 point+chemin		# extremite ligne cote pointe
     courbe1 new.chemin TO courbe2				# 
     courbe2 'i miroir.axey chemin.transforme courbe2 chemin.inverse	# 
     courbe1 new.chemin TO courbe3 				# 
     courbe2 new.chemin TO courbe4
     courbe1 INTERNE courbe2 chemin.rejoint courbe2 chemin.delete 
     courbe3 EXTERNE courbe4 chemin.rejoint courbe4 chemin.delete

     courbe3 new.chemin TO grosi			# ligne interne grossiere
     grosi margeLentillesMasqueur chemin.empate	# le bord cote pointe ne bouge pas
     grosi EXTERNE chemin.clos
     grosi chemin.supprime.papillons			# grosi est cree
     
     courbe3 margeLentillesMasqueur 2 * chemin.empate # cote interne du detourage
     courbe1 chemin.inverse
     courbe1 EXTERNE courbe3 chemin.rejoint courbe3 chemin.delete

     courbe1 EXTERNE chemin.clos
     courbe1 chemin.supprime.papillons
     courbe1 c>b
     
     courbe1 'i miroir.axex chemin.transforme
     courbe1 c>b
     
     courbe1 chemin.delete

     # == Construction du pont 
     0 new.chemin TO courbe1
     courbe1 EXTERNE w/2 30 - 10 MAX l/2 cpa
     courbe1 EXTERNE x_raccord ycoupe cpa
     courbe1 new.chemin TO courbe2
     courbe2 'i miroir.axey chemin.transforme courbe2 chemin.inverse
     
     courbe1 INTERNE courbe2 chemin.rejoint
     courbe2 chemin.delete
     courbe1 new.chemin TO courbe2
     courbe2 'i miroir.axex chemin.transforme courbe2 chemin.inverse
     courbe1 EXTERNE courbe2 chemin.rejoint courbe2 chemin.delete
     courbe1 EXTERNE chemin.clos
     courbe1 c>b courbe1 chemin.delete

     50ohme new.chemin TO courbe1    # courbe de reference ligne de masse
     courbe1 xcoupe 0 xcoupe 20000 chemin.coupe.simple 1 = NOT	# coupure 
     ABORT" COUPE INCORRECTE !!!"# coupe
     gl50/2 unites 1600 EXTERNE courbe1 point+chemin	# extremite cote pointe
     courbe1 new.chemin TO courbe2
     courbe2 'i miroir.axex chemin.transforme courbe2 chemin.inverse
     courbe1 EXTERNE courbe2 chemin.rejoint courbe2 chemin.delete 
     courbe1 new.chemin TO courbe3
     courbe1 new.chemin TO grose
     
     grose margeLentillesMasqueur NEGATE chemin.empate
     grose EXTERNE 1250 -1600 cpa
     grose INTERNE 1250 1600 cpa
     grose EXTERNE chemin.clos
     grose chemin.supprime.papillons
     
     courbe3 margeLentillesMasqueur 2 * NEGATE chemin.empate
     courbe3 chemin.inverse
     courbe1 EXTERNE courbe3 chemin.rejoint courbe3 chemin.delete

     courbe1 EXTERNE chemin.clos
     courbe1 chemin.supprime.papillons
     courbe1 c>b
     
     courbe1 'i miroir.axey chemin.transforme
     courbe1 c>b
     
     courbe1 chemin.delete
     
   7 niveau.lxw
     grosi c>b
     grosi 'i miroir.axex chemin.transforme
     grosi c>b
     grosi chemin.delete
     grose c>b
     grose 'i miroir.axey chemin.transforme
     grose c>b
     grose chemin.delete
    
    }



namespace eval tpg {


  Struct::new bloc_tbs
    setLayer 0                ;# Niveau de debugging (a ne pas fabriquer)
    brxy 0 0 20000 20000 
#    sref bloc_tbs_croix 0 0
#    sref bloc_tbs_transistors 0 0


  

    foreach {l w} {5 7 5 10 5 17 5 54 8 27 6 20 7 45 5 40} {
        set nom tbs${l}x${w}
        tbs $nom [expr $l*10] [expr $w*10]
      Struct::new $nom
        foreach i {1 3 4 5 6 7} {
            sref ${nom}_$i 0 0
        }
    }


  Struct::new tbs_a_pivoter
    foreach {l w} {5 7 5 10 5 17 5 54 8 27 6 20 7 45 5 40} {
        set nom tbs${l}x${w}
        sref ${nom} 0 0
    }

puts [list a faire  Struct::transforme tbs_a_pivoter test_tot 999]

  Struct::new element_bloc_tbs
    sref tbs8x27  2500 1250
    sref tbs5x10  7500 1250
    sref tbs5x54 12500 1250
    sref tbs5x7  17500 1250
    sref tbs5x40  2500 3750
    sref tbs6x20  7500 3750
    sref tbs5x17 12500 3750
    sref tbs7x45  17500 3750
    
  Struct::new fin_bloc_tbs
   setLayer 7                     ;# Sortie de contacts (gros faisceau)
    set c [Chemin::newFromString {x=900;>3200;^500;I<3200;Ev500;}]
                                 bfc $c
    Chemin::translate c 5000 0 ; bfc $c
    Chemin::translate c 5000 0 ; bfc $c
    Chemin::translate c 5000 0 ; bfc $c
    Chemin::transform c miroir.axex
    Chemin::translate c 0 16000 ; bfc $c
    Chemin::translate c -5000 0 ; bfc $c
    Chemin::translate c -5000 0 ; bfc $c
    Chemin::translate c -5000 0 ; bfc $c

  Struct::new bloc_tbs_croix
    sref aligne_tbs_80 3500 17500  ;# Systeme d'alignement croix-viseur de 80 microns

  Struct::new bloc_tbs_transistors
    sref fin_bloc_tbs     0  500  ;# Extension plan de masse des dispos de bord
    sref element_bloc_tbs 0  1000 ;# 1ere ligne de transistors
    sref element_bloc_tbs 0  6000 ;# 2eme ligne de transistors
    sref element_bloc_tbs 0 11000 ;# 3eme ligne de transistors
}

