#!/usr/local/bin/tclsh

# Script de sauvegarde des r�pertoire vitaux des disques Unix du L2M
#
# ATTENTION : (extrait de man ufsdump)
#
#     When running ufsdump, the file sys-
#     tem must be inactive; otherwise, the output of  ufsdump  may
#     be  inconsistent and restoring files correctly may be impos-
#     sible.  A file system is inactive when it is UNMOUNTED OR the
#     system  is  in  SINGLE USER MODE.  A file system is not con-
#     sidered inactive if one tree of the file system is quiescent
#     while another tree has files or directories being modified.
#

# Hi�rarchie d'appel des proc�dures :
#
# Programme principal
# -> nisTo3col
# -> sauvetout
#   -> splitAutoHomeInTable
#   -> sauve
#

set Historique {

1998-07-06, EH : Cr�ation de l'historique
1998-07-06, EH : Ajouts de commentaires au script original de FP
1998-07-06, EH : �limination de l'ajout de www dans la liste $homes
                  (redondance)
1998-09-15, FP : Changement de l'ordre des progs
1998-09-15, FP : variable LOG chang�e
                 (/home/Logs/backup.$date -> /home/Logs/backups/backup.$date)
1998-09-15, FP : Changement de la nature de "Historique"
                 (commentaires -> variable)
1998-10-06, EH : Renommage de quelques nom de variables (plus explicite)
1998-10-06, EH : Ajouts de commentaires

}


# ----------------------------------------------------------------------
# Pour le d�bogage :
#
# dbexec : proc�dure qui affiche une commande (avec un pr�fixe "exec : ")
#          au lieu de l'ex�cuter
# ----------------------------------------------------------------------
proc dbexec args {
    puts "exec : $args"
}


# ----------------------------------------------------------------------
# Constantes
# ----------------------------------------------------------------------


# Utilitaire de dump
set DUMP "/usr/sbin/ufsdump"
# Niveau du dump
# 0 = copie du filesystem complet dans fichier de dump
set LEVEL 0
# Commande de dump avec options (cf. man ufsdump)
# d = tape density (ici 54000 bpi)
# s = size of the volume  being  dumped to (ici 13000 feet)
# b = blocking factor (ici 126 blocs)
# f = use dump file specified in command line
# u = update the dump record
set DUMPOP "$DUMP ${LEVEL}dsbfu 54000 13000 126"

# Gestionnaire de p�riph�rique pour le lecteur de bande
# (cf. man st, rubriques Files) :
# rmt : raw magnetic tape
# 0cn : 0 = bande no 0, c = compress�, n = no rewind
#       autres modes autoris�s :
#       0 0b 0n 0bn 0l 0lb 0ln 0lbn 0m 0mb 0mn 0mbn
#                  l,m,h,u,c  specifies  the  density  (low,
# 		   medium,  high, ultra/compressed), b the optional
# 		   BSD behavior (see mtio(7I)), and n the  optional
# 		   no  rewind behavior.
# 		   For 8mm tape devices (Exabyte 8200/8500/8505):
# 			   l                Standard 2 Gbyte format
# 			   m                5 Gbyte format (8500, 8505 only)
# 			   h,c              5 Gbyte compressed format (8505 only)
set TAPE "/dev/rmt/0cn"
# H�te sur lequel est connect� le lecteur de bande
set SERVEUR dao1


# ----------------------------------------------------------------------
# sauve : 
#
# entr�e : TableArg, names
# sortie : TableArg
# retour : rien
#

# proc�dure qui execute la sauvegarde sur bande. Un fichier ufsdump
# par �l�ment de la liste names qui contient les points de montage :
#
# names :
#      mountpoint1 mountpoint2
#
# on utilise les informations contenues dans le tableau TableArg qui
# est du type :
#
# TableArg :
#      Tableau(mountpoint1) = machine1 path1
#      Tableau(mountpoint2) = machine2 path2
#
# ----------------------------------------------------------------------

proc sauve {TableArg names} {
    upvar $TableArg Table
    # boucle sur les points de montage
    foreach qui $names {
        global numero DUMPOP SERVEUR TAPE log
	# on r�cup�re la machine et le chemin absolu
        set ou $Table($qui)
        set machine [lindex $ou 0]
        set path    [lindex $ou 1]
	# compte-rendu sur la sortie standard
        puts "$numero -> $qui $machine $path"
        puts "rsh -n $machine $DUMPOP ${SERVEUR}:${TAPE} $path"
	# envoi de la commande au shell
        set err [catch {dbexec rsh -n $machine $DUMPOP ${SERVEUR}:${TAPE} $path} messages]
        puts "messages = \n$messages"
        puts "err = $err"
	# �criture dans le fichier de log de la sortie de la commande shell
        puts $log "$numero -> $qui $machine $path (erreur = $err)"
        puts $log $messages
        flush $log
	# si la sortie de la commande shell contient la cha�ne
	# "DUMP IS DONE", on incr�mente le num�ro
        if {[string first "DUMP IS DONE" $messages] >= 0} {
            incr numero
        }
    }
}

# ----------------------------------------------------------------------
# splitAutoHomeInTable : 
#
# entr�e : Tableau Liste
# sortie : Tableau
# retour : rien
#
#
# proc�dure de transformation d'une liste en tableau associatif :
# on part d'une liste du type 
#
#  {mountpoint1 machine1 path1} {mountpoint2 machine2 path2}
#
# pour construire le tableau associatif
#
#  Tableau(mountpoint1) = machine1 path1
#  Tableau(mountpoint2) = machine2 path2
# ----------------------------------------------------------------------

proc splitAutoHomeInTable {Tableau Liste} {
    # la variable tableau correspond � la variable du niveau n-1 Tableau
    upvar $Tableau tableau
    # purge du tableau (utile ?)
    foreach a [array names tableau] {
        unset tableau($a)
    } 
    # boucle sur les �l�ments de la liste
    foreach ligne $Liste {
	# on r�cup�re l'�l�ment courant (qui est une liste)
        set elems [eval list $ligne]
	# cette liste doit avoir 3 �l�ments
        if {[llength $elems] != 3} {
            puts stderr "DANGER : [llength $elems] �l�ments (au lieu de 3) pour $ligne"
        }
	# on remplit le tableau :
	#   cl�    = �l�ment 0
	#   valeur = �l�ments 1 et 2 (liste)
        set qui [lindex $elems 0]
        set tableau($qui) [lrange $elems 1 2] 
    }
}

# ----------------------------------------------------------------------
# sauvetout : 
#
# entr�e : Liste
# sortie : rien
# retour : rien
#
# Proc�dure qui appelle la proc�dure sauve en lui formatant ses deux
# arguments :
#  - un tableau associatif de type dit T :
#
#      Tableau(mountpoint1) = machine1 path1
#      Tableau(mountpoint2) = machine2 path2
#
#  - une liste des points de montage
#
#      mountpoint 1mountpoint2
#
# Ces deux arguments sont construits � partir d'une liste de type dit L : 
#
#    {mountpoint1 machine1 path1} {mountpoint2 machine2 path2}
#
# ----------------------------------------------------------------------

proc sauvetout Liste {
    # on transforme la liste de type L en tableau associatif de type T
    set Table(dummy) {}
    splitAutoHomeInTable Table $Liste
    # on construit une liste � partir des premiers �l�ments de chaque
    # �l�ment de la liste de type L (les points de montage)
    set names {}
    foreach n $Liste {
        lappend names [lindex $n 0]
    }
    sauve Table $names
}

# ----------------------------------------------------------------------
# nisTo3col :
#
# entr�e : racine, table, liste
# retour : ret
#
# Proc�dure qui transforme le sous-ensemble d'une table NIS+ "table"
#
#     cl�_1 valeur_1
#     cl�_2 valeur_2
#     ...
#     cl�_n valeur_n
#
# dont les cl�s figurent dans la liste "liste"
# (en supposant que valeur_i s'�crit v_avant_i:v_apr�s_i)
# en liste de liste
#
#     {a_1 b_1 c_1} {a_2 b_2 c_2} ... {a_n b_n c_n}
#
# o�
# 
# a_i = racine/cl�_i
# b_i = v_avant_i
# c_i = v_apr�s_i
# 
# Exemple :
# 
#      nisTo3col /home auto_home.org_dir $homes
# 
# transforme la liste NIS+
# 
#      heintze l2m:/export/home/heintze
#      finley fico:/export/clos/finley
#      regis l2m:/export/home/regis
# 
# en 
# 
#      {/home/heintze l2m /export/home/heintze}...
#      {/home/finley fico /export/clos/finley}...
#      {/home/regis l2m /export/home/regis}
# ----------------------------------------------------------------------

proc nisTo3col {racine table liste} {
    # table NIS+ (cl�-valeur) transform�e en liste de liste
    # {{cl�_1 valeur_1} {cl�_2 valeur_2} ...}
    set l [exec niscat $table]
    set l [split $l \n]
    # liste pr�c�dente transform�e en tableau T(cl�) = valeur
    foreach ll $l {
        foreach {nom mp} $ll {}
        set T($nom) $mp
    }
    set ret [list]
    # pour chaque nom de la liste "liste"
    foreach nom $liste {
	# si la cl� n'existe dans pas dans la table NIS+, on r�le
        if {![info exists T($nom)]} {
            puts stderr "$table : pas de cle $nom"
        } else {
	    # si elle existe, s�parer la valeur au niveau du ":"
            set mp [split $T($nom) :]
            foreach {ou quoi} $mp {}
            lappend ret [list $racine/$nom $ou $quoi]
        }
    }
    return $ret
}

# ======================================================================
# Programme principal
# ======================================================================

# ----------------------------------------------------------------------
# Cr�ation d'un fichier de log
# ----------------------------------------------------------------------

# Date au format japonais pour le nom du fichier de log
set date [clock format [clock seconds] -format  %Y-%m-%d]
# Nom du fichier de log
set LOG /home/Logs/backups/backup.$date

# Cr�ation du fichier. Si le fichier existe d�j�, on le renomme en lui 
# ajoutant le suffixe BAK avec un incr�ment
if {[file exists $LOG]} {
    set i 0
    while [file exists $LOG.BAK$i] {
        incr i
    }
    file rename $LOG $LOG.BAK$i
}
set log [open $LOG w]

# On met du texte dans le fichier de log : un pense-b�te pour les
# instructions des restauration
puts $log {Pour r�cup�rer les fichiers Num�ro1 et Num�ro2, le mieux est
	# /usr/bin/rsh -n $SERVEUR mt -f /dev/rmt/0mn asf Num�ro1
	# /usr/sbin/ufsrestore if $SERVEUR:/dev/rmt/0mn
	# /usr/bin/rsh -n $SERVEUR mt -f /dev/rmt/0mn asf Num�ro2
	# /usr/sbin/ufsrestore if $SERVEUR:/dev/rmt/0mn
Bien qu'il soit �videmment pr�f�rable d'aller dans un ordre croissant,
l'exabyte retrouve tr�s vite un fichier quelconque.
}
flush $log


# ----------------------------------------------------------------------
# Liste des r�pertoires � sauvegarder
# ----------------------------------------------------------------------

# 1. Pr�liminaires
# ----------------------------------------------------------------------

# Deux partitions importantes contenant des donn�es utilisateurs :
set HOMEDIR /export/home
set ILEAFDIR /home/desktops

# Sauvegarde contexte (r�pertoire original)
set pwd [pwd]

# Dans le r�pertoire "home" :
# - on constitue une liste ("homes") avec tous les noms de r�pertoire 
#   qui commencent par [a-z] 
# - on cherche puis on retire (on remplace par rien) de la liste
#   l'�l�ment "desktops"
# - on trie par ordre alphab�tique
cd $HOMEDIR
set homes [glob \[a-z\]*]
## lappend homes www
set err [catch {lsearch $homes desktops} index]
if {!$err} {
    set homes [lreplace $homes $index $index]
}
set homes [lsort $homes]

# Dans le r�pertoire "documents interleaf utilisateurs" :
# - on constitue une liste ("desktops") avec tous les noms de r�pertoire 
#   qui commencent par [a-z]
# - on trie par ordre alphab�tique
cd $ILEAFDIR
set desktops [glob \[a-z\]*]
set desktops [lsort $desktops]

# Restauration contexte (r�pertoire original)
cd $pwd

# D'autres r�pertoires � sauver (programmes) sont �num�r�s dans la liste
# "progs"
set progs {NICgpib Tcl linux asdex cap60 dt gnu gnuplot ileaf src utl}

# 2. Construction de la liste proprement dite ("Vital")
# ----------------------------------------------------------------------

# �laboration de la liste "Vital" des r�pertoires � sauver
# Cette liste est une liste de liste du type
# {{<point de montage> <machine> <r�pertoire absolu>} ...}
set Vital [list]

# Ajout des r�pertoires /home/<users>
set Vital [concat $Vital [nisTo3col /home auto_home.org_dir $homes]]

# Ajout des r�pertoires utilisateurs Interleaf
foreach f $desktops {
    lappend Vital [list /home/desktops/$f l2m /export/ileaf/desktops/$f]
}

# Ajout des partitions / et /usr de l2m
lappend Vital {/ l2m /} {/usr l2m /usr}

# Ajout des r�pertoires /progs/*
set Vital [concat $Vital [nisTo3col /prog auto_prog.org_dir $progs]]

# ----------------------------------------------------------------------
# Sauvegarde sur bande
# ----------------------------------------------------------------------

# Affichage de tout ce qui est sauv�
puts "sauvegarde de ..."
foreach l $Vital {
    puts $l
}

# RAZ num�ro du fichier sur la bande
set numero 0
# Rembobinage de la bande
puts "rsh -n $SERVEUR mt -f $TAPE rewind"
dbexec rsh -n $SERVEUR mt -f $TAPE rewind

# Sauvegarde du contenu de la liste pr�c�demment �tablie
sauvetout $Vital

# Fermeture du fichier de log
close $log

# Cr�ation du r�sum� du fichier de log
set dir [file dirname [info script]]
dbexec $dir/resume3.tcl $LOG

