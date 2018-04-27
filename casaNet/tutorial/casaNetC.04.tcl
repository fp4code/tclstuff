# casaNetC.04.tcl

proc bgerror {message} {
    global errorInfo
    puts stderr "bgerror $message"
    puts stderr "bgerror errorInfo = $errorInfo"
    puts stderr "bgerror info level = [info level]"
}

proc casaNet_litSocket {socket} {
    if {[eof $socket]} {
        puts stdout "Liaison $socket interrompue ([fconfigure $socket -peername])"
        flush stdout
        fileevent $socket readable {}
        close $socket
        return
    }
    set lu [gets $socket]
    puts stdout "lu \"$lu\""
    flush stdout
}
