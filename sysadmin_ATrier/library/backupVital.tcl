#!/usr/local/bin/tclsh


set LEVEL 0
set DUMP "/usr/sbin/ufsdump"
set PRINT "lp"
set FORME "/usr/openwin/bin/mp -lo"
# autorisés : 0 0b 0n 0bn 0l 0lb 0ln 0lbn 0m 0mb 0mn 0mbn
set TAPE "/dev/rmt/0cn"
set DUMPOP "$DUMP ${LEVEL}dsbfu 54000 13000 126"
set SERVEUR fico6

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
        if {[string find $messages "DUMP IS DONE"] >= 0} {
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
set log [open /home/logs/backup.$dada a]

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

set homes {
asdex    fico9  /export/home/asdex
be       l2m    /export/homebis/be
bloch    l2m    /export/home1404/bloch
bourneix l2m    /export/homebis/bourneix
cambril  l2m    /export/homebis/cambril
cavanna  l2m    /export/homebis/cavanna
chen     sbl3   /export/home/chen
christin l2m    /export/homebis/christin
cornette l2m    /export/homebis/cornette
couraud  l2m    /export/homebis/couraud
darre    l2m    /export/homebis/darre
david    l2m    /export/homebis/david
decanini l2m    /export/homebis/decanini
denk     l2m    /export/homebis/denk
desmicht l2m    /export/homebis/desmicht
devillhe l2m    /export/homebis/devillhe
dupuis   l2m    /export/homebis/dupuis
ernest   l2m    /export/homebis/ernest
essaidi  l2m    /export/homebis/essaidi
fab      l2m    /export/homebis/fab
faini    nano3  /export/home/faini
ferlazzo l2m    /export/homebis/ferlazzo
fico2    l2m    /export/homebis/fico2
ficopt   ufico  /export/home/ficopt
fournelf l2m    /export/homebis/fournelf
franck   l2m    /export/homebis/franck
freixath l2m    /export/homebis/freixath
gierak   l2m    /export/homebis/gierak
gilbert  l2m    /export/homebis/gilbert
goujonan  l2m    /export/homebis/goujonan
heintze  l2m    /export/homebis/heintze
jin      l2m    /export/homebis/jin
jluc     l2m    /export/homebis/jluc
jnmo97   l2m    /export/homebis/jnmo97
jouault  l2m    /export/homebis/jouault
kottler  l2m    /export/homebis/kottler
launois  hl     /export/home/launois
laurent  l2m    /export/homebis/laurent
lee      l2m    /export/homebis/lee
local    l2m    /export/homebis/local
logs     l2m    /export/homebis/logs
madouri  l2m    /export/homebis/madouri
mailly   nano3  /export/home/mailly
marzin   admin1 /export/home/marzin
mayeux   l2m    /export/homebis/mayeux
mejias   l2m    /export/homebis/mejias
msch     l2m    /export/homebis/msch
nedelcu  l2m    /export/homebis/nedelcu
oracle   unano  /export/home/oracle7
palmier  l2m    /export/homebis/palmier
pepin    l2m    /export/homebis/pepin
petitf   l2m    /export/homebis/petitf
planel   l2m    /export/home1404/planel
rita     l2m    /export/homebis/rita
rousseau l2m    /export/homebis/rousseau
sembag   l2m    /export/homebis/sembag
senellpa l2m    /export/homebis/senellpa
simong   l2m    /export/homebis/simong
sysadmin l2m    /export/hometer/sysadmin
teissier fico7  /export/home/teissier
thierry  l2m    /export/homebis/thierry
vieu     l2m    /export/homebis/vieu
vtm      l2m    /export/homebis/vtm
www      dao3   /export/home/www
xoff     l2m    /export/homebis/xoff
zzwang   l2m    /export/homebis/zzwang}

# obtenu par [glob *]

set desktops {L2M amhag arquey be bloch bourneix cambril cassam cavanna chen darre david domergue dupuis ernest fab faini ferlazzo finley franck gierak jluc kjchen kottler lagadec launois lebreton lee lelarge local madouri mailly mayeux msch nour petitf planel ravet regis rousseau simon teissier thierry vieu vtm xoff zzwang}

set progs {Khoros2.2  ufico /export/free/sysadmin/Khoros2.2
asdex      fico9 /export/home/asdex/src
Tcl        l2m   /export/p6/local/src/Tcl
TeK        dao3  /export/homebis/TeK
Wingz      l2m   /usr/local/src/WingzS1
asyst      l2m   /export/p6/local/src/asyst
cap60      l2m   /usr/local/src/cap60
dt         l2m   /usr/local/etc/dt
gnu        l2m   /export/p6/local/src/gnu
gnuplot    l2m   /usr/local/src/gnuplot
grapher-3d l2m   /export/p6/local/src/grapher-3d-2.1.1
ileaf      l2m   /export/ileaf/ileaf
java       l2m   /export/p6/local/src/java
javaL2M    l2m   /export/homebis/javaL2M
linux      ufico /export/free/linux
local3     dao3  /export/homebis/local3
msdos_bin  l2m   /export/homebis/msdos_bin
netscape   l2m   /export/p6/local/src/netscape
pcb        l2m   /prog/sl/src/pcb
samba      l2m   /export/p6/local/src/samba-1.9.17p1
slatec     ufico /export/free/sysadmin/netlib/slatec
sniffit    l2m   /export/p6/local/src/sniffit.0.3.5
src        l2m   /export/p6/src
usrS1      dao3  /export/homebis/usrS1
utl        l2m   /export/p6/local/src/utl
sl         l2m   /export/p6/local}

set Vital [list {root l2m /} {usr l2m /usr} {roots l2m /export/root}]

foreach l [split $homes \n"] {
    foreach {nom ou quoi} $l {}
    lappend Vital [list home/$nom $ou $quoi]
}

foreach f $desktops {
    lappend Vital [list desktop/$f l2m /export/ileaf/desktops/$f]
}

foreach l [split $progs \n"] {
    foreach {nom ou quoi} $l {}
    lappend Vital [list prog/$nom $ou $quoi]
}

sauvetout $Vital

close $log
