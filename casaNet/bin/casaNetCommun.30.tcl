#
# procédures communes à maison30.tcl et à labo30.tcl
# 2004-12-10, ajout de One shot...exit
#

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
    global casaNet_LIAISONS

    set bytes [read $sockA 4096]
    if {[string length $bytes] != 0} {
        puts -nonewline $sockB $bytes
        flush $sockB
        # puts "$bytes"
    }

    if {[eof $sockA]} {
        puts stderr "EOF $sockA ([fconfigure $sockA -peername])"
        set casaNet_LIAISONS($sockA,$sockB) "EOF $sockA ([fconfigure $sockA -peername])"
        fileevent $sockA readable {}
        fileevent $sockB readable {}
        close $sockA
        close $sockB
	if {[info exists casaNet_LIAISONS(oneShot)]} {
	    puts stderr "One shot -> exiting"
	    exit
	}
    }
}

proc casaNet_pont {sockA sockB} {
    fconfigure $sockA \
            -blocking 0 -buffering full -buffersize 4096 -translation binary -encoding binary
    fileevent $sockA readable [list casaNet_transmet $sockA $sockB]
}

proc casaNet_bipont {sockA sockB} {
    global casaNet_LIAISONS

    set casaNet_LIAISONS($sockA,$sockB) "Connected"
    casaNet_pont $sockA $sockB
    casaNet_pont $sockB $sockA
}
