set HELP(::sysadmin::fichUtils::readOriginalLink) {
    API {
        Retourne le fichier original.
        $f est un lien ou un lien sur un lien, etc.
    }
}

proc ::sysadmin::fichUtils::readOriginalLink {f} {
    while {[file type $f] == "link"} {set f [file readlink $f]}
    return $f
}

set HELP(::sysadmin::fichUtils::whereIsScript) {
    API {
        Retourne le répertoire original du fichier en cours de lecture,
        qui peut être un lien ou un lien sur un lien, etc.
    }
}

proc ::sysadmin::fichUtils::whereIsScript {} {
    return [file dirname [readOriginalLink [info script]]]
}
