Appel externe:

    % timak
equivalent à
    % timak -do default

    % timak -do man doc
    % timak -do {create sharedLib libtcl_blas}
    % timak -do {subdir toto -do man} {subdir titi}

Après "-do", et avant la prochaine option "-..." on a une suite de choses à faire.
Une "chose à faire" peut être {create ...},  {subdir ...} ou un autre mot quelconque.

#####################################################################################
Pour appeler "timak -do default" dans le sous-répertoires "blas", le fichier
"Timak.tcl" doit contenir

    do subdir blas

Le fichier "Timak.tcl" est en fait sourcé par un interpréteur Tcl.
"do subdir blas" est une commande "interne", équivalente à

    do -case default subdir blas

Pour que "timak" soit appelé dans chacun des sous-répertoires si l'on
a appelé "timak -do foobar", il faut écrire

    do -case foobar subdir blas

Pour que "timak barfoo" soit appelé dans chacun des sous-répertoires, il faut écrire

    do subdir blas -do barfoo

Évidemment, on peut combiner:

    do -case foobar subdir blas -do foobar

On peut aussi transmettre la même option, en passant la chaine vide "-do {}"

    do -case foobar subdir blas -do {}

Cela est particulièrement intéressant avec l'option "-case {}". Dans ce cas, taper "timak -do foobar"
revient à taper "timak -do foobar" dans tous les sous-répertoires.

    do -case {} subdir blas -do {}

L'option suivant "-case" est considérée comme une liste de possibilités.

    do -case {foo bar} subdir blas -do {}

sera prise en compte dans les 2 cas "timak -do foo" et "timak -do bar"
et appellera la commande correspondante dans le sous-répertoire "blas"

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
do -case default -do lib ;# idem "do -do lib" "do lib"
do -case default -do bin ;# 
do -case doc -in doc -do default ;# ou   do -case doc -in doc
do -case doc2 -in doc -do doc2   ;# ou   do -case doc2 -in doc -do {}


syntaxe:
do -case unCas -do unAutreCas
do -case unCas -in unRepertoire -do unAutreCas
do -case unCas -create nature name

Le bloc "-case default" peut être omis.

do -do unAutreCas
do -in unRepertoire -do unAutreCas
do -create nature name


##########
Dans blas:
##########

exec timak {subdir src}
exec timak
exec timak -do default

donnent tous trois la même chose:

"exec timak" est transformé en "exec timak -do default"
La liste de choses à faire est donc

La lecture de "do -case default xxx" ou de "do xxx" ajoute 
"xxx" (ici {subdirs src}) à DO_CASE(default) 
#############


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
		    puts "Dépendance brutale pour $lib in $ici"
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

proc timak::ini {} {puts stderr "A FAIRE!!!"}


proc timak::main {argv} {

    variable DEBUG

    global errorInfo
#    variable PWD [unambiguousPwd]
    # déclarations obligatoires pour "source"
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
set HELP(::timak::timakFiles) {
    retourne une liste fichier/contenu des fichiers Timak.tcl parents à lire
    du fichier lui-même au plus ancien des parents

    OBSOLETE
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
