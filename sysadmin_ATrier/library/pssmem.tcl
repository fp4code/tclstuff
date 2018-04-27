#!/prog/Tcl/bin/tclsh


set rep [exec /usr/bin/ps -efo "rss pmem user osz vsz pcpu pid s nice args"]
# nice et args peuvent disparaitre si le process est defunct
set rep [split $rep \n]
set header [lindex $rep 0]
set lignes [lrange $rep 1 end]


proc rsscomp {a1 a2} {
    global coltri
    return [expr [lindex $a1 $coltri] < [lindex $a2 $coltri]]
}

set osz 0
set vsz 0
set rss 0

set coltri 0

set lignes [lsort -command rsscomp $lignes]

puts "tri en rss (The resident set size of the process)"
puts ""

foreach l $lignes {
    incr osz [lindex $l 3] 
    incr vsz [lindex $l 4] 
    incr rss [lindex $l 0]
    puts [linsert $l 0 $rss]
}


puts ""
puts "rss (The resident set size of the process) = $rss kB"
puts "vsz (The virtual memory size of the process) = $vsz kB"
puts "osz (The size (in pages) of the  swappable  process's image in main memory) = $osz *4 kB"

set osz 0
set vsz 0
set rss 0

set coltri 0

puts "tri en vsz (The virtual memory size of the proces)"
puts ""

set lignes [lsort -command rsscomp $lignes]
foreach l $lignes {
    incr osz [lindex $l 3] 
    incr vsz [lindex $l 4] 
    incr rss [lindex $l 0]
    puts [linsert $l 0 $vsz]
}


puts ""
puts "rss (The resident set size of the process) = $rss kB"
puts "vsz (The virtual memory size of the process) = $vsz kB"
puts "osz (The size (in pages) of the  swappable  process's image in main memory) = $osz *4 kB"

