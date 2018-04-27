#!/usr/local/bin/tclsh

package require fidev
package require essais_f77

if {[catch {setVarC toto 22} messages]} {
    puts "Erreur : $messages"
} else {
    puts "OK, toto=$toto"
}

set titi(a) a
if {[catch {setVarC titi 22} messages]} {
    puts "Erreur : $messages"
} else {
    puts "OK, titi=$titi"
}

aList {q we rty}

puts [inverse 0.0]

