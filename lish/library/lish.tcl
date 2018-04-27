namespace eval lish {}

set HELP(lish::greek) {
wikit/703.html

Greeklish

Richard Suchenwirth - Greeklish is a name used in the Web for Greek text written in Latin letters, in other words, a transliteration. See
http://homepages.lycos.com/cast00/lypersonal/ for an example - which uses 8 for Theta and differs slightly from the encoding used here. 

The following proc translates text in Greeklish to the appropriate Unicodes (cf. Unicode and UTF-8) for the Greek letters. Transliteration is
mostly strict, i.e. a 1:1 mapping (that's why slight oddities like Q for Theta occur, but it can be memorized as "a circle with something at it"). I
made one exception for the accented letters, which in Greeklish are written with trailing apostrophe.

Example: [lish::greek Aqh'nai] gives the Greek name of Athens. 
}

namespace eval lish {
    variable i18n_a2g

    array set i18n_a2g {
        A \u391 B \u392 G \u393 D \u394 E \u395 Z \u396 H \u397 Q \u398
        I \u399 K \u39a L \u39b M \u39c N \u39d J \u39e O \u39f P \u3a0
        R \u3a1 S \u3a3 T \u3a4 U \u3a5 F \u3a6 X \u3a7 Y \u3a8 W \u3a9
        a \u3b1 b \u3b2 g \u3b3 d \u3b4 e \u3b5 z \u3b6 h \u3b7 q \u3b8
        i \u3b9 k \u3ba l \u3bb m \u3bc n \u3bd j \u3be o \u3bf p \u3c0
        r \u3c1 c \u3c2 s \u3c3 t \u3c4 u \u3c5 f \u3c6 x \u3c7 y \u3c8 w \u3c9
        ";" \u387 ? ";"
    }
}

proc ::lish::greek {args} {
    variable i18n_a2g
    set res ""
    foreach {in out} {
        A' \u386 E' \u388 H' \u389 I' \u38a O' \u38c U' \u38e W' \u38f
        a' \u3ac e' \u3ad h' \u3ae i' \u3af o' \u3cc u' \u3cd w' \u3ce
    } {regsub -all $in $args $out args}
    foreach i [split $args ""] {
        if {[array names i18n_a2g $i]!=""} {
            append res $i18n_a2g($i)
        } else {
            append res $i
        }
    }
    return $res
}


set HELP(lish::keyboard) {
wikit/560.html

Keyboard widget

Richard Suchenwirth -- This proc creates a frame and grids buttons into it for the specified character range (Unicodes welcome, but in 0x..
notation!). Each button bears its character as label, and inserts its character into the text widget specified with the -receiver option. This
requires Tcl/Tk 8.1 or better and a font with the characters you want (of course). 

OPTIONS 

      -keys range: list of (decimal or hex Unicodes of) characters to display. Consecutive sequences may be written as range, e.g.
      {0x21-0x7E} gives the printable lower ASCII chars. 
      -keysperline n: number of keys per line, default: 16. 
      -title string: If not "", text of a title label displayed above the keys. Default: "". 
      -dir direction: if "r2l", moves cursor one to the left after each keypress. Useful for Arab/Hebrew. Default: l2r. 
      -receiver widgetpath: Name of a text widget to receive the keystrokes at its insert cursor. 

EXAMPLE: a rudimentary editor for Greek, in two lines: 

   pack [text .t -width 80 -height 24]
   pack [lish::keyboard .kbdGr\
           -title Greek\
           -keys {0x386-0x38a 0x38c 0x38e-0x3a1 0x3a3-0x3ce}\
           -receiver .t]

And here's some useful ranges if you happen to have the Cyberbit font: 

 Arabic (context glyphs) {0xFE80-0xFEFC} r2l
 Cyrillic                {0x410-0x44f}
 Greek                   {0x386-0x38a 0x38c 0x38e-0x3a1 0x3a3-0x3ce}
 Hebrew                  {0x5d0-0x5ea 0x5f0-0x5f4}  r2l
 Hiragana                {0x3041-0x3094}
 Katakana                {0x30A1-0xU30FE}
 Thai                    {0xE01-0xE3A 0xE3F-0xE5B}

BUGS 

It would be more straightforward to specify characters in the -keys argument literally, or in \uxxxx notation. But at home I still have 8.1a1
(blush) where Unicode scan don't work. Very Soon Now... ;-)
}



proc ::lish::keyboard {w args} {
  frame $w
  array set opts {
     -keys {0x21-0x7E} -title "" -keysperline 16 -dir l2r -receiver ""
  }
  array set opts $args ;# no errors checked
  set klist {}; set n 0
  if {$opts(-title)!=""} {
     grid [label $w.title -text $opts(-title) ] \
              -sticky news -columnspan $opts(-keysperline)
     }
  foreach i [clist2list $opts(-keys)] {
     set c [format %c $i]
     set cmd "$opts(-receiver) insert insert [list $c]"
     if {$opts(-dir)=="r2l"} {
        append cmd ";$opts(-receiver) mark set insert {insert - 1 chars}"
     } ;# crude approach to right-to-left (Arabic, Hebrew)
     button $w.k$i -text $c -command $cmd  -padx 5 -pady 0
     lappend klist $w.k$i
     if {[incr n]==$opts(-keysperline)} {
       eval grid $klist -sticky news
       set n 0; set klist {}
     }
   }
   if [llength $klist] {eval grid $klist -sticky news}
   set w ;# return widget pathname, as the others do
}

proc lish::clist2list {clist} {
   #-- clist: compact integer list w.ranges, e.g. {1-5 7 9-11}
   set res {}
   foreach i $clist {
       if [regexp {([^-]+)-([^-]+)} $i -> from to] {
           for {set j [expr $from]} {$j<=[expr $to]} {incr j} {
               lappend res $j
           }
       } else {lappend res [expr $i]}
   }
   set res
}

