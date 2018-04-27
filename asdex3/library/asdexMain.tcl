#!/usr/local/bin/wish8.0

set LIBTCL /prog/Tcl/lib
set AsdexTclDir /prog/asdex/Tcl
set ASDEXTCL $AsdexTclDir/asdex3

# -----------------------------------------------------------------------------#
# Chargement d'utilitaires
# -----------------------------------------------------------------------------#

set ASDEX(dir) /home/asdex

# package require superTable 1.3
package require fidev
package require superTable
package require nr 1.0
package require asyst 1.1
package require kdutil 1.2
package require aide 1.2
package require minihelp 1.0
package require superWidgetsListbox 1.2
package require stringutils 1.0


# -----------------------------------------------------------------------------#
# -----------------------------------------------------------------------------#


proc erreur {commentaire} {
    kd_message_box error $commentaire
}

# ---------------------------------------------------------------------------- #
# Variables globales
# ---------------------------------------------------------------------------- #
set globvarcomment {
        _______
	dirData
répertoire niveau 0
ex :		/home/local/asdex/data
        ______
	Plaque
sous-répertoire de dirData
le fichier fichier $Plaque/info.txt contient la description des dispos et mesures
ex :		SF5
        _____
	Dispo
morceau de plaque ou étape
sous-répertoire de Plaque
ex :		SF5.1
        ______
	Mesure
sous-répertoire de $Dispo 
ex :		I_Vbc
	___
	Typ
type de mesure (extension du fichier)
ex : 		sch
        ____
	Brut
tableau des fichiers de mesures brutes
Les arguments sont par ex. : sch, res, etc. (extension des fichiers)
La valeur est le nombre de fichiers ayant cette extension
        _____
	BrutC
tableau des cadres de mesures brutes.
Deux arguments : le second est identique à celui de Brut
Le premier est l'un des 4 limin, limax, comin, comax
        ___
        txt
subwidget text correspndant au fichier $txt_file
        _________
        txt_modif
flag indiquant si le fichier de commentaire $txt_file a été modifié
        ________
        txt_file
nom du fichier de commentaire
ex :		.SF5
        ___________
        plotTableau
Tableau asyst en cours de trace.
Interne à a6plot.tcl
        ______
        index3
Index propre aux fichiers multicourbes
        __________
        adrAffiche SUPPRIME
adresse du fichier asyst en cours
Interne à a6plot.tcl
        _______
        PosCour
Position courante, genre L02C13
        _____
        lDMid
A revoir
        ________
        KdResult
A revoir

        ___
        plx
Largeur d'une cellule
        ___
        ply
Hauteur d'une cellule
        __
        pl
frame de la carte
        ___
        hlt
subwidget de choix de choixDirMesure
        ___
        hlm
subwidget de choix de choixMesures
        ___
        hld
subwidget de choix de choixTypMes
        _________
        choixFils
tableau
argument : l'un des subwidgets de choix
valeur : la fonction de choix
        ______
        lock_x, lock_y, lock_x1, lock_y1
Contenant " lock x " ou "unlock x" : état des axes


}

source ${ASDEXTCL}/repert.tcl       ;# gestion des répertoires
set ASDEX(plx) 20
set ASDEX(ply) 20
source ${ASDEXTCL}/tablico.tcl      ;# proc choixMesures
source ${ASDEXTCL}/text.tcl         ;# gestion de la fenêtre texte
source ${ASDEXTCL}/choix.tcl        ;# procédures de choix dans les listes
source ${ASDEXTCL}/choixMesures.tcl  ;#

set ASDEX(udir) [pwd]


wm title . "Asdex3.0a"
wm iconname . "Asdex"
# image create bitmap iconAsdex -file $AsdexTclDir/bitmaps/asdex.xbm

# source ${ASDEXTCL}/asdex.xbm

image create bitmap asdex-logo -file $AsdexTclDir/bitmaps/asdex.xbm
wm iconbitmap . @$AsdexTclDir/bitmaps/asdex.xbm

wm geometry . +0+0

source ${ASDEXTCL}/carte.tcl  ;# gestion du canvas géographique
source ${ASDEXTCL}/gauche.tcl ;# partie gauche de la fenêtre
source ${ASDEXTCL}/a6plot.tcl ;# procédures pour courbes xy
source ${ASDEXTCL}/droite.tcl ;# gestion de la partie droite de la fenêtre
toplevel .droite -relief raised -borderwidth 3
plot_ui .droite


puts [info globals]

# source ${ASDEXTCL}/developpe.tcl

choixMesure_ui

# Pour les fenetres non documentees
::aide::nondocumente .
