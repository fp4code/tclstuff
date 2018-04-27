#!/usr/local/bin/tclsh

# 10 janvier 2000 (FP): modif du calcul de home

if {$argc != 1} {
    puts stderr "Syntaxe : [info script] username | /repertoire"
    exit 1
}

set destin $argv

if {[string index $destin 0] == "/"} {
    set home $destin
} else {
    if [catch {set home ~$destin} message] {
	puts stderr "$message"
	exit 1
    }
}

if {![file exists $home]} {
    puts stderr "Le r�pertoire $home n'existe pas"
    exit 1
}

set fichier $home/.XauthorityDONS

proc afaire {} {
    global destin
    puts stderr "Il faut que l'utilisateur $destin frappe une fois pour toutes"
    puts stderr "la commande \"inipretecran\" sur cette machine."
}

if {![file exists $fichier]} {
    puts stderr "Le Fichier \"$fichier\" n'existe pas."
    afaire
    exit 1
}

if {![file writable $fichier]} {
    puts stderr "Le Fichier \"$fichier\" ne peut pas �tre �crit"
    afaire
    exit 1
}

set ecran $env(DISPLAY)

exec /usr/openwin/bin/xauth nextract - $ecran > $fichier
set ii [string first ":" $ecran]
incr ii -1
set machine [string range $ecran 0 $ii]

if {$destin != "root"} {
    puts "L'�cran $ecran est pr�t� � $destin. Taper maintenant"
    puts "        % /bin/su - $destin"
    puts "puis    % empruntecran $machine -principal ; exit"
    puts "ou      % empruntecran $machine -secondaire ; exit"
} else {
    puts "L'�cran $ecran est pr�t� � root sur $machine. Taper maintenant"
    puts "        % su -"
    puts "    Ne pas oublier le -, sinon KATASTROFE. Taper ensuite"
    puts "        # /usr/local/bin/empruntecran $machine -principal; exit"
}
puts ""
puts "l'option -principal suppose que vous ne travaillez que sur cet �cran :"
puts "                    elle met � jour le fichier .DISPLAY"
puts "l'option -secondaire ne met pas � jour le fichier .DISPLAY"
puts "                     et impose que \"$destin\" tape ult�rieurement"
puts "        % setenv DISPLAY $ecran"

exit 0

