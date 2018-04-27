#!/bin/sh
#\
exec tclsh8.4 "$0" ${1+"$@"}

set filenames $argv

namespace eval exifvalues {}

# ImageWidth ImageLength BitsPerSample

array set exifvalues::Compression {
    1 uncompressed
    6 "JPEG compression (thumbnails only)"
}

array set exifvalues::PhotometricInterpretation {
    2 RGB
    6 YCbCr
}

array set exifvalues::Orientation {
    default 1
    1 top-left
    2 top-right
    3 bottom-right
    4 bottom-left
    5 left-top
    6 right-top
    7 right-bottom
    8 left-bottom
}

# SamplesPerPixel

array set exifvalues::PlanarConfiguration {
    1 "chunky format"
    2 "planar format"
}

# YCbCrSubSampling

array set exifvalues::YCbCrPositioning {
    default 1
    1 centered
    2 co-sited
}

proc exifvalues::XResolution {f} {
    return "[lindex $f 0]/[lindex $f 1]"
}

proc exifvalues::YResolution {f} {
    return "[lindex $f 0]/[lindex $f 1]"
}

# JPEGInterchangeFormatLength 

# C. Tags Relating to Image Data Characteristics

# TransferFunction WhitePoint PrimaryChromaticities YCbCrCoefficients ReferenceBlackWhite

array set exifvalues::ResolutionUnit {
    2 inches
    3 centimeters
}

array set exifvalues::YCbCrPositioning {
    1 centered
    2 co-sited
}

array set exifvalues::MeteringMode {
    0 Unknown
    1 Average
    2 CenterWeightedAverage
    3 Spot
    4 MultiSpot
    5 Pattern
    6 Partial
}

array set exifvalues::LightSource {
    0 unknown
    1 Daylight
    2 Fluorescent
    3 "Tungsten (incandescent light)"
    4 Flash
    9 "Fine weather"
    10 "Cloudy weather"
    11 "Shade"
    12 "Daylight fluorescent (D 5700   7100K)"
    13 "Day white fluorescent (N 4600   5400K)"
    14 "Cool white fluorescent (W 3900   4500K)"
    15 "White fluorescent (WW 3200   3700K)"
    17 "Standard light A"
    18 "Standard light B"
    19 "Standard light C"
    20 D55
    21 D65
    22 D75
    23 D50
    24 "ISO studio tungsten"
    255 "other light source"
}

array set exifvalues::Flash {
    0 "no flash"
    1 "flash fired"
    5 "flash fired, strobe return light not detected"
    7 "flash fired, strobe return light detected"
    9 "Flash fired, compulsory flash mode "
    13 "Flash fired, compulsory flash mode, return light not detected "
    15 "Flash fired, compulsory flash mode, return light detected "
    16 "Flash did not fire, compulsory flash mode "
    24 "Flash did not fire, auto mode "
    25 "Flash fired, auto mode "
    29 "Flash fired, auto mode, return light not detected "
    31 "Flash fired, auto mode, return light detected "
    32 "No flash function "
    65 "Flash fired, red-eye reduction mode "
    69 "Flash fired, red-eye reduction mode, return light not detected "
    71 "Flash fired, red-eye reduction mode, return light detected "
    73 "Flash fired, compulsory flash mode, red-eye reduction mode "
    77 "Flash fired, compulsory flash mode, red-eye reduction mode, return light not detected "
    79 "Flash fired, compulsory flash mode, red-eye reduction mode, return light detected "
    89 "Flash fired, auto mode, red-eye reduction mode "
    93 "Flash fired, auto mode, return light not detected, red-eye reduction mode "
    95 "Flash fired, auto mode, return light detected, red-eye reduction mode"
}

array set exifvalues::ColorSpace {
    1 sRGB
    65535 Uncalibrated
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

array set exifvalues::SensingMethod {
    1 "Not defined"
    2 "One-chip color area sensor"
    3 "Two-chip color area sensor"
    4 "Three-chip color area sensor"
    5 "Color sequential area sensor"
    7 "Trilinear sensor"
    8 "Color sequential linear sensor"
}

array set exifvalues::FileSource {
    3 "DSC"
}

array set exifvalues::SceneType {
    1 "A directly photographed image"
}

array set exifvalues::CustomRendered {
    0 "Normal process"
    1 "Custom process"
}

array set exifvalues::ExposureMode {
    0 "Auto"
    1 "Manual"
    2 "Auto bracket"
}

array set exifvalues::WhiteBalance {
    0 "Auto"
    1 "Manual"
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

array set exifvalues::SceneCaptureType {
    0 "Standard"
    1 "Landscape"
    2 "Portrait"
    3 "Night scene"
}

array set exifvalues::GainControl {
    0 "None"
    1 "Low gain up"
    2 "High gain up"
    3 "Low gain down"
    4 "High gain down"
}

array set exifvalues::Contrast {
    0 "Normal"
    1 "Soft"
    2 "Hard"
}

array set exifvalues::Saturation {
    0 "Normal"
    1 "Low saturation"
    2 "High saturation"
}

array set exifvalues::Sharpness {
    0 "Normal"
    1 "Soft"
    2 "Hard"
}

array set exifvalues::SubjectDistanceRange {
    0 "unknown"
    1 "Macro"
    2 "Close view"
    3 "Distant view"
}

proc exifvalues::value {bloc tn} {
    if {$tn == {}} {
	return -code error "tn vide"
    }
# puts stderr "exifvalues::$tn -> [info commands ::exifvalues::$tn]"
    if {[info command ::exifvalues::$tn] != ""} {
	if {[llength $bloc] != 1} {
	    return -code error "longueur [llength $bloc] pour $tn"
	}
	set value [::exifvalues::$tn [lindex $bloc 0]]
    } elseif {[info exists exifvalues::$tn]} {
	if {[llength $bloc] != 1} {
	    return -code error "longueur [llength $bloc] pour $tn"
	}
	set v [lindex $bloc 0]
	if {[info exists exifvalues::[set tn]($v)]} {
	    set value [set exifvalues::[set tn]($v)]
	} else {
	    set value \#$v
	}
    } else {
	puts  -nonewline stderr "! "
	set value $bloc
    }
    return $value
}

# Cf. p. 30 

array set EXIFTYPE {
    256 {ImageWidth A short_or_long 1}
    257 {ImageLength A short_or_long 1}
    258 {BitsPerSample A short 3}
    259 {Compression A short 1}
    262 {PhotometricInterpretation A short 1}   
    270 {ImageDescription D ascii any}
    271 {Make D ascii any}
    272 {Model D ascii any}
    273 {StripOffsets B short_or_long *S}
    274 {Orientation A short 1}
    277 {SamplesPerPixel A short 1}
    278 {RowsPerStrip B short_or_long 1}
    279 {StripByteCounts B short_or_long *S}
    282 {XResolution A rational 1}
    283 {YResolution A rational 1}
    284 {PlanarConfiguration A short 1}
    296 {ResolutionUnit A short 1}
    301 {TransferFunction C short 3*256}
    305 {Software D ascii any}
    306 {DateTime D ascii 20}
    305 {Artist D ascii any}
    318 {WhitePoint C rational 2}
    319 {PrimaryChromaticities C rational 6}
    513 {JPEGInterchangeFormat B long 1}
    514 {JPEGInterchangeFormatLength B long 1}
    529 {YCbCrCoefficients C rational 6}
    530 {YCbCrSubSampling A short 2}
    531 {YCbCrPositioning A short 1}
    532 {ReferenceBlackWhite C rational 6}
    33432 {Copyright D ascii any}
    33434 {ExposureTime G rational 1}
    33437 {FNumber G rational 1}
    34665 {ExifIFDPointer 0 long 1}
    34850 {ExposureProgram G short 1}
    34852 {SpectralSensitivity G ascii any}
    34853 {GPSInfoIFDPointer 0 long 1}
    34855 {ISOSpeedRatings G short any}
    34856 {OECF G undefined any}
    36864 {ExifVersion A undefined 4}
    36867 {DateTimeOriginal F ascii 20}
    36868 {DateTimeDigitized F ascii 20}
    37121 {ComponentsConfiguration C undefined 4}
    37122 {CompressedBitsPerPixel C rational 1}
    37377 {ShutterSpeedValue G srational 1}
    37378 {ApertureValue G rational 1}
    37379 {BrightnessValue G srational 1}
    37380 {ExposureBiasValue G srational 1}
    37381 {MaxApertureValue G rational 1}
    37382 {SubjectDistance G rational 1}
    37383 {MeteringMode G short 1}
    37384 {LightSource G short 1}
    37385 {Flash G short 1}
    37386 {FocalLength G rational 1}
    37396 {SubjectArea G short 2_or_3_or_4} 
    37500 {MakerNote D undefined any}
    37510 {UserComment D undefined any}
    37520 {SubSecTime F ascii any}
    37521 {SubSecTimeOriginal F ascii any}
    37522 {SubSecTimeDigitized F ascii any}
    40960 {FlashPixVersion A undefined 4}
    40961 {ColorSpace B short 1}
    40962 {PixelXDimension C short_or_long 1}
    40963 {PixelYDimension C short_or_long 1}
    40964 {RelatedSoundFile E ascii 13}
    40965 {InteroperabilityIFDPointer 0 long 1}
    41483 {FlashEnergy G rational 1}
    41484 {SpatialFrequencyResponse G undefined any}
    41486 {FocalPlaneXResolution G rational 1}
    41487 {FocalPlaneYResolution G rational 1}
    41488 {FocalPlaneResolutionUnit G short 1}
    41492 {SubjectLocation G short 2}
    41493 {ExposureIndex G rational 1}    
    41495 {SensingMethod G short 1}
    41728 {FileSource G undefined 1}
    41729 {SceneType G undefined 1}
    41730 {CFAPattern G undefined any}
    41985 {CustomRendered G short 1}
    41986 {ExposureMode G short 1}
    41987 {WhiteBalance G short 1}
    41988 {DigitalZoomRatio G rational 1}
    41989 {FocalLength35mmFilm G short 1}
    41990 {SceneCaptureType G short 1}
    41991 {GainControl G rational 1}
    41992 {Contrast G short 1}
    41993 {Saturation G short 1}
    41994 {Sharpness G short 1}
    41995 {DeviceSettingDescription G undefined any}
    41996 {SubjectDistanceRange G short 1}
    42016 {ImageUniqueID H ascii 33}
}

catch {unset x}
foreach n [array names EXIFTYPE] {
    set l $EXIFTYPE($n)
    if {[llength $l] != 4} {
	return -code error "Erreur pour [list $n $l]"
    }
    set name [lindex $l 0]
    if {[info exists x($name)]} {
	return -code error "Doublon pour [list $n $l]"
    }
    set x($name) {}
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
	    set tn [lindex $EXIFTYPE($tag) 0]
	    set value [exifvalues::value $bloc $tn]
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

proc exif {filename} {
    set jpeg [readJpeg $filename l]
    set tiff [readApp1 [lindex $l 1]]
    readTiff $tiff
    analyseJpeg $jpeg
}


proc analyseJpeg {jpeg} {
    return {}
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
}


foreach filename $filenames {
    puts stderr "\n$filename"
    set err [catch {exif $filename} m]
    if {$err} {
	puts stderr "$filename -> $m"
    }
}

