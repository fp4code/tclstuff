##################################################
# script Tcl pour constituer un album photos Web #
# (C) 2002 CNRS/LPN                              #
# corrections : Fabrice.Pardo@Lpn.cnrs.fr        #
##################################################

# à lancer avec tclsh :
# cd là_où_on_veut_faire_l_index ; tclsh là_où_se_trouve_ce_fichier

###########################################################################
# Incorporer entre les accolades de "array set R {}"                      #
# une liste double donnant le nom des fichiers et la rotation à appliquer #
# Si un nom n'est pas donné, la photo n'est pas tournée                   #
###########################################################################

array set R {
Atelier/0101Gilbert6.jpg 0
Atelier/0101Gilbert8.jpg -
Atelier/0101LaurentC7.jpg 0
Atelier/0703Yvon34.jpg 0
Composants/0705batK3.jpg 0
Composants/0705cambridge6.jpg 0
Composants/0705composants5.jpg 0
Composants/0705Dupuis2.jpg 0
Composants/0705Fabrice1.jpg 0
Composants/0705fabrice7.jpg +
Composants/0705JLuc8.jpg 0
Composants/0705lDupuis3.jpg 0
Composants/0705Leo4.jpg -
Composants/0705manipfab7.jpg +
Composants/0705Roland6.jpg 0
Composants/0705Sicault7.jpg -
Composants/0705Sicault8.jpg -
Composants/0705stephane1.jpg 0
Composants/0705stephane2.jpg 0
Composants/070cambridge5.jpg 0
FIB/0703Jacques33.jpg 0
FIB/0704FIB1.jpg +
FIB/0704FIB3.jpg 0
FIB/070FIB2.jpg -
MBEE/0703Alex1.jpg 0
MBEE/0703Alex2.jpg 0
MBEE/0703Alex3.jpg 0
MBEE/0704SPM4.jpg 0
MBEE/0704TIP1.jpg -
MBEE/0705Alex9.jpg 0
MBEE/0705francois3.jpg 0
MBEE/0705Francois4.jpg 0
MBEE/0705mob4.jpg 0
MBEE/0705SPM5.jpg 0
MBEE/0705SPM6.jpg -
MBEE/0705SPM7.jpg 0
MBEE/070Anto8.jpg 0
MBER/0101Giovanni5.jpg 0
MBER/0101MBEvero2.jpg 0
MBER/0101MBEvero3.jpg 0
MBER/0101MBEvero4.jpg 0
MBER/0703Jacquelin29.jpg 0
MBER/0704Pascale10.jpg 0
MBER/0704Pascale11.jpg 0
MBER/0704Pascale12.jpg 0
MBER/0705MBEvero1.jpg 0
Meso/0703cecile6.jpg 0
Meso/0703Faini10.jpg 0
Meso/0703Faini11.jpg 0
Meso/0703Faini8.jpg 0
Meso/0703Faini9.jpg 0
Meso/0703Meso4.jpg -
Meso/0703Meso5.jpg -
Meso/0704Mailly12.jpg 0
Meso/0704meso1.jpg -
Meso/070Jin7.jpg 0
Photo_Yvon/06280004.jpg 0
Photo_Yvon/06280005.jpg -
Photo_Yvon/06280006.jpg -
Photo_Yvon/06280007.jpg -
Photo_Yvon/06280008.jpg -
Photo_Yvon/06280009.jpg 0
Photo_Yvon/06280010.jpg 0
Photo_Yvon/06280011.jpg 0
Photo_Yvon/06280012.jpg -
Photo_Yvon/06280013.jpg -
Photo_Yvon/06280014.jpg -
Photo_Yvon/06280015.jpg 0
Photo_Yvon/06280017.jpg -
Photo_Yvon/0628cam16.jpg -
Photo_Yvon/0628Delphine18.jpg -
Photo_Yvon/0628Melissa19.jpg 0
Photo_Yvon/0628Melissa20.jpg -
Photo_Yvon/0628STM3.jpg 0
Photo_Yvon/062STM2.jpg -
SBL/0705leob3.jpg 0
SBL/0705leot4.jpg 0
SBL/0705lithoX3.jpg -
SBL/0705lithoX4.jpg 0
SBL/0705masq5.jpg -
SBL/0705masq6.jpg 0
SBL/0705mesure46.jpg -
SBL/0705metalisatø1.jpg 0
SBL/0705metalisatø2.jpg 0
SBL/0705plasma10.jpg 0
SBL/0705plasma11.jpg 0
SBL/07microscopes7.jpg 0
SBL/0plasma9.jpg 0
SBL_personnel/0704Ali10.jpg 0
SBL_personnel/0704Andre9.jpg 0
SBL_personnel/0704edmond2.jpg 0
SBL_personnel/0704edmond3.jpg 0
SBL_personnel/0704laurence4.jpg 0
SBL_personnel/0704laurence5.jpg 0
SBL_personnel/0704Laurence6.jpg 0
SBL_personnel/0704Laurence7.jpg 0
SBL_personnel/0704Laurent11.jpg 0
SBL_personnel/0704xavier13.jpg 0
SBL_personnel/0705cambridge6.jpg 0
SBL_personnel/0705david4.jpg 0
SBL_personnel/0705Edmond10.jpg 0
SBL_personnel/0705Leo4.jpg -
SBL_personnel/0705xavier8.jpg 0
SBL_personnel/070cambridge5.jpg 0
ServicesGeneraux/0628Delphine18.jpg -
ServicesGeneraux/0628Melissa19.jpg 0
ServicesGeneraux/0628Melissa20.jpg -
ServicesGeneraux/0703Eric28.jpg 0
ServicesGeneraux/0704JYM17.jpg 0
ServicesGeneraux/0705Eric5.jpg 0
ServicesGeneraux/0705Manuel1.jpg 0
ServicesGeneraux/070Delph30.jpg 0
ServicesGeneraux/070Delph31.jpg 0
ServicesGeneraux/070Delph32.jpg 0
snom/0704chen14.jpg -
snom/0704chen15.jpg 0
snom/0704david16.jpg 0
snom/0704decanini13.jpg 0
snom/07050002.jpg 0
snom/0705Amira1.jpg 0
snom/0705Anne2.jpg 0
snom/0705Anne3.jpg 0
STM/0101JC9.jpg 0
STM/0704STM4.jpg -
STM/0704STM5.jpg -
STM/0704STM6.jpg -
STM/0704STM7.jpg -
STM/0704Xtoffe8.jpg 0
STM/0704zao14.jpg 0
STM/0704zao15.jpg 0
Atelier/0101Gilbert6.jpg 0
Atelier/0101Gilbert8.jpg -
Atelier/0101LaurentC7.jpg 0
Atelier/0703Yvon34.jpg 0
}

########################
# Entête html standard #
########################

set content {<!doctype html public "-//w3c//dtd html 4.0 transitional//en">
<html>
<head>
   <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
</head>
<body>
}

###############################################################################
# Traitement de tous les fichiers .jpg de tous les sous-répertoires immédiats #
# Pour chaque répertoire, on construit une liste de fichiers, en éliminant    #
# les fichiers dont le nom début par mini_ ou par r_                          #
# Chaque liste est un élément du tableau F, indexé par le nom du répertoire   #
###############################################################################

set fichiers [glob */*.jpg]
foreach df $fichiers {
    foreach {d f} [file split $df] {break}
    if {![string match mini_* $f] && ![string match r_* $f]} {
        lappend F($d) $f
    }
}

################################
# Boucle sur chaque répertoire #
################################

foreach d [lsort [array names F]] {

    ###################################
    # Impression du nom du répertoire #
    ###################################

    append content <p>\n
    append content "$d\n"
    append content <br>\n

    ###########################################################
    # On sépare les photos horizontales des photos verticales #
    ###########################################################

    set cv ""
    set ch ""

    #############################
    # Boucle sur chaque fichier #
    #############################

    foreach f $F($d) {

        puts stderr $d/$f
        
        #####################################
        # Création des images tournées      #
        # au moyen de la commande "convert" #
        # associée au programme ImageMagick #
        #####################################

        if {[info exists R($d/$f)]} {
            if {$R($d/$f) == "-"} {
                set h 128
                set w 96
                set cvar cv
                exec convert -rotate +90 $d/$f $d/r_$f
                set f r_$f
            } elseif {$R($d/$f) == "+"} {
                set h 128
                set w 96
                set cvar cv
                exec convert -rotate -90 $d/$f $d/r_$f
                set f r_$f
            } else {
                set h 96
                set w 128
                set cvar ch
            }
        } else {
            puts stderr " Non enregistré ! -> pas de rotation"
                set h 96
                set w 128
                set cvar ch
        }

        #####################################
        # Création des mini-images          #
        # au moyen de la commande "convert" #
        # associée au programme ImageMagick #
        #####################################
        
        exec convert -size ${w}x${h} $d/$f $d/mini_$f

        #################################################################
        # Ajout de la chaine à l'une des deux variables cv ou ch        #
        # On prend soin de créer le champ ALT pour les aveugles         #
        # Pour les bien-voyants, affiche aussi des ballons-commentaires #
        #################################################################

        append $cvar "<a href=\"$d/$f\"><img SRC=\"$d/mini_$f\" ALT=\"$d/$f\" height=$h width=$w></a>\n"
    }

    ######################################################
    # Impression des photos verticales puis horizontales #
    ######################################################

    append content $cv
    append content $ch
    append content </p>\n
}

################################
# Fin standard du fichier html #
################################

append content </body>\n</html>\n

################################################################################
# Sauvegarde du fichier index.html en index.html.old et écriture de intex.html #
################################################################################

if [file exists index.html.old] {
    puts stderr "Effacer d'abord index.html.old"
    exit 1
}
set fh [open index.html.new w]

puts -nonewline $fh $content
close $fh

if [file exists index.html] {
    file rename index.html index.html.old
    puts stderr "\"index.html\" renommé \"index.html.old\""
}

file rename index.html.new index.html

####################
# fin du programme #
####################
