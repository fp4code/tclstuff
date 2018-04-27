
set titi [tiff::open /net/l2m/disk2/home/Stable/fab/Y/Pritchard/p440.tiff]
puts "stripSize = [tiff::query stripSize $titi]"

foreach tag {ARTIST\
        BADFAXLINES\
        BITSPERSAMPLE\
        CLEANFAXDATA\
        COLORMAP\
        COMPRESSION\
        CONSECUTIVEBADFAXLINES\
        DATATYPE\
        DATETIME\
        DOCUMENTNAME\
        DOTRANGE\
        EXTRASAMPLES\
        FAXMODE\
        FAXFILLFUNC\
        FILLORDER\
        GROUP3OPTIONS\
        GROUP4OPTIONS\
        HALFTONEHINTS\
        HOSTCOMPUTER\
        IMAGEDEPTH\
        IMAGEDESCRIPTION\
        IMAGELENGTH\
        IMAGEWIDTH\
        INKNAMES\
        INKSET\
        JPEGTABLES\
        JPEGQUALITY\
        JPEGCOLORMODE\
        JPEGTABLESMODE\
        MAKE\
        MATTEING\
        MAXSAMPLEVALUE\
        MINSAMPLEVALUE\
        MODEL\
        ORIENTATION\
        PAGENAME\
        PAGENUMBER\
        PHOTOMETRIC\
        PLANARCONFIG\
        PREDICTOR\
        PRIMARYCHROMATICITIES\
        REFERENCEBLACKWHITE\
        RESOLUTIONUNIT\
        ROWSPERSTRIP\
        SAMPLEFORMAT\
        SAMPLESPERPIXEL\
        SMAXSAMPLEVALUE\
        SMINSAMPLEVALUE\
        SOFTWARE\
        STONITS\
        STRIPBYTECOUNTS\
        STRIPOFFSETS\
        SUBFILETYPE\
        SUBIFD\
        TARGETPRINTER\
        THRESHHOLDING\
        TILEBYTECOUNTS\
        TILEDEPTH\
        TILELENGTH\
        TILEOFFSETS\
        TILEWIDTH\
        TRANSFERFUNCTION\
        WHITEPOINT\
        XPOSITION\
        XRESOLUTION\
        YCBCRCOEFFICIENTS\
        YCBCRPOSITIONING\
        YCBCRSUBSAMPLING\
        YPOSITION\
        YRESOLUTION\
        ICCPROFILE} {
    set err [catch {tiff::getField $tag tiff1} message]
    puts "$tag = $message"
}
