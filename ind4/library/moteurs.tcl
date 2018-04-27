set Jaeger(1)  MoteurP1
set Jaeger(2)  MoteurP2
set Jaeger(3)  MoteurP3
set Jaeger(4)  MoteurP4
set Jaeger(5)  Moteur+P3P4
set Jaeger(6)  Moteur+P1P2
set Jaeger(7)  0elec
set Jaeger(8)  0V
set Jaeger(9)  0meca
set Jaeger(10) 0V_Puissance
set Jaeger(11) fdc+
set Jaeger(12) fdc-
set Jaeger(13) codeurA
set Jaeger(14) codeurB
set Jaeger(15) Codeur_5V
set Jaeger(16) 0V_Logique

# Bus-alim

set courant(alim1) 4A
set courant(alim2) 4A
set courant(alim3) neant
set courant(alim4) 12A
set courant(alim5) 12A

set BUS78_J1(2)  [list alim4 0V] 
set BUS78_J1(4)  [list alim4 12V] 
set BUS78_J1(6)  [list alim3 5V] 
set BUS78_J1(8)  [list alim3 0V] 
set BUS78_J1(12) terre 
set BUS78_J1(14) presence_secteur
set BUS78_J1(16) surveillance_alim5
set BUS78_J1(18) voyant_marche
set BUS78_J1(20) telecommande
set BUS78_J1(22) [list alim5 12V]
set BUS78_J1(24) [list alim1 0V]
set BUS78_J1(26) [list alim1 30V]
set BUS78_J1(28) [list alim2 0V]
set BUS78_J1(30) [list alim2 30V]
set BUS78_J1(32) [list alim5 0V]

#

set BUS78_J18(1) presence_secteur
set BUS78_J18(2) surveillance_alim5
set BUS78_J18(3) voyant_marche
set BUS78_J18(4) telecommande

# Bus-cartes

set notes(alimP) "alim1+alim2"

set BUS78_J2(1) [list alimP 0V]
set BUS78_J2(2) [list alimP 30V]
set BUS78_J2(3) [list alimP 60V]

set BUS78_J2(4) [list alim5 0V]
set BUS78_J2(5) [list alim5 12V]

set notes(BUS78_J3) BUS78_J2
set notes(BUS78_J4) BUS78_J2
set notes(BUS78_J5) BUS78_J2
set notes(BUS78_J6) BUS78_J2

set notes(alimL) "alim3+alim4"

set BUS78_J7(1) [list alimL 12V]
set BUS78_J7(2) [list alimL 5V] ; # non utilisé
set BUS78_J7(3) [list alimL 0V]

set notes(BUS78_J8) BUS78_J7
set notes(BUS78_J9) BUS78_J7
set notes(BUS78_J10) BUS78_J7
set notes(BUS78_J11) BUS78_J7
set notes(BUS78_J12) BUS78_J7
set notes(BUS78_J13) BUS78_J7
set notes(BUS78_J14) BUS78_J7
set notes(BUS78_J15) BUS78_J7
set notes(BUS78_J16) BUS78_J7
set notes(BUS78_J17) BUS78_J7

