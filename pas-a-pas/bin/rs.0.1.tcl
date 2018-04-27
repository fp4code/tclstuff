#!/bin/sh
# \
exec wish "$0" ${1+"$@"}

# 1999/12/21 (FP) gros nettoyage. Les imprimantes Apple sont abandonnées
# 2002/02/06 (FP) ajout de .ps au suffixe. L'imprimante imprime texto les fichier .txt !
# insuffisant en fait : il a.txt.b.ps est imprimé texto par la lexmark optra-S !

package require fidev
package require pas-a-pas_rs

