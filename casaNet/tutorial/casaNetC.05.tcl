# casaNetC.05.tcl

proc bgerror {message} {
    global errorInfo
    puts stderr "bgerror $message"
    puts stderr "bgerror errorInfo = $errorInfo"
    puts stderr "bgerror info level = [info level]"
}

proc casaNet_litSocket {socket stopVarName} {
    upvar #0 $stopVarName stopVar
    if {[eof $socket]} {
        set qui [fconfigure $socket -peername]
        puts stdout "Liaison $socket interrompue ($qui)"
        flush stdout
        fileevent $socket readable {}
        close $socket
        set stopVar "eof $qui"
        return
    }
    set lu [gets $socket]
    puts stdout "lu \"$lu\""
    flush stdout
}
