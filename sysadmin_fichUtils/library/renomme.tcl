proc ::sysadmin::fichUtils::fichBak f {
    set ext orig_[clock format [clock seconds] -format %Y-%m-%d_%H:%M:%S]
    puts stderr "$f renomm� en $f.$ext"
    file rename $f $f.$ext
    return $f.$ext
}

