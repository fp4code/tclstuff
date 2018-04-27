# 2004-09-29 (FP)

set dsk [open /home/fab/Y/pdp/Cop_ra82_boot.dsk r]
fconfigure $dsk -encoding binary -translation binary

proc get_block {dsk bn} {
     seek $dsk [expr {512*$bn}] start
     return [read $dsk 512]
}

proc get_bootstrap_block {dsk} {
     return [get_block $dsk 0]
}

# on suppose qu'il n'y a pas de bad block
proc get_home_block {dsk} {
    set hb [get_block $dsk 1]

    set details {
	H.IBSZ 2 s {Index File Bitmap Size} { 
	    This  16-bit  word  contains the number of blocks that
	    make up the index file bitmap.  (The index file bitmap
	    is  discussed  in  section  5.1.4.) This value must be
	    non-zero for a valid home block.  
	}
	H.IBLB 4 i {Index File Bitmap LBN} { 
	    This  doubleword  contains  the starting logical block
	    address of the index file bitmap.  Once the home block
	    of  a  volume  has  been  found, it is this value that
	    provides access to the rest of the index file  and  to
	    the  volume.  The LBN is stored with the high order in
	    the first 16 bits, followed by the low order  portion.
	    This value must be non-zero for a valid home block.  
	}
	H.FMAX 2 s {Maximum Number of Files} { 
	    This  word  contains  the maximum number of files that
	    may be present on the volume at any time.  This  value
	    must be non-zero for a valid home block.  
	}
	H.SBCL 2 s {Storage Bitmap Cluster Factor} {
	    This  word  contains  the  cluster  factor used in the
	    storage bitmap file.  The cluster factor is the number
	    of  blocks  represented  by  each  bit  in the storage
	    bitmap.   Volume  clustering  is  not  implemented  in
	    ODS-1;  the only legal value for this item is 1.  
	}
	H.DVTY 2 s {Disk Device Type} {
	    This  word  is  an  index identifying the type of disk
	    that contains this volume.  It is currently  not  used
	    and always contains 0.  
	}
	H.VLEV 2 s {Volume Structure Level} { 
	    This  word  identifies  the  volume's structure level.
	    Like the file structure level,  this  word  identifies
	    the  version of Files-11 which created this volume and
	    permits upward  compatibility  of  media  as  Files-11
	    evolves.   The  volume  structure level is affected by
	    all portions of  the  Files-11  structure  except  the
	    contents  of the file header.  This document describes
	    Files-11 version 1;  the only  legal  values  for  the
	    structure  level  are  401  and 402 octal.  The former
	    (401) is the standard value  for  most  volumes.   The
	    latter (402) is an advisory that the volume contains a
	    multiheader index file.  (A multiheader index file  is
	    required to support more than about 26,000 files.  The
	    index file may in  fact  be  multiheader  without  the
	    volume having a structure level of 402.) 
	}
	H.VNAM 12 a12 {Volume Name} { 
	    This  area  contains  the  volume  label  as  an ASCII
	    string.  It is padded out to 12 bytes with nulls.  The
	    volume  label  is used to identify individual Files-11
	    volumes.  
	}
	{} 4 x4 Unused {}
	H.VOWN 2 s {Volume Owner UIC} {
	    This  word contains the binary UIC of the owner of the
	    volume.  The format is the same as that  of  the  file
	    owner UIC stored in the file header.  
	}
	H.VPRO 2 s {Volume Protection Code} { 
	    This word contains the protection code for the entire
	    volume.  Its contents are coded in the same manner as
	    the  file  protection code stored in the file header,
	    and it is interpreted in the same way in  conjunction
	    with  the  volume  owner  UIC.  All operations on all
	    files on the volume must pass both the volume and the
	    file protection check to be permitted.  (Refer to the
	    discussion on file protection in section 3.4.1.7).  
	}
	H.VCHA 2 s {Volume Characteristics} {
	    This  word  contains  bits  which  provide additional
	    control over access to  the  volume.   The  following
	    bits are defined:  
	    
	    CH.NDC  Obsolete,  used  by  RSX-11D  /  IAS.  Set if
	    device control functions are not permitted on
	    this  volume.   Device  control functions are
	    those which can threaten the integrity of the
	    volume, such as direct reading and writing of
	    logical blocks, etc.  
	    
	    CH.NAT  Obsolete,  used by RSX-11D / IAS.  Set if the
            volume may not be  attached,  i.e.,  reserved
            for exclusive use by one task.  
	    
	    CH.SDI  Set  if  the  volume  contains  only a single
            directory.   If   this   bit   is   set,   no
            directories  should  be created on the volume
            other  than  the  MFD.   The  access  methods
            should  also  be  informed of this situation,
            e.g.  by setting the DV.SDI bit  in  the  UCB
            device characteristics word.  
	}
	H.DFPR 2 s {Default File Protection} {
	    This  word  contains  the  file  protection  that  is
	    assigned to all files created on this  volume  if  no
	    file protection is specified by the user.  
	}
	{} 6 x6 Unused {}
	H.WISZ 1 c {Default Window Size} {
	    This  word  contains the number of retrieval pointers
	    used for the "window" (in-memory  file  access  data)
	    when  files  are  accessed  on  the  volume,  if  not
	    otherwise specified by the accessor.  
	}
	H.FIEX 1 c {Default File Extend} { 
	    This  byte  contains  the  number  of blocks that are
	    allocated to a file when a user extends the file  and
	    asks for the system default value for allocation.  
	}
	H.LRUC 1 c {Directory Pre-Access Limit} { 
	    This   byte   contains  a  count  of  the  number  of
	    directories  to  be  stored  in  the  file   system's
	    directory  access  cache.   More  generally, it is an
	    estimate of the number of  concurrent  users  of  the
	    volume, and its use may be generalized in the future. 
	}
	H.REVD 7 a7 {Date of Last Home Block Revision} { 
	    This  field  (ill  defined  field) is in the standard
	    ASCII date format and reflects the date of  the  last
	    modifications to fields in the home block.  
	}
	H.REVC 2 s {Count of Home Block Revisions} {
	    This  field  reflects  the  number of above mentioned
	    modifications.
	}
	{} 2 x2 Unused {}
	H.CHK1 2 s {First Checksum} {
	    This  word  is  an  additive  checksum of all entries
	    preceding in the home block (i.e., all  those  listed
					 above).  It is computed by the same sort of algorithm
	    as the file header checksum (see section 3.4.4.1).  
	}
	H.VDAT 14 a14 {Volume Creation Date} {
	    This  area contains the date and time that the volume
	    was   initialized.    It    is    in    the    format
	    "DDMMMYYHHMMSS",  followed  by  a  single null.  (The
	    same format is used in the ident  area  of  the  file
	    header, section 3.4.2).  
	}
	{} 382 x382 Unused {
	    This  area is reservied for the relative volume table
	    for volume sets.  This field is  not  used,  although
	    some versions of DSC referred to this area.  
	}
	H.PKSR 4 i {Pack Serial Number} { 
	    This  area  contains the manufacturer supplied serial
	    number for  the  physical  volume.   For  last  trace
	    devices,  the  pack serial number is contained on the
	    volume in the manufacturer data.  For  other  devices
	    the  user must supply this information manually.  The
	    serial number is contained  in  the  home  block  for
	    convenience and consistency.  
	}
	{} 12 x12 Unused  {}
	H.INDN 12 a12 {Volume Name} { 
	    This  area  contains another copy of the ASCII volume
	    label.  It is padded out to 12 bytes with spaces.  It
	    is   placed   here  in  accordance  with  the  volume
	    identification standard (STD 167).  
	}
	H.INDO 12 a12 {Volume Owner} { 
	    This  area  contains an ASCII expansion of the volume
	    owner UIC in the form  "[proj,prog]".   Both  numbers
	    are  expressed  in  decimal  and  are padded to three
	    digits with leading zeroes.  The area is  padded  out
	    to  12 bytes with trailing spaces.  It is placed here
	    in accordance with the volume identification standard
	    (STD 167).  
	}
	H.INDF 12 a12 {Format Type} { 
	    This  field  contains  the  ASCII string "DECFILE11A"
	    padded out to 12 bytes with  spaces.   It  identifies
	    the volume as being of Files-11 format.  It is placed
	    here in accordance  with  the  volume  identification
	    standard (STD 167).  
	}
	{} 2 x2 Unused {}
	H.CHK2 2 s {Second Checksum} { 
	    This  word  is  the  last word of the home block.  It
	    contains an additive checksum of  the  preceding  255
	    words  of  the  home block, computed according to the
	    algorithm in section 3.4.4.1.  
	}
    }
    set format {}
    set vars [list]
    set S [list]
    set C [list]
    set entries [list]
    foreach {a b c d e} $details {
	append format $c
	if {$a == {}} {
	    continue
	}
	if {[string range $a 0 1] != "H."} {
	    return -code error "error for \"$a\""
	}
	set aa [string range $a 2 end]
	lappend entries $aa
	lappend vars H($aa)
	set short_H($aa) $d
	set long_H($aa) $e
	if {$c == "s"} {
	    lappend S $aa
	} elseif {$c == "c"} {
	    lappend C $aa
	}
    }
    eval [list binary scan $hb $format] $vars

    foreach p {VNAM INDN INDO INDF VDAT} {
	set n [string first \0 $H($p)]
	if {$n >= 0} {
	    incr n -1
	    set H($p) [string range $H($p) 0 $n]
	}
    }
    foreach p $S {
	set H($p) [expr {$H($p) & 0xffff}]
    }
    foreach p $C {
	set H($p) [expr {$H($p) & 0xff}]
    }

    binary scan $hb s255 s_list
    set check 0
    foreach s $s_list {
	set check [expr {$check + (0xffff & $s)}]
    }
    if {($check & 0xffff) != $H(CHK2)} {
	return -code error "H.CHK2 error"
    } else {
	puts stderr "H.CHK2 OK"
    }
    if {$H(SBCL) != 1} {
	return code error "Not legal H.SBCL value: $H(SBCL)"
    }
    return [list $entries [array get H] [array get short_H] [array get long_H]]
}

set hb [get_home_block $dsk]
set entries [lindex $hb 0]
array set H [lindex $hb 1]
array set short_H [lindex $hb 2]
array set long_H [lindex $hb 3]


set w 0
foreach k $entries {
    set ww [string length $short_H($k)]
    if {$ww > $w} {
	set w $ww
    }
}
foreach k $entries {
    puts [format "%-${w}s  %4s %s" $short_H($k) $k $H($k)]
}
