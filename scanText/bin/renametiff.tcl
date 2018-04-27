#!/bin/sh
#\
exec tclsh "$0" ${1+"$@"}

set HELP {
Les fichiers sont supposés être scannés sous les noms
p000.tif  -> 0000.tiff
p0001.tif -> 0002.tiff
...
p400.tif  -> 0400.tiff
p4001.tif -> 0402.tiff
...
p4009.tif -> 0418.tiff
p40010.tif -> 0420.tiff
...
}

proc renamefile {f} {
    if {[regexp {^([pi])(...)(.*)\.tif$} $f tout pi n1 n2] != 1} {
        puts stderr "cannot regexp $f"
        return 1
    }
    if {$n2 == {}} {
        set n2 0
    } elseif {[string index $n2 0] == "0"} {
        puts stderr "bad n2 = \"$n2\"" 
        return 2
    }
    set n [expr {$n1 + 2*$n2}]
    set nf $pi[format %03d $n].tiff
    if {[file exists $nf]} {
        puts stderr "file exists $nf (for $f)"
        return 3
    }
    puts "$f -> $nf"
    file rename $f $nf
    file attributes $nf -permissions 0644
}

foreach f [glob p*.tif] {
    renamefile $f
}

