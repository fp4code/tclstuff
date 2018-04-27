# 5 septembre 2001 (FP)

package require fileutil

proc iszip f {return [expr {[string match *.zip $f] || [string match *.ZIP $f]}]}

set ICI /home/www/html/private/hydre.auteuil.cnrs-dir.fr/freeway/webcnrs/achats/Details

cd $ICI
set zips [::fileutil::find . iszip]

foreach f $zips {
    cd $ICI
    set dir [file dirname $f]
    cd $dir
    set n [file tail $f]
    puts $f
    exec unzip -uo $n
}
