#!/usr/local/bin/tclsh

proc switchBug {tcol} {
    set rIVbad [list @ I V instant statut]
    set rVIbad [list @ V I instant statut]
    set rIVgood "@ I V instant statut"
    set rVIgood "@ V I instant statut"
    puts stderr [list $tcol == $rIVbad : [expr {$tcol == $rIVbad}]]
    puts stderr [list $tcol == $rIVgood : [expr {$tcol == $rIVgood}]]
    switch -- $tcol {
	$rIVbad {puts OK}
	$rVIbad {puts OK}
	default {puts stderr "\"$tcol\" should be \"$rIVbad\" or \"$rVIbad\""}
    }
    switch -- $tcol {
	$rIVgood {puts OK}
	$rVIgood {puts OK}
	default {puts stderr "\"$tcol\" should be \"$rIVgood\" or \"$rVIgood\""}
    }
    switch -- $tcol {
	"@ I V instant statut" {puts OK}
	"@ V I instant statut" {puts OK}
	default {puts stderr "\"$tcol\" should be \"$rIVgood\" or \"$rVIgood\""}
    }
    switch -- $tcol "
	$rIVbad {puts OK}
	$rVIbad {puts OK}
	default {puts BAD}
    "
    switch -- $tcol \
	"@ I V instant statut" {puts OK}\
	"@ V I instant statut" {puts OK}\
	default {puts stderr "\"$tcol\" should be \"$rIVgood\" or \"$rVIgood\""}
}

switchBug [list @ I V instant statut]

switchBug {@ I V instant statut}

# Le PB est que dans la forme "switch xyz {...}, les expressions dans {...} ne sont pas évaluées
