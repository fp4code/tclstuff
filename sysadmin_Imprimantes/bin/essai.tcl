#!/bin/sh
# the next line restarts using expectk \
exec expectk "$0" "$@"

set rows 10
set cols 132
set term .t

spawn ls

# stty rows $rows columns $cols < $spawn_out(slave,name)
set term_spawn_id $spawn_id

text $term -relief sunken -bd 1 -width $cols -height $rows -wrap none
pack $term
$term tag configure standout -background  black -foreground white
