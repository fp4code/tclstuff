package require fidev
package require fidev_asdexUtils


set dejafait {

      cd /home/asdex/data
      
      catch {exec find . -type d -name "TLM*" -print} tlms
      
      ::fidev::asdexUtils::comprimeTout [split $tlms \n]
      
      ::fidev::asdexUtils::comprimeTout [findDirs sch 10]
      ::fidev::asdexUtils::comprimeTout [findDirs sgt 3]
      ::fidev::asdexUtils::comprimeTout [findDirs sg2 3]
      ::fidev::asdexUtils::comprimeTout [findDirs scs 4]
      ::fidev::asdexUtils::comprimeTout [findDirs cgt 10]
      ::fidev::asdexUtils::comprimeTout [findDirs spt 6]
      ::fidev::asdexUtils::comprimeTout [findDirs ecb 3]
      ::fidev::asdexUtils::comprimeTout [findDirs ec4 3]
      ::fidev::asdexUtils::comprimeTout [findDirs sc4 5]
      ::fidev::asdexUtils::comprimeTout [findDirs rvi 3]
      ::fidev::asdexUtils::comprimeTout [findDirs vrc 3]
      ::fidev::asdexUtils::comprimeTout [findDirs log 5]
      ::fidev::asdexUtils::comprimeTout [findDirs cti 3]
      ::fidev::asdexUtils::comprimeTout [glob ./SF5/SF5.1/hyper/*]

}

##########################################################################

cd /home/asdex/data

catch {exec find . -name "*.tgz" -print} fichiers
set TGZ [list]
foreach f [split $fichiers \n] {
    if {[string match "./*tgz" $f]} {
        lappend TGZ $f
    } else {
        puts stderr [list warning $f]
    }
}

foreach f [lsort $TGZ] {
    set contenu [::fidev::asdexUtils::tgzContenu $f errs]
    set CONTENUS($f) $contenu
    if {$errs != {}} {
        set ERRS($f) $errs
    }
    puts [list $f -> $contenu]
}

foreach f [lsort [array names ERRS]] {
    puts [list $f -> $ERRS($f)]
}

set log [open tgz.dat w]
foreach f [lsort [array names CONTENUS]] {
    puts $log [list $f $CONTENUS($f)]
}
close $log

