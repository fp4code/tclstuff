set EXEMPLE {

    package require fidev; package require spalab

    ini
    cd /home/asdex/data/L72228/L72228.1/hyper2
    set DISPO 63B5x17
    ::scilab::exec $tid load('[pwd]/${DISPO}.scilab')
    
    # ::scilab::exec $tid r=who()
    # set vars [::scilab::get $tid r]
    
    set PREFIXES [lindex [::scilab::get $tid _${DISPO}_prefixes] 3]
    set PREFIXES [lsort $PREFIXES]
    
    set prefix _63B5x17_180_14_
    
    # On passe à l'épluchage base commune.
    
    
    
    set PMOD(Cp)     0
    set PMOD(Lb)     0
    set PMOD(Lc)     0
    set PMOD(Le)     5e-12
    set PMOD(Rb)     18.
    set PMOD(rb)     0.
    set PMOD(cc_ext) 0.e-15
    set PMOD(ce_ext) 0.e-15
    set PMOD(Rc)     0
    set PMOD(Re)     0.
    set PMOD(Ro)     3.6e3
    set PMOD(Z0)     50
    set PMOD(Zrel)   1.0
    set PMOD(alpha0) 0.905
    set PMOD(cc)     8e-15
    set PMOD(ce)     3e-15
    set PMOD(m)      0.22
    set PMOD(nL)     700e-6
    set PMOD(re)     5.
    set PMOD(taub)   0.4e-12
    set PMOD(tauc)   0.4e-12
    set PMOD(typAlpha) 0
    
    
    
    # on recale tout
    

    # real(zcc)
    set PMOD(cc) 6e-15
    set PMOD(nL) 670e-6
    # deg(zcc) rebique dans les fréquences élevées. Une self négative fait du bien!
    set PMOD(Lc) -7e-10
    set PMOD(nL) 720e-6
    # 

    # examinons alpha

    # améliore la phase mais dégrade db:
    # m tauc 0.8e-12
    # m taub 0.8e-12
    # améliore la phase mais dégrade un peu db:
    # m m 1
    # ne change rien:
    # m nL 700e-6
    # améliore alpha à fréquence très élevée, mais dégrade à fréquence faible

    # h21 est déplorable
    # fréquence nulle, partie réelle
    set PMOD(alpha0) 0.912

    # partie réelle et imaginaire
    set PMOD(taub) 1.2e-12
    set PMOD(tauc) 0.65e-12
    # Il faut recaler real(cfit2)
    set PMOD(nL) 400e-6

    # zb est redevenu correct, mais zcc a perdu
    # h21 n'est pas beau à fréquence élevée
    set PMOD(cc) 8e-15
    set PMOD(Lc) -0.5e-9
    set PMOD(nL) 380e-6
    set PMOD(Lc) -0.4e-9

    # tout est beau, sauf à très haute fréquence real(zcc), real(h21) et U_mason
    # Noter qu'il suffit que taub+tauc reste constant

    # PROJET: mettre le alpha calculé dans le modèle.
    set PMOD(typAlpha) 0
    # m typAlpha 1


    set optim {

        optim 30e9 cc 1e-15 20e-15 taub 0.2e-12 2e-12 tauc 0.2e-12 2e-12 nL 300e-6 900e-6 Lc -1e-8 1e-8 Ro 2000 5000 Zrel 0.7 1.4 alpha0 0.8 0.95 ce 1e-15 100e-15 m 0 1 re 1 20


        #-> {1.30738341484e-15 1.20785012651e-12 6.51469404843e-13 0.000380000000003 -3.99999891459e-10 3600.0 1.0 0.912 3.70916813068e-15 0.22 5.0}

        # m cc 1.31e-15 taub 1.21e-12 tauc 0.65e-12 nL 380.e-6 Lc  -4e-10 Ro  3600.0 Zrel 1.0 alpha0 0.912 ce 3.71e-15 m 0.22 re 5.0
        # pas super jojo

        set PMOD(cc) 1.31e-15
        set PMOD(taub) 1.21e-12
        set PMOD(tauc) 0.65e-12
        set PMOD(nL) 380.e-6
        set PMOD(Lc)  -4e-10
        set PMOD(Ro)  3600.0
        set PMOD(Zrel) 1.0
        set PMOD(alpha0) 0.912
        set PMOD(ce) 3.71e-15
        set PMOD(m) 0.22
        set PMOD(re) 5.0

    }




    # Le modèle ne marche pas pour Rb !
    # Il y a un bug dans le calcul de nmod 0!
    # Si la longueur de ligne et Cp sont nuls, on trouve bien un real(zb) constant

    set PMOD(Cp)      0
    set PMOD(Lb)      0
    set PMOD(Lc)      0
    set PMOD(Le)      0
    set PMOD(Rb)      50
    set PMOD(Rc)      0
    set PMOD(Re)      1
    set PMOD(Z0)      50
    set PMOD(Zrel)    1.0
    set PMOD(alpha0)  0.905
    set PMOD(cc)      5e-15
    set PMOD(ce)      1e-15
    set PMOD(Ro)      2e3
    set PMOD(m)       0.22
    set PMOD(nL)      0e-6
    set PMOD(re)      52
    set PMOD(taub)    0.4e-12
    set PMOD(tauc)    0.4e-12

    # ajustement de Rb

    set PMOD(Rb) 30.
    set PMOD(Re) 0
    set PMOD(re) 2.5
    # m nL 400e-6
    # La ligne fait du bien à zb à fréquence faible, mais il faut diminuer Rb, et augmenter re
    set PMOD(nL) 400e-6
    set PMOD(Rb) 26.
    set PMOD(re) 5.
    # m ce 100e-15
    # pas bon
    set PMOD(ce) 10e-15
    set PMOD(Rb) 20.
    set PMOD(re) 4.
    set PMOD(Re) 1.
    # m re 5 Re 0.
    # On est bien calé à fréquence nulle real(zb) pas beau
    set PMOD(re) 5.
    set PMOD(Re) 0.
    # m Lb 1e-11
    # m Cp 2e-15
    # m Zrel 0.9
    # m ce 100e-15
    # m Zrel 1.2
    set PMOD(nL) 500e-6
    set PMOD(Zrel) 1.2
    # m Zrel 1.3
    # real(efit) -> ajuster Cbe
    set PMOD(ce) 3e-15
    m Le 1e-11 nL 600e-6
    # imag(efit1) -> ajuster Cbe
    set PMOD(Le) 5e-12
    # imag(efit1) -> créer une résonance à 35 GHz -> LC=2.1e-23

    # On passe au collecteur
    # ajustement de Ro
    set PMOD(Ro) 3.7e3
    # Noter que cela trouble les courbes précédentes
    # 
    # m cc 10e-15
    set PMOD(cc) 5e-15
    # on a un beau zcc
    # on revient à zb
    set PMOD(Rb) 18.
    set PMOD(Ro) 3.6e3
    set PMOD(cc) 8e-15
    # on est content. Reste cfit2. Il un superbe pôle. Il faut introduire Rc
    m Lc 5e-12
    m Rc 0.1
    # On a une magnifique parabole sur imag(cfit2), et une résonance sur la partie réelle
    # La parabole, c'est Cbc
    m cc 12e-15
    # mais cele détraque un peu tout, et ne change pas la résonance. celle-ci vient de la ligne
    set PMOD(nL) 750e-6
    # elle existe aussi avec Zrel=1. essayons
    set PMOD(Zrel) 1.0
    set PMOD(nL) 700e-6
    # Mainteneant un est dans les choux un peu de partout, mais la résonance définit très bien la ligne
    # donc on la garde

    # on essaye avec une grosse self dans le collecteur
    set PMOD(nL) 500e-6
    # m Lc 2e-9
    # Il faut plus de 2e-9. Cela entraine des rénonances innacceptables
    set PMOD(nL) 700e-6
    set PMOD(nL) 650e-6




    ##############################################################



}






set EXEMPLE_DE_CREATION_DE_FICHIERS_AVEC_SCILAB {

    file delete /home/fab/tmp/_63B5x17_180_14_h21.dat
    ::scilab::exec $tid {write('/home/fab/tmp/_63B5x17_180_14_h21.dat',\
            [_63B5x17_180_14_f, sparams_rimp(_63B5x17_180_14_h21), sparams_rimp(q4_h21)],\
            '(9(1X,E9.3))')}
    file delete /home/fab/tmp/_63B5x17_180_14_U.dat
    ::scilab::exec $tid {write('/home/fab/tmp/_63B5x17_180_14_U.dat',\
            [_63B5x17_180_14_f, sparams_rimp(_63B5x17_180_14_U), sparams_rimp(q4_U)],\
            '(9(1X,E9.3))')}

    file delete /home/fab/tmp/_63B5x17_180_14_zb.dat
    ::scilab::exec $tid {write('/home/fab/tmp/_63B5x17_180_14_zb.dat',\
            [_63B5x17_180_14_f, sparams_rimp(_63B5x17_180_14_zb), sparams_rimp(q4_zb)],\
            '(9(1X,E9.3))')}
}

set EXEMPLE_D'EXPLORATION_MULTIPLE {

    puts $gp "set nolog x"
    puts $gp {set yrange [-10:0]}
    set i 0

    foreach prefix $PREFIXES {
        puts $gp "set ter X11 $i"
        puts $gp {set yrange [-100:0]}
        set v ${prefix}s22
        ::scilab::exec $tid "\[${v}p, m\] =  phasemag(${v})"
        plot ${prefix}f ${v}p
        ::scilab::exec $tid "clear ${v}p"
        #    incr i
    }
}




set prefix _63B5x17_100_14_
set PMOD(Cp) 0
set PMOD(Lb) 0
set PMOD(Lc) 0
set PMOD(Le) 5e-12
set PMOD(Rb) 25
set PMOD(Rc) 0
set PMOD(Re) 0.
set PMOD(Ro) 10e3
set PMOD(Z0) 50
set PMOD(Zrel) 1.0
set PMOD(alpha0) 0.912
set PMOD(cc) 30e-15
set PMOD(cc_ext) 0.e-15
set PMOD(ce) 3e-15
set PMOD(m) 0.22
set PMOD(nL) 200e-6
set PMOD(rb) 0.
set PMOD(re) 17
set PMOD(taub) 1.2e-12
set PMOD(tauc) 0.65e-12
set PMOD(typAlpha) 0


proc plotall {} {
    uplevel {
	puts $gp {set nologscale x}
	puts $gp {set xrange [0e9:50e9]}
	aplot zb {} {} {} {}
	aplot ze {} {} {} {}
#	aplot ze {0:0.5} {-0.5:0} {-40:0} {-90:0}
	aplot efit1 {} {} {} {}
#	aplot efit2 {0:50} {-20:20} {-40:40} {-360:0}
	puts $gp {set logscale x}
	puts $gp {set xrange [0.5e9:50e9]}
	aplot zcc {} {} {} {}
	aplot cfit1 {} {} {} {}
	aplot s11 {} {} {} {}
	aplot s12 {} {} {} {}
	aplot s21 {} {} {} {}
	aplot s22 {} {} {} {}
	aplot h21 {} {} {} {}
#	aplot cfit2 {-10:10} {0:0.05} {-40:40} {-360:0}
#	aplot alpha {0:1} {-1:0} {-20:0}  {-90:0}
    }
}


set rien {{
#	puts $gp {set xrange [8e9:14e9]}
#	puts $gp {set xrange [.5e9:10e9]}
#	aplot cfit2 {-50:50} {0:0.005} {-40:40} {-360:0}
#	aplot h21 {0:15} {-15:0} {5:25} {-90:0}
#	aplot racU {0:15} {0:10} {5:25} {0:90}
#	puts $gp {set nologscale x}
#	aplot bs21 {-10:10} {-10:10} {0:20} {-360:0}
#	aplot bs22 {0:2} {-2:0} {-5:5} {-90:0}
#	aplot s11 {-1:1} {-1:1} {-20:0} {-360:0}
#	aplot s12 {0:0.05} {0.:0.05} {-40:-20} {-360:-270}
#	aplot s21 {-10:10} {-10:10} {0:20} {-360:0}
#	aplot s22 {0:1} {-1:0} {-5:0} {-90:0}
    }
}


set PMOD(Rb) 17
# zb n'est pas idéal, mais ze a l'air bien
set PMOD(Re) 0
set PMOD(re) 7
# même re=0 ne convient pas en fait
set PMOD(nL) 500e-6

set PMOD(nL) 350e-6
# on voit une asymptote à fréquence élevée. Est-ce Re?

set PMOD(Re) 2.
set PMOD(re) 6.
set PMOD(ce) 5000e-15
set PMOD(re) 3.
set PMOD(ce) 7000e-15
# on affine real(ze)
set PMOD(Re) 1.8
set PMOD(re) 3.2
set PMOD(Le) 1e-11

set PMOD(ce) 100e-15
set PMOD(Le) 6e-11
set PMOD(ce) 7000e-15
set PMOD(Le) 0
set PMOD(ce) -4000e-15
# ce c'est fou!
set PMOD(re) 4
set PMOD(Re) 1
# pas mal sauf à haute fréquence.
# real(zb) on choisit le comportement a f élevée
set PMOD(Rb) 35.
# passons à cc
# négatif encore !
set PMOD(cc) -15e-15
set PMOD(cc) -13e-15

# autre essai
set PMOD(nL) 500e-6
set PMOD(Lc) 0
set PMOD(cc) -14e-15

set SPIEGEL {
    # article de spiegel
    proc plotall {} {
        uplevel {
            puts $gp {set logscale x}
            puts $gp {set xrange [0.1e9:100e9]}
            aplot s11 {-0.5:1} {-0.5:1} {} {-360:0}
            aplot s12 {-0.05:0.2} {-0.05:0.2} {} {-360:-270}
            aplot s21 {-10:10} {-10:10} {0:20} {-360:0}
            aplot s22 {-0.5:1.0} {-0.5:1.0} {-5:0} {-90:0}
            aplot spiegel {0:40} {0:200} {} {}
            aplot spiegel2 {} {0:200} {} {}
            aplot h21 {} {} {0:50} {}
        }
    }
    
    set PMOD(Z0) 50.
    set PMOD(nL) 0
    set PMOD(Zrel) 1.0
    set PMOD(Cp) 0
    set PMOD(cc_ext) 0
    set PMOD(cc) 17e-15
    set PMOD(re) 3.
    set PMOD(Re) 7
    set PMOD(taud) 0.56e-12
    set PMOD(ce) 100e-15
    set PMOD(Rc) 4.
    set PMOD(Lc) 106e-12
    set PMOD(rb) 42.
    set PMOD(Rb) 7.
    set PMOD(Le) 108e-12
    set PMOD(Lb) 94e-12
    set PMOD(Ro) 1e6
    set PMOD(alpha0) 0.991
    set prefix A9_
    ::scilab::exec $tid {A9_f=10^([8:0.02:log10(40e9)])}

    m cc 7.73e-15 cc_ext 9.27e-15

} ;# fin SPIEGEL


set ETUDE_63B5x17_020_14_ {

    # 15 juillet 1999

    set prefix _63B5x17_020_14_

    proc plotall {} {
        uplevel {
            puts $gp {set nologscale x}
            puts $gp {set xrange [0e9:50e9]}
            aplot zb {} {} {} {-360:0}
            aplot ze {} {} {} {-360:0}
            #	aplot efit1 {} {} {} {}
            puts $gp {set logscale x}
            puts $gp {set xrange [0.5e9:50e9]}
            aplot zcc {} {} {} {-360:0}
            aplot zcc {} {-0.5:0.5} {} {-360:0}
            puts $gp {set nologscale x}
            puts $gp {set xrange [0e9:50e9]}
            aplot unsurzcc {} {} {} {-360:0}
            aplot alpha {} {} {}  {}
            aplot s11 {} {} {} {-360:0}
            aplot s12 {} {} {} {-360:0}
            aplot s21 {} {} {} {-360:0}
            aplot s22 {} {} {} {}
            aplot h21 {} {} {} {-360:0}
            aplot racU {} {-1:1} {} {-1:1}
            #	aplot cfit2 {-30:30} {0:0.05} {-40:40} {-360:0}
        }
    }


    set PMOD(Z0) 50.
    set PMOD(nL) 0
    set PMOD(Zrel) 1.0
    set PMOD(Cp) 0
    set PMOD(cc_ext) 0
    set PMOD(cc) 10e-15
    set PMOD(re) 10.
    set PMOD(Re) 0.
    set PMOD(taub) 1e-12
    set PMOD(tauc) 1e-12
    set PMOD(ce) 10e-15
    set PMOD(Rc) 0.
    set PMOD(rb) 0.
    set PMOD(Rb) 7.
    set PMOD(Le) 0.e-12
    set PMOD(Lb) 0.e-12
    set PMOD(Lc) 0.e-12
    set PMOD(Ro) 1e6
    set PMOD(alpha0) 0.9


    # Les db de ze, ze et zcc descendent régulièrement
    # faute de mieux:
    set PMOD(nL) 350e-6

    # On ajuste real(zb)
    set PMOD(Rb) 22.

    # real(ze) à fréquence faible :
    set PMOD(re) 17.

    # real(zcc) à fréquence faible

    set PMOD(cc) 10e-15
    set PMOD(Ro) 45e3
    # 1/(Ro*cc) = 2e9

    set PMOD(cc) 11e-15

    # dégrade real: améliore imag
    # m cc 12e-15 

    # real(zz) devient négatif. On corrige avec nL
    set PMOD(nL) 500e-6 
    # trop
    set PMOD(nL) 400e-6 

    # db(zcc) descend bien droit avec log(f). En fait, Ro*cc*omega est >> 1
    set PMOD(cc) 10e-15

    # la phase de cc remonte trop
    set PMOD(nL) 350e-6

    # à fréquence basse, real(cc) est trop faible, imag(cc) pas assez négatif
    # real dégradé, imag ok:
    # m Ro 55e3
    # real bon, imag un peu meilleur
    # m cc 9e-15
    # real bon, imag trop corrigé
    m  cc 9e-15 Ro 55e3
    # bon à fréquence basse, mais pente de db incorrecte
    m  cc 9e-15 Ro 50e3

    # La partie réelle de 1/zcc permet de trouver nL et Ro
    # La partie imaginaire cc
    set PMOD(Ro) 45e3
    set PMOD(cc) 11e-15

    set PMOD(Zrel) 1.0
    set PMOD(nL) 370e-6
    # noter une grosse anomalie sur real(1/zcc) à 35 Ghz

    set PMOD(Zrel) 1.2
    set PMOD(nL) 480e-6

    set PMOD(Zrel) 0.8
    set PMOD(nL) 320e-6

    # Il faut indroduire un Rc assez conséquent pour suivre real(1/zcc)
    set PMOD(Zrel) 0.8
    set PMOD(nL) 320e-6
    set PMOD(Rc) 40.
    set PMOD(cc) 10e-15

    set PMOD(Zrel) 1.0
    set PMOD(nL) 420e-6
    set PMOD(Rc) 65.
    set PMOD(cc) 11e-15

    # l'anomalie à 35 GHz correspond très bien à un aller-retour dans la ligne!


    set PMOD(Zrel) 0.5
    set PMOD(nL) 300e-6
    set PMOD(Rc) 65.
    set PMOD(cc) 11e-15

    # tout est plus doux!


    set PMOD(Zrel) 0.7
    set PMOD(nL) 300e-6
    set PMOD(Rc) 120.
    set PMOD(cc) 10e-15

    set PMOD(Zrel) 0.6
    set PMOD(nL) 280e-6
    set PMOD(Rc) 120.
    set PMOD(cc) 10e-15

    set PMOD(Zrel) 0.5
    set PMOD(nL) 260e-6
    set PMOD(Rc) 400.
    set PMOD(cc) 9e-15

    set PMOD(Zrel) 1.0
    set PMOD(nL) 400.e-6
    set PMOD(nL) 0
    set PMOD(nL) -100e-6
    set PMOD(nL) -350e-6
    set PMOD(nL) 350e-6


    set PMOD(nL) 500e-6

    # m cc 9e-15


    # On veut étudier les conséquences des lignes

    set PMOD(Zrel) 1.0
    set PMOD(nL) 0

    mm 0 0 1 1 360e-6 400e-6

    # L'impédance Zrel ne change rien sur s12 et s21


    # 10 fF de pad dégrade db(zb) 
    # mm 10e-15  0 1.0 1.0 400e-6 400e-6
    # mm 10e-15  0 1.0 1.0 350e-6 350e-6


    # Difficile de connaitre les lignes. Tout ce que l'on sait, c'est que leur longueur est de 150um, moins la longueur des pointes.
    # Elle est donc comprise entre 100 et 150um. Fois 3.5 -> nL entre 350e-6 et  525e-6

    # Hypothèse 1:
    set PMOD(Cp) 0.
    set PMOD(nL) 420e-6
    set PMOD(Zrel) 1.
    # -> Rb entre 13. et 18.
    set PMOD(Rb) 15.5
    # Un souci pour imag(zb), qui décroit !
    # -> diminuer nL
    # pas d'effet de Zrel
    # -> effet négatif de Cp
    # voir plus tard cc_ext
    set PMOD(Lb) 0

    # ze: 
    set PMOD(re) 18.3
    # il faut faire descendre imag(ze)
    # -> il faut raccourcir la ligne. Encore!


    ##################################################
    # 16 juillet 1999

    proc plotall {} {
        uplevel {
            puts $gp {set nologscale x}
            puts $gp {set xrange [0e9:50e9]}
            aplot zb {} {} {} {-360:0}
            aplot ze {} {} {} {-360:0}
            #	aplot efit1 {} {} {} {}
            puts $gp {set logscale x}
            puts $gp {set xrange [0.5e9:50e9]}
            aplot zcc {} {} {} {-360:0}
            puts $gp {set xrange [0.5e9:5e9]}
            aplot zcc {} {} {} {-360:0}
            puts $gp {set nologscale x}
            puts $gp {set xrange [0e9:50e9]}
            aplot unsurzcc {} {} {} {-360:0}
            puts $gp {set logscale x}
            puts $gp {set xrange [0.5e9:50e9]}
            aplot alpha {} {} {}  {}
            puts $gp {set nologscale x}
            puts $gp {set xrange [0e9:50e9]}
            aplot s11 {} {} {} {-360:0}
            aplot s12 {} {} {} {-360:0}
            aplot s21 {} {} {} {-360:0}
            aplot s22 {} {} {} {}
            puts $gp {set logscale x}
            puts $gp {set xrange [0.5e9:50e9]}
            aplot h21 {} {} {} {-360:0}
            aplot racU {} {-1:1} {} {-1:1}
            #	aplot cfit2 {-30:30} {0:0.05} {-40:40} {-360:0}
        }
    }


    # l'accident à 35 GHz est sur s22
    set prefix _63B5x17_250_15_
    set PMOD(Rp) 0.
    set PMOD(Cp) 0.
    set PMOD(nL) 0
    set PMOD(Zrel) 1.
    # Mauvais calibrage ?


    set prefix _63B5x17_250_15_
    set PMOD(Cp) 0.
    set PMOD(nL) 350e-6
    set PMOD(Zrel) 1.
    # 
    set PMOD(Rb) 30.
    set PMOD(rb) 0.
    set PMOD(Lb) 0.

    set PMOD(re) 4.7
    set PMOD(Re) 0.
    set PMOD(Le) 13e-12
    set PMOD(ce) 0.

    set PMOD(cc) 11.5e-15
    set PMOD(Ro) 0.42e3
    set PMOD(Rc) 0.
    set PMOD(Lc) 0.

    # La partie réelle de 1/zcc ne dvrait pas chuter

    set PMOD(Cp) 0.
    set PMOD(nL) 400e-6
    set PMOD(Zrel) 0.85

    set PMOD(Rb) 30.
    set PMOD(rb) 0.
    set PMOD(Lb) 0.

    set PMOD(re) 4.7
    set PMOD(Re) 0.
    set PMOD(Le) 16e-12
    set PMOD(ce) 0.
    # ze est impeccable jusqu'à 25 GHz

    set PMOD(cc) 10e-15
    set PMOD(Ro) 0.43e3
    set PMOD(Rc) 0.
    set PMOD(Lc) 0.
    # real(zc) pas terrible à fréquence basse (mauvais signe)
    # sauf à rendre la longueur de ligne nulle, on ne s'en débarrasse pas. Voir aussi cc_ext

    set PMOD(alpha0) 0.9
    set PMOD(taub) 0.8e-12
    set PMOD(tauc) 0.8e-12


    set PMOD(taub) 1.8e-12
    set PMOD(tauc) 0.01e-12
    set PMOD(cc_ext) 2e-15
    set PMOD(cc) 8e-15

    set PMOD(Rb) 22.
    set PMOD(rb) 8.

    # real(alpha) parfait:  m taub 2e-12

    set PMOD(taub) 2e-12
    set PMOD(cc_ext) 2e-15
    # similaire:
    # m taub 1.8e-12 cc_ext 2.5e-15
    # real(alpha) inchangé, imag dégradé
    # m taub 1.4e-12 tauc 0.6e-12
    
    # alpha ne dépend pas de Lc +-100e-12
    # imag remonte avec cc 7e-15
    # mieux: diminuer nL



    set PMOD(tauc) 0.1e-12
    set PMOD(ce) 20e-15
    # optim 30e9 Lb 0 100e-12 Lc 0 100e-12 Le 0 100e-12 Rb 0 40 Rc 0 20 Re 0 6 re 0 6 Ro 400 460 Zrel 0.7 1.2 alpha0 0.85 0.93 cc_ext 0 9e-15 ce 20e-15 500e-15 nL 330e-6 550e-6 rb 0 40 taub 0.1e-12 3e-12 tauc 0.1e-12 3e-12
    # OUBLI de cc!

    # -> 16 1 DOUBLE {0.0 9.60387606795e-16 1.60019182653e-11 22.0 1.40890469424e-15 0.0 4.7 430.0 0.85 0.9 5.27718517213e-15 2.0572114945e-14 0.0004 8.0 2.00221323194e-12 1e-13}
    # -> 1 1 DOUBLE 16.6961211149

    # 0.0 9.60387606795e-16 1.60019182653e-11 22.0 1.40890469424e-15 0.0 4.7 430.0 0.85 0.9 5.27718517213e-15 2.0572114945e-14 0.0004 8.0 2.00221323194e-12 1e-13

    set PMOD(Lb) 0.
    set PMOD(Lc) 9.6e-16
    set PMOD(Le) 16e-12
    set PMOD(Rb) 22. 
    set PMOD(Rc) 1.4e-15
    set PMOD(Re) 0.
    set PMOD(re) 4.7
    set PMOD(Ro) 430. 
    set PMOD(Zrel) .85 
    set PMOD(alpha0) 0.9
    set PMOD(cc_ext) 5.28e-15 
    set PMOD(ce) 20.6e-15
    set PMOD(nL) 400e-6
    set PMOD(rb) 8.0
    set PMOD(taub) 2e-12 
    set PMOD(tauc) 0.1e-12 

    # oubli de cc!


    # excellent fit sur s22

    set prefix  _63B5x17_250_14_

    set PMOD(Rb) 19.5
    set PMOD(re) 5.1
    set PMOD(Le) 14e-12
    set PMOD(Ro) 900.
    # cc_ext fait du bien à zb
    set PMOD(cc_ext) 5e-15
    set PMOD(cc) 3.8e-15
    # en module, alpha est bien
    # reste la phase
    set PMOD(m) 0.3
    set PMOD(taub) 1.4e-12
    set PMOD(m) 0.5
    set PMOD(taub) 0.8e-12
    set PMOD(tauc) 0.01e-12
    # étude sur h21 et U
    set PMOD(taub) 1.2e-12
    # excellent h21
    # ne change pas U, dégrade h21:
    # m tauc 0.4e-12
    # ne change pas h21, diminue (améliore U):
    # m cc 6e-15
    # noter que s12 est excellent jusqu'à 25 GHz
    # On peut encore améliorer le creux de zcc:
    set PMOD(Lc) 200e-12
    set PMOD(cc) 3.4e-15
    # améliorer s11:
    set PMOD(Lb) 10e-12
    # set PMOD(m) 1
    set PMOD(m) 0.22
    set PMOD(taub) 1.6e-12

    # On a une nouvelle formule pour alpha, à partir de zcc-Rc-i om Lc
    # impossible de faire descendre plus vite real(alpha)
    # avec les tau
    # m cc 5e-15 tauc 0.4e-12
    # en augmentant cc, on peux
    # INUTILES: Rb rb taub(2.5 ps -> parvient en dessous de 30 GHz) tauc
    # ce perturbe la partie imag.
    # UTILES: 
    #  Le Ro Rp typAlpha   Rc Zrel cc_ext alpha0 re Re nL Z0 Cp m Lb cc Lc
    # m Rc 20 Ro  870.
    set PMOD(Rc) 1.5
    set PMOD(Ro) 899
    set PMOD(alpha0) 0.904
    # s21 est mal fitté

    # essai d'amélioration du transistor
    set PMOD(taub) 0.5e-12
    set PMOD(rb) 24
    set PMOD(Rb) 60.
    # là Ft est comparable, mais avec une pente classique!












    # Voyant s11 et s22, on est certain de la présence d'une résonance sur les lignes.
    # Il manque un terme de perte pour voir le pic
    set PMOD(Rp) 5.
    # La 

    set PMOD(Cp) 0.
    set PMOD(nL) 0
    set PMOD(Zrel) 1.
    # On n'y arrive pas. On se limite donc à 30 GHz avant de refaire les mesures

    set PMOD(Rp) 0.
    set PMOD(Cp) 0.
    set PMOD(nL) 400e-6
    set PMOD(Zrel) 0.85


    # 19 juillet 1999

    proc plotall {} {
        uplevel {
            puts $gp {set nologscale x}
            puts $gp {set xrange [0e9:50e9]}
            aplot zb {} {} {} {-360:0}
            aplot ze {} {} {} {-360:0}
            #	aplot efit1 {} {} {} {}
            puts $gp {set logscale x}
            puts $gp {set xrange [0.5e9:50e9]}
            aplot zcc {} {} {} {-360:0}
            puts $gp {set nologscale x}
            puts $gp {set xrange [0:5e9]}
            aplot zcc {} {} {} {}
            puts $gp {set xrange [0e9:50e9]}
            aplot unsurzcc {} {} {} {-360:0}
            aplot alpha {} {} {}  {}
            aplot zce {} {} {} {}
            puts $gp {set nologscale x}
            puts $gp {set xrange [0e9:50e9]}
            aplot s11 {} {} {} {-360:0}
            aplot s12 {} {} {} {-360:0}
            aplot s21 {} {} {} {-360:0}
            aplot s22 {} {} {} {}
            puts $gp {set logscale x}
            puts $gp {set xrange [0.5e9:200e9]}
            aplot h21 {} {} {} {-360:0}
            aplot racU {} {-1:1} {} {-1:1}
            #	aplot cfit2 {-30:30} {0:0.05} {-40:40} {-360:0}
        }
    }

    set prefix _63B5x17_250_15_
    set PMOD(Z0) 50
    set PMOD(nL) 400e-6
    set PMOD(Cp) 0.
    set PMOD(Rp) 0.
    set PMOD(Rb) 22.
    set PMOD(rb) 8.0
    set PMOD(Lb) 0.
    set PMOD(re) 4.7
    set PMOD(Re) 0.
    set PMOD(ce) 20.6e-15
    set PMOD(Le) 16e-12
    set PMOD(Ro) 430.
    set PMOD(cc) 6e-15
    set PMOD(cc_ext) 5.28e-15
    set PMOD(Rc) 1.4e-15
    set PMOD(Lc) 9.6e-16
    set PMOD(alpha0) 0.9
    set PMOD(m) 0.22
    set PMOD(taub) 2e-12
    set PMOD(tauc) 0.1e-12
    set PMOD(Zrel) .85
    set PMOD(ce_ext) 0
    set PMOD(typAlpha) 0

    # s21 pas terrible


    # ramzi:

    set prefix _63B5x17_180_14_
    set PMOD(Z0) 50
    set PMOD(Zrel) 1.0
    set PMOD(nL) 350e-6
    set PMOD(Cp) 0
    set PMOD(Rp) 0
    set PMOD(Rb) 18.
    set PMOD(rb) 0.
    set PMOD(Lb) 0.5e-12
    set PMOD(re) 5.
    set PMOD(Re) 0.13
    set PMOD(ce) 200e-15
    set PMOD(Le) 10e-12
    set PMOD(Ro) 3.8e3
    set PMOD(cc) 8e-15
    set PMOD(cc_ext) 0.
    set PMOD(Rc) 10
    set PMOD(Lc) 250e-15
    set PMOD(alpha0) 0.912
    set PMOD(m) 0.22
    set PMOD(taub) 0.98e-12
    set PMOD(tauc) 0.07e-12
    set PMOD(ce_ext) 0.
    set PMOD(typAlpha) 0
    # real(zcc) incorrect
    set PMOD(Ro) 3.6e3
    # max
    set PMOD(Rc) 7
    set PMOD(Rc) 0
    fitalphaTer 2 30e9

    set PMOD(typAlpha) 1
    set PMOD(numer) {[0.912927666877 1.08869435449e-12 -5.52160202197e-24]}
    set PMOD(denom) {[0.999928150491 2.25285825292e-12 -7.27987732956e-24]}

    # etude de ze


    _63B5x17_020_14_ _63B5x17_040_14_ _63B5x17_060_14_ _63B5x17_080_14_ _63B5x17_100_14_ _63B5x17_120_14_ _63B5x17_140_14_ _63B5x17_160_14_ _63B5x17_180_14_ _63B5x17_200_14_ _63B5x17_210_14_ _63B5x17_220_12_ _63B5x17_220_13_ _63B5x17_220_14_ _63B5x17_220_15_ _63B5x17_230_14_ _63B5x17_250_14_ _63B5x17_250_15_


    set prefix _63B5x17_020_14_
    set PMOD(re) 17.

    set prefix _63B5x17_040_14_
    set PMOD(re) 11.

    set prefix _63B5x17_060_14_
    set PMOD(re) 8.7

    set prefix _63B5x17_080_14_
    set PMOD(re) 7.

    set prefix _63B5x17_100_14_
    set PMOD(re) 7.

    set prefix _63B5x17_120_14_
    set PMOD(re) 6.2

    set prefix _63B5x17_140_14_
    set PMOD(re) 5.8

    set prefix _63B5x17_160_14_
    set PMOD(re) 5

    set prefix _63B5x17_180_14_
    set PMOD(re) 5

    set prefix _63B5x17_200_14_
    set PMOD(re) 4.9

    set prefix _63B5x17_210_14_
    set PMOD(re) 5.2

    set prefix _63B5x17_220_12_
    set PMOD(re) 5.

    set prefix _63B5x17_220_13_
    set PMOD(re) 

    set prefix _63B5x17_220_14_
    set PMOD(re) 

    set prefix _63B5x17_220_15_
    set PMOD(re) 

    set prefix _63B5x17_230_14_
    set PMOD(re) 

    set prefix _63B5x17_250_14_
    set PMOD(re) 

    set prefix _63B5x17_250_15_
    set PMOD(re) 4.8

    # 

    set PREFIX _63B5x17_180_14_
    # fitalpha 2
    set PMOD(numer) {[0.914053331333 2.04276468605e-12 -4.8649233779e-24]}
    set PMOD(denom) {[0.999941853221 3.30931129074e-12 -5.89150047102e-24]}
    # set PMOD(typAlpha) 1

    u=(0:50e-15:1000e-12)
    h=syslin('d', poly(P_numer, 's', 'coeff'), poly(P_denom, 's', 'coeff'))
    hd=dscr(h, 1e-12)

    y=flts(u,  dscr(tf2ss(h), 50e-15))

    P_numer=[1, 2, -4]
    P_denom=[1, 3, -6]
    h=poly(P_numer, 's', 'coeff')/poly(P_denom, 's', 'coeff')
    u=[1 ones(1:1:999)]
    y=flts(u, tf2ss(h))
    plot(y(1:100))

    P_numer=[1, 4, -16]
    P_denom=[1, 6, -24]
    h=syslin('c', poly(P_numer, 's', 'coeff'), poly(P_denom, 's', 'coeff'))
    u=[1 ones(1:1:999)]
    y=flts(u, tf2ss(h));
    plot(y)

    P_numer=[0.914053331333 2.04276468605 -4.8649233779]
    P_denom=[0.999941853221 3.30931129074 -5.89150047102]
    h=poly(P_numer, 's', 'coeff')/poly(P_denom, 's', 'coeff')
    u=[1 ones(1:1:999)]
    y=flts(u, tf2ss(h))
    plot(y)






    #########################################################################
    # initialisation ramzi3 pour le meme dispo mes pour une densite de 100mA
    #########################################################################

    set prefix _63B5x17_100_14_
    set PMOD(Rp)       0
    set PMOD(Cp)       0
    set PMOD(Lb)       0.5e-12
    set PMOD(Lc)       250e-15
    set PMOD(Le)       18e-12
    set PMOD(Rb)       18.
    set PMOD(rb)       0.
    set PMOD(cc_ext)       0.
    set PMOD(ce_ext)       0.
    set PMOD(Rc)       10
    set PMOD(Re)       0.13
    set PMOD(Ro)       8.7e3
    set PMOD(Z0)       50
    set PMOD(Zrel)     1.0
    set PMOD(alpha0)   0.912
    set PMOD(cc)       9e-15
    set PMOD(ce)       170e-15
    set PMOD(m)        0.22
    set PMOD(nL)       350e-6
    set PMOD(re)       6.5
    set PMOD(taub)     0.98e-12
    set PMOD(tauc)     0.07e-12
    set PMOD(typAlpha) 0


    set PMOD(numer) {[0.913610697995 1.91071046802e-12 -4.30595666846e-24]}
    set PMOD(denom) {[0.999947389014 3.26629427824e-12 -5.33060738574e-24]}
    set PMOD(typAlpha) 1

    set PMOD(numerTHz) {[0.913330267324 1.90416073166 -5.94870930712]}
    set PMOD(denomTHz) {[0.999927828882 3.33008067715 -7.31246309756]}

    set PMOD(numerTHz) {[0.913417286296 4.21206135222 -0.0058146764457]}
    set PMOD(denomTHz) {[1.00001667728 5.85692863775 1.68976183585]}
    m

    SCILAB:

    sl=syslin('c', poly(P_numerTHz, 's', 'coeff'), poly(P_denomTHz, 's', 'coeff')
    slss=tf2ss(sl); ssprint(slss)

    fTHz=(0.01:0.01:10)       
    xselect(); xbasc(); bode(fTHz, repfreq(slss, fTHz))     


    sldt=dscr(slss,0.1);
    u=ones(1,200);
    y=flts(u,sldt);
    xselect(); xbasc(); plot(y./(1-y))

    u=zeros(1,200);u(1)=1
    y=flts(u,sldt);
    xselect(); xbasc(); plot(y(20:200))


    s {syslin('c', poly(P_numerTHz, 's', 'coeff'), poly(P_denomTHz, 's', 'coeff'))


}


# 21 juillet 1999
set prefix _63B5x17_250_15_
set PMOD(Z0) 50
set PMOD(nL) 400e-6
set PMOD(Cp) 0.
set PMOD(Rp) 0.
set PMOD(Rb) 22.
set PMOD(rb) 8.0
set PMOD(Lb) 0.
set PMOD(re) 4.7
set PMOD(Re) 0.
set PMOD(ce) 20.6e-15
set PMOD(Le) 16e-12
set PMOD(Ro) 430.
set PMOD(cc) 6e-15
set PMOD(cc_ext) 5.28e-15
set PMOD(Rc) 1.4e-15
set PMOD(Lc) 9.6e-16
set PMOD(alpha0) 0.9
set PMOD(m) 0.22
set PMOD(taub) 2e-12
set PMOD(tauc) 0.1e-12
set PMOD(Zrel) .85
set PMOD(ce_ext) 0
set PMOD(typAlpha) 0

fitalpha 2

set PMOD(numer) {[0.895840087007 2.0259525885e-12 -2.46358272207e-24]}
set PMOD(denom) {[1.00000297176 4.59865244622e-12 3.01101764096e-25]}
set PMOD(typAlpha) 1

fitalphaBis 2


SCILAB:

sl=syslin('c', poly(P_numer, 's', 'coeff'), poly(P_denom, 's', 'coeff'))
slss=tf2ss(sl); ssprint(slss)

f=(0.01e12:0.01e12:10e12)       
xselect(); xbasc(); bode(f, repfreq(slss, f))     

dt=0.1e-12
sldt=dscr(slss,dt);

u=ones(1,200);
y=flts(u,sldt);
xselect(); xbasc(); plot2d(dt*(1:size(y,2)),y./(1-y))

u=zeros(1,200);u(1)=1
y=flts(u,sldt);
t=dt*(1:size(y,2))
xselect(); xbasc(); plot2d(t(2:200),log(abs(y(2:200))))



set PMOD(numer) {[0.895840087007 2.0259525885e-12 -2.46358272207e-24]}
set PMOD(denom) {[1.00000297176 4.59865244622e-12 3.01101764096e-25]}
trep
set PMOD(numer) {[0.910605448212 7.55620006528e-13 -2.22303236237e-24]}
set PMOD(denom) {[0.999982339498 3.10059689798e-12 -1.7893829655e-24]}
trep

# 26 juillet 1999

package require fidev; package require spalab

ini
cd /home/asdex/data/SF5/SF5.1/hyper2
set DISPO 43_26_h
::scilab::exec $tid load('[pwd]/${DISPO}.scilab')
set PREFIXES [lindex [::scilab::get $tid _${DISPO}_prefixes] 3]
set PREFIXES [lsort $PREFIXES]


set prefix _43_26_h_170_24_

# ramzi

set PMOD(Rp)       0
set PMOD(Cp)       5e-15
set PMOD(Lb)       0.5e-12
set PMOD(Lc)       250e-15
set PMOD(Le)       10e-12
set PMOD(Rb)       8
set PMOD(rb)       25
set PMOD(cc_ext)       4e-15
set PMOD(ce_ext)       200e-15 ;# mortel!
set PMOD(Rc)       35
set PMOD(Re)       0.13
set PMOD(Ro)       4.7e3
set PMOD(Z0)       50
set PMOD(Zrel)     1.0
set PMOD(alpha0)   0.87
set PMOD(cc)       1e-15
set PMOD(ce)       200e-15
set PMOD(m)        0.22
set PMOD(nL)       470e-6
set PMOD(re)       4.
set PMOD(taub)     1e-12
set PMOD(tauc)     0.12e-12
set PMOD(typAlpha) 0

set PMOD(Ro) 4.5e3
set PMOD(ce_ext)   0.0

set PMOD(numer) {[0.894713440291 6.85913340518e-11 -2.05954314387e-23]}
set PMOD(denom) {[1.00176361253 8.06749268671e-11 1.78691517287e-22]}
set PMOD(typAlpha) 1

set PMOD(Z0) 50
set PMOD(Zrel) 1.0
set PMOD(nL) 470e-6
set PMOD(Cp) 0.
set PMOD(Rp) 0.
set PMOD(Rb) 16.
set PMOD(rb) 0.
set PMOD(Lb) 0
set PMOD(re) 4.
set PMOD(Re) 0.
set PMOD(ce) 5e-15
set PMOD(Le) 0.
set PMOD(Ro) 4.5e3
set PMOD(cc) 5e-15
set PMOD(cc_ext) 0.
set PMOD(Rc) 0.
set PMOD(Lc) 0.
set PMOD(alpha0) 0.89
set PMOD(m) 0.22
set PMOD(taub) 1e-12
set PMOD(tauc) 0.12e-12
set PMOD(ce_ext) 0.
set PMOD(denom) {[1.00000246354 2.39098730437e-12 2.4960919027e-25]}
set PMOD(numer) {[0.876879426815 -1.55195000465e-13 -1.09404807576e-25]}
set PMOD(typAlpha) 0
set PMOD(cc) 7.5e-15
set PMOD(re) 5.5
set PMOD(numer) {[0.872877221751 -1.39760749357e-12 9.38541259694e-25]}
set PMOD(denom) {[0.999986060359 2.03339681249e-12 -1.41238087678e-24]}
set PMOD(typAlpha) 1

# fitalpha 2 1e-6
# pourquoi est-ce mieux avec 1e-6 ?
set PMOD(numer) {[0.887531002474 6.3797550508e-11 -6.16743687703e-23]}
set PMOD(denom) {[1.00202886128 7.67280999328e-11 2.0556633774e-22]}


set p $prefix
set freqmul 1
set freqmul 1e-6
set deg 2
::scilab::exec $tid "${p}zce = ${p}bz21 - ${p}bz12"
::scilab::exec $tid "${p}zcc = ${p}bz22 - ${p}bz12"
::scilab::exec $tid "${p}alpha = (${p}zce./(${p}zcc - (1/P_Z0)*(P_Rc - %i*P_Lc.*omega))).*(1+%i*omega.*P_ce.*P_re)"

::scilab::exec $tid "fresp=\[${prefix}alpha\]"

::scilab::exec $tid "f=\[${p}f*$freqmul\]"
::scilab::exec $tid "\[h, erreur\]=frep2tf_b(f,fresp,$deg,'c',ones(f))"

::scilab::exec $tid "hn=coeff(numer(h))"
::scilab::exec $tid "hd=coeff(denom(h))"

set numer [lindex [::scilab::get $tid hn] 3]
set denom [lindex [::scilab::get $tid hd] 3]
puts "# err=[lindex [::scilab::get $tid erreur] 3]"

puts "set PMOD(numer) \{\[$numer\]\}" 
puts "set PMOD(denom) \{\[$denom\]\}" 

::scilab::exec $tid "frespfit=repfreq(syslin('c', poly(\[$numer\], 's', 'coeff'), poly(\[$denom\], 's', 'coeff')),f)"
::scilab::exec $tid "xbasc(0)"
::scilab::exec $tid "bode(f,\[fresp;frespfit\])"





# compréhension de frep2tf_b
set p $prefix
set freqmul 1
set freqmul 1e-6
set deg 2
::scilab::exec $tid "${p}zce = ${p}bz21 - ${p}bz12"
::scilab::exec $tid "${p}zcc = ${p}bz22 - ${p}bz12"
::scilab::exec $tid "${p}alpha = (${p}zce./(${p}zcc - (1/P_Z0)*(P_Rc - %i*P_Lc.*omega))).*(1+%i*omega.*P_ce.*P_re)"

::scilab::exec $tid "fresp=\[${prefix}alpha\]"

::scilab::exec $tid "f=\[${p}f*$freqmul\]"

s frq=f
s repf=fresp
s dg=2
s dom='c'
s n=size(frq,'*');
s w=2*%i*%pi*matrix(frq,n,1)
s m=2*dg
s {a1=w.*.[ones(1,dg)]}
s {a1=[ones(n,1),a1.^(ones(n,1).*.[1:(dg)])]}
s {a2=a1; for k=1:n; a2(k,:)= -repf(k)*a2(k,:);end}
s {a=[a1,a2]}
s {[rmax,imax]=maxi(abs(repf))}
s {L2=a(imax,1:dg+1)}
s {L=[zeros(L2),L2,%i;L2,zeros(L2),repf(imax)*%i]}
s {BigL=[real(L);imag(L)]}
s {c=[1;repf(imax)]}
s {Bigc=[real(c);imag(c)]}
s {[ww,dim]=rowcomp(BigL)}
s {BigL=ww*BigL;Bigc=ww*Bigc}
s {BigL=BigL(1:dim,:);Bigc=Bigc(1:dim,:)}
s {a=[a,zeros(size(a,1),1)]}
s {w1=weight(:)*ones(1,size(a,2))}
s {a= w1.*a}
s {BigA=[real(a);imag(a)]}
s {x=LSC(BigA,BigL,Bigc)}
g {BigL*x - Bigc}
s {[_W,_rk]=colcomp(BigL)}
s {_LW=BigL*_W}
s {_Anew=BigA*_W}
s {_A1=_Anew(:,1:($-_rk))}
s {_A2=_Anew(:,($-_rk+1:$))}
s {_x2=inv(_LW(:,$-_rk+1:$))*Bigc}
s {_b=-_A2*_x2}
s {_x1=_A1\_b}
g {_A1*_x1-_b}
s {_x=_W*[_x1;_x2]}


s getf(SCI+'/macros/auto/frep2tf.sci')

::scilab::exec $tid "\[h, erreur\]=frep2tf_b(f,fresp,$deg,'c',ones(f))"


# pour rapport 28 juillet 1999
set prefix _63B5x17_250_15_
set PMOD(Z0) 50
set PMOD(nL) 400e-6
set PMOD(Cp) 0.
set PMOD(Rp) 0.
set PMOD(Rb) 22.
set PMOD(rb) 8.0
set PMOD(Lb) 0.
set PMOD(re) 4.7
set PMOD(Re) 0.
set PMOD(ce) 20.6e-15
set PMOD(Le) 16e-12
set PMOD(Ro) 430.
set PMOD(cc) 6e-15
set PMOD(cc_ext) 5.28e-15
set PMOD(Rc) 1.4e-15
set PMOD(Lc) 9.6e-16
set PMOD(alpha0) 0.9
set PMOD(m) 0.22
set PMOD(taub) 2e-12
set PMOD(tauc) 0.1e-12
set PMOD(Zrel) .85
set PMOD(ce_ext) 0
set PMOD(typAlpha) 0
set PMOD(numer) {[0.89362526504 1.6688361945e-12 -2.19972868612e-24]}
set PMOD(denom) {[0.999990958973 4.11505820227e-12 -9.16047589171e-25]}
set PMOD(typAlpha) 1


set prefix _63B5x17_180_14_
set PMOD(Z0) 50
set PMOD(Zrel) 0.85
set PMOD(nL) 400e-6
set PMOD(Cp) 0
set PMOD(Rp) 0
set PMOD(Rb) 10.
set PMOD(rb) 4.
set PMOD(Lb) -20.e-12
set PMOD(re) 5.
set PMOD(Re) 0.13
set PMOD(ce) 200e-15
set PMOD(Le) 20e-12
set PMOD(Ro) 3.6e3
set PMOD(cc) 8e-15
set PMOD(cc_ext) 0.
set PMOD(Rc) 0
set PMOD(Lc) 120e-12
set PMOD(alpha0) 0.912
set PMOD(m) 0.22
set PMOD(taub) 0.98e-12
set PMOD(tauc) 0.07e-12
set PMOD(ce_ext) 0.
set PMOD(typAlpha) 0
# real(zcc) incorrect

# fitalphaTer 2 30e9
set PMOD(typAlpha) 1
set PMOD(numer) {[0.912787181733 5.83000060047e-13 -7.13807891887e-24]}
set PMOD(denom) {[0.999911011021 1.67629626996e-12 -9.01646871214e-24]}
