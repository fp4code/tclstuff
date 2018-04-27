#!/bin/sh
# the next line restarts using wish \
exec wish8.3 "$0" "$@"

package require -exact snack 2.1

snack::sound s -channels 2

pack [frame .b]
pack [snack::levelMeter .b.left  -width 20 -length 200 \
	-orient vertical -oncolor green] -side left
pack [snack::levelMeter .b.right -width 20 -length 200 \
	-orient vertical -oncolor orange] -side left

s record
# after 100 UpdateV1
after 100 UpdateV2 0 0

proc UpdateV1 {} {
  set l [s max -start 0 -end -1 -channel 0]
  set r [s max -start 0 -end -1 -channel 1]
  s length 0

  .b.left  configure -level $l
  .b.right configure -level $r

  after 50 UpdateV1
}

proc UpdateV2 {begin N} {
  set l [s max -start $begin -end -1 -channel 0]
  set r [s max -start $begin -end -1 -channel 1]
  set begin [s length]
  if {$N%20 == 0} {
    puts stderr "$N $begin"
  }

  .b.left  configure -level $l
  .b.right configure -level $r

  after 50 UpdateV2 $begin [incr N]
}
