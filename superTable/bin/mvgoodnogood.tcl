package require fidev
package require superTable

# voir si on est en good ou nogood


if {[file exists nogood.spt]} {

catch {unset nogood}
catch {mkdir nogood}
set n *
set lignes [lindex [::superTable::fileToTable nogood nogood.spt n {}] 0]
foreach l $lignes {
    set f $nogood([list $l repertoire])/$nogood([list $l fichier])
    if {[catch {file rename $f nogood} message]} {
        puts $message
    }
}
catch {mkdir good}
foreach f [glob {*[ABC]*.spt}] {mv $f good}


# le fichier "nogood.spt" existe

} elseif {[file exists good.spt]} {

catch {unset good}
catch {mkdir good}
set n *
set lignes [lindex [::superTable::fileToTable good good.spt n {}] 0]
foreach l $lignes {
    set f $good([list $l repertoire])/$good([list $l fichier])
    if {[catch {file rename $f good} message]} {
        puts $message
    }
}
catch {mkdir nogood}
foreach f [glob {*[ABC]*.spt}] {mv $f nogood}

} else {

puts stderr "Savez-vous que sous \"sptdisplay\" on peut appuyer sur \"Enter\" ou \"Escape\" ???"

}



{
    cd ..
    catch {unset good}
    set good [glob */good/*.spt]
    foreach f $good {
        set f [lindex [split [lindex [file split $f] end] .] 0]
        puts "    $f \\"
    }
}

{
    foreach f {5x7 5x10 5x17 5x40 5x54 6x20 7x45 8x27} {
	mkdir $f
        foreach g [glob *$f.spt] {
	    file rename $g $f/$g
	}
    }



}