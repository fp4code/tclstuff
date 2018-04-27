# RCS: @(#) $Id: alladin_md5.tcl,v 1.7 2003/03/11 12:03:36 fab Exp $

namespace eval alladin_md5 {}

fidev_load ../src/libtcl_alladin_md5 Alladin_md5

proc alladin_md5::string {string} {
    set handle [alladin_md5::init]
    alladin_md5::append $handle $string
    set bstring [alladin_md5::finish $handle]
    if {[binary scan $bstring H32 ret] != 1} {
        return -code error "Erreur du programmeur de \"alladin_md5::md5\" cannot scan bstring"
    }
    return $ret
}

proc alladin_md5::fileAllInMemory {file} {
    set f [open $file r]
    fconfigure $f -encoding binary -translation binary
    set s [read $f]
    set ret [alladin_md5::string $s]
    close $f
    return $ret
}

proc alladin_md5::file {file} {
    set f [open $file r]
    # puts stderr $f
    fconfigure $f -encoding binary -translation binary
    set handle [alladin_md5::init]
    while {![eof $f]} {
        set bytes [read $f 4096]
        # puts stderr $bytes
        alladin_md5::append $handle $bytes
    }
    close $f
    set bstring [alladin_md5::finish $handle]
    if {[binary scan $bstring H32 ret] != 1} {
        return -code error "Erreur du programmeur de \"alladin_md5::md5\" cannot scan bstring"
    }
    return $ret
}

package provide alladin_md5 1.0
