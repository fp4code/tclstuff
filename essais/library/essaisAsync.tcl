#!/usr/local/bin/tclsh

package require fidev

catch {package require rien} ;# pour lire le fichier et mettre � jour

fidev_load  ../src/libessais essais

::essais::boucle 10
