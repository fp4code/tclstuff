#!/usr/local/bin/tclsh

# killPCttsessions.tcl
#
# Tue les processus de la forme "ttsession -s -d 139.100.240.*" qui
# sont cr��s lors de la connexion d'un PC au monde unix via un
# �mulateur de terminal X. Ces processus ne sont apparamment pas
# d�truits lors de la d�connexion. Ce petit script permet donc de
# faire le m�nage et peut-�tre de diminuer l'activit� du processus
# "rpc.ttdbserver" qui consomme beaucoup de ressources CPU
#
# Auteur : Fabrice Pardo

set lignes [exec ps -ef -o "user pid args"]

foreach l [split $lignes \n] {
    set user [lindex $l 0]
    set pid [lindex $l 1]
    set commande [lrange $l 2 end]
    if {[string match {ttsession -s -d 139.100.240.*} $commande]} {
        puts [list $user $pid $commande]
        exec kill -KILL $pid
    }
}

