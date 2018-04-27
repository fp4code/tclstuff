proc supprimeDe {nomDeListe elem} {
    upvar $nomDeListe liste

    set i [lsearch $liste $elem]
    if {$i < 0} {
        error "$elem ne figure pas dans la liste \"$liste\""
    }
    set liste [lreplace $liste $i $i]
    return $i
}
