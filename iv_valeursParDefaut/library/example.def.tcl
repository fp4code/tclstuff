proc valeurs.par.defaut {} {
# Sequences d'initialisation conplementaires aux sequences standard de chaque appareil de la liste GPIBAPP(init)
    global smu1
    set temperature 0
    smu1 write "F0,S3W1XF1,S3W1X" ;# 50Hz_integ, enable_default_delay
    smu1 write "F0,1XO0XF1,1XO0X" ;# Local sense"
    smu1 write "D1,SMU1 2 FILSX"  ;# Affiche "2 fils" sur l'ecran du smu
    puts "ATTENTION : Local Sensing"
}

# indispensable parce que le fichier est sourcé dans une procédure
global ASDEXDATA GPIBAPP

# Liste des commandes executees a chaque appel de ce fichier :
#===========================================================

# Nom qui apparaitra au menu "type de mesure" de la fenetre principale de commande.
    set ASDEXDATA(typMes) bidon

# Liste facultatives d'initialisation de la fenetre principale de commande.
# Elles peuvent etre modifiees de facon interactive.
    set GPIBAPP(conn) {} ;# Liste des appareils normalement connectes
    set GPIBAPP(init) {} ;# Liste des appareils initialisables
    set GPIBAPP(poll) {} ;# Liste des appareils pour le SRQ
    set GPIBAPP(sources) {} ;# Liste des appareils source a mettre au repos

# Definit la procedure de mesure situee dans le rep "~fidev/Tcl/mesures"
    installIn mes.xeq mes.<EXAMPLE>

# Definit les proc de deplacements/enregistrements (on n'y touche pas!)
    installIn tc.mesure.xeq tc.mesure
    installIn valeurs.par.defaut.xeq valeurs.par.defaut ;# Cf. ci-dessus

# Lectures de mparams et eparams
    source $ASDEXDATA(rootData)/$ASDEXDATA(echantillon)/$ASDEXDATA(mparams)
    source $ASDEXDATA(rootData)/$ASDEXDATA(echantillon)/$ASDEXDATA(typCar)/$ASDEXDATA(eparams)
# Definit la procedure de sauvegarde
    installIn sauv.xeq sauvInSupertable
