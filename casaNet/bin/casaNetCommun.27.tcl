#
# procédures communes à maison27.tcl et à labo27.tcl
#

set HTTPS_PORT 443

package require md5 2.0
puts -nonewline stderr "mot de passe casaNet : "
set pass [gets stdin]
set MD5PASS [md5::md5 -hex $pass]

proc bgerror {message} {
    global errorInfo
    puts stderr "bgerror $message"
    puts stderr "bgerror errorInfo = $errorInfo"
}

proc casaNet_transmet {sockA sockB} {
    global casaNet_TERMINE

    set bytes [read $sockA 4096]
    if {[string length $bytes] != 0} {
        puts -nonewline $sockB $bytes
        flush $sockB
        # puts "$bytes"
    }

    if {[eof $sockA]} {
        puts stderr "EOF $sockA ([fconfigure $sockA -peername])"
        set casaNet_TERMINE "EOF $sockA ([fconfigure $sockA -peername])"
        fileevent $sockA readable {}
        fileevent $sockB readable {}
        close $sockA
        close $sockB
    }
}
