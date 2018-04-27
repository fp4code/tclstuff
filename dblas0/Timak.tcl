# ambigu: do -case default -in src
do -case bubu -in src -do default

do -case baba -do bibi
do -case bibi -do bobo
do -case bubu1 -do bubu2
do -case bubu2 -do bubu1
do -case bubu1 -do bubu3
do -case bubu3 -in src -do default

do -in src
