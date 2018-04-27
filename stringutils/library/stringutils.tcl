package provide stringutils 1.0

set HELP(stringutils::stripzeros) {
retourne la chaine $chaine apr�s suppression des z�ros en son d�but
}

namespace eval stringutils {
    proc stripzeros {chaine} {
        regsub ^0+(.+) $chaine \\1 retval
        return $retval
    }
}
