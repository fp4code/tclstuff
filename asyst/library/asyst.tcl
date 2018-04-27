package provide fidev_asyst

namespace eval ::fidev::asyst {
    variable a6ref [binary format H8 a6a6a6a6]
}

set HELP(::fidev::asyst::isAnAsystFile) {
    Intro {
        Détermine si un fichier est un fichier Asyst en lisant
        sa signature (octets 8 à 11)
    }

    API {
        file : nom du fichier
        retourne 1 si le fichier estun fichier Asyst, 0 sinon
    }
}


proc ::fidev::asyst::isAnAsystFile {file} {
    variable a6ref
    set err [catch {open $file r} f]
    if {$err} {
        error $f
    }
    set err [catch {read $f 8} dummy]
    if {$err} {
        error $f
    }
    set err [catch {read $f 4} a6]
    if {$err} {
        error $f
    }
    return [expr {$a6ref == $a6}]
}

::fidev::asyst::isAnAsystFile 1200_295.res
