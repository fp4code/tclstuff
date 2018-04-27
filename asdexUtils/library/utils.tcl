package provide fidev_asdexUtils 1.0

namespace eval ::fidev::asdexUtils {}

set HELP(::fidev::asdexUtils::comprime) {
Comprime le répertoire au format tgz


}

proc ::fidev::asdexUtils::comprime {dir} {
    if {[file pathtype $dir] != "relative"} {
        error "$dir n'est pas un répertoire relatif"
    }
    if {![info exists Poubelle]} {
        file mkdir Poubelle
    }
    if {![file isdirectory $dir]} {
        error "$dir n'est pas un répertoire"
    }
    exec tar cf $dir.t $dir
    exec /usr/local/bin/gzip -best -S gz $dir.t
    set dirac [file dirname $dir]
    catch {file mkdir /home/asdex/Poubelle/$dirac}
    file rename $dir /home/asdex/Poubelle/$dirac
}


proc ::fidev::asdexUtils::comprimeTout {liste} {
    foreach d $liste {
        puts $d
        if {[string match ./* $d]} {
            if {[catch {comprime $d} err]} {
                puts $err
            }
         }
    }
}

proc ::fidev::asdexUtils::findDirs {ext mini} {
    catch "exec find . -type f -name *$ext -print" fichiers
    foreach f [split $fichiers \n] {
        if {[string match "./*$ext" $f]} {
            set dir [file dirname $f]
            if {[info exists DIRS($dir)]} {
                incr DIRS($dir)
            } else {
                set DIRS($dir) 1
            }
        }
    }
    set ret [list]
    foreach dir [lsort [array names DIRS]] {
        if {$DIRS($dir) < $mini} {
            puts "insuffisant : $dir : $DIRS($dir)"
        } else {
            lappend ret $dir
        }
    }
    return $ret
}

         ###############################
set HELP(::fidev::asdexUtils::tgzContenu) {
         ###############################
    Intro {
        Gestion de fichiers tar gnu-zippés
    }

    API {
        tgz      : nom du fichier "tgz"
        errsName : nom de la variable destinée à recevoir la liste des erreurs

        Retour   : liste des extensions (caractères suivant le dernier .)
                   des fichiers
    }
    
    Internals {            
    }
}
     ###############################
proc ::fidev::asdexUtils::tgzContenu {tgz errsName} {
     ###############################
    upvar $errsName errs
    set errs [list]
    set err [catch {exec /usr/local/bin/zcat $tgz | /prog/gnu/bin/tar tvf -} contenu]
    if {$err} {
        lappend errs [list ERREUR : $tgz $contenu]
        return {}
    }
    set contenu [split $contenu \n]
    foreach f $contenu {
       # saute les entrées répertoire et liens du fichier tar
        if {[string match {[dl]*} $f]} {
            continue
        }
        if {[llength $f] != 6} {
            lappend errs [list ERREUR : longueur != 6 : \"$f\"]
            continue
        }
        set nom [lindex $f 5]
        set extension [file extension $nom]
        if {$extension != {}} { 
            set extension [string range $extension 1 end]
            set last [string length $extension]
            incr last -1
            set lastcar [string index $extension $last]
           # saute les fichiers de sauvegarde
            if {$lastcar != "%" &&  $lastcar != "\$"} {
                set extensions($extension) {}
            }
            set dirnames([file dirname $nom]) {}
        }
    }
    return [list [lsort [array names extensions]]\
                 [lsort [array names dirnames  ]]\
           ]
}


