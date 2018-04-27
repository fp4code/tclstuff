##################################################
# script Tcl pour constituer un album photos Web #
# (C) 2002 CNRS/LPN                              #
# corrections : Fabrice.Pardo@Lpn.cnrs.fr        #
##################################################

set HELP(html::photoIndex) {
    unix_ou_dos% cd là_où_on_veut_faire_l_index
    unix_ou_dos% tclsh

    # sous l'interpréteur tclsh, taper les commandes :

    package require fidev ; package require html_photoIndex

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
        FIB/0703Jacques33.jpg 0
        FIB/0704FIB1.jpg +
        FIB/0704FIB3.jpg 0
    }

    html::createPhotoIndex
}


######################
# début du programme #
######################

package provide html_photoIndex 1.0

namespace eval html {}

set L 128
set l 96

proc html::createPhotoIndex {} {
    global R L l

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
    # les fichiers dont le nom débute par mini_ ou par r_                         #
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
                    exec convert -rotate +90 $d/$f $d/r_$f
                    set f r_$f
                } elseif {$R($d/$f) == "+"} {
                    exec convert -rotate -90 $d/$f $d/r_$f
                    set f r_$f
                }
            }

            set err [catch {exec convert -verbose $d/$f NULL >@ stdout} blabla]

            if {$err} {
                puts stderr "ERREUR : \"$blabla\""
            } else {
                puts $blabla
            }

            continue
            
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
        puts stderr "Effacer d'abord index.html.old (commande \"file delete index.html.old\")"
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
    
}

####################
# fin du programme #
####################

