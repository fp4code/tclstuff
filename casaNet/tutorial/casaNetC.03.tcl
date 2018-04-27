# casaNetC.03.tcl

proc casaNet_litSocket {socket} {
    set lu [gets $socket]
    puts stdout "lu \"$lu\""
    flush stdout
}

