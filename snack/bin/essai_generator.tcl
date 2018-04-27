# 26 décembre 2002 (FP)

# A LANCER AVEC WISH

package require snack 2.2
set f [snack::filter generator 440.0]
$f configure 440 20000 0.0 sine -1
snack::sound s
s stop
s play -filter $f
