package provide make 1.0

namespace eval make {
    variable PROGS
}

#-----------------------------------------------------------------------------#
# Recompilation automatique du code f77 associé et chargement
# -----------------------------------------------------------------------------#

#set make::PROGS(c) "cc -xCC -I/prog/Tcl/tcl${tcl_patchLevel}/generic\
                    -g -Kpic -c"
#set make::PROGS(f77) "f77 -g -u -C -U -Kpic -c"
#set make::PROGS(ld) "f77 -g -G -ztext"

set HELP(make::executeExec) {
    exécute proprement une commande Unix $executeExec qui
    se permet de causer sur stderr même sans motif d'erreur
}
proc make::executeExec {commande} {
    global errorCode
    puts $commande
    set err [catch {eval exec $commande} message]
    if {$err == 0 || $errorCode == "NONE"} {
        puts $message
    } else {
        error $message
    }
}

set HELP(make::makeOneFromOne) {
    crée le fichier objet
}
proc make::makeOneFromOne {programme nom inExt outExt} {
    set in $nom$inExt
    set out $nom$outExt
    if {![file exists $out] || [file mtime $out] < [file mtime $in]} {
        if {[catch {executeExec "$programme $in"} message]} {
            puts $message
            file delete $out
        } else {
            puts $message
        }
    }
    return $out
}

proc make::makeOneFromMany {programme out many} {
    if {![file exists $out]} {
        set doIt 1
    } else {
        set doIt 0
        foreach in $many {
            if {[file mtime $out] < [file mtime $in]} {
                set doIt 1
                break
            }
        }
    }
    if {$doIt} {
        executeExec [concat $programme $many]
    }
}

proc make::makeLib {lib choses} {
    variable PROGS
    set objs {}
    set libname lib${lib}.so
    foreach nom $choses {
        set src [glob $nom.\[cf\]]
        if {[llength $src] == 0} {
            error "Pas de source pour $nom"
        }
        if {[llength $src] > 1} {
            error "Plusieurs sources pour $nom : $src"
        }
        if {[string match *.c $src]} {
            lappend objs [makeOneFromOne $PROGS(CC) $nom .c .o]
        } elseif {[string match *.f $src]} {
            lappend objs [makeOneFromOne $PROGS(FC) $nom .f .o]
        }
    }
    makeOneFromMany "$PROGS(LD_SO) -o $libname" $libname $objs
}

proc make::makeAndLoad {dir libname args} {
    set didi [pwd]
    puts "makeAndLoad in $dir"
    cd $dir
    makeLib lib $args
    cd $didi
    load $dir/lib$libname.so
}

proc make::makeClean {} {
    foreach f [glob *.c *.f *.so] {
        file delete $f
    }
}
