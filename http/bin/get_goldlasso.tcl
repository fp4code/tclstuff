#!/bin/sh
# \
exec tclsh "$0" ${1+"$@"}

# 2006-01-19 (FP) pour récupérer les adresse de goldlasso

package require http

::http::config -proxyhost proxy.lpn.prive -proxyport 8080

if {$argc != 2} {
    puts stderr "syntaxe : $argv0 umin umax"
    exit 1
}

set umin [lindex $argv 0]
set umax [lindex $argv 1]

for {set u $umin} {$u <= $umax} {incr u} {

    set token [http::geturl http://eloop.goldlasso.com/optout/index.php?u=$u]
    set data [::http::data $token]
    ::http::cleanup $token
    
    set aaas [regexp "When you registered for partial free access to Science Online,\nyou agreed to receive occasional messages from AAAS" $data]
 
    set ok [regexp "<td>Update or change your Email Address</td>
                        <td><input type=\"text\" name=\"email\" size=\"\[0-9\]+\"  value=\"(\[^\"\]*)\"></td>" $data tout email]

    if {!$ok} {set email NO_EMAIL}
    
    puts stdout "[format "%10d" $u] $aaas $email"
}
