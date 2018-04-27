# 19 décembre 2002
# Première étape :

foreach f [glob ../*/*/*] {
    set nf [string tolower [string map {{ } _} [file tail $f]]]
    puts "$f -> $nf"
    if {[catch {exec cp -p $f $nf} mm]} {
        puts $mm
    }
}

set l { \
abram        Izo.Abram
angela       Angela.Vasanelli
aubin        Guy.Aubin
barbay       Sylvain.Barbay
bardou       Nathalie.Bardou
bencheikh    Kamel.Bencheikh
bensoussan   Marcel.Bensoussan
bloch        Jacqueline.Bloch
bouchoule    Sophie.Bouchoule
cambriol     Edmond.Cambril
cavanna      Antonella.Cavanna
chanconie    Gilbert.Chanconie
charbonneau1 Delphine.Charbonneau
chen         Yong.Chen
chouteau     David.Chouteau
chriqui      Yves.Chriqui
coelho       Paulo.Coelho
collin       Stephanne.Collin
couraud1     Laurent.Couraud
david        Christophe.David
decanini     Dominique.Decanini
dumeige      Laurent.Dumeige
duphil1      Audry.Duphil
edmond       Edmond.Cambril
eldahdah     Neyla.Eldahdah
esnault1     Jean-Claude.Esnault
eusebe       Eric.Eusebe
faini        Giancarlo.Faini
ferlazzo1    Laurence.Ferlazzo
flicstein    Jean.Flicstein
gennser      Ulf.Gennser
glas         Frank.Glas
halbwachs1   Emmanuel.Halbwachs1
harmand      Jean-Christophe.Harmand
horache      ElHoussine.Horache
hours        Julien.Hours
jin          Yong.Jin
jusserand    Bernard.Jusserand
krebs        Olivier.Kerbs
kuszelewicz  Robert.Kuszelewicz
lafosse1     Xavier.Lafosse
largeau2     Ludovic.Largeau
laurent      Sabine.Laurent
lebib        Amira.Lebib
legratiet1   Luc.Legratiet
lemaitre     Aristide.Lemaitre
levenson     Ariel.Levenson
li           Lianhe.Li
lijadi       Melania.Lijadi
lucas        Tristan.Lucas
madouri1     Ali.Madouri
mailly       Dominique.Mailly
marzin       Jean-Yves.Marzin
merat_combes Marie-Noelle.Merat-Combes
meriadec     Cristelle.Meriadec
merzeau      Laurent.Merzeau
meunier      Karine.Meunier
minot        Christophe.Minot
moison2      Jean-Marie.Moison
monnier      Paul.Monnier
mouillet     Robert.Mouillet
moussou      Alexandra.Moussou
nicolas      Nicolas.Allemandou
oria         Olivier.Oria
oudar        Jean-Louis.Oudar
pardo        Fabrice.Pardo
patriarche   Gilles.Patriarche
pelouard     Jean-Luc.Pelouard
pepin        Anne.Pepin
peyrade      David.Peyrade
raj          Rama.Raj
rao          Elchuri.Rao
rita         Rita.Magri
robert       Isabelle.Robert
sagnes       Isabelle.Sagnes
saint-girons Guillaume.Saint-Girons
sermage      Bernard.Sermage
symonds      Clementine.Symonds
talneau      Anne.Talneau
travers      Laurent.Travers
varoutsis    Spyros.Varoutsis
vidakovic    Petar.Vidakovic
voisin       Paul.Voisin
wang         Zhao-Zhong.Wang}


foreach ll [split $l \n] {
    set a [lindex $ll 0]
    set b [lindex $ll 1]
    if {$b != {}} {
        if {[catch {file rename -force $a.gif /home/p10admin/A/html/Lpn/databases/trombines/$b.gif} mm]} {
            puts $mm
        }
    }
}


