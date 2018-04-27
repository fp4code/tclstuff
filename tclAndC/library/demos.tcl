#!/bin/sh
# The next line is a TK comment, but a shell command \
exec ./demos "$0" "$@"

set liste [list 1.0 2.0 3.0 4.0]
puts [sommeListe $liste]

set binArr [binary format d* $liste]
puts [sommeBinString $binArr]

