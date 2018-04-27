package provide stringutils 1.0

set HELP(stringutils::stripzeros) {
retourne la chaine $chaine après suppression des zéros en son début
}

namespace eval stringutils {
    proc stripzeros {chaine} {
        regsub ^0+(.+) $chaine \\1 retval
        return $retval
    }
}
