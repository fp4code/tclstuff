#!/bin/sh

# the next line restarts using tclsh \
exec tclsh "$0" "$@"


# 3 mai 2000. On n'utilise plus "cd", qui n'est pas ind�pendant de l'interpr�teur


set HELP(timak) {

Appel externe:

    % timak
equivalent �
    % timak -do default

    % timak -do man doc
    % timak -do {create sharedLib libtcl_blas}
    % timak -do {subdir toto -do man} {subdir titi}

Apr�s "-do", et avant la prochaine option "-..." on a une liste de choses � faire.
Une "chose � faire" peut �tre {create ...},  {subdir ...} ou un autre mot quelconque.

Pour pr�voir un travail parall�le, "timak" travaille en deux passes.
Dans une premi�re passe, il collecte tous les "create ..." avec leurs relations
de d�pendance directe.
Cette liste permet de construire un treillis.
Dans une seconde passe, "timak" ex�cute les "create ..." qui sont feuilles du treillis
puis toutes les branches dont les feuilles ont pu �tre cr��es correctement, etc.

#####################################################################################
Pour appeler "timak -do default" dans le sous-r�pertoires "blas", le fichier
"Timak.tcl" doit contenir

    do subdir blas

Le fichier "Timak.tcl" est en fait sourc� par un interpr�teur Tcl.
"do subdir blas" est une commande "interne", �quivalente �

    do -case default subdir blas

Pour que "timak" soit appel� dans chacun des sous-r�pertoires si l'on
a appel� "timak -do foobar", il faut �crire

    do -case foobar subdir blas

Pour que "timak barfoo" soit appel� dans chacun des sous-r�pertoires, il faut �crire

    do subdir blas -do barfoo

�videmment, on peut combiner:

    do -case foobar subdir blas -do foobar

On peut aussi transmettre la m�me option, en passant la chaine vide "-do {}"

    do -case foobar subdir blas -do {}

Cela est particuli�rement int�ressant avec l'option "-case {}". Dans ce cas, taper "timak -do foobar"
revient � taper "timak -do foobar" dans tous les sous-r�pertoires.

    do -case {} subdir blas -do {}

L'option suivant "-case" est consid�r�e comme une liste de possibilit�s.

    do -case {foo bar} subdir blas -do {}

sera prise en compte dans les 2 cas "timak -do foo" et "timak -do bar"
et appellera la commande correspondante dans le sous-r�pertoire "blas"

################

Exemple:

Appel externe "timak"
-> Transformation en "timak -do default"

Appel externe "timak -do default"
-> Cherche dans "Timak.tcl" "do -case default xxx" ou "do xxx"
Transformation en "timak -do xxx"

#####################
Exemples de Timak.tcl
#####################

# blas/Timak.tcl
do -case default -in src

# blas/src/Timak.tcl
do -case lib -create sharedLib libtcl_blas
do -case bin -create program blassh
do -case default -do lib
do -case default -do bin ;# ou   do -do bin
do -case doc -in doc -do default ;# ou   do -case doc -in doc
do -case doc2 -in doc -do doc2   ;# ou   do -case doc2 -in doc -do {}

##########
Dans blas:
##########

exec timak {subdir src}
exec timak
exec timak -do default

donnent tous trois la m�me chose:

"exec timak" est transform� en "exec timak -do default"
La liste de choses � faire est donc

La lecture de "do -case default xxx" ou de "do xxx" ajoute 
"xxx" (ici {subdirs src}) � DO_CASE(default) 

#####
26 avril 2000
Exemples d'appel, nouvelle syntaxe

exec timak
exec timak -do default
exec timak -do lib
exec timak -do lib bin
exec timak -create sharedLib libtcl_blas
exec timak -create sharedLibs {libtcl_blas libtcl_blos} program blassh
exec timak -create sharedLibs {libtcl_blas libtcl_blos} programs {blassh blassh2}
exec timak -do lib

exec timak -in blas
exec timak -in {blas blis blos}              ;# L'argument unique permet d'autoriser un r�pertoire de nom "-do"
exec timak -in {blas blis blos} -do default
exec timak -in {blas blis blos} -do lib bin
exec timak -in blas -create sharedLib libtcl_blas programs {blassh blassh2} # interdit (on ne transmet que des "-do")

�quivalents dans les fichiers Timak.tcl: remplacer "exec timak" par "do -case xxx"

exec timak -> {-do default}
exec timak -do default -> {-do default}
exec timak -do lib -> {-do lib}
exec timak -create sharedLib libtcl_blas


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
"timak -do {create sharedLib libtcl_blas}".

    set    LIBS(libtcl_blas) [list ../../../fortran/blas/src/libblas $TCLLIB libc]

idem pour cr�er un ex�cutable

    set SOURCES(blassh) mainTcl.c
    set    LIBS(blassh) [list ./libtcl_blas $TCLLIB]

cr�e la biblioth�que partag�e "libtcl_blas" et le programme "blassh"

    do create sharedLib libtcl_blas
    do create program blassh

des conditions sont possibles:

    do -case lib create sharedLib libtcl_blas

#####################################################################################

QUE FAIT TIMAK ?

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

proc ::timak::reverseList {list} {
    set ret [list]
    set i [llength $list]
    incr i -1
    while {$i >= 0} {
	lappend ret [lindex $list $i]
	incr i -1
    }
    return $ret
}

set HELP(::timak::timakFiles) {
    retourne une liste fichier/contenu des fichiers Timak.tcl parents � lire
    du fichier lui-m�me au plus ancien des parents

    $$$ Il faut g�rer les erreurs
}

set HELP(::timak::readTimak) {
  un r�pertoire racine $root �tant donn� sous forme de liste
  un sous-r�pertoire $dir �tant donn� sous forme de liste
  la proc�dure retourne le contenu du fichier Timak.tcl
  r�visions {
      {27 avril 2000} {}
      {3 mai 2000} {}
  }
}
proc ::timak::readTimak {root dir} {
    if {[catch {
        set fichier [eval file join $root $dir Timak.tcl]
        set f [open $fichier r]
        set ret [read -nonewline $f]
        close $f
    } message]} {
        return -code error "file \"$fichier\": $message"
    }
    return $ret
}

set HELP(::timak::getRoot) {
    4 mai 2000 (FP)

    Un r�pertoire �tant donn� sous forme de liste {/ home fab A fidev Tcl} ou {D:/ users fab}
    on remonte les parents jusqu'� trouver le dernier r�pertoire contenant un fichier Timak.tcl
    On retourne l'index dans la liste "$directory" qui correspond � la racine 
}

proc ::timak::getRoot {directory} {
    puts stderr [list ::timak::getRoot $directory]
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

set HELP(::timak::readTimaks) {
    - un r�pertoire racine $root �tant donn� sous forme de liste
    - un r�pertoire $directory �tant donn� sous forme de liste
    - On v�rifie que la racine de $directory est bien $root
    - On charge (si cela n'a pas �t� fait) le tableau de nom $TIMAKSName
      du contenu des fichiers Timak.tcl. Le nom du r�pertoire (sous forme de liste) forme l'index.


    revisions {
        {27 avril 2000} {}
        {3 mai 2000} {suppression des "cd"}
    }
}
proc ::timak::readTimaks {rootControl TIMAKSName directory} {
    upvar $TIMAKSName TIMAKS
    set Timaks [list]

    set iroot [::timak::getRoot $directory]
    set root [lrange $directory 0 $iroot]
    if {$root != $rootControl} {
        return -code error "Splitted directory \"$directory\" has \"$root\" as root, I want \"$rootControl\"."
    }

    set ifirst [expr {$iroot + 1}]
    set imax [llength $directory]
    for {set i $iroot} {$i < $imax} {incr i} {
        set dir [lrange $directory $ifirst $i]
        # Tcl admet un indice "vide" pour les tableaux associatifs
        if {![info exists TIMAKS($dir)]} {
            set TIMAKS($dir) [::timak::readTimak $root $dir]
        }
        lappend Timaks $dir
    }
    return $Timaks
}

set HELP(::timak::giveTimaks) {
}

proc ::timak::giveTimaks {dir} {
       
    set ret [list]
    set imax [llength $dir]
    for {set i -1} {$i < $imax} {incr i} {
        lappend ret [lrange $dir 0 $i]
    }
    return $ret
}

# modifie DO_LIST par l'interm�diaire des commandes "do ..." contenues dans 
# les fichiers Timaks
proc ::timak::interpretTimaks {TIMAKSName Timaks} {
    upvar $TIMAKSName TIMAKS

    foreach dir [lrange $Timaks 0 end-1] {
        set IGNORE_DO 1
        if {[catch {eval $TIMAKS($dir)} message]} {
            return -code error "error sourcing in $dir: $message"
        }
    }
    set dir [lindex $Timaks end]
    set IGNORE_DO 0

    if {[catch {eval $TIMAKS($dir)} message]} {
        return -code error "error sourcing in $dir: $message"
    }

    set ret [list]
    foreach key [lsort [array names DO_LIST]] {
        lappend ret $key $DO_LIST($key)
    }
    return $ret
}

set HELP(::timak::do) {
C'est la commande qui est appel�e par les lignes "do ..." des fichiers "Timak.tcl"

}

proc ::timak::do {args} {
    upvar IGNORE_DO IGNORE_DO
    upvar DO_LIST   DO_LIST

    if {$IGNORE_DO} {
	return
    }
    
    set SYNTAX "wrong # args: should be \"::timak::do ?-case aAcase? ...\""
    
    if {[llength $args] < 2 || [string index $args 0] != "-"} {
	return -code error $SYNTAX
    }
    
    # do -case toto -create ...
    # do first reste
        
    if {[lindex $args 0] == "-case"} {
        lappend DO_LIST([lindex $args 1]) [lrange $args 2 end]
    } else {
        lappend DO_LIST(default) [lrange $args 0 end]
    }
}

set HELP(timak::timakFirstPass) {
    {
        {26 avril 2000} {(FP)}
        {27 avril 2000} {(FP) Refonte compl�te}
    }

    retourne une liste de d�pendances
    {
        {
            r�pertoire {program blassh} r�pertoire {sharedLib libtcl_blas} r�pertoire {sharedLib libblas}
        }
        {
            r�pertoire {program blassh2} r�pertoire {sharedLib libtcl_blas}
        }
    }

    Chaque �l�ment de la liste correspond � un objet � construire � partir d'un r�pertoire donn�
    Chaque �l�ment de la liste est une liste, dont les 2 premiers �l�ments repr�sentent
           ce qui est � construire, et dont les paires d'�l�ments suivants sont les �l�ments n�cessaires
   $$$ Non termin�

}

proc ::timak::timakFirstPass {TIMAKName Timaks argv} {

    upvar $TIMAKName TIMAK
    set ROOT [lindex $Timaks 0]

    # cr�ation d'un interpr�teur ind�pendant
    set interp [interp create]

    $interp alias ::timak::interpretTimaks ::timak::interpretTimaks

    # Interpr�tation des fichiers pour en retirer la "dolist"
    set DO_LIST [$interp eval [list ::timak::interpretTimaks TIMAK $Timaks]]
    puts stderr [list $Timaks -> $DO_LIST]

    if {$argv == {}} {
        set local 1
        set dolist [list default]
    } else {
        set reste [lrange $argv 1 end]
        switch -- [lindex $argv 0] {
            "-create" {
                set local 1
                if {[llength $reste] % 2} {
                    return -code error "-create key value key value ..."
                }
                foreach {key value} $reste {
                    set CREATE($key) $value
                }
            }
            "-do" {
                set local 1
                if {$reste == 0} {
                    return -code error "-do ..."
                }
                set dolist $reste
            }
            "-in" {
                set local 0
                if {[llength $reste] == 0} {
                     return -code error "-in subdir_list"     
                }
                set subdirs [lindex $reste 0]
                set reste [lrange $reste 1 end]
                if {$reste == {}} {
                    set dolist [list default]
                } else {
                    if {[lindex $reste 0] != "-do" || [llength $reste] == 1} {
                        return -code error "-in subdir_list -do ..."
                    }
                    set dolist [list [lindex $reste 1]] 
                }
            }
            default {
                return -code error "\[-do | -create | -in\] ..."
            }
        }
    }


    if {!$local} {
        set pwd [pwd]
        foreach dir $subdirs {
            if {[llength [file split $dir]] != 1} {
                return -code error "\"$dir\" is not immediate subdirectory"
            }
            if {[file type $dir] != "directory"} {
                return -code error "\"$dir\" is not a true directory"
            }
            if {[file pathtype $dir] != "relative"} {
                return -code error "subdir \"$dir\" is not relative"
            }
            cd $dir
            timak::timak [list -do $dolist]
            cd $pwd
        }
    } else {
        ::timak::readTimaks $ROOT TIMAKS [::timak::timakFiles] [file split [pwd]]
    }
    if {$dolist != {}} {
        ::timak::doIt $dolist CREATE SUBDIRS
    }
    if {[info exists CREATE]} {
        ::timak::readTimaks $ROOT TIMAKS [::timak::timakFiles] [file split [pwd]]
        ::timak::createIt $ROOT TIMAKS INTERPS CREATE
    }
    return
}

proc ::timak::timakCreateIt {ROOT TIMAKSName INTERPSName repertoire what} {

    upvar $TIMAKSName TIMAKS
    upvar $INTERPSName INTERPS

    if {[info exists INTERPS($repertoire)]} {
        puts stderr "exists"
        set interp $INTERPS($repertoire)
    } else {
        puts stderr "new interp is created in $repertoire"
        # cr�ation de l'interpr�teur ind�pendant
        set interp [interp create]
        $interp alias ::timak::unambiguousPwd ::timak::unambiguousPwd
        $interp alias ::timak::getScript ::timak::getScript
        $interp alias ::timak::do ::timak::do
        
        #
        global createScripts
        $interp eval $createScripts
        #

        foreach dir [::timak::giveTimaks $repertoire] {
            set IGNORE_DO 1
            if {[catch {$interp eval [list namespace eval timak [::timak::getScript TIMAKS $dir]]} message]} {
                global errorInfo
                return -code error "error sourcing in $dir: $errorInfo"
            }
        }
        # enregistrement de l'interpr�teur
        set INTERPS($repertoire) $interp
    }

    puts stderr [list createIt $repertoire $what]
    # le "pwd", comme tous les "env" est partag� par tous les interpr�teurs
    set pwd [pwd]
    if {[catch {$interp eval ::timak::create [lindex $what 0] [lindex $what 1]} message]} {
        global errorInfo
        return -code error "error creating \"$what\" in \"$repertoire\": $errorInfo"
    }
}

proc ::timak::getScript {TIMAKSName dir} {
    upvar $TIMAKSName TIMAKS
    if {![info exists TIMAKS($dir)]} {
        if {![info exists TIMAKS]} {
            set read "nothing"
        } else {
            set read [lsort [array names TIMAKS]]
        }
        return -code error "\nThe script in \"$dir\" is not in readlist\nReadlist is: \{$read\}"
    }
    return $TIMAKS($dir)
}

set HELP(global) {
    
    Au plan global, il existe une proc�dure permet de savoir o� mettre le r�sultat
    d'une op�ration en fonction de la source

    Un biblioth�que sera cr��e virtuellement dans le r�pertoire du fichier Timak.tcl
    qui contient la liste des sources.
}


set createScripts {


set c1 {
SHELL = /bin/sh

CC=cc
FC=f77 -v
CFLAGS = -g -Kpic -xCC
FFLAGS = -g -Kpic -U -u -C

LIBNAME = lib${LIB}.so

PREFIX = /home/fidev/lib-sparc-solaris

CPPFLAGS+= -DSPECIAL_COMPLEX_RETURN

# M77 pour complexes ?

FLIBS = -lF77 -lsunmath -lM77

X11LIBS = -L/usr/openwin/lib -R/usr/openwin/lib -lX11

}

# cr�ation de fichiers objet
# $fsrc = fichier source
# $fdst = fichier objet � cr�er
# moreRecentVar = nom d'une variable � mettre � jour
# variable INCLUDES = liste d'arguments

proc timak::createSharedObjFromFortran {fsrc fdst moreRecentVar} {
    set command [list f77 -g -c -KPIC -DPIC $fsrc -o $fdst]
    upvar $moreRecentVar moreRecent
    return [timak::createSomething $fsrc $fdst moreRecent $command]
}

proc timak::createObjFromFortran {fsrc fdst moreRecentVar} {
    set command [list f77 -g -c $fsrc -o $fdst]
    upvar $moreRecentVar moreRecent
    return [timak::createSomething $fsrc $fdst moreRecent $command]
}

proc timak::createSharedObjFromC {fsrc fdst moreRecentVar} {
    variable DEBUG
    variable INCLUDES
    if {$DEBUG(call)} {
	puts "timak::createSharedObjFromC $fsrc $fdst $moreRecentVar"
    }
    set src [file dirname $fsrc]
    set command [concat cc -g -xCC -c -KPIC -DPIC [timak::includes $src $INCLUDES] [list $fsrc] -o [list $fdst]]
    upvar $moreRecentVar moreRecent
    return [timak::createSomething $fsrc $fdst moreRecent $command]
}

proc timak::createObjFromC {fsrc fdst moreRecentVar} {
    variable INCLUDES
    set src [file rootname $fsrc]
    set command [concat cc -g -xCC -c [timak::includes $src $INCLUDES] [list $fsrc] -o [list $fdst]]
    upvar $moreRecentVar moreRecent
    return [timak::createSomething $fsrc $fdst moreRecent $command]
}

set HELP(timak::createSomething) {
    28 avril 2000
    La compilation des objets pour les biblioth�ques les programmes
    est actuellement faite "sur place".
    On peut imaginer �tendre le syst�me de d�pendances
    pour permettre une compilation en parall�le sur plusieurs machines
}

proc timak::createSomething {fsrc fdst moreRecentVar command} {
    variable INCLUDES
    variable DEBUG
    global errorCode errorInfo

    if {$DEBUG(call)} {
	puts [list timak::createSomething $fsrc $fdst $moreRecentVar $command]
    }

    upvar $moreRecentVar moreRecent
    if {![file exists $fsrc]} {
	return -code error "inexistent source file: \"$fsrc\"" 
    }
    if {[file exists $fdst] && [file mtime $fsrc] <= [file mtime $fdst]} {
	# puts "OK $fdst"
	if {$moreRecent < [file mtime $fdst]} {
	    set moreRecent [file mtime $fdst]
	    if {$DEBUG(depend)} {
		puts "[file mtime $fdst] [pwd]/$fdst"
	    }
	}
	return 0
    } 
    puts stderr [list command = $command]
    set err [catch {eval exec $command} blabla]
    if {$err == 0} {
        return
    }
    set savedErrorCode $errorCode ;# est-ce utile ?

    if {$savedErrorCode == "NONE"} {
        puts stderr "OK"
	if {$moreRecent < [file mtime $fdst]} {
	    set moreRecent [file mtime $fdst]
	}
	return 0
    } elseif {[lindex $savedErrorCode 0] == "CHILDSTATUS"} {
	puts stderr $blabla
	return -code error "*** compilation error(s)"
    } else {
	puts stderr $blabla
	return -code error "*** errorCode -> $savedErrorCode"
    }
}

# cr�ation d'un programme ou d'une biblioth�que

proc timak::create {progOrLib name} {
    # tableaux des sources et des biblioth�ques
    variable SOURCES
    variable LIBS
    variable STOP
    variable DEBUG
    
    global errorCode
    
    set fortranFiles 0
    set CFiles 0
    set errors 0
    set pwd [pwd]
    puts $pwd 
    set objs [list]
    set moreRecent 0
    set objDest [timak::destFromSource obj $pwd]
    if {$DEBUG(call)} {
	puts [list timak::create $progOrLib $name]
    }    

    switch $progOrLib {
	"program" {
	    set fromFortran timak::createObjFromFortran
	    set fromC timak::createObjFromC
	    set finalName $name
	    set finalDest [timak::destFromSource bin $pwd]
	    set specialLinkOptions [list]
	}
	"sharedLib" {
	    set fromFortran timak::createSharedObjFromFortran
	    set fromC timak::createSharedObjFromC
	    set finalName ${name}.so
	    set finalDest [timak::destFromSource lib $pwd]
	    set specialLinkOptions [list -G -z text -z defs]
	}
	default {
	    return -code error "*** timak::createProgramOrLib: \"$progOrLib\" should be \"program\" or \"sharedLib\""
	}
    }
    
    cd $objDest
    set realDest [pwd]
    
    foreach f [set SOURCES($name)] {
	set type [timak::getTypeOfFile $f]
	set obj [file rootname [file tail $f]].o
	lappend objs $obj
	switch $type {
	    "fortran" {
		set err [catch {$fromFortran $pwd/$f $obj moreRecent} message]
		if {!$err} {
		    incr fortranFiles
		}
	    }
	    "C" {
		set err [catch {$fromC $pwd/$f $obj moreRecent} message]
		if {!$err} {
		    incr CFiles
		}
	    }
	    default {
		set message  "*** timak::createProgramOrLib unknown type \"$type\""
	    }
	}
	if {$err} {
	    if {$STOP(createObj)} {
                global errorInfo
		return -code error "\nerrorInfo=\n$errorInfo\n$message=\n$message"
	    } 
	    puts stderr "ERROR: $message"
	    incr errors
	}
    }

    # on retourne au plus aux sources, mais on se rappelle le lieu de compilation
    cd $pwd
    
    if {$errors != 0} {
	return -code "*** incomplete compilation"
    }
    
    if {$fortranFiles != 0} {
	set linker [concat f77 -V $specialLinkOptions]
    } else {
	set linker [concat  cc -V $specialLinkOptions]
    }
    
    if {[info exists LIBS($name)]} {
	set libs [timak::libs $LIBS($name) $finalDest]
    } else {
	set libs {}
    }
    
    set command [concat $linker -o [list $finalName] $objs $libs]
    
    cd $realDest

    if {[file exists $finalName]} {
	set fnmt [file mtime $finalName]
	if {$DEBUG(depend)} {
	    puts "$fnmt [file join $realDest $finalName]"
	}	    
	if {$moreRecent <= $fnmt} {
	    cd $pwd
	    return
	}
    } else {
	if {$DEBUG(depend)} {
	    puts "inexistent [file join $realDest $finalName]"
	}
    }
    
    puts stderr [list create: command = $command]
    catch {eval exec $command} blabla

    cd $pwd

    if {$errorCode == "NONE"} {
	puts "OK, $finalName is made in $realDest"
	return
    } elseif {[lindex $errorCode 0] == "CHILDSTATUS"} {
	puts $blabla
	return -code error "*** link error(s)"
    } else {
	puts $blabla
	return -code error "*** errorCode -> $errorCode"
    }
}

proc timak::includes {src list} {
    set elems [list]
    foreach elem $list {
	lappend elems [timak::include $src $elem]
    }
    return $elems
}

proc timak::include {src elem} {
    variable DEBUG
    if {$DEBUG(call)} {
	puts "timak::include $src $elem"
    }
    set path [file split $elem]
    set pathtype [file pathtype [lindex $path 0]]
    switch $pathtype {
	"absolute" {
	    set path [eval file join $path]
	}
	"relative" {
	    if {$path == "."} {
		set path $src
	    } else {
		set path [eval file join [file split $src] $path]
	    }
	}
	default {
	    return -code error "*** ERROR: Unknown path type \"$pathtype\""
	}
    }
    return "-I$path"
}

proc timak::libs {liblist dest} {
    set libs [list]
    foreach lib $liblist {
	eval lappend libs [timak::lib $lib $dest]
    }
    return $libs
}

proc timak::lib {lib dest} {
    global errorCode
    set libpath [file split $lib]
    if {[llength $libpath] > 1} {
	set libname [lindex $libpath end]
	set libpath [lrange $libpath 0 end-1]
    } else {
	set libname $libpath
	set libpath {}
    }
    if {![string match lib* $libname]} {
	return -code error "*** ERROR: \"$libname\" has not \"lib...\" form"
    }
    set liblib -l[string range $libname 3 end]
    if {$libpath == {}} {
	return $liblib
    } else {
	set pathtype [file pathtype [lindex $libpath 0]]
	switch $pathtype {
	    "absolute" {
		set path [eval file join $libpath]
	    }
	    "relative" {
		if {$libpath == "."} {
		    set path $dest
		} else {
		    set path [eval file join [file split $dest] $libpath]
		}
	    }
	    default {
		return -code error "*** ERROR: Unknown path type \"$pathtype\""
	    }
	}
	return [list -R$path -L$path $liblib]
    }
}

set old {
proc timak::libs {liblist dest} {
    set libs [list]
    foreach lib $liblist {
	eval lappend libs [timak::lib $lib $dest]
    }
    return $libs
}

proc timak::lib {lib dest} {
    global errorCode
    set libpath [file split $lib]
    if {[llength $libpath] > 1} {
	set libname [lindex $libpath end]
	set libpath [lrange $libpath 0 end-1]
    } else {
	set libname $libpath
	set libpath {}
    }
    if {![string match lib* $libname]} {
	return -code error "*** ERROR: \"$libname\" has not \"lib...\" form"
    }
    set liblib -l[string range $libname 3 end]
    if {$libpath == {}} {
	return $liblib
    } else {
	set pathtype [file pathtype [lindex $libpath 0]]
	switch $pathtype {
	    "absolute" {
		set path [eval file join $libpath]
	    }
	    "relative" {
		if {$libpath == "."} {
		    set path $dest
		} else {
		    set ici [pwd]
		    puts "D�pendance brutale pour $lib in $ici"
		    if {[catch {cd [eval file join $libpath]} blabla]} {
			return -code error "*** in $ici: $blabla"
		    }
		    set ticom [list exec timak [list create sharedLib $libname] >@ stdout]
		    puts [list $ticom in [pwd]]
		    catch $ticom blabla
		    if {$errorCode == "NONE"} {
			puts "$libname is made in [pwd]"
			cd $ici
		    } else {
			puts stderr "   $blabla"
			incr errors
			cd $ici
			return -code error "*** ERROR in doSubdirs"
		    }		    
		    set path [eval file join [file split $dest] $libpath]
		}
	    }
	    default {
		return -code error "*** ERROR: Unknown path type \"$pathtype\""
	    }
	}
	return [list -R$path -L$path $liblib]
    }
}

}

proc timak::getTypeOfFile {f} {
    set extension [file extension $f]
    switch $extension {
	".f" {return fortran}
	".c" {return C}
	default {return -code error "*** timak::getTypeOfFile unknown extension: \"$extension\""}
    }
}

namespace eval ::timak {
    variable PWD [pwd]
    variable INCLUDES ""
    variable LIBS
    ###### pour diagnostiquer les d�pendances circulaires

    variable MARKIN
    variable MARKOUT

    variable STOP
    set STOP(compile) 1
    set STOP(createObj) 1
    variable DEBUG
    set DEBUG(depend) 1
    set DEBUG(call) 0  
}



}

set old {
proc timak::ini {} {puts stderr "A FAIRE!!!"}


proc timak::main {argv} {

    variable DEBUG

    global errorInfo
#    variable PWD [unambiguousPwd]
    # d�clarations obligatoires pour "source"
#    variable DOLIST
#    variable SOURCES
#    variable INCLUDES
#    variable LIBS
#    set Timaks [list]
#    set errors 0

    
    
  
    if {![info exists DOLIST]} {
	return -code error "*** ERROR No \"timak::do\" line, nothing to do!"
    } 
    
    if {[llength $argv] == 0} {
	if {![info exists DOLIST(default)]} {
	    return -code error "*** No \"timak::do default\" line, nothing to do!"
	} 
	set dolist $DOLIST(default)
    } else {
	set dolist [list]
	if {$DEBUG(call)} {
	    puts "argv = $argv"
	}
	foreach do $argv {
	    lappend dolist $do
	}
    }
    
    foreach command $dolist {
	if {$DEBUG(call)} {
	    puts "$command"
	# puts [info commands timak::*]
	# puts [info commands *]
	}
	set err [catch {eval $command} message]
	if {$err} {
	    return -code error $message
	}
    }
    if {$errors} {
	return -code error "*** ERRORS in mainLoop" ;# "ERRORS in mainLoop"
    } else {
	return
    }
}

proc timak::firstScan {createListName do} {
    upvar $createListName createList
    
    set timaks [::timak::timakFiles]
    puts [list timaks = $timaks]
}


proc ::timak::createIt {CREATEARRAY} {
    upvar $CREATEARRAY CREATE
    puts "TODO"
    parray CREATE
}

proc timak::doIt {dolist CREATEARRAY SUBDIRSLIST} {
    upvar $CREATEARRAY CREATE
    upvar $SUBDIRSLIST SUBDIRS
    variable DO_LIST
    puts "TODO $dolist"
    while {$dolist != {}} {
        set newdolist [list]
        foreach do $dolist {
            if {![info exists DO_LIST($do)]} {
                if {![info exists DONE($do)]} {
                    return -code error "Pas de recette pour \"-do $do\""
                }
            } else {
                set dodo $DO_LIST($do)
                unset DO_LIST($do)
                set DONE($do) {}
                switch -- [lindex $dodo 0] {
                    case "-do" {
                        if {[llength $dodo] < 2} {
                            return -code error "ligne incorrecte \"$dodo\""
                        }
                        eval append newdolist [lrange $dodo 1 end]
                    }
                    case "-in" {
                        lappend SUBDIRS $dodo
                    }
                    case "-create" {
                        append CREATE $dodo
                    }
                    default {
                        return -code error "ligne incorrecte \"$dodo\""
                    }
                }
            }
        }
        set dolist $newdolist
    }
}
}

######################
#                    #
# D�BUT DU PROGRAMME #
#                    #
######################

puts stderr ##############################
puts stderr [concat $argv0 $argv]
puts stderr ##############################
puts stderr {}

# lecture des proc�dures dans l'interpr�teur principal
# lecture des fichiers, sans interpr�tation

set pwd [file split [pwd]]
set ROOT [lrange $pwd 0 [::timak::getRoot $pwd]]
set Timaks [::timak::readTimaks $ROOT TIMAKSCONTENTS [file split [pwd]]]

puts stderr "Timaks -> $Timaks"
puts stderr "ROOT -> $ROOT"
parray TIMAKSCONTENTS

puts stderr {}
puts stderr  ################################
puts stderr "essai direct de la seconde passe"
puts stderr  ################################
puts stderr {}


cd /home/fab/A/fidev/Tcl/blas/src
set Timaks [::timak::readTimaks $ROOT TIMAKSCONTENTS [file split [pwd]]]
puts stderr [list TIMAKSCONTENTS: [array names TIMAKSCONTENTS]]

::timak::timakCreateIt $ROOT TIMAKSCONTENTS INTERPS {Tcl blas src} {sharedLib libtcl_blas}
::timak::timakCreateIt $ROOT TIMAKSCONTENTS INTERPS {Tcl blas src} {program blassh}

puts stderr {}
puts stderr  ######################################
puts stderr "autre essai direct de la seconde passe"
puts stderr  ######################################
puts stderr {}

cd /home/fab/A/fidev/Tcl/pvm/src
set Timaks [::timak::readTimaks $ROOT TIMAKSCONTENTS [file split [pwd]]]

::timak::timakCreateIt $ROOT TIMAKSCONTENTS INTERPS {Tcl pvm src} {sharedLib libtclpvm}

cd /home/fab/A/fidev/Tcl/scilab/src
set Timaks [::timak::readTimaks $ROOT TIMAKSCONTENTS [file split [pwd]]]

::timak::timakCreateIt $ROOT TIMAKSCONTENTS INTERPS {Tcl scilab src} {sharedLib libtclscilab}

puts stderr {}
puts stderr  ##############
puts stderr "fin de l'essai"
puts stderr  ##############
puts stderr {}


cd /home/fab/A/fidev/Tcl/vector/src
set Timaks [::timak::readTimaks $ROOT TIMAKSCONTENTS [file split [pwd]]]
horreur [catch {timak::timakFirstPass TIMAKSCONTENTS $Timaks $argv} message]

exit 0



