#!/bin/sh

# the next line restarts using tclsh \
exec tclsh "$0" "$@"



set HELP(timak) {
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
exec timak -create sharedLib libtcl_blas
exec timak -create sharedLibs {libtcl_blas libtcl_blos} program blassh
exec timak -create sharedLibs {libtcl_blas libtcl_blos} programs {blassh blassh2}
exec timak -do lib

exec timak -in blas
exec timak -in {blas blis blos}              ;# L'argument unique aurai permis d'autoriser un r�pertoire de nom "-do" INTERDIT
exec timak -in {blas blis blos} -do default  ;# INTERDIT, utiliser "foreach d {blas blis blos} {exec timak -in $d -do default}
exec timak -in {blas blis blos} -do lib bin  ;# INTERDIT (risques de confusion avec les noms comportant un blanc)
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
    - On v�rifie que la racine de $directory est bien $root
    - On charge (si cela n'a pas �t� fait) le tableau de nom $TIMAKSName
      du contenu des fichiers Timak.tcl. Le nom du r�pertoire (sous forme de liste) forme l'index.

    retour: liste des r�pertoires

    revisions {
        {27 avril 2000} {}
        {3 mai 2000} {suppression des "cd"}
    }

    Utilisation {Pr�liminaire � FirstPass}
}
proc ::timak::readTimaks {rootControl TIMAKSCONTENTSName directory} {
    upvar $TIMAKSCONTENTSName TIMAKSCONTENTS
    set TimakDirs [list]

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
        if {![info exists TIMAKSCONTENTS($dir)]} {
            set TIMAKSCONTENTS($dir) [::timak::readTimak $root $dir]
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

##################################
set HELP(::timak::interpretTimaks) {

    modifie CASEDO par l'interm�diaire des commandes "do ..." contenues dans 
    les fichiers Timaks

    Les valeurs sont tri�es et jamais dupliqu�es

}

proc ::timak::interpretTimaks {TIMAKSCONTENTSName TimakDirs} {
    upvar $TIMAKSCONTENTSName TIMAKSCONTENTS

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
        foreach x [array names X] {
            puts stderr "x=$x"
        }
    }

    return [list $ret1 $ret2]
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
        switch [string range [lindex $reste 0] 1 end] {
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

proc timak::firstPass {TIMAKSCONTENTSName ROOT dir doList CREATEName} {
    upvar $TIMAKSCONTENTSName TIMAKSCONTENTS
    upvar $CREATEName CREATE

    puts $dir

    set TimakDirs [::timak::readTimaks $ROOT TIMAKSCONTENTS $dir]
    set ici [lindex $TimakDirs end]

    # cr�ation d'un interpr�teur ind�pendant
    set interp [interp create]

    $interp alias ::timak::interpretTimaks ::timak::interpretTimaks
   
    # Interpr�tation des fichiers pour en retirer la "dolist" 

    set err [catch {$interp eval [list ::timak::interpretTimaks TIMAKSCONTENTS $TimakDirs]} message]
    if {$err} {
        global errorInfo
        puts stderr "ERREUR, message = $message"
        puts stderr "      , errorInfo = $errorInfo"
        return -code error "IRR�M�DIABLE"
    }

    array set CASEDO [lindex $message 0]
    array set CASECREATE [lindex $message 1]

    foreach do $doList {set DOLIST($do) {}}

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
                set CREATE([list $dir $x]) {} 
            }
        }
    }
    foreach subdir [lsort [array names IN]] {
        timak::firstPass TIMAKSCONTENTS $ROOT [concat $dir [list $subdir]] $IN($subdir) CREATE
    }
    return
}

###########################
set HELP(::timak::createIt) {
    Chaque r�pertoire a son interpr�teur Tcl attitr�, d�fini par le tableau
    de nom $INTERPSName, index� par $repertoire
    S'il n'existe pas, l'interpr�teur est cr�� et initialis� au moyen
    de la lign�e de fichiers Timak.tcl
    
    L'argument $what contient deux �l�ments, nature et nom
    La proc�dure ::timak::create est appel�e avec ces deux arguments
}
proc ::timak::createIt {ROOT TIMAKSCONTENTSName INTERPSName repertoire what} {

    upvar $TIMAKSCONTENTSName TIMAKSCONTENTS
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

    puts stderr [list createIt $repertoire $what]
    # le "pwd", comme tous les "env" est partag� par tous les interpr�teurs
    set pwd [pwd]
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
    puts $ff
}
set createScriptsFile [open [file join [file dirname $f] createScripts.1.1.tcl] r]
set CREATESCRIPTS [read -nonewline $createScriptsFile]
close $createScriptsFile

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


set rien {
set pwd [file split [pwd]]
set ROOT [lrange $pwd 0 [::timak::getRoot $pwd]]
set TimakDirs [::timak::readTimaks $ROOT TIMAKSCONTENTS [file split [pwd]]]

puts stderr "TimakDirs -> $TimakDirs"
puts stderr "ROOT -> $ROOT"
parray TIMAKSCONTENTS

puts stderr {}
puts stderr  ################################
puts stderr "essai direct de la seconde passe"
puts stderr  ################################
puts stderr {}

cd /home/fab/A/fidev/Tcl/blas/src
set TimakDirs [::timak::readTimaks $ROOT TIMAKSCONTENTS [file split [pwd]]]
puts stderr [list TIMAKSCONTENTS: [array names TIMAKSCONTENTS]]

::timak::createIt $ROOT TIMAKSCONTENTS INTERPS {Tcl blas src} {sharedLib libtcl_blas}
::timak::createIt $ROOT TIMAKSCONTENTS INTERPS {Tcl blas src} {program blassh}

puts stderr {}
puts stderr  ######################################
puts stderr "autre essai direct de la seconde passe"
puts stderr  ######################################
puts stderr {}

cd /home/fab/A/fidev/Tcl/pvm/src
set TimakDirs [::timak::readTimaks $ROOT TIMAKSCONTENTS [file split [pwd]]]

::timak::createIt $ROOT TIMAKSCONTENTS INTERPS {Tcl pvm src} {sharedLib libtclpvm}

cd /home/fab/A/fidev/Tcl/scilab/src
set TimakDirs [::timak::readTimaks $ROOT TIMAKSCONTENTS [file split [pwd]]]

::timak::createIt $ROOT TIMAKSCONTENTS INTERPS {Tcl scilab src} {sharedLib libtclscilab}

puts stderr {}
puts stderr  ##############
puts stderr "fin de l'essai"
puts stderr  ##############
puts stderr {}
}

cd /home/fab/A/fidev/Tcl
set pwd [file split [pwd]]
set ROOT [lrange $pwd 0 [::timak::getRoot $pwd]]

puts stderr {}
puts stderr [list ROOT = $ROOT]

horreur [catch {timak::firstPass TIMAKSCONTENTS $ROOT $pwd {default} CREATE} message]

parray CREATE
exit 0



