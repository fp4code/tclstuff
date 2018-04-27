#!/bin/sh
# The next line is executed by /bin/sh, but not tcl \
exec tclsh "$0" ${1+"$@"}

##
## 20 mars 2002 (FP)
##
## teste l'existence d'un serveur http
##

set LINES 0
set MAXLINES 100
set TIMEOUT 2000

proc status {host sock} {
    global LINES
    catch {fconfigure $sock -peername} message
    close $sock
    incr LINES -1
    if {$message != "can't get peername: socket is not connected"} {
        puts stderr "$host $message"
    }
}

proc tryIt {host msec_timeout} {
    global LINES

    set sock [socket -async $host 80]
    incr LINES
    after $msec_timeout [list status $host $sock]
}

for {set i 1} {$i < 255} {incr i} {
    tryIt 10.8.0.$i $TIMEOUT
    while {$LINES > $MAXLINES} {
        vwait LINES
    }
}
for {set i 1} {$i < 255} {incr i} {
    tryIt 10.9.0.$i $TIMEOUT
    while {$LINES > $MAXLINES} {
        vwait LINES
    }
}
for {set i 1} {$i < 255} {incr i} {
    tryIt 10.6.0.$i $TIMEOUT
    while {$LINES > $MAXLINES} {
        vwait LINES
    }
}
for {set i 1} {$i < 30} {incr i} {
    tryIt 10.4.0.$i $TIMEOUT
    while {$LINES > $MAXLINES} {
        vwait LINES
    }
}
for {set i 1} {$i < 30} {incr i} {
    tryIt 10.5.0.$i $TIMEOUT
    while {$LINES > $MAXLINES} {
        vwait LINES
    }
}
for {set i 1} {$i < 255} {incr i} {
    tryIt 10.7.0.$i $TIMEOUT
    while {$LINES > $MAXLINES} {
        vwait LINES
    }
}
