#!/bin/sh
# \
exec tclsh "$0" ${1+"$@"}

##
## maison4.tcl
##
## attend une connection de labo4 à travers le proxy et cause à peine
## encrypte
## 

set svcPort 443

# Handles the output from the labo and labo shutdown
proc readLabo {labo} {
    set l [gets $labo]
    if {[eof $labo]} {
        close $labo
    } else {
        puts stderr "Labo: \"$l\""
    }
}


proc accept {labo addr port} {
  
    fileevent $labo readable [list readLabo $labo]
    puts stderr "Accept from [fconfigure $labo -peername]"
    fconfigure $labo -buffering line -blocking 0
    
    # Send Acceptance string to client
    set date [clock format [clock seconds]]
    set boundary "-----NEXT_PART_[clock seconds].[pid]"
    puts $labo "HTTP/1.1 200 OK"
    puts $labo "Date: $date"
    puts $labo "Server: CNRS/LPN/Phydis maison"
    puts $labo ""
    puts $labo ""
    puts $labo ""
    puts $labo "blabla"

    # log the connection
    puts stderr "Accepted connection from $addr at $date"
}

# Create a server socket on port $svcPort. 
# Call proc accept when a client attempts a connection.

socket -server accept $svcPort
vwait events    ;# handle events till variable events is set
