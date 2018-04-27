set filename /big/fab/Photos/p1000151.jpg

namespace eval exifvalues {}

proc exifvalues::Orientation {v} {
    switch $v {
	default 1
	1 {return top-left}
	2 {return top-right}
	3 {return bottom-right}
	4 {return bottom-left}
	5 {return left-top}
	6 {return right-top}
	7 {return right-bottom}
	8 {return left-bottom}
	default {return \#$v}
    }
}

proc exifvalues::ResolutionUnit {v} {
    switch $v {
	2 {return inches}
	3 {rerurn centimeters}
	default {return \#$v}
    }
}

proc exifvalues::YCbCrPositioning {v} {
    switch $v {
	1 {return centered}
	2 {return co-sited}
	default {return \#$v}
    }
}

proc exifvalues::MeteringMode {v} {
    switch $v {
	0 {return Unknown}
	1 {return Average}
	2 {return CenterWeightedAverage}
	3 {return Spot}
	4 {return MultiSpot}
	5 {return Pattern}
	6 {return Partial}
	default {return \#$v}
    }
}

proc exifvalues::LightSource {v} {
    switch $v {
	0 {return unknown}
	1 {return Daylight}
	2 {return Fluorescent}
	3 {return "Tungsten (incandescent light)"}
	4 {return Flash}
	9 {return "Fine weather"}
	10 {return "Cloudy weather"}
	11 {return "Shade"}
	12 {return "Daylight fluorescent (D 5700   7100K)"}
	13 {return "Day white fluorescent (N 4600   5400K)"}
	14 {return "Cool white fluorescent (W 3900   4500K)"}
	15 {return "White fluorescent (WW 3200   3700K)"}
	17 {return "Standard light A"}
	18 {return "Standard light B"}
	19 {return "Standard light C"}
	20 {return D55}
	21 {return D65}
	22 {return D75}
	23 {return D50}
	24 {return "ISO studio tungsten"}
	255 {return "other light source"}
	default {return \#$v}
    }
}

proc exifvalues::Flash {v} {
    switch $v {
	0 {return "no flash"}
	1 {return "flash fired"}
	5 {return "flash fired, strobe return light not detected"}
	7 {return "flash fired, strobe return light detected"}
	9 {return "Flash fired, compulsory flash mode "}
	13 {return "Flash fired, compulsory flash mode, return light not detected "}
	15 {return "Flash fired, compulsory flash mode, return light detected "}
	16 {return "Flash did not fire, compulsory flash mode "}
	24 {return "Flash did not fire, auto mode "}
	25 {return "Flash fired, auto mode "}
	29 {return "Flash fired, auto mode, return light not detected "}
	31 {return "Flash fired, auto mode, return light detected "}
	32 {return "No flash function "}
	65 {return "Flash fired, red-eye reduction mode "}
	69 {return "Flash fired, red-eye reduction mode, return light not detected "}
	71 {return "Flash fired, red-eye reduction mode, return light detected "}
	73 {return "Flash fired, compulsory flash mode, red-eye reduction mode "}
	77 {return "Flash fired, compulsory flash mode, red-eye reduction mode, return light not detected "}
	79 {return "Flash fired, compulsory flash mode, red-eye reduction mode, return light detected "}
	89 {return "Flash fired, auto mode, red-eye reduction mode "}
	93 {return "Flash fired, auto mode, return light not detected, red-eye reduction mode "}
	95 {return "Flash fired, auto mode, return light detected, red-eye reduction mode"}
	default {return \#$v}
    }
}

proc exifvalues::ColorSpace {v} {
    switch $v {
	1 {return sRGB}
	65535 {return Uncalibrated}
	default {return \#$v}
    }
}

proc exifvalues::XResolution {f} {
    return "[lindex $f 0]/[lindex $f 1]"
}

proc exifvalues::YResolution {f} {
    return "[lindex $f 0]/[lindex $f 1]"
}

proc exifvalues::ExposureTime {f} {
    return "1/[expr {double([lindex $f 1])/[lindex $f 0]}]"
}

proc exifvalues::FNumber {f} {
    return "[expr {double([lindex $f 0])/[lindex $f 1]}]"
}

proc exifvalues::CompressedBitsPerPixel {f} {
    return "[expr {double([lindex $f 0])/[lindex $f 1]}]"
}

proc exifvalues::ShutterSpeedValue {f} {
    return "1/2**[expr {double([lindex $f 0])/[lindex $f 1]}]"
}

proc exifvalues::ApertureValue {f} {
    return "2**([expr {double([lindex $f 0])/[lindex $f 1]}]/2)"
}

proc exifvalues::MaxApertureValue {f} {
    return "2**([expr {double([lindex $f 0])/[lindex $f 1]}]/2)"
}

proc exifvalues::FocalLength {f} {
    return "[expr {double([lindex $f 0])/[lindex $f 1]}]"
}

proc exifvalues::PixelXDimension {v} {return $v}

proc exifvalues::PixelYDimension {v} {return $v}

proc exifvalues::SensingMethod {v} {
    switch $v {
	1 {return "Not defined"}
	2 {return "One-chip color area sensor"}
	3 {return "Two-chip color area sensor"}
	4 {return "Three-chip color area sensor"}
	5 {return "Color sequential area sensor"}
	7 {return "Trilinear sensor"}
	8 {return "Color sequential linear sensor"}
	default {return \#$v}
    }
}

proc exifvalues::FileSource {v} {
        switch $v {
	3 {return "DSC"}
	default {return \#$v}
    }
}

proc exifvalues::SceneType {v} {
        switch $v {
	1 {return "A directly photographed image"}
	default {return \#$v}
    }
}

proc exifvalues::CustomRendered {v} {
    switch $v {
	0 {return "Normal process"}
	1 {return "Custom process"}
	default {return \#$v}
    }
}

proc exifvalues::ExposureMode {v} {
    switch $v {
	0 {return "Auto"}
	1 {return "Manual"}
	2 {return "Auto bracket"}
	default {return \#$v}
    }
}

proc exifvalues::WhiteBalance {v} {
    switch $v {
	0 {return "Auto"}
	1 {return "Manual"}
	default {return \#$v}
    }
}

proc exifvalues::DigitalZoomRatio {f} {
    return "[expr {double([lindex $f 0])/[lindex $f 1]}]"
}

proc exifvalues::FocalLength35mmFilm {v} {
    if {$v == 0} {
	return unknown
    } else {
	return $v
    }
}

proc exifvalues::SceneCaptureType {v} {
    switch $v {
	0 {return "Standard"}
	1 {return "Landscape"}
	2 {return "Portrait"}
	3 {return "Night scene"}
	default {return \#$v}
    }
}

proc exifvalues::GainControl {v} {
    switch $v {
	0 {return "None"}
	1 {return "Low gain up"}
	2 {return "High gain up"}
	3 {return "Low gain down"}
	4 {return "High gain down"}
	default {return \#$v}
    }
}

proc exifvalues::Contrast {v} {
    switch $v {
	0 {return "Normal"}
	1 {return "Soft"}
	2 {return "Hard"}
	default {return \#$v}
    }
}

proc exifvalues::Saturation {v} {
    switch $v {
	0 {return "Normal"}
	1 {return "Low saturation"}
	2 {return "High saturation"}
	default {return \#$v}
    }
}

proc exifvalues::Sharpness {v} {
    switch $v {
	0 {return "Normal"}
	1 {return "Soft"}
	2 {return "Hard"}
	default {return \#$v}
    }
}

proc exifvalues::SubjectDistanceRange {v} {
    switch $v {
	0 {return "unknown"}
	1 {return "Macro"}
	2 {return "Close view"}
	3 {return "Distant view"}
	default {return \#$v}
    }
}




array set EXIFTYPE {
    271 Make
    272 Model
    274 Orientation
    282 XResolution
    283 YResolution
    296 ResolutionUnit
    305 Software
    306 DateTime
    531 YCbCrPositioning
    34665 ExifIFDPointer
    33434 ExposureTime
    33437 FNumber
    34859 ExposureProgram
    33855 ExposureSpeedRating
    36864 ExifVersion
    36867 DateTimeOriginal
    36868 DateTimeDigitized
    37121 ComponentsConfiguration
    37122 CompressedBitsPerPixel
    37377 ShutterSpeedValue
    37378 ApertureValue
    37380 ExposureBiasValue
    37381 MaxApertureValue
    37383 MeteringMode
    37384 LightSource
    37385 Flash
    37386 FocalLength
    37500 MakerNote
    40960 FlashPixVersion
    40961 ColorSpace
    40962 PixelXDimension
    40963 PixelYDimension
    40965 InteroperabilityIFDPointer
    41495 SensingMethod
    41728 FileSource
    41729 SceneType
    41730 CFAPattern
    41985 CustomRendered
    41986 ExposureMode
    41987 WhiteBalance
    41988 DigitalZoomRatio
    41989 FocalLength35mmFilm
    41990 SceneCaptureType
    41991 GainControl
    41992 Contrast
    41993 Saturation 
    41994 Sharpness
    41996 SubjectDistanceRange
}


array set EXIFMARKERS {e1 APP1 e2 APP2 db DQT c4 DHT dd DRI c0 SOF da SOS d9 EOI}


proc readJpeg {filename listName} {
    global EXIFMARKERS
    upvar $listName list
    set img [open $filename r]
    fconfigure $img -translation binary -encoding binary

    # read in first two bytes
    binary scan [read $img 2] "H4" byte1
    # check to see if this is a JPEG, all JPEGs start with "ffd8", make
    # that SHOULD start with
    if {$byte1!="ffd8"} {
	close $img
	return -code error "Error! $filename is not a valid JPEG file!"
    }

    set rlist [list d8]
    set list [list {}]
    # cool, it's a JPG so let's loop through the whole file until we
    # find the next marker.
    while {![eof $img]} {

	while {$byte1!="ff"} {
	    binary scan [read $img 1] "H2" byte1
	}
	
	# we found the next marker, now read in the marker type byte,
	# throw out any extra "ff"'s
	while {$byte1=="ff"} {
	    binary scan [read $img 1] "H2" byte1
	}
	
	binary scan [read $img 2] "S" offset
	# the offset includes its own two bytes so we need to subtract
	# them
	set offset [expr {$offset -2}]
	# read ahead to the next marker
	
	if {[info exists EXIFMARKERS($byte1)]} {
	    set bn $EXIFMARKERS($byte1)
	} else {
	    set bn $byte1
	}
	puts stderr "$bn $offset"
	if {$offset < 0} break
	
	lappend rlist $byte1
	lappend list [read $img $offset]
    } ;# end while
    return $rlist
 } ;# end proc


proc readApp1 {data} {
    if {[string range $data 0 4] != "Exif\0"} {
	return -code error "Not an exif"
    }
    set tiff [string range $data 6 end]
   return $tiff
#    readTiff $tiff
}

proc readTiff {tiff} {
    global KNOWNVAL UNKNOWNVAL
    set byteOrder [string range $tiff 0 1]
    if {$byteOrder == "II"} {
	# little endian
	set i2 s
	set i4 i

    } elseif {$byteOrder == "MM"} {
	# big endian
	set i2 S
	set i4 I
    } else {
	return -code error "Bad byte order"
    }
    binary scan [string range $tiff 2 2] "c" s42
    if {$s42 != 42} {
	return -code error "missing 42"
    }
    binary scan [string range $tiff 4 7] $i2 offsetOfIFD
    puts stderr $offsetOfIFD

    readBlocsII $tiff $offsetOfIFD
    if {[info exists KNOWNVAL(ExifIFDPointer)]} {
	readBlocsII $tiff $KNOWNVAL(ExifIFDPointer)
    }
    if {[info exists KNOWNVAL(InteroperabilityIFDPointer)]} {
	readBlocsII $tiff $KNOWNVAL(InteroperabilityIFDPointer)
    }
}

proc readBlocsII {tiff offset} {
    global EXIFTYPE
    global KNOWNVAL UNKNOWNVAL
    binary scan [string range $tiff $offset [expr {$offset + 1}]] s1 N
    set next [expr {$offset + 2}]
    for {set i 0} {$i < $N} {incr i} {
	set r [readIFD_II $tiff $next]
	set tag [lindex $r 0]
	set type [lindex $r 1] ;# 1 byte 2 ascii 3 short 4 long 5 rational 7 undefined 9 slong 10 srational
	set count [lindex $r 2]
	set offset [lindex $r 3]
	# puts stderr " $tag $type $count $offset"
	switch $type {
	    1 {
		set bloc [readByte $tiff $count $offset]
	    }
	    2 {
		set bloc [readAscii $tiff $count $offset]
	    }
	    3 {
		set bloc [readShortII $tiff $count $offset]
	    }
	    4 {
		set bloc [readLongII $tiff $count $offset]
	    }
	    5 {
		set bloc [readRationalII $tiff $count $offset]
	    }
	    7 {
		set bloc [readByte $tiff $count $offset]
	    }
	    9 {
		set bloc [readSLongII $tiff $count $offset]
	    }
	    10 {
		set bloc [readSRationalII $tiff $count $offset]
	    }
	    default {
		return -code error "type \"$type\" inconnu"
	    }
	}
	

	if {[info exists EXIFTYPE($tag)]} {
	    set tn $EXIFTYPE($tag)
	    if {[info command exifvalues::$tn] != ""} {
	        if {[llength $bloc] != 1} {
		    return -code error "longueur [llength $bloc] pour $tn"
		}
		set value [exifvalues::$tn [lindex $bloc 0]]
	    } else {
		puts  -nonewline stderr "! "
		set value $bloc
	    }
	    set KNOWNVAL($tn) $value
	} else {
	    set tn TAG\#$tag
	    set value $bloc
	    set UNKNOWNVAL($tn) $value
	}

	puts stderr "$tn = $value"
	set next [lindex $r end]
    }
}

proc readIFD_II {tiff offset} {
    set a $offset
    set b [expr {$a + 1}]
    binary scan [string range $tiff $a $b] s tag
    set tag [expr {$tag & 0xffff}]
    set a [expr {$b + 1}]
    set b [expr {$a + 1}]
    binary scan [string range $tiff $a $b] s type
    set a [expr {$b + 1}]
    set b [expr {$a + 3}]
    binary scan [string range $tiff $a $b] i count
    set a [expr {$b + 1}]
    set b [expr {$a + 3}]
    binary scan [string range $tiff $a $b] i offset
    set a [expr {$b + 1}]
    return [list $tag $type $count $offset $a]
}

# lire immediatement si rentre dans 4 octets

proc readByte {tiff count offset} {
    set ret [list]
    if {$count <= 4} {
	if {$count >= 1} {
	    lappend ret [expr {$offset & 0xff}]
	    if {$count >= 2} {
		lappend ret [expr {($offset >> 4) & 0xff}]
		if {$count >= 3} {
		    lappend ret [expr {($offset >> 8) & 0xff}]
		    if {$count >= 4} {
			lappend ret [expr {($offset >> 12) & 0xff}]
		    }
		}
	    }
	}
    } else {
	set a $offset
	set b [expr {$offset + $count}]
	for {set i $a} {$i < $b} {incr i} {
	    binary scan [string index $tiff $i] c1 v
	    lappend ret [expr {$v & 0xff}]
	}
    }
    return $ret
}

proc readAscii {tiff count offset} {
    if {$count <= 4} {
	return "A FAIRE"
    } else {
	binary scan [string range $tiff $offset [expr {$offset - 1 + $count}]] a$count ret
    }
    return $ret
}

proc readShortII {tiff count offset} {
    set ret [list]
    if {$count <= 2} {
	if {$count >= 1} {
	    lappend ret [expr {$offset & 0xffff}]
	    if {$count >= 2} {
		lappend ret [expr {($offset >> 8) & 0xffff}]
	    }
	}
    } else {
	set a $offset
	set b [expr {$a + 2*$count}]
	set ret [list]
	for {set i $a} {$i < $b} {incr i 2} {
	    binary scan [string range $tiff $i [expr {$i + 1}]] s1 v
	    lappend ret [expr {$v & 0xffff}]
	}
    }
    return $ret
}

proc readLongII {tiff count offset} {
    if {$count == 1} {
	set ret [expr {wide($offset) & 0xffffffff}]
    } else {
	set a $offset
	set b [expr {$a + 4*$count}]
	set ret [list]
	for {set i $a} {$i < $b} {incr i 4} {
	    binary scan [string range $tiff $i [expr {$i + 3}]] i1 v
	    lappend ret [expr {wide($v) & 0xffffffff}]
	}
    }
    return $ret
}

proc readRationalII {tiff count offset} {
    set a $offset
    set b [expr {$a + 8*$count}]
    set ret [list]
    for {set i $a} {$i < $b} {incr i 8} {
	binary scan [string range $tiff $i [expr {$i+3}]] i1 v1
	binary scan [string range $tiff [expr {$i+4}] [expr {$i+7}]] i1 v2
	lappend ret [list [expr {wide($v1) & 0xffffffff}] [expr {wide($v2) & 0xffffffff}]]
    }
    return $ret
}

proc readSLongII {tiff count offset} {
    if {$count == 1} {
	set ret $offset
    } else {
	binary scan [string range $tiff $offset [expr {$offset - 1 + 4*$count}]] i$count ret
    }
    return $ret
}

proc readSRationalII {tiff count offset} {
    set a $offset
    set b [expr {$a + 8*$count}]
    set ret [list]
    for {set i $a} {$i < $b} {incr i 8} {
	binary scan [string range $tiff $i [expr {$i+3}]] i1 v1
	binary scan [string range $tiff [expr {$i+4}] [expr {$i+7}]] i1 v2
	lappend ret [list $v1 $v2]
    }
    return $ret
}


set jpeg [readJpeg $filename l]
set tiff [readApp1 [lindex $l 1]]
readTiff $tiff

bb

# set jpeg [read -nonewline $f] ; close $f

# ISO DIS 10918-1
# format JFIF

set SOI  "\xff\xd8" ;# start of image
set APP1 "\xff\xe1" ;# application segment 1
set APP2 "\xff\xe2" ;# application segment 2
set DQT  "\xff\xdb" ;# define quantization table
set DRI  "\xff\xdd" ;# define huffmann table
set SOF  "\xff\xc0" ;# start of frame
set SOS  "\xff\xda" ;# start of scan
set EOI  "\xff\xd9" ;# end of image

set start [string range $jpeg 0 1]
if {$start != $SOI} {
    return -code error "bad SOI"
}

