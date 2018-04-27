# Cf. http://mini.net/tcl/757
# http://www.faqs.org/faqs/jpeg-faq/part1/

proc get_jpg_dimensions {filename} {

  # open the file
  set img [open $filename r+]
  # set to binary mode - VERY important
  fconfigure $img -translation binary

  # read in first two bytes
  binary scan [read $img 2] "H4" byte1
  # check to see if this is a JPEG, all JPEGs start with "ffd8", make
  # that SHOULD start with
  if {$byte1!="ffd8"} {
    close $img
    puts "Error! $filename is not a valid JPEG file!"
    exit
  }

  # cool, it's a JPG so let's loop through the whole file until we
  # find the next marker.
  while { ![eof $img]} {

    while {$byte1!="ff"} {
      binary scan [read $img 1] "H2" byte1
    }

    # we found the next marker, now read in the marker type byte,
    # throw out any extra "ff"'s
    while {$byte1=="ff"} {
      binary scan [read $img 1] "H2" byte1
    }

    # if this the the "SOF" marker then get the data
    if { ($byte1>="c0") && ($byte1<="c3") } {
      # it is the right frame. read in a chunk of data containing the
      # dimensions.
      binary scan [read $img 7] "x3SS" height width
      close $img ;# FIX
      # return the dimensions in a list
      return [list $height $width]
    } else {

      # this is not the the "SOF" marker, read in the offset of the
      # next marker
      binary scan [read $img 2] "S" offset
      # the offset includes its own two bytes so we need to subtract
      # them
      set offset [expr $offset -2]
      # move ahead to the next marker
      seek $img $offset current
    } ;# end else

  } ;# end while
    # we didn't find an "SOF" marker, return zeros for error detection
    set height 0
    set width 0
    close $img
    return [list $height $width]

 } ;# end proc
