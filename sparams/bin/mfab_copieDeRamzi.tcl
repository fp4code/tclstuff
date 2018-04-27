##############################################
# il faut lancer "xpvm" dans une fenêtre indépendante
# puis "tclsh" (avec emacs : "C-x 2" puis "ESC x shell") puis suivre les intructions dans l'odre
#############################################

set env(FIDEV_EXPERIMENTAL) /home/fab/C/fidev-sparc-SunOS-5.7-cc/lib
package require fidev; package require spalab

########################################################################
# attendre que la fenêtre scilab soit ouverte avant de lancer la suite #
########################################################################

ini

############
## Notes ###
############

set NOTE1 {
 une commande erronée va rendre scilab indépendant. ex:
    scilab::exec $tid toto
 pour relancer la connexion, taper
    exec('/home/fab/A/fidev/scilab/essai_pvm/esclave.sce',-1)
 dans la fenêtre scilab
}

set NOTE2 {
 dans certains cas rares, la connexion est déphasée. Il faut alors taper
    scilab::pvm_recv $tid
 jusqu'à ce que l'interpréteur réponde "PvmNoBuf", après 30s de réflexion.
}


##############################################################
# chargement de toutes les mesures sur le  dispo 31C5x40 #####
##############################################################

cd /home/asdex/A/data/L72229/L72229.4/hyper

set DISPO 31C5x40
::scilab::exec $tid load('[pwd]/${DISPO}.scilab')
set PREFIXES [lsort [lindex [::scilab::get $tid _${DISPO}_prefixes] 3]]

# choix d'un des PREFIXES

set prefix _31C5x40_0070_120_



set PMOD(Rp)       0.
set PMOD(Cp)       0.
set PMOD(Lb)       0.5e-12
set PMOD(Lc)       250e-15
set PMOD(Le)       10e-12
set PMOD(Rb)       6.
set PMOD(rb)       20.
set PMOD(cc_ext)       3.3e-15
set PMOD(ce_ext)       0.
set PMOD(Rc)       30
set PMOD(Re)       1.
set PMOD(Ro)       4.4e3
set PMOD(Z0)       50
set PMOD(Zrel)     1.0
set PMOD(alpha0)   0.89
set PMOD(cc)       3e-15
set PMOD(ce)       200e-15
set PMOD(key)      0.5e-12
set PMOD(m)        0.22
set PMOD(nL)       470e-6
set PMOD(re)       3.5
set PMOD(taub)     0.7e-12
set PMOD(tauc)     2.3e-12
set PMOD(typAlpha) 0

proc plotall {} {
    uplevel {
#	puts $gp {set xrange [1e9:10e9]}
#	aplot cfit2 {-50:50} {0:0.005} {-40:40} {-360:0}
	puts $gp {set logscale x}
	puts $gp {set xrange [.1e9:100e9]}
#	aplot zb {0:1} {0:0.5} {-10:0} {-360:-300}
#	aplot ze {0:0.2} {-0.1:0} {-40:0} {-90:0}
#	aplot efit1 {0:0.2} {-1:0} {-40:40} {-360:0}
#	aplot efit2 {-50:50} {-20:20} {-40:40} {-360:0}
#	aplot zcc {-20:80} {-80:20} {0:40} {-180:0}
#	aplot cfit1 {-20:80} {-3000:0} {0:80} {-360:0}
#	aplot cfit2 {-10:10} {0:0.05} {-40:40} {-360:0}
#	aplot alpha {0:1} {-1:0} {-20:0}  {-90:0}
	aplot h21 {0:15} {-15:0} {-10:25} {-90:0}
	aplot racU {0:15} {0:10} {5:25} {0:90}
aplot s21 {-6:2} {-1:4 } {-10:20} {-500:-100.0}
        aplot s22 {-0.5:1} {-0.5:1} {-40:40} {-360:0}
        aplot s12 {-0.05:0.2} {-0.05:0.2} {-40:40} {-360:0}
        aplot s11 {-0.5:1} {-0.5:1} {-40:40} {-360:0}

   }
}


# trace

m




#################################
# pour utiliser fitalpha 2 ######
#################################

# recharger le programme fitalpha2 (suivre les instructions suivantes:)
#   fitalpha 2
#set PMOD(numer) {[0.949614307676 2.62400782825e-12 -6.12087985065e-25]}
set PMOD(denom) {[0.999944605081 2.55228098749e-12 -5.61267881072e-24]}
# set PMOD(typAlpha) 1
# !m
# ppmod : permet d'afficher touts les parametres d'initialisation


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% 

###########################################################
# chargement de toutes les mesures sur le  dispo SF5.1#####

###########################################################

cd /home/asdex/B/data/SF5/SF5.1/hyper2
set DISPO 43_26_h
::scilab::exec $tid load('[pwd]/${DISPO}.scilab')
set PREFIXES [lsort [lindex [::scilab::get $tid _${DISPO}_prefixes] 3]]


########################################################
# choix d'une mesure sur le dispo 43_26 : 20 mA, 2.4V###
########################################################

set prefix _43_26_h_200_24_

##########################################################################
# initialisation (ramzi) pour le dispo 43_26 pour une densite de 200mA####
##########################################################################

set prefix _43_26_h_200_24_


set PMOD(Rp)       0.
set PMOD(Cp)       0.
set PMOD(Lb)       0.5e-12
set PMOD(Lc)       250e-15
set PMOD(Le)       10e-12
set PMOD(Rb)       6.
set PMOD(rb)       20.
set PMOD(cc_ext)       3.3e-15
set PMOD(ce_ext)       0.
set PMOD(Rc)       30
set PMOD(Re)       1.
set PMOD(Ro)       4.4e3
set PMOD(Z0)       50
set PMOD(Zrel)     1.0
set PMOD(alpha0)   0.89
set PMOD(cc)       3e-15
set PMOD(ce)       200e-15
set PMOD(key)      0.5e-12
set PMOD(m)        0.22
set PMOD(nL)       470e-6
set PMOD(re)       3.5
set PMOD(taub)     0.7e-12
set PMOD(tauc)     2.3e-12
set PMOD(typAlpha) 0


$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$  28/7/99/   $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

# beaucoup de difficulte' pour fiter pour ce courant (20mA) 

$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$



########################################################
# choix d'une mesure sur le dispo 43_26 : 17 mA, 2.4V###
########################################################

set prefix _43_26_h_170_24_

##########################################################################
# initialisation (ramzi) pour le dispo 43_26 pour une densite de 170mA####
##########################################################################

set prefix _43_26_h_170_24_


set PMOD(Rp)       0.
set PMOD(Cp)       0.
set PMOD(Lb)       0.5e-12
set PMOD(Lc)       250e-15
set PMOD(Le)       10e-12
set PMOD(Rb)       6.
set PMOD(rb)       20.
set PMOD(cc_ext)       3.3e-15
set PMOD(ce_ext)       0.
set PMOD(Rc)       30
set PMOD(Re)       1.
set PMOD(Ro)       4.4e3
set PMOD(Z0)       50
set PMOD(Zrel)     1.0
set PMOD(alpha0)   0.89
set PMOD(cc)       3e-15
set PMOD(ce)       200e-15
set PMOD(key)      0.5e-12
set PMOD(m)        0.22
set PMOD(nL)       470e-6
set PMOD(re)       3.5
set PMOD(taub)     0.7e-12
set PMOD(tauc)     2.3e-12
set PMOD(typAlpha) 0


$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$  28/7/99/   $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

# Les valeurs si dessus donnent le" meilleur" fit de h21, U et alpha. 
# alpha pour les hautes frequences presente un ecart (partie imaginaire) 
# avec fitalpha 2 : on a un bon fit de la phase mais en magnitude on a un ecart surtout au depard jusqu'a 10Ghz.
# avec fitalpha2 : alpha (partie reelle et imaginaire) est bien fite'e 
# le fit des autres parametres est legerement ameliore' par
#m Ro 4.8e3 Rc 3  cc 3e-15
$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$


########################################################
# choix d'une mesure sur le dispo 43_26 : 14 mA, 2.4V###
########################################################

set prefix _43_26_h_140_24_

##########################################################################
# initialisation (ramzi) pour le dispo 43_26 pour une densite de 170mA####
##########################################################################

set prefix _43_26_h_140_24_


set PMOD(Rp)       0.
set PMOD(Cp)       0.
set PMOD(Lb)       0.5e-12
set PMOD(Lc)       250e-15
set PMOD(Le)       10e-12
set PMOD(Rb)       6.
set PMOD(rb)       20.
set PMOD(cc_ext)       3.3e-15
set PMOD(ce_ext)       0.
set PMOD(Rc)       30
set PMOD(Re)       1.
set PMOD(Ro)       4.4e3
set PMOD(Z0)       50
set PMOD(Zrel)     1.0
set PMOD(alpha0)   0.89
set PMOD(cc)       3e-15
set PMOD(ce)       200e-15
set PMOD(key)      0.5e-12
set PMOD(m)        0.22
set PMOD(nL)       470e-6
set PMOD(re)       3.5
set PMOD(taub)     0.7e-12
set PMOD(tauc)     2.3e-12
set PMOD(typAlpha) 0


########################################################################
# initialisation ramzi pour le dispo 43_26 pour une densite de 100mA####
########################################################################

set prefix _43_26_h_100_24_


set PMOD(Rp)       0
set PMOD(Cp)       0
set PMOD(Lb)       0
set PMOD(Lc)       0
set PMOD(Le)       0
set PMOD(Rb)       6
set PMOD(rb)       23
set PMOD(cc_ext)     3.8e-15
set PMOD(ce_ext)     0.
set PMOD(Rc)       30
set PMOD(Re)       0.2
set PMOD(Ro)       7e3
set PMOD(Z0)       50
set PMOD(Zrel)     1.0
set PMOD(alpha0)   0.89
set PMOD(cc)       3e-15
set PMOD(ce)       200e-15
set PMOD(key)      0.5e-12
set PMOD(m)        0.22
set PMOD(nL)       470e-6
set PMOD(re)       4.6
set PMOD(taub)     0.85e-12
set PMOD(tauc)     1.8e-12
set PMOD(typAlpha) 0


$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$  28/7/99/   $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

# Les valeurs si dessus donnent le" meilleur" fit de h21, U et alpha. 
# alpha pour les hautes frequences presente toujours un ecart (partie imaginaire) 
# dans ce cas le fitalpha 2 presente un bon fit de la phase mais en magnitude on a un ecart surtout au depard jusqu'a 10Ghz.
# pas de probleme alpha est tres bien fite' dans ce cas avec fitalpha2 

$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$




########################################################################
# initialisation ramzi pour le dispo 43_26 pour une densite de 70mA#####
########################################################################

set prefix _43_26_m_070_24_


set PMOD(Rp)       0
set PMOD(Cp)       5e-15
set PMOD(Lb)       0.
set PMOD(Lc)       250e-15
set PMOD(Le)       10e-12
set PMOD(Rb)       6
set PMOD(rb)       25
set PMOD(cc_ext)       4e-15
set PMOD(ce_ext)       0.
set PMOD(Rc)       0.15
set PMOD(Re)       4
set PMOD(Ro)       19e3
set PMOD(Z0)       50
set PMOD(Zrel)     1.0
set PMOD(alpha0)   0.87
set PMOD(cc)       3.6e-15
set PMOD(ce)       200e-15
set PMOD(key)      0.5e-12
set PMOD(m)        0.22
set PMOD(nL)       470e-6
set PMOD(re)       3.3
set PMOD(taub)     2.95e-12
set PMOD(tauc)     0.15e-12
set PMOD(typAlpha) 0


$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$  28/7/99/   $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

# Les valeurs si dessus donnent le" meilleur" fit de h21, U et alpha. 
# alpha pour ce courant de 7mA est bien fite' (taub+tauc= 3.1ps) 
# meme resultat avec fitalpha 2 sauf que la magnitude de alpha presente un ecart surtout au depard jusqu'a 10Ghz. 
$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$




%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

#########################################################
# chargement de toutes les mesures sur le dispo L72228###

#########################################################

cd /home/asdex/data/L72228/L72228.1/hyper2
set DISPO 63B5x17
::scilab::exec $tid load('[pwd]/${DISPO}.scilab')
set PREFIXES [lsort [lindex [::scilab::get $tid _${DISPO}_prefixes] 3]]



##########################################################
# choix d'une mesure sur le dispo L7228 : 25 mA, 1.4V#####
##########################################################

set prefix _63B5x17_250_14_




#############################################################################
# initialisation ramzi1 pour le meme dispo mes pour une densite de 250mA#####
#############################################################################

set prefix _63B5x17_250_14_

set PMOD(Rp)       0
set PMOD(Cp)       0
set PMOD(Lb)       0.5e-12
set PMOD(Lc)       250e-15
set PMOD(Le)       18e-12
set PMOD(Rb)       28.
set PMOD(rb)       0.
set PMOD(cc_ext)       0.
set PMOD(ce_ext)       0.
set PMOD(Rc)       10
set PMOD(Re)       0.13
set PMOD(Ro)       0.9e3
set PMOD(Z0)       50
set PMOD(Zrel)     1.0
set PMOD(alpha0)   0.912
set PMOD(cc)       10e-15
set PMOD(ce)       200e-15
set PMOD(key)      0.5e-12
set PMOD(m)        0.22
set PMOD(nL)       350e-6
set PMOD(re)       5.
set PMOD(taub)     0.75e-12
set PMOD(tauc)     0.07e-12
set PMOD(typAlpha) 0



$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$ 28/7/99 $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
# il a toujours un ecart sur alpha (taub+tauc=0.82ps) a hautes frequences
# le fitalpha 2 donne un tres bon fit sur la majorite des parametres  
$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$


####################################################################
# initialisation ramzi2 pour le dispo pour une densite de 200mA#####
####################################################################

set prefix _63B5x17_200_14_

set PMOD(Rp)       0
set PMOD(Cp)       0
set PMOD(Lb)       0.5e-12
set PMOD(Lc)       250e-15
set PMOD(Le)       10e-12
set PMOD(Rb)       18.
set PMOD(rb)       0.
set PMOD(cc_ext)       0.
set PMOD(ce_ext)       0.
set PMOD(Rc)       10
set PMOD(Re)       0.13
set PMOD(Ro)       3.3e3
set PMOD(Z0)       50
set PMOD(Zrel)     1.0
set PMOD(alpha0)   0.912
set PMOD(cc)       8e-15
set PMOD(ce)       200e-15
set PMOD(key)      0.5e-12
set PMOD(m)        0.22
set PMOD(nL)       350e-6
set PMOD(re)       4.8
set PMOD(taub)     0.7e-12
set PMOD(tauc)     0.15e-12
set PMOD(typAlpha) 0



$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$ 28/7/99 $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
# il a toujours un ecart sur alpha (taub+ tauc=0.85ps) a hautes frequences
# le fitalpha 2 donne un tres bon fit sur la majorite des parametres  
$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$



####################################################################
# initialisation ramzi2 pour le dispo pour une densite de 180mA#####
####################################################################

set prefix _63B5x17_180_14_

set PMOD(Rp)       0
set PMOD(Cp)       0
set PMOD(Lb)       0.5e-12
set PMOD(Lc)       250e-15
set PMOD(Le)       10e-12
set PMOD(Rb)       18.
set PMOD(rb)       0.
set PMOD(cc_ext)       0.
set PMOD(ce_ext)       0.
set PMOD(Rc)       10
set PMOD(Re)       0.13
set PMOD(Ro)       3.8e3
set PMOD(Z0)       50
set PMOD(Zrel)     1.0
set PMOD(alpha0)   0.912
set PMOD(cc)       8e-15
set PMOD(ce)       200e-15
set PMOD(key)      0.5e-12
set PMOD(m)        0.22
set PMOD(nL)       350e-6
set PMOD(re)       5.
set PMOD(taub)     0.75e-12
set PMOD(tauc)     0.1e-12
set PMOD(typAlpha) 0



$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$ 28/7/99 $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
# il a toujours un ecart sur alpha (taub+ tauc=0.85ps) a hautes frequences
# le fitalpha 2 donne un tres bon fit sur la majorite des parametres  
$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$


#############################################################################
# initialisation ramzi3  pour le meme dispo mes pour une densite de 140mA####
#############################################################################

set prefix _63B5x17_140_14_

set PMOD(Rp)       0
set PMOD(Cp)       0
set PMOD(Lb)       0.5e-12
set PMOD(Lc)       600e-15
set PMOD(Le)       15e-12
set PMOD(Rb)       17.5
set PMOD(rb)       0.
set PMOD(cc_ext)       0.
set PMOD(ce_ext)       0.
set PMOD(Rc)       10
set PMOD(Re)       0.13
set PMOD(Ro)       5.6e3
set PMOD(Z0)       50
set PMOD(Zrel)     1.0
set PMOD(alpha0)   0.912
set PMOD(cc)        8e-15
set PMOD(ce)       130e-15
set PMOD(key)      0.5e-12
set PMOD(m)        0.22
set PMOD(nL)       350e-6
set PMOD(re)       5.7
set PMOD(taub)     0.9e-12
set PMOD(tauc)     0.1e-12
set PMOD(typAlpha) 0


$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$ 28/7/99 $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
# il a toujours un ecart sur alpha (taub+ tauc=1ps) a hautes frequences
# le fitalpha 2 donne un tres bon fit sur la majorite des parametres  
$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$


#############################################################################
# initialisation ramzi4 pour le meme dispo mes pour une densite de 100mA#####
#############################################################################

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
set PMOD(key)      0.5e-12
set PMOD(m)        0.22
set PMOD(nL)       350e-6
set PMOD(re)       6.5
set PMOD(taub)     0.8e-12
set PMOD(tauc)     0.1e-12
set PMOD(typAlpha) 0


$$$$$$$$$$$$$$$$$$$$$$$$$$  28/7/99  $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
# il a toujours un ecart sur alpha (taub+ tauc=0.9ps) a hautes frequences
# le fitalpha 2 donne un tres bon fit sur la majorite des parametres  
$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$

#############################################################################
# initialisation ramzi5  pour le meme dispo mes pour une densite de 80mA#####
#############################################################################

set prefix _63B5x17_080_14_

set PMOD(Rp)       0
set PMOD(Cp)       0
set PMOD(Lb)       0.5e-12
set PMOD(Lc)       600e-15
set PMOD(Le)       15e-12
set PMOD(Rb)       18.
set PMOD(rb)       0.
set PMOD(cc_ext)       0.
set PMOD(ce_ext)       0.
set PMOD(Rc)       10
set PMOD(Re)       0.13
set PMOD(Ro)       9.8e3
set PMOD(Z0)       50
set PMOD(Zrel)     1.0
set PMOD(alpha0)   0.912
set PMOD(cc)       9e-15
set PMOD(ce)       170e-15
set PMOD(key)      0.5e-12
set PMOD(m)        0.22
set PMOD(nL)       350e-6
set PMOD(re)       7
set PMOD(taub)     0.75e-12
set PMOD(tauc)     0.1e-12
set PMOD(typAlpha) 0



$$$$$$$$$$$$$$$$$$$$$$$$$$  28/7/99  $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
# il a toujours un ecart sur alpha (taub+ tauc=0.85ps) a hautes frequences
# le fitalpha 2 donne un tres bon fit sur la majorite des parametres  
$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$


#############################################################################
# initialisation ramzi6  pour le meme dispo mes pour une densite de 60mA#####
#############################################################################

set prefix _63B5x17_060_14_

set PMOD(Rp)       0
set PMOD(Cp)       0
set PMOD(Lb)       0.5e-12
set PMOD(Lc)       600e-15
set PMOD(Le)       15e-12
set PMOD(Rb)       18.
set PMOD(rb)       0.
set PMOD(cc_ext)       0.
set PMOD(ce_ext)       0.
set PMOD(Rc)       10
set PMOD(Re)       0.13
set PMOD(Ro)       15.5e3
set PMOD(Z0)       50
set PMOD(Zrel)     1.0
set PMOD(alpha0)   0.912
set PMOD(cc)       10e-15
set PMOD(ce)       170e-15
set PMOD(key)      0.5e-12
set PMOD(m)        0.22
set PMOD(nL)       350e-6
set PMOD(re)       8.75
set PMOD(taub)     0.75e-12
set PMOD(tauc)     0.1e-12
set PMOD(typAlpha) 0

$$$$$$$$$$$$$$$$$$$$$$$$$$  28/7/99  $$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$
# il a toujours un ecart sur alpha (taub+ tauc=0.85ps) a hautes frequences
# le fitalpha 2 donne un tres bon fit sur la majorite des parametres  
$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$$





##############################
### OPTIONNEL pour le plot ###
##############################


proc plotall {} {
    uplevel {
	puts $gp {set logscale x}
	puts $gp {set xrange [.5e9:50e9]}
	aplot zb {} {} {-10:0} {-360:-300}
	aplot ze {} {} {-40:0} {-90:0}
#aplot efit1 {0:0.2} {-1:0} {-40:40} {-360:0}
#aplot efit2 {-50:50} {-20:20} {-40:40} {-360:0}
	aplot zcc {} {} {0:40} {-180:0}
 	puts $gp {set nologscale x}
	puts $gp {set xrange [0e9:50e9]}
	aplot unsurzcc {} {} {} {}
	puts $gp {set logscale x}
	puts $gp {set xrange [.5e9:50e9]}
	aplot cfit1 {-20:80} {-3000:0} {0:80} {-360:0}
#	aplot cfit2 {-10:10} {0:0.05} {-40:40} {-360:0}
	aplot alpha {0:1} {} {}  {}
	aplot h21 {} {} {} {}
	aplot racU {} {0:10} {} {0:90}
	aplot s21 {} {} {} {-360:0}
        aplot s22 {} {} {} {-360:0}
        aplot s12 {} {} {} {-360:0}
       aplot s11 {} {} {} {-360:0}

   }
}



######################################
# initialisation2 (aticle Spiegel)####
######################################

set PMOD(Cp)       0
set PMOD(Lb)       94e-12
set PMOD(Lc)       106e-12
set PMOD(Le)       108e-12
set PMOD(Rb)       42
set PMOD(rb)       0.
set PMOD(cc_ext)       0.
set PMOD(Rc)       0.25
set PMOD(Re)       7.
set PMOD(Ro)       1e3
set PMOD(Z0)       50
set PMOD(Zrel)     1.0
set PMOD(alpha0)   0.912
set PMOD(cc)       17e-15
set PMOD(ce)       100e-15
set PMOD(key)      0.5e-12
set PMOD(m)        0.22
set PMOD(nL)       380e-6
set PMOD(re)       5.
set PMOD(taub)     0.3e-12
set PMOD(tauc)     0.26e-12
set PMOD(typAlpha) 0

######################################################
# trace de caractéristiques en modifiant cc et re#####
######################################################
# taper

 m cc 8e-15  


#####################
#LES OBSERVATIONS####
#####################
# Rb augmente, fmax diminue  
# cc fait varier fmax (courbe du gain U decalee vers la gauche)
# re augmente, ft et fmax diminuent 
# on corrige la partie reelle de ze par re
# on corrige imag(ze) par Le,(Le) corrige aussi S11 et S12
# on corrige la partie imaginaire de S11 et S12 par Ro
# on corrige la partie reelle de zb par Rb
# on corrige imag de zcc par cc et Ro
# l'augmentation de Lc decale les parametres S
# avec le fitalpha 2 Rc=0.25 
# nL corrige S22 imag de zcc
# taub corrige real de alpha


#############################
### OPTIONNEL2 pour plot  ###
#############################

# définition des traces: modifier les lignes, copier-coller dans TCL

proc plotall {} {
    uplevel {
	puts $gp {set xrange [8e9:14e9]}
	aplot cfit2 {-50:50} {0:0.005} {-40:40} {-360:0}
	puts $gp {set logscale x}
	puts $gp {set xrange [.5e9:50e9]}
	aplot zb {0:1} {0:0.5} {-10:0} {-360:-300}
	aplot ze {0:0.2} {-0.1:0} {-40:0} {-90:0}
	aplot efit1 {0:0.2} {-1:0} {-40:40} {-360:0}
	aplot efit2 {-50:50} {-20:20} {-40:40} {-360:0}
	aplot zcc {-20:80} {-80:20} {0:40} {-180:0}
	aplot cfit1 {-20:80} {-3000:0} {0:80} {-360:0}
#	aplot cfit2 {-10:10} {0:0.05} {-40:40} {-360:0}
	aplot alpha {0:1} {-1:0} {-20:0}  {-90:0}
	aplot h21 {0:15} {-15:0} {5:25} {-90:0}
	aplot racU {0:15} {0:10} {5:25} {0:90}
	aplot s21 {-10:10} {-10:10} {-40:40} {-360:0}
        aplot s22 {-10:10} {-10:10} {-40:40} {-360:0}
        aplot s12 {-10:10} {-10:10} {-40:40} {-360:0}
       aplot s11 {-10:10} {-10:10} {-40:40} {-360:0}

   }
}


#####################
### OPTIONNEL 2bis###
#####################

# définition des traces: modifier les lignes, copier-coller dans TCL

proc plotall {} {
    uplevel {
#	puts $gp {set xrange [8e9:14e9]}
#	aplot cfit2 {-50:50} {0:0.005} {-40:40} {-360:0}
	puts $gp {set logscale x}
	puts $gp {set xrange [.1e9:100e9]}
#	aplot zb {0:1} {0:0.5} {-10:0} {-360:-300}
#	aplot ze {0:0.2} {-0.1:0} {-40:0} {-90:0}
#	aplot efit1 {0:0.2} {-1:0} {-40:40} {-360:0}
#	aplot efit2 {-50:50} {-20:20} {-40:40} {-360:0}
#	aplot zcc {-20:80} {-80:20} {0:40} {-180:0}
#	aplot cfit1 {-20:80} {-3000:0} {0:80} {-360:0}
#	aplot cfit2 {-10:10} {0:0.05} {-40:40} {-360:0}
#	aplot alpha {0:1} {-1:0} {-20:0}  {-90:0}
	aplot h21 {0:15} {-15:0} {5:25} {-90:0}
#	aplot racU {0:15} {0:10} {5:25} {0:90}
aplot s21 {-6:2} {-1:4 } {-10:20} {-500:-100.0}
        aplot s22 {-0.5:1} {-0.5:1} {-40:40} {-360:0}
        aplot s12 {-0.05:0.2} {-0.05:0.2} {-40:40} {-360:0}
        aplot s11 {-0.5:1} {-0.5:1} {-40:40} {-360:0}

   }
}

###############################################################################







































