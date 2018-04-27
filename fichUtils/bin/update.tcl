set MD5SUM /prog/gnu/bin/md5sum

# les arborescences sont données sous forme de listes,
# relatives au répertoire hôte
# le fichier est donné sous forme de liste, relativement à l'arborescence
# Ce qui est dans "$arnew" va se trouver dans "$arcible".
# Ce qui est dans "$arcible" est éventuellement sauvé dans $arsav"

# 7 octobre 2001 (FP) révision

set rien {
    set arcible A
    set arnew A.berta
    set arsav [concat S [clock format [clock seconds] -format %Y.%m.%d]]

    set file [file split fidev/Tcl/snack/src/synthesis.c]

    cd 
    set ici [pwd]
    cd $arnew
    set update fidev
    if {[catch {set fichiers [exec find $update -type f -print]} message]} {
        return -code error $message
    } else {
        set fichiers $message
    }
    cd $ici
    foreach file $fichiers {
        remplace $arcible $arnew $arsav $file
    }

    exec find [eval file join $arnew $update] -type d -depth -exec rmdir \{\} \; -print

}


set HELP(idem) {
    retourne 1 si les fichiers $f1 et $f2 sont identiques
}
proc idem {fich1 fich2} {
    set f1 [open $fich1 r]
    set c1 [read -nonewline $f1]
    close $f1
    set f2 [open $fich2 r]
    set c2 [read -nonewline $f2]
    close $f2
    return [expr {[string compare $c1 $c2] == 0}]
}

proc remplace {arcible arnew arsav file} {
    global MD5SUM

    set new [eval file join $arnew $file]
    set sav [eval file join $arsav $file]
    set cible [eval file join $arcible $file]

    set dirnew [file dirname $new]
    set dirsav [file dirname $sav]
    set dircible [file dirname $cible]

    if {[file exists $cible]} {
        if {[idem $cible $new]} {
            file delete $new
            return
        }

        if {[file exists $sav]} {
            return -code error "La sauvegarde \"$sav\" existe"
        }
        if {![file exists $dirsav]} {
            file mkdir $dirsav
        }
        puts stderr [list $cible -> $sav]
        file rename $cible $sav
        set withsav 1
    } else {
        set withsav 0
        if {![file exists $dircible]} {
            file mkdir $dircible
        }
    }
    puts stderr [list $new -> $cible]
    if {[catch {file rename $new $cible} message]} {
        if {$withsav} {
            puts stderr [list $sav -> $cible]
            file rename $sav $cible
        }
        return -code error "$message, réversion faite"
    }
    return
}
