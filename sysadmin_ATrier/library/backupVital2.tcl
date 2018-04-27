#!/usr/local/bin/tclsh


set LEVEL 0
set DUMP "/usr/sbin/ufsdump"
set PRINT "lp"
set FORME "/usr/openwin/bin/mp -lo"
# autorisés : 0 0b 0n 0bn 0l 0lb 0ln 0lbn 0m 0mb 0mn 0mbn
set TAPE "/dev/rmt/0cn"
set DUMPOP "$DUMP ${LEVEL}dsbfu 54000 13000 126"
set SERVEUR ufico

proc sauve {TableArg names} {
    upvar $TableArg Table
    foreach qui $names {
        global numero DUMPOP SERVEUR TAPE log
        set ou $Table($qui)
        set machine [lindex $ou 0]
        set path [lindex $ou 1]
        puts "$numero -> $qui $machine $path"
        puts "rsh -n $machine $DUMPOP ${SERVEUR}:${TAPE} $path"
        set err [catch {exec rsh -n $machine $DUMPOP ${SERVEUR}:${TAPE} $path} messages]
        puts "messages = $messages"
        puts "err = $err"
        puts $log "$numero -> $qui $machine $path (erreur = $err)"
        puts $log $messages
        flush $log
        if {[string first $messages "DUMP IS DONE"] >= 0} {
            incr numero
        }
    }
}

# on part d'une liste {n1 machine1 /path1} {n2 machine2 /path2}
# on initialise le tableau n1 -> machine1 path1
#                          n2 -> machine2} path2
proc splitAutoHomeInTable {Tableau Liste} {
    upvar $Tableau tableau 
    foreach a [array names tableau] {
        unset tableau($a)
    } 
    foreach ligne $Liste {
        set elems [eval list $ligne]
        if {[llength $elems] != 3} {
            puts stderr "DANGER : [llength $elems] éléments (au lieu de 3) pour $ligne"
        }
        set qui [lindex $elems 0]
        set tableau($qui) [lrange $elems 1 2] 
    }
}

proc sauvetout Liste {
    set Table(dummy) {}
    splitAutoHomeInTable Table $Liste
    set names {}
    foreach n $Liste {
        lappend names [lindex $n 0]
    }
    sauve Table $names
}

set dada [exec /usr/bin/date +%y%m%d]
set log [open /home/Logs/backup.$dada a]

puts $log {Pour récupérer les fichiers Numéro1 et Numéro2, le mieux est
	# /usr/bin/rsh -n fico6 mt -f /dev/rmt/0mn asf Numéro1
	# /usr/sbin/ufsrestore if fico6:/dev/rmt/0mn
	# /usr/bin/rsh -n fico6 mt -f /dev/rmt/0mn asf Numéro2
	# /usr/sbin/ufsrestore if fico6:/dev/rmt/0mn
Bien qu'il soit évidemment préférable d'aller dans un ordre croissant,
l'exabyte retrouve très vite les fichiers
} 
flush $log

set numero 0
puts "rsh -n $SERVEUR mt -f $TAPE rewind"
exec rsh -n $SERVEUR mt -f $TAPE rewind

# amhag    l2m    /export/homebis/amhag
# etman    l2m    /export/homebis/etman
# essais   l2m    /export/homebis/essais
# godin    l2m    /export/homebis/godin
# lebreton l2m    /export/homebis/lebreton
# lelarge  l2m    /export/homebis/lelarge
# lung     l2m    /export/homebis/lung
# skey     l2m    /export/homebis/skey
# ntrigue  l2m    /export/home/ntrigue
# regis    l2m    /export/homebis/regis
# seguinbr l2m    /export/homebis/seguinbr
# sylvestr l2m    /export/homebis/sylvestr
# boeuf    l2m    /export/homebis/boeuf
# kjchen   l2m    /export/homebis/kjchen
# arquey   l2m    /export/homebis/arquey

set homes {\
asdex ufico /export/home/asdex
alexp l2m /export/homebis/alexp
alexq l2m /export/homebis/alexq
be l2m /export/homebis/be
bloch l2m /export/homebis/bloch
bourneix l2m /export/homebis/bourneix
burniede l2m /export/homebis/burniede
cambril l2m /export/homebis/cambril
cavanna l2m /export/homebis/cavanna
chen l2m /export/homebis/chen
cornette l2m /export/homebis/cornette
couraud l2m /export/homebis/couraud
darre l2m /export/homebis/darre
david l2m /export/homebis/david
decanini l2m /export/homebis/decanini
delphine l2m /export/homebis/delphine
demichsy l2m /export/homebis/demichsy
denk l2m /export/homebis/denk
desmicht l2m /export/homebis/desmicht
dupuis l2m /export/homebis/dupuis
ernest l2m /export/homebis/ernest
essaidi l2m /export/homebis/essaidi
fab l2m /export/homebis/fab
faini l2m /export/homebis/faini
ferlazzo l2m /export/homebis/ferlazzo
fico2 l2m /export/homebis/fico2
ficosimu l2m /export/homebis/ficosimu
franck l2m /export/homebis/franck
freixath l2m /export/homebis/freixath
gierak l2m /export/homebis/gierak
gilbert l2m /export/homebis/gilbert
goujonan l2m /export/homebis/goujonan
heintze l2m /export/homebis/heintze
jin l2m /export/homebis/jin
jluc l2m /export/homebis/jluc
jouault l2m /export/homebis/jouault
kottler l2m /export/homebis/kottler
launois l2m /export/homebis/launois
laurent l2m /export/homebis/laurent
lelarge l2m /export/homebis/lelarge
madouri l2m /export/homebis/madouri
mailly l2m /export/homebis/mailly
marzin l2m /export/homebis/marzin
mayeux l2m /export/homebis/mayeux
mejias l2m /export/homebis/mejias
msch l2m /export/homebis/msch
nour l2m /export/homebis/nour
pepin l2m /export/homebis/pepin
petitf l2m /export/homebis/petitf
planel l2m /export/homebis/planel
rege l2m /export/homebis/rege
regis l2m /export/homebis/regis
rita l2m /export/homebis/rita
rousseau l2m /export/homebis/rousseau
sembag l2m /export/homebis/sembag
senellpa l2m /export/homebis/senellpa
simong l2m /export/homebis/simong
sysadmin l2m /export/homebis/sysadmin
teissier l2m /export/homebis/teissier
thierry l2m /export/homebis/thierry
thomas l2m /export/homebis/thomas
vieu l2m /export/homebis/vieu
vtm l2m /export/homebis/vtm
zzwang l2m /export/homebis/zzwang}

# obtenu par [glob *]

set desktops {L2M alexp alexq be bloch bourneix cambril cavanna chen cornette darre david delphine demichsy denk dupuis ernest fab faini ferlazzo fico2 franck freixath gierak gilbert goujonan heintze jluc jouault kottler lagadec launois lelarge madouri mailly marzin mayeux msch nour pepin petitf planel regis rita rousseau sembag senellpa simong sysadmin teissier thierry thomas vieu vtm zzwang
}

set progs {Tcl        l2m   /export/p6/local/src/Tcl
cap60      l2m   /usr/local/src/cap60
dt         l2m   /usr/local/etc/dt
gnu        l2m   /export/p6/local/src/gnu
gnuplot    l2m   /usr/local/src/gnuplot
ileaf      l2m   /export/ileaf/ileaf
src        l2m   /export/p6/src
utl        l2m   /export/p6/local/src/utl
sl         l2m   /export/p6/local}


set Vital [list]

foreach l [split $homes \n"] {
    foreach {nom ou quoi} $l {}
    lappend Vital [list home/$nom $ou $quoi]
}

foreach f $desktops {
    lappend Vital [list desktop/$f l2m /export/ileaf/desktops/$f]
}

lappend Vital [list {root l2m /} {usr l2m /usr} {roots l2m /export/root}]

foreach l [split $progs \n"] {
    foreach {nom ou quoi} $l {}
    lappend Vital [list prog/$nom $ou $quoi]
}

sauvetout $Vital

close $log
