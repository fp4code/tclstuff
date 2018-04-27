#!/bin/sh
#\
exec tclsh "$0" "$@"

if {$argc != 2} {
    puts stderr "syntaxe: $argv0 repertoire_relatif destination"
    exit 1
}

set env(PATH) /usr/bin:/bin

set source      [lindex $argv 0]
set destination [lindex $argv 1]

# l'option -depth permet d'afficher le répertoire après le contenu
# afin que cpio puisse modifier les caractéristiques de celui-là

exec find $source -depth -print | cpio -pdm $destination >&@ stdout

unset destination
unset source




