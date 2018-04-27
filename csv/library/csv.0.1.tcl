# 25 septembre 2001 (FP)

package provide phi10_csv 0.1

set HELP(phi10::csv) {

  Procedures for handling Comma Separated files of Values.    
  Compatibility tested with WNT Excel 2000

  When reading, rows are normally delimited by one of $LINESEPS elements
  When writing, rows are normally delimited by $LINESEP

  Cells are normally delimited by $separator

  When writing, if a cell contains a special character
  ($LINESEP, $separator or one of $MORELINESEPS and $MORETOQUOTE),
  each $QUOTE character is doubled and the whole cell is surrouded by $QUOTE

  When reading, if a cell begins by $QUOTE, all characters are
  readed, until first simple $QUOTE, replacing $QUOTE$QUOTE sequences
  by a single $QUOTE. Eventual subsequent chars are added
  to the quoted first part of the cell.

}

namespace eval phi10::csv {
  variable LINESEP \n
  variable MORELINESEPS [list \r\n \r]
  variable QUOTE \"
  variable MORETOQUOTE [list \t]                          ;# space are not quoted
  variable REGSEP ; array set REGSEP {, , ; ; | \\| / / : :}  ;# all allowed separators
}

# probably private procedure
proc phi10::csv::readCell {all index QUOTE separator ENDCELL_REGEXP} {
  if {[string index $all $index] == $QUOTE} {
    incr index
    if {![regexp -start $index -indices -- "\\A((\[^$QUOTE\]|$QUOTE$QUOTE)*)" $all dummy ii junk]} {
      puts stderr \"[string range $all $index [expr {$index+80}]]\"...
      return -code error "Missing closing quote, index = $index"
    }
    set i0 [lindex $ii 0]
    set i1 [lindex $ii 1]
    set index [expr {$i1+2}]
    set cell [string range $all $i0 $i1]
    regsub -all $QUOTE$QUOTE $cell $QUOTE cell
  } else {
    set cell ""
  }

  if {![regexp -start $index -indices -- $ENDCELL_REGEXP $all dummy ii]} {
    return -code error "Missing cell or line delimiter, index = $index"
  }
  set i0 [lindex $ii 0]
  set i1 [lindex $ii 1]
  if {$i0 != $index} {
    append cell [string range $all $index [expr {$i0-1}]]
  }
  set index [expr {$i1+1}]
  if {[string index $all $i0] == $separator} {
    return [list 0 $index $cell]
  } else {
    return [list 1 $index $cell]
  }
}

set HELP(phi10::csv::stringToList) {
  convert the string $all from a CSV file to a matrix list
  i.e. {{li1 co1} {li1 co2} ...} {{li2 co1} {li2 co2} ...} ...

  The string needs to be terminated by a $LINESEP or one
  of the $MORELINESEPS strings. So, don't use "read -nonewline ..."

  $separator is the cell separator. Tipically "," or ";"

  The list is returned.
}

proc phi10::csv::stringToList {all {separator ,}} {
  variable LINESEP
  variable MORELINESEPS
  variable QUOTE
  variable REGSEP
  if {![info exists REGSEP($separator)]} {
    return -code error "separator should be one of [array names REGSEP]"
  }
  global ENDCELL_REGEXP
  set ENDCELL_REGEXP "([join [concat [list $LINESEP] [list $REGSEP($separator)] $MORELINESEPS] |])"
  set index 0
  set rows [list]
  set cols [list]
  while {$index < [string length $all]} {
    set oldindex $index
    foreach {endrow index cell} [phi10::csv::readCell $all $index $QUOTE $separator $ENDCELL_REGEXP] break
    lappend cols $cell
    if {$endrow} {
      lappend rows $cols
      set cols [list]
    }
    if {$index <= $oldindex} {
      return -code error "Programming error : index = $index, oldindex = $oldindex"
    }
  }
  return $rows
}

set HELP(phi10::csv::listToString) {
  convert the string list $rows to a CSV string

  The string is terminated by a $LINESEP
  So, use "puts -nonewline ..."

  $separator is the cell separator. Tipically "," or ";"

  The CSV string is returned
}

proc phi10::csv::listToString {rows {separator ,}} {
  variable LINESEP
  variable QUOTE
  variable REGSEP
  variable MORELINESEPS
  variable MORETOQUOTE

  set TOQUOTE_REGEXP "([join [concat [list $LINESEP] [list $REGSEP($separator)] $MORELINESEPS $MORETOQUOTE] |])"

  set ncols 0
  foreach row $rows {
    set nc [llength $row]
    if {$nc > $ncols} {
      set ncols $nc
    }
  }
  set all ""
  foreach row $rows {
    set notFirst 0
    set nc 0
    foreach cell $row {
      incr nc
      if {$notFirst} {
        append all $separator
      } else {
        set notFirst 1
      }
      if {[regsub -all $QUOTE $cell $QUOTE$QUOTE cell] || [regexp $TOQUOTE_REGEXP $cell]} {
        append all \"$cell\"
      } else {
        append all $cell
      }
    }
    while {$nc < $ncols} {
      incr nc
      append all $separator
    }
    append all $LINESEP
  }
  return $all
}

proc phi10::csv::fileToList {fileName {separator ,}} {
  set f [open $fileName r]
  fconfigure $f -translation binary
  set all [read $f]
  close $f
  return [phi10::csv::stringToList $all $separator]
}

proc phi10::csv::listToFile {rows fileName {separator ,}} {
  set f [open $fileName w]
  fconfigure $f -translation binary
  puts -nonewline $f [phi10::csv::listToString $rows $separator]
  close $f
}

proc phi10::csv::test {file {separator ,}} {
  set tmpfile /tmp/csv[pid].csv
  phi10::csv::listToFile [phi10::csv::fileToList $file $separator] $tmpfile $separator
  catch {exec tkdiff $file $tmpfile}
  file delete $tmpfile
}

set FPprivateTest {
  package require fidev
  package require phi10_csv

  foreach file [glob /prog/Tcl/tcllib-1.0/examples/csv/*.csv] {phi10::csv::test $file ,}

  set phi10::csv::LINESEP \r\n              # in order to write DOS file
  set phi10::csv::MORELINESEPS [list \r \n]
  foreach file [glob ~/Z/*/*/*.csv] {
    puts $file
    phi10::csv::test $file \;
  }
}