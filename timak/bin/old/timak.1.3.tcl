#!/bin/sh

# the next line restarts using tclsh \
exec tclsh "$0" "$@"

proc putsdebug {message} {
    if 0 {
        puts stderr $message
    }
}

set HELP(timak) {
# 16 novembre 2000

set LIBS($libname) [concat $GLOBLIBS(complexmath) $GLOBLIBS(math)]
  ne marche pas
  reste = 0

set LIBS($libname) [concat ../../dblas1/src/libdblas1 $GLOBLIBS(complexmath) $GLOBLIBS(math)]
  marche

corrig� en introduisant "autonomous" dans ::algraph::depthList

# 3 mai 2000. On n'utilise plus "cd", qui est commun aux interpr�teurs

Pour pr�voir un travail parall�le, "timak" travaille en deux passes.

Dans une premi�re passe, il collecte tous les "create ..." avec leurs relations
de d�pendance directe.
Cette liste permet de construire un treillis.

Dans une seconde passe, "timak" ex�cute les "create ..." qui sont feuilles du treillis
puis toutes les branches dont les feuilles ont pu �tre cr��es correctement, etc.

#############
26 avril 2000
Exemples d'appel, nouvelle syntaxe
##################################

exec timak
exec timak -do default
exec timak -do lib
exec timak -do lib bin
exec timak -create lib libtcl_blas
exec timak -create libs {libtcl_blas libtcl_blos} program blassh
exec timak -create libs {libtcl_blas libtcl_blos} programs {blassh blassh2}
exec timak -do lib

exec timak -in blas
exec timak -in {blas blis blos}              ;# L'argument unique aurai permis d'autoriser un r�pertoire de nom "-do" INTERDIT
exec timak -in {blas blis blos} -do default  ;# INTERDIT, utiliser "foreach d {blas blis blos} {exec timak -in $d -do default}
exec timak -in {blas blis blos} -do lib bin  ;# INTERDIT (risques de confusion avec les noms comportant un blanc)
exec timak -in blas -create lib libtcl_blas programs {blassh blassh2} # interdit (on ne transmet que des "-do")

�quivalents dans les fichiers Timak.tcl: remplacer "exec timak" par "do -case xxx"

exec timak -> {-do default}
exec timak -do default -> {-do default}
exec timak -do lib -> {-do lib}
exec timak -create lib libtcl_blas

Dans un r�pertoire donn� on peut
  - cr�er des choses (option -create ...)
  - mettre en oeuvre une indirection (option -do ...)
  - passer le b�b� � un sous-r�pertoire (v�rifier par "file split" que c'est bien un sous-r�pertoire)
Les proc�dures correspondantes sont timak::create, timak::do et timak::in.

#####################################################################################

on construit la liste de r�pertoires qui contiennent les fichiers "*.h" n�cessaire
� la compilation

    set INCLUDES [list $TCLINCLUDEDIR ../../horreur/src]

on d�finit la liste des sources d'une biblioth�que

    set SOURCES(libtcl_blas) {tclBlas1Cmd.c tclBlas0Cmd.c tclBlasUtil.c tclBlasInit.c}

on d�finit la liste des biblioth�ques que n�cessite une biblioth�que.
Lorsqu'une biblioth�que est relative, on va dans le r�pertoire qui la
contient ex�cuter "timak" pour cr�er la biblioth�que. Ici:
"timak -do {create lib libtcl_blas}".

    set    LIBS(libtcl_blas) [list ../../../fortran/blas/src/libblas $TCLLIB libc]

idem pour cr�er un ex�cutable

    set SOURCES(blassh) mainTcl.c
    set    LIBS(blassh) [list ./libtcl_blas $TCLLIB]

cr�e la biblioth�que partag�e "libtcl_blas" et le programme "blassh"

    do create lib libtcl_blas
    do create program blassh

des conditions sont possibles:

    do -case lib create lib libtcl_blas

#####################################################################################

QUE FAIT TIMAK ? (obsol�te ?)

- lanc� � partir d'un r�pertoire, le programme "timak"
commence par v�rifier que le fichier "Timak.tcl" existe.

S'il n'existe pas, c'est une erreur grave.

On suppose donc que le fichier "Timak.tcl" existe.
"timak" examine l'existence dans le r�pertoire parent
du fichier "Timak.tcl".
On remonte comme cela jusqu'au dernier r�pertoire anc�tre
contenant un fichier "Timak.tcl".

L'interpr�teur se place ensuite dans un namespace vierge,
(ou bien dans un nouvel interpr�teur)
importe la commande "::timak::do"
et ex�cute sur chaque fichier "Timak.tcl"
la commande Tcl "source", en partant de l'anc�tre et
en finissant par le r�pertoire d'o� la commande "timak"
a �t� lanc�e. Toutes les commandes "::timak::do"
sont ignor�es lors de la lecture des fichiers parents

Dans le cas d'une commande "do subdir", l'interpr�teur
passe dans ce r�pertoire et lance la commande "timak".

Dans une version plus �labor�e, on commence par
construire une liste de choses � cr�er.

}

namespace eval timak {
    variable PWD
}


#####################################################
# UTILITAIRES unambiguousPwd, timakFiles, reverseList

proc horreur {err} {

    if {!$err} {
        return
    }
    
    global errorInfo tcl_interactive
    puts stderr $errorInfo
    
    if {$tcl_interactive} {
        puts stderr "exit $err"
    } else {
        exit $err
    }
}

proc ::timak::nativeDir {list} {
    return [file nativename [eval file join $list]]
}


set HELP(::timak::unambiguousPwd) {
    retourne un identificateur non ambigu, au moyen d'une variable globale PWD
    ex : /export/global/Home/fab et /home/fab sont ambigus sur la machine "u5fico" du L2M.
    On predra garde que [pwd] est li� � la variable env(PWD), et que
    comme lui, il est le m�me pour tous les interpr�teurs
}

proc ::timak::unambiguousPwd {} {
    variable PWD
    set pwd [pwd]
    file lstat $pwd a
    set ui "$a(dev),$a(ino)" ;# unambiguous id DANGER, architecture dependant
    if {[info exists PWD($ui)]} {
        return $PWD($ui)
    } else {
        set PWD($ui) $pwd
        return $pwd
    }
}


############################
set HELP(::timak::readTimak) {
  un r�pertoire racine $root �tant donn� sous forme de liste
  un sous-r�pertoire $dir �tant donn� sous forme de liste
  la proc�dure retourne le contenu du fichier Timak.tcl
  r�visions {
      {27 avril 2000} {}
      {3 mai 2000} {}
  }

  Utilisation {::timak::readTimaks}
}
proc ::timak::readTimak {fulldir} {
    if {[catch {
        set fichier [eval file join $fulldir Timak.tcl]
        set f [open $fichier r]
        set ret [read -nonewline $f]
        close $f
    } message]} {
        return -code error "file \"$fichier\": $message"
    }
    return $ret
}

##########################
set HELP(::timak::getRoot) {
    4 mai 2000 (FP)

    Un r�pertoire �tant donn� sous forme de liste {/ home fab A fidev Tcl} ou {D:/ users fab}
    on remonte les parents jusqu'� trouver le dernier r�pertoire contenant un fichier Timak.tcl
    On retourne l'index dans la liste "$directory" qui correspond � la racine 

    Utilisation {::timak::readTimaks}
}

proc ::timak::getRoot {directory} {
    set nativedir [eval file join $directory]
    
    if {![file isdirectory $nativedir]} {
        return -code error "\"$nativedir\" is not a directory"
    }
    if {[file pathtype $nativedir] != "absolute"} {
        return -code error "\"$nativedir\" is not absolute pathtype (it's [file pathtype $nativedir])"
    }
 
    if {![file exists [file join $nativedir Timak.tcl]]} {
        return -code error "No \"Timak.tcl\" file"
    }

    set i [expr {[llength $directory] - 1}]
    set itest [expr {$i - 1}]

    while {[file exists [eval file join [lrange $directory 0 $itest] Timak.tcl]] && $i != 0} {
        set i $itest
        incr itest -1
    }
    return $i
}

#############################
set HELP(::timak::readTimaks) {
    Cette proc�dure sert � r�cup�rer le contenu d'une lign�e de fichiers Timak.tcl

    Ces fichiers sont 
    - un r�pertoire racine $root �tant donn� sous forme de liste
    - un r�pertoire $directory �tant donn� sous forme de liste
    - On charge (si cela n'a pas �t� fait) le tableau de nom $TIMAKSName
      du contenu des fichiers Timak.tcl. Le nom du r�pertoire (sous forme de liste) forme l'index.

    retour: liste des r�pertoires

    revisions {
        {27 avril 2000} {}
        {3 mai 2000} {suppression des "cd"}
    }

    Utilisation {Pr�liminaire � FirstPass}
}
proc ::timak::readTimaks {root TIMAKSCONTENTSName reldir} {
    upvar $TIMAKSCONTENTSName TIMAKSCONTENTS

    #set iroot [::timak::getRoot $directory]
    #set root [lrange $directory 0 $iroot]
    #if {$root != $rootControl} {
    #    return -code error "Splitted directory \"$directory\" has \"$root\" as root, I want \"$rootControl\"."
    #}

    
    if {![info exists TIMAKSCONTENTS()]} {
        # Tcl admet un indice "vide" pour les tableaux associatifs
        set TIMAKSCONTENTS() [::timak::readTimak $root]
    }
    set TimakDirs [list {}]
    set dir [list]
    foreach d $reldir {
        lappend dir $d
        if {![info exists TIMAKSCONTENTS($dir)]} {
            set TIMAKSCONTENTS($dir) [::timak::readTimak [concat $root $dir]]
        }     
        lappend TimakDirs $dir
    }
    return $TimakDirs
}

################################
set HELP(::timak::giveAncestors) {
    ::timak::giveAncestors {q w e} -> {} q {q w} {q w e}
}

proc ::timak::giveAncestors {dir} {
       
    set ret [list]
    set imax [llength $dir]
    for {set i -1} {$i < $imax} {incr i} {
        lappend ret [lrange $dir 0 $i]
    }
    return $ret
}


################################


##################################
set HELP(::timak::interpretTimaks) {

    modifie CASEDO par l'interm�diaire des commandes "do ..." contenues dans 
    les fichiers Timaks

    Les valeurs sont tri�es et jamais dupliqu�es

}

proc ::timak::interpretTimaks {TIMAKSCONTENTSName ROOT TimakDirs} {
    upvar $TIMAKSCONTENTSName TIMAKSCONTENTS

    # Il faudrait masquer le nom des variables

    foreach dir [lrange $TimakDirs 0 end-1] {
        set IGNORE_DO 1
        if {[catch {eval $TIMAKSCONTENTS($dir)} message]} {
            return -code error "error sourcing in $dir: $message"
        }
    }
    set dir [lindex $TimakDirs end]
    set IGNORE_DO 0

    if {[catch {eval $TIMAKSCONTENTS($dir)} message]} {
        global errorInfo
        puts stderr $errorInfo
        return -code error "error sourcing in $dir: $message"
    }

    set ret1 [list]
    foreach key [lsort [array names DO_LIST]] {
        catch {unset X}
        foreach do $DO_LIST($key) {
            set X($do) {}
        }
        lappend ret1 $key [lsort [array names X]]
    }

    set ret2 [list]
    foreach key [lsort [array names CREATE_LIST]] {
        catch {unset X}
        foreach do $CREATE_LIST($key) {
            set X($do) {}
        }
        lappend ret2 $key [lsort [array names X]]
    }

    set ret3 [list]
    foreach x [lsort [array names LIBS]] {
        set libs [list]
        foreach lib [lsort $LIBS($x)] {
            if {[string index $lib 0] == "/"} {
                continue
                # not relative lib
            }
            set lib [split $lib /]
            if {[llength $lib] == 0} {
                return -code error "void lib"
            } elseif {[llength $lib] == 1} {
                continue
                # not relative lib
            }
            set libFromRoot $dir
            while {[llength $lib] > 0} {
                set d [lindex $lib 0]
                set lib [lrange $lib 1 end]
                switch $d {
                    "." {}
                    ".." {set libFromRoot [lrange $libFromRoot 0 end-1]}
                    default {lappend libFromRoot $d}
                }
            }
            lappend libs $libFromRoot
        }
        if {$libs != {}} {
            lappend ret3 $x $libs
        }
    }

    return [list $ret1 $ret2 $ret3]
}

#####################
set HELP(::timak::do) {
C'est la commande qui est appel�e par les lignes "do ..." des fichiers "Timak.tcl"

}

proc ::timak::do {args} {
    upvar IGNORE_DO IGNORE_DO
    upvar DO_LIST DO_LIST
    upvar CREATE_LIST CREATE_LIST

    if {$IGNORE_DO} {
	return
    }
    
    set SYNTAX "wrong # args: should be \"::timak::do ?-case aAcase? ...\""
    
    if {[llength $args] < 1} {
	return -code error "command \"do $args\": $SYNTAX"
    }
    
    # do -case toto -create ...
    
    set reste $args

    if {[lindex $args 0] == "-case"} {
        set case [lindex $reste 1]
        set reste [lrange $reste 2 end]
    } else {
        set case default
        set reste [lrange $reste 0 end]
    }
    
    if {[lindex $reste 0] == "-in"} {
        set in [lindex $reste 1]
        set reste [lrange $reste 2 end]
    } else {
        set in .
        set reste [lrange $reste 0 end]
    }
    if {[string index [lindex $reste 0] 0] == "-"} {
        switch -exact [string range [lindex $reste 0] 1 end] {
            "do" {set dos [lrange $reste 1 end]}
            "create" {
                set create [lrange $reste 1 end]
                if {[llength $create] != 2} {
                    return -code error "-create type name"
                }
            }
            default {
                return -code error "bad do: $args"
            }
        }
    } else {
        set dos $reste
    }

    if {[info exists dos]} {
        if {$dos == {}} {
            if {$in == "." || $case == "default"} {
                set dos [list default]
            } else {
                return -code error "do ambigu: $args"
            }
        }
        foreach do $dos {
            lappend DO_LIST($case) [list $in $do]
        }
    }
    if {[info exists create]} {
        lappend CREATE_LIST($case) $create
    }
}

##############################
set HELP(timak::interpretArgs) {
    

}
proc timak::interpretArgs {caseName in  args} {
    

}




##########################
set HELP(timak::firstPass) {
    {
        {26 avril 2000} {(FP)}
        {27 avril 2000} {(FP) Refonte compl�te}
    }

    retourne une liste de d�pendances
    {
        {
            r�pertoire {program blassh} r�pertoire {lib libtcl_blas} r�pertoire {lib libblas}
        }
        {
            r�pertoire {program blassh2} r�pertoire {lib libtcl_blas}
        }
    }

    Chaque �l�ment de la liste correspond � un objet � construire � partir d'un r�pertoire donn�
    Chaque �l�ment de la liste est une liste, dont les 2 premiers �l�ments repr�sentent
           ce qui est � construire, et dont les paires d'�l�ments suivants sont les �l�ments n�cessaires
   $$$ Non termin�

}

proc timak::firstPass {TIMAKSCONTENTSName CREATEName ROOT dir doList createList} {
    upvar $TIMAKSCONTENTSName TIMAKSCONTENTS
    upvar $CREATEName CREATE

    putsdebug "$dir"

    set TimakDirs [::timak::readTimaks $ROOT TIMAKSCONTENTS $dir]
    set ici [lindex $TimakDirs end]

    # cr�ation d'un interpr�teur ind�pendant
    set interp [interp create]

    $interp alias ::timak::interpretTimaks ::timak::interpretTimaks
   
    # Interpr�tation des fichiers pour en retirer la "dolist" 

    set err [catch {$interp eval [list ::timak::interpretTimaks TIMAKSCONTENTS $ROOT $TimakDirs]} message]
    if {$err} {
        global errorInfo
        puts stderr "ERREUR, message = $message"
        puts stderr "      , errorInfo = $errorInfo"
        return -code error "IRR�M�DIABLE"
    }

    array set CASEDO [lindex $message 0]
    array set CASECREATE [lindex $message 1]
    array set LIBDEPENDS [lindex $message 2]

    # Les tableaux sont cr��s m�me vides

    # construction du type � partir du nom

    foreach case [array names CASECREATE] {
        foreach create $CASECREATE($case) {
            foreach {type nom} $create {break}
            if {[info exists TYPE($nom)] && $TYPE($nom) != $type} {
                return -code error "Le nom \"$nom\" a les deux types \"$TYPE($nom)\" et \"$type\""
            }
            set TYPE($nom) $type
        }
    }

    foreach x [array names LIBDEPENDS] {
        set libs $LIBDEPENDS($x)
        unset LIBDEPENDS($x)
        if {![info exists TYPE($x)]} {
            puts stderr "LIBS($x) inutile dans le Timak de [timak::nativeDir [concat $ROOT $dir]]"
            continue
        }
        set type $TYPE($x)
        switch -exact $type {
            "program" {
                # Il faudrait une variable globale pour faire un choix statique/dynamique
                set deptype lib
            }
            "lib" {
                set deptype lib
            }
            default {
                return -code error "type de \"$x\" inconnu : \"$type\""
            }
        }
        set newlibs [list]
        foreach lib $libs {
            lappend newlibs [list [lrange $lib 0 end-1] [concat $deptype [lindex $lib end]]]
        }
        putsdebug [list set LIBDEPENDS([list $dir [list $type $x]]) $newlibs]
        set LIBDEPENDS([list $dir [list $type $x]]) $newlibs
    }

    foreach do $doList {set DOLIST($do) {}}
    if {$createList != {}} {
        if {[info exists DOLIST(create)]} {
            return -code error "\"create\" is a reserved word; use \"do -create\", no \"do -do create\""
        }
        set  DOLIST(create) {}
        set CASECREATE(create) $createList
    }

    while {[array names DOLIST] != {}} {
        set do [lindex [array names DOLIST] 0]
        if {![info exists CASEDO($do)] && ![info exists CASECREATE($do)]} {
            if {$do != "nothing"} {
                return -code error "ERROR: I don't know how to do \"$do\" in [timak::nativeDir $dir]"
            } else {
                set VU($do) {}
                unset DOLIST($do)
                continue
            }
        }
        set VU($do) {}
        unset DOLIST($do)
        if {[info exists CASEDO($do)]} {
            foreach ww $CASEDO($do) {
                foreach {where what} $ww {break}
                if {$where == "."} {
                    if {![info exists VU($what)]} {
                        set DOLIST($what) {}
                    }
                } else {
                    lappend IN($where) $what
                }
            }
        }
        if {[info exists CASECREATE($do)]} {
            foreach x $CASECREATE($do) {
                set create [list $dir $x]
                if {[info exists LIBDEPENDS($create)]} {
                    putsdebug [list set CREATE($create) $LIBDEPENDS($create)]
                    set CREATE($create) $LIBDEPENDS($create)
                } else {
                    set CREATE($create) {}
                }
            }
        }
    }
    putsdebug [list dir = $dir]
    putsdebug [list IN = [lsort [array names IN]]]
    foreach subdir [lsort [array names IN]] {
        timak::firstPass TIMAKSCONTENTS CREATE $ROOT [concat $dir [list $subdir]] $IN($subdir) {}
    }
    return
}

set HELP(timak::finishFirstPass) {
    On se retrouve avec des CREATE(A) {B C D}
    Sans CREATE(B)
}

proc timak::finishFirstPass {TIMAKSCONTENTSName ROOT CREATEName} {
    upvar $TIMAKSCONTENTSName TIMAKSCONTENTS
    upvar $CREATEName CREATE
    
    foreach c [array names CREATE] {
        foreach todo $CREATE($c) {
            if {![info exists CREATE($todo)]} {
                if {[info exists TODO($todo)]} {
                    incr TODO($todo)
                } else {
                    set TODO($todo) 1
                    putsdebug [list todo = $todo -> [lindex $todo 0]]
                    lappend DOLISTINDIR([lindex $todo 0]) [lindex $todo 1]
                }
            }
        }
    }
    set dirs [array names DOLISTINDIR]
    putsdebug " reste = [llength $dirs]"
    # if {[llength $dirs] != 0} {parray DOLISTINDIR}
    putsdebug [list dirs = $dirs]
    foreach dir [lsort $dirs] {
        timak::firstPass TIMAKSCONTENTS CREATE $ROOT $dir {} $DOLISTINDIR($dir)
    }
    return [llength $dirs]
}

#******************************************************************#
#                  GRAPHES ALG�BRIQUES                             #
#******************************************************************#

namespace eval algraph {}

set HELP(::dag::treillis) {
    ou "acyclic digraph" ou "directed acyclic graph" ou "DAG"
    "outdegree" = nombre de fl�ches qui sortent

    Chaque "arc"

}

set HELP(::algraph::arclist) {

    en entr�e, $arcsOfNode(A) contient la liste des noeuds B
    pour lesquelles il y a un arc de A vers B.

    en sortie, on a une liste paire repr�sentant les arcs.

    si $arcsOfNode(A) == {B C D}, $arcsOfNode(B) == {C E}, le retour sera
    {A B  A C  A D  B C  B E}

    how:
       -alreadyClean: suppos�es propres
       -verif: on v�rifie qu'il n'y a pas d'arcs doubles
       -cleanIt: les arcs doubles sont supprim�s

}


proc ::algraph::arcList {how &arcsOfNode} {
    upvar ${&arcsOfNode} arcsOfNode

    if {![info exists arcsOfNode]} {
        return {}
    }
    set ret [list]
    switch -- $how {
        "-alreadyClean" {
            foreach a [array names arcsOfNode] {
                foreach b $arcsOfNode(a) {
                    lappend ret $a $b
                }
            }
        }
        "-verif" {
            foreach a [array names arcsOfNode] {
                if {[info exists B]} {
                    unset B
                }
                foreach b $arcsOfNode($a) {
                    if {[info exists B($b)]} {
                        return -code error "node \"$a\" has two arcs to \"$b\""
                    }
                    lappend ret $a $b
                    set B($b) {}
                }
            }
        }
        "-cleanIt" {
            foreach a [array names arcsOfNode] {
                if {[info exists B]} {
                    unset B
                }
                foreach b $arcsOfNode($a) {
                    if {![info exists B($b)]} {
                        lappend ret $a $b
			set B($b) {}
                    }
                }
            }
        }
        default {
            return -code error "bad argum(s) \"$args\", should be \"-alreadyClean\", \"-verif\" or \"-cleanIt\""
        }
    }
    return $ret
}

set HELP(::algraph::fillArcListArray) {
    Le tableau array est suppos� vide en entr�e

    La liste $list est une liste paire a1 b1 a2 b2 a3 b3 ...
    repr�sentant des arcs (ai bi)

    En sortie, array est index� par les noeuds A d'o� part au moins un arc.
    $array(A) est la liste des noeuds o� arrive un arc partant de A.
    
    Retourne une liste contenant tous les noeuds qui n'ont besoin de personne,
    o� arrive au moins un arc, mais d'o� n'en part aucun.
    Un noeud ne figure jamais deux fois dans la liste.
}

proc ::algraph::fillArcListArray {&array list} {
    upvar ${&array} array 

    array set LEAF {}
    # Le tableau LEAF existe et est vierge
    foreach {a b} $list {
        lappend array($a) $b
        set LEAF($b) {}
    }
    # Les index du tableau array sont les noeuds A d'o� part au moins un arc
    # $array(A) est la liste des noeuds o� arrive un arc partant de A
    # Les index du tableau LEAF sont les noeuds o� arrive au moins un arc 
    set ret [list]
    # $ret est une liste vierge
    foreach b [array names LEAF] {
        if {![info exists array($b)]} {
            lappend ret $b
        }
    }
    return $ret
    # On retourne une liste contenant tous les noeuds qui n'ont besoin de personne,
    # o� arrive au moins un arc, mais d'o� n'en part aucun.
    # Un noeud ne figure jamais deux fois dans la liste.
}

set HELP(::algraph::fillReverseArcListArray) {

    Le tableau array est suppos� vide en entr�e

    La liste $list est une liste paire a1 b1 a2 b2 a3 b3 ...
    repr�sentant des arcs (ai bi)

    En sortie, array est index� par les noeuds A d'o� part au moins un arc.
    $array(A) est la liste des noeuds o� arrive un arc partant de A.
    
    # On retourne une liste contenant tous les noeuds qui ne sont n�cessaires � personne,
    # d'o� part au moins un arc, mais o� n'en arrive aucun.
    # Un noeud ne figure jamais deux fois dans la liste.
}

proc ::algraph::fillReverseArcListArray {&array list} {
    upvar ${&array} array
    
    array set LEAF {}
    # LEAF est un tableau existe et est vierge
    foreach {a b} $list {
        lappend array($b) $a
        set LEAF($a) {}
    }
    # Les index du tableau array sont les noeuds B o� arrive au moins un arc
    # $array(B) est la liste des noeuds d'o� part un arc arrivant en B
    # Les index du tableau LEAF sont les noeuds d'o� part au moins un arc 
    set ret [list]
    # $ret est une liste vierge   
    foreach a [array names LEAF] {
        if {![info exists array($a)]} {
            lappend ret $a
        }
    }
    return $ret
    # On retourne une liste contenant tous les noeuds qui ne sont n�cessaires � personne,
    # d'o� part au moins un arc, mais o� n'en arrive aucun.
    # Un noeud ne figure jamais deux fois dans la liste.
}

set HELP(::algraph::depthList) {
    On a des noeuds.
    Un noeud n'est jamais isol�.
    Deux noeuds A B sont �ventuellement r�unis par un arc unique orient�,
    appel� "a besoin de"
    Si A a besoin de B, B figure dans la liste $arcsOfNode(A)

    Le graphe est suppos� acyclique
    
    Si un noeud n'a besoin de personne, on dira qu'il
    a une profondeur 0.
    Si un noeud a besoin d'au moins un noeud,
    mais n'a besoin que des noeuds de profondeur 0, on dira
    qu'il a la profondeur 1.
    Si un noeud a besoin d'au moins un noeud de profondeur 1,
    et seulement de noeuds de profondeur 1 ou 0, on dira qu'il a
    la profondeur 2.
    Si un noeud a besoin d'au moins un noeud de profondeur N,
    et seulement de noeuds de profondeur <= N, on dirq qu'il
    a la profondeur N+1.
}

proc ::algraph::depthList {&arcsOfNode} {
    upvar ${&arcsOfNode} arcsOfNode

    set autonomous [list]
    foreach b [array names arcsOfNode] {
        if {$arcsOfNode($b) == {}} {
            lappend autonomous $b
        }
    }
    putsdebug "autonomous = $autonomous"

    set arclist [::algraph::arcList -cleanIt arcsOfNode]
    # $arcList est une liste paire a1 b1 a2 b2 a3 b3 ... o� (ai bi) est un arc.
    # Il est garanti qu'aucun arc ne figure en double

    array set AL {}
    # Le tableau AL est vierge et existant
    set leafs [::algraph::fillArcListArray AL $arclist]
    # Le tableau AL existe
    # Le tableau AL a pour index les noeuds A d'o� part au moins un arc
    # $AL(A) est la liste des noeuds o� arrive un arc partant de A
    # $leafs est la liste des noeuds qui n'ont besoin de personne
    putsdebug "AL:"
    # parray AL
    putsdebug "leafs = $leafs"

    array set RAL {}
    # Le tableau RAL est vierge et existant
    ::algraph::fillReverseArcListArray RAL $arclist
    # Le tableau RAL existe
    # Le tableau RAL a pour index les noeuds B o� arrive au moins un arc
    # $RAL(B) est la liste des noeuds d'o� partent un arc arrivant en B

    foreach a [array names AL] {
        set OUTDEG($a) [llength $AL($a)]
    }
    # Le tableau OUTDEG n'existe pas n�cessairement
    # Le tableau OUTDEG a pour index les noeuds A d'o� part au moins un arc
    # $OUTDEG($a) est le nombre d'arcs partant de A

    array set HERE {}
    if {$leafs != {}} {
        foreach b $leafs {
            set HERE($b) {}
        }
    } else {
        if {[llength $autonomous] != 1} {
            puts stderr "WARNING : \[llength \$autonomous\] == [llength $autonomous]"
        }
    }
    foreach b $autonomous {
        set HERE($b) {}
    }
    # Le tableau HERE existe
    # Les index du tableau HERE sont les noeuds d�o� ne part aucun arc.
    putsdebug HERE:
    # parray HERE

    set prof 0
    set nextProf 1
    array set PROF {}
    # PROF est un tableau vierge
    while {[info exists HERE]} {
	# Les index du tableau HERE sont les noeuds de profondeur $prof
        set nodes [array names HERE]
	# $nodes est la liste des noeuds de profondeur $prof
        unset HERE
	# HERE n'existe plus
	# Il sera �ventuellement rempli
	# Sinon, la prochaine boucle ne sera pas affectu�e
        foreach b $nodes {
            set PROF($b) $prof
	    # PROF contiendra la profondeur des noeuds
            if {[info exists RAL($b)]} {
		# Il arrive au moint un arc sur $b 
                foreach a $RAL($b) {
		    # balayage de tous les noeuds d'o� part un arc en direction de $b
                    incr OUTDEG($a) -1
                    if {$OUTDEG($a) == 0} {
			# On a balay� tous les arcs partant de $a, donc PROF($a) == $prof + 1
                        if {[info exists PROF($a)]} {
			    #  PROF($a) <= $prof : contradiction
                            return -code error "Cyclic Graph on node \"$a\""
                        }
                        set PROF($a) $nextProf
                        set HERE($a) {}
                    }
                }
            }
	}
	# HERE contient tous les noeuds de profondeur $prof + 1
        incr prof
        incr nextProf
    }

    array set IPROF {}
    foreach a [array names PROF] {
        lappend IPROF($PROF($a)) $a
    }
        
    set ret [list]
    foreach i [lsort -integer [array names IPROF]] {
        lappend ret $IPROF($i)
    }
    putsdebug [list ret = $ret]
    return $ret
}

#******************************************************************#

###########################
set HELP(::timak::createIt) {
    Chaque r�pertoire a son interpr�teur Tcl attitr�, d�fini par le tableau
    de nom $INTERPSName, index� par $repertoire
    S'il n'existe pas, l'interpr�teur est cr�� et initialis� au moyen
    de la lign�e de fichiers Timak.tcl
    
    L'argument $what contient deux �l�ments, nature et nom
    La proc�dure ::timak::create est appel�e avec ces deux arguments

    Il peut paraitre inefficace de lancer plusieurs interpr�teurs,
    mais n'oublions pas qu'� terme, ils seront lanc�s sur plusieurs machines
    en parall�le.
}
proc ::timak::createIt {ROOT TIMAKSCONTENTSName INTERPSName repertoire what} {

    upvar $TIMAKSCONTENTSName TIMAKSCONTENTS
    upvar $INTERPSName INTERPS

    if {[info exists INTERPS($repertoire)]} {
        putsdebug "  exists"
        set interp $INTERPS($repertoire)
    } else {
        putsdebug "\nnew interp is created in $repertoire"
        # cr�ation de l'interpr�teur ind�pendant
        set interp [interp create]
        $interp alias ::timak::unambiguousPwd ::timak::unambiguousPwd
        $interp alias ::timak::getScript ::timak::getScript
        $interp alias ::timak::do ::timak::do
        
        #
        global CREATESCRIPTS
        $interp eval $CREATESCRIPTS
        #

        foreach dir [::timak::giveAncestors $repertoire] {
            set IGNORE_DO 1
            if {[catch {$interp eval [list namespace eval timak [::timak::getScript TIMAKSCONTENTS $dir]]} message]} {
                global errorInfo
                return -code error "error sourcing in $dir: $errorInfo"
            }
        }
        # enregistrement de l'interpr�teur
        set INTERPS($repertoire) $interp
    }

    # le "pwd", comme tous les "env" est partag� par tous les interpr�teurs
    cd [timak::nativeDir [concat $ROOT $repertoire]]
    if {[catch {$interp eval ::timak::create [lindex $what 0] [lindex $what 1]} message]} {
        global errorInfo
        return -code error "error creating \"$what\" in \"$repertoire\": $errorInfo"
    }
}

################################################
proc ::timak::getScript {TIMAKSCONTENTSName dir} {
    upvar $TIMAKSCONTENTSName TIMAKSCONTENTS
    if {![info exists TIMAKSCONTENTS($dir)]} {
        if {![info exists TIMAKSCONTENTS]} {
            set read "nothing"
        } else {
            set read [lsort [array names TIMAKSCONTENTS]]
        }
        return -code error "\nThe script in \"$dir\" is not in readlist\nReadlist is: \{$read\}"
    }
    return $TIMAKSCONTENTS($dir)
}

set HELP(global) {
    
    Au plan global, il existe une proc�dure permet de savoir o� mettre le r�sultat
    d'une op�ration en fonction de la source

    Un biblioth�que sera cr��e virtuellement dans le r�pertoire du fichier Timak.tcl
    qui contient la liste des sources.
}


set f [info script]
while {[file type $f] == "link"} {
    set ff [file readlink $f]
    if {[file pathtype $ff] == "relative"} {
        set ff [file join [file dirname $f] $ff]
    }
    if {$f == $ff} {
        return -code error "loopback link: \"$f\""
    }
    set f $ff
    putsdebug $ff
}
set createScriptsFile [open [file join [file dirname $f] createScripts.1.1.tcl] r]
set CREATESCRIPTS [read -nonewline $createScriptsFile]
close $createScriptsFile

######################
#                    #
# D�BUT DU PROGRAMME #
#                    #
######################

#puts stderr ##############################
#puts stderr [concat $argv0 $argv]
#puts stderr ##############################
#puts stderr {}

# lecture des proc�dures dans l'interpr�teur principal
# lecture des fichiers, sans interpr�tation


set rien {
set pwd [file split [pwd]]
set ROOT [lrange $pwd 0 [::timak::getRoot $pwd]]
set TimakDirs [::timak::readTimaks $ROOT TIMAKSCONTENTS [file split [pwd]]]

putsdebug "TimakDirs -> $TimakDirs"
putsdebug "ROOT -> $ROOT"

puts stderr {}
puts stderr  ################################
puts stderr "essai direct de la seconde passe"
puts stderr  ################################
puts stderr {}

cd /home/fab/A/fidev/Tcl/blas/src
set TimakDirs [::timak::readTimaks $ROOT TIMAKSCONTENTS [file split [pwd]]]
puts stderr [list TIMAKSCONTENTS: [array names TIMAKSCONTENTS]]

::timak::createIt $ROOT TIMAKSCONTENTS INTERPS {Tcl blas src} {lib libtcl_blas}
::timak::createIt $ROOT TIMAKSCONTENTS INTERPS {Tcl blas src} {program blassh}

puts stderr {}
puts stderr  ######################################
puts stderr "autre essai direct de la seconde passe"
puts stderr  ######################################
puts stderr {}

cd /home/fab/A/fidev/Tcl/pvm/src
set TimakDirs [::timak::readTimaks $ROOT TIMAKSCONTENTS [file split [pwd]]]

::timak::createIt $ROOT TIMAKSCONTENTS INTERPS {Tcl pvm src} {lib libtclpvm}

cd /home/fab/A/fidev/Tcl/scilab/src
set TimakDirs [::timak::readTimaks $ROOT TIMAKSCONTENTS [file split [pwd]]]

::timak::createIt $ROOT TIMAKSCONTENTS INTERPS {Tcl scilab src} {lib libtclscilab}

puts stderr {}
puts stderr  ##############
puts stderr "fin de l'essai"
puts stderr  ##############
puts stderr {}
}

set A(a) {}
set A(b) {}
set A(c) {}
set A(d) {}
set A(e) {}
set A(f) {a b}
set A(g) {a b e}
set A(h) {a f d e}

#cd /home/fab/A/fidev/Tcl/vector
set pwd [file split [pwd]]
set i [::timak::getRoot $pwd]
set ROOT [lrange $pwd 0 $i]
incr i
set dir [lrange $pwd $i end]

putsdebug {}
putsdebug [list ROOT = $ROOT]

if {$argv == {}} {
    set dolist default
    set createlist {}
} else {
    if {[string index [lindex $argv 0] 0] != "-"} {
        puts stderr "usage : timak -do ..., or timak -create ..."
        exit 1
    }
    if {[lindex $argv 0] == "-do"} {
        set dolist [lrange $argv 1 end]
        set createlist {}
    } elseif {[lindex $argv 0] == "-create"} {
        set dolist {}
        set createlist [list]
        foreach {type nom} [lrange $argv 1 end] {
            lappend createlist [list $type $nom]
        }
    } else {
        puts stderr "usage : timak -do ..., or timak -create ..."
        exit 1
    }
}

putsdebug [list dolist = $dolist createlist = $createlist]

horreur [catch {timak::firstPass TIMAKSCONTENTS CREATE $ROOT $dir $dolist $createlist} message]

while {[set reste [timak::finishFirstPass TIMAKSCONTENTS $ROOT CREATE]] != 0} {
    putsdebug "reste->$reste"
}

if {[catch {parray CREATE} message]} {
    puts $message
}

set ordres [::algraph::depthList CREATE]

putsdebug [list ordres = $ordres]

proc ::timak::reverseList {list} {
    set ret [list]
    set i [llength $list]
    for {incr i -1} {$i >= 0} {incr i -1} {
	lappend ret [lindex $list $i]
    }
    return $ret
}

set i 0
foreach o $ordres {
    foreach x [lsort $o] {
        # putsdebug "$i $x"
        ::timak::createIt $ROOT TIMAKSCONTENTS INTERPS [lindex $x 0] [lindex $x 1]
    }
    incr i
}

exit 0





