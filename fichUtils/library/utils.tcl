set HELP(::fidev::fichUtils::followLinks) {
    API {
        Retourne le fichier original.
        $f est un lien ou un lien sur un lien, etc.
    }
}


# 28 mars 2001 (FP) rajout de if {[file pathtype $nf] == "relative"} ...
# 29 mars 2001 (FP) correction
proc ::fidev::fichUtils::followLinks {f} {
    set seen($f) {}
    while {[file type $f] == "link"} {
    	set nf [file readlink $f]
        puts stderr "$f -> $nf"
        if {[file pathtype $nf] == "relative"} {
            set f [file join [file dirname $f] $nf]
        } else {
            set f $nf
        }
        if {[info exists seen($f)]} {
            error "$f is a circular link"
        }
        set seen($f) {}
    }
    return $f
}

set HELP(::fidev::fichUtils::whereIsScript) {
    API {
        Retourne le répertoire original du fichier en cours de lecture,
        qui peut être un lien ou un lien sur un lien, etc.
    }
}

proc ::fidev::fichUtils::whereIsScript {} {
    return [file dirname [followLinks [info script]]]
}
