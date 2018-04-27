# 29 octobre 1999
# basé sur "AutoCAD 2000 DXF Reference-v.u15.0.02 "
# Cf. http://www.autodesk.com/techpubs/autocad/dxf/

package require fidev
package require fidev_zinzout

set FICHIER /home/fab/Y/D1Niv2.dxf
# set FICHIER batd2.dxf

namespace eval dxf {
    variable HEADERVARS
    set HEADERVARS(ACADMAINTVER) [list 70 "Maintenance version number (should be ignored)"]
    set HEADERVARS(ACADVER)      [list  1 "The AutoCAD drawing database version number:" [list AC1006 R10 AC1009 "R11 and R12" AC1012 R13 AC1014 R14 AC1500 "AutoCAD 2000"]]
    set HEADERVARS(ANGBASE)      [list  50 "Angle 0 direction"]
    set HEADERVARS(ANGDIR)       [list  70 {} [list 1 Clockwise angles 0 Counterclockwise]]
    set HEADERVARS(ATTMODE)      [list  70 "Attribute visibility:" [list 0 None 1 Normal 2 All]]
    set HEADERVARS(AUNITS)       [list  70 "Units format for angles"]

    set HEADERVARS(AUPREC)       [list  70 "Units precision for angles"]
    set HEADERVARS(CECOLOR)      [list  62 "Current entity color number:" [list 0 BYBLOCK 256 BYLAYER]]
    set HEADERVARS(CELTSCALE)    [list  40 "Current entity linetype scale" ]
    set HEADERVARS(CELTYPE)      [list   6 "Entity linetype name, or BYBLOCK or BYLAYER"]
    set HEADERVARS(CELWEIGHT)    [list 370 "Lineweight of new objects"]
    set HEADERVARS(CPSNID)       [list 390 "Plotstyle handle of new objects. If CEPSNTYPE is 3, then this value indicates the handle"]
    set HEADERVARS(CEPSNTYPE)   [list 380 "Plotstyle type of new objects:" [list\
	    0 "PlotStyle by layer"\
	    1 "PlotStyle by block"\
	    2 "PlotStyle by dictionary default"\
	    3 "PlotStyle by object ID/handle"]]
    set HEADERVARS(CHAMFERA)     [list  40 "First chamfer distance"]
    set HEADERVARS(CHAMFERB)     [list 40 Second chamfer distance"]
    set HEADERVARS(CHAMFERC)     [list 40 Chamfer length"]
    set HEADERVARS(CHAMFERD)     [list 40 "Chamfer angle"]
    set HEADERVARS(CLAYER)       [list 8 "Current layer name"]
    set HEADERVARS(CMLJUST)      [list 70 "Current multiline justification:" [list 0 Top 1 Middle 2 Bottom]]
    set HEADERVARS(CMLSCALE)     [list 40 "Current multiline scale"]
    set HEADERVARS(CMLSTYLE)     [list 2 "Current multiline style name"]
    set HEADERVARS(DIMADEC)     [list 70 "Number of precision places displayed in angular dimensions"]
    set HEADERVARS(DIMALT)       [list 70 "Alternate unit dimensioning performed if nonzero"]
    set HEADERVARS(DIMALTD)      [list 70 "Alternate unit decimal places"]
    set HEADERVARS(DIMALTF)      [list 40 "Alternate unit scale factor"]
    set HEADERVARS(DIMALTRND)    [list 40 "Determines rounding of alternate units"]
    set HEADERVARS(DIMALTTD)     [list 70 "Number of decimal places for tolerance values of an alternate units dimension"]
    set HEADERVARS(DIMALTTZ)     [list 70 "Controls suppression of zeros for alternate tolerance values:" [list\
	    0 "Suppresses zero feet and precisely zero inches"\
	    1 "Includes zero feet and precisely zero inches"\
	    2 "Includes zero feet and suppresses zero inches"\
	    3 "Includes zero inches and suppresses zero feet"]]
    set HEADERVARS(DIMALTU)      [list 70 "Units format for alternate units of all dimension style family members except angular:" [list\
	    1 Scientific\
	    2 Decimal\
	    3 Engineering\
            4 "Architectural (stacked)"\
	    5 "Fractional (stacked)"\
            6 "Architectural"\
            7 "Fractional"]]
    set HEADERVARS(DIMALTZ)       [list 70 "Controls suppression of zeros for alternate unit dimension values:" [list\
	    0 "Suppresses zero feet and precisely zero inches"\
	    1 "Includes zero feet and precisely zero inches"\
	    2 "Includes zero feet and suppresses zero inches"\
	    3 "Includes zero inches and suppresses zero feet"]]
    set HEADERVARS(DIMAPOST)       [list 1 "Alternate dimensioning suffix"]
    set HEADERVARS(DIMASO)         [list 70 {} [list 1 "Create associative dimensioning" 0 "Draw individual entities"]]
    set HEADERVARS(DIMASZ)         [list 40 "Dimensioning arrow size"]
    set HEADERVARS(DIMATFIT)      [list 70 "Controls dimension text and arrow placement when space is not sufficient to place both within the extension lines. AutoCAD adds a leader to moved dimension text when DIMTMOVE is set to 1:" [list\
	    0 "Places both text and arrows outside extension lines"\
	    1 "Moves arrows first, then text"\
	    2 Moves text first, then arrows\
	    3 "Moves either text or arrows, whichever fits best"]]
    set HEADERVARS(DIMAUNIT)       [list 70 "Angle format for angular dimensions:" [list\
	    0 "Decimal degrees"\
	    1 "Degrees/minutes/seconds"\
	    2 "Gradians"\
	    3 "Radians"\
	    4 "Surveyor's units"]]
    set HEADERVARS(DIMAZIN) [list 70 "Controls suppression of zeros for angular dimensions:" [list\
	    0 "Displays all leading and trailing zeros"\
	    1 "Suppresses leading zeros in decimal dimensions"\
	    2 "Suppresses trailing zeros in decimal dimensions "\
	    3 "Suppresses leading and trailing zeros"]]
    set HEADERVARS(DIMBLK)  [list   1 "Arrow block name"]
    set HEADERVARS(DIMBLK1  [list   1 "First arrow block name"]
    set HEADERVARS(DIMBLK2) [list   1 "Second arrow block name"]
    set HEADERVARS(DIMCEN)  [list  40 "Size of center mark/lines"]
    set HEADERVARS(DIMCLRD) [list 70 "Dimension line color, range is 0 BYBLOCK, 256 BYLAYER"]
    set HEADERVARS(DIMCLRE) [list 70 "Dimension extension line color, range is 0 BYBLOCK, 256 BYLAYER"]
    set HEADERVARS(DIMCLRT) [list 70 "Dimension text color, range is 0 BYBLOCK, 256 BYLAYER"]
    set HEADERVARS(DIMDEC)  [list 70 "Number of decimal places for the tolerance values of a primary units dimension"]
    set HEADERVARS(DIMDLE)  [list 40 "Dimension line extension"]
    set HEADERVARS(DIMDLI)  [list 40 "Dimension line increment"]
    set HEADERVARS(DIMDSEP) [list 70 "Single-character decimal separator used when creating dimensions whose unit format is decimal"]
    set HEADERVARS(DIMEXE)  [list 40 "Extension line extension"]
    set HEADERVARS(DIMEXO)  [list 40 "Extension line offset"]
    set HEADERVARS(DIMFAC)  [list 40 "Scale factor used to calculate the height of text for dimension fractions and tolerances. AutoCAD multiplies DIMTXT by DIMTFAC to set the fractional or tolerance text height"]
    set HEADERVARS(DIMGAP)  [list 40 "Dimension line gap"]
    set HEADERVARS(DIMJUST) [list 70 "Horizontal dimension text position:" [list\
	    0 "Above dimension line and center-justified between extension lines"\
	    1 "Above dimension line and next to first extension line"\
	    2 "Above dimension line and next to second extension line"\
	    3 "Above and center-justified to first extension line"\
	    4 "Above and center-justified to second extension line"]]
    set HEADERVARS(DIMLDRBLK) [list  1 "Arrow block name for leaders"]
    set HEADERVARS(DIMLFAC)   [list  40 "Linear measurements scale factor"]
    set HEADERVARS(DIMLIM)    [list 70 "Dimension limits generated if nonzero"]
    set HEADERVARS(DIMLUNIT)  [list 70 "Sets units for all dimension types except Angular:" [list\
	    1 Scientific 2 Decimal 3 Engineering 4 Architectural 5 Fractional 6 "Windows desktop"]]
    set HEADERVARS(DIMLWD)    [list 70 "Dimension line lineweight -3 Standard -2 ByLayer -1 ByBlock 0-211 an integer representing 100th of mm"]
    set HEADERVARS(DIMLWE)    [list 70 "Extension line lineweight -3 Standard -2 ByLayer -1 ByBlock 0-211 an integer representing 100th of mm"]
    set HEADERVARS(DIMPOST)   [list  1 "General dimensioning suffix"]
    set HEADERVARS(DIMRND)    [list 40 "Rounding value for dimension distances"]
    set HEADERVARS(DIMSAH)    [list 70 "Use separate arrow blocks if nonzero"]
    set HEADERVARS(DIMSCALE)  [list 40 "Overall dimensioning scale factor"]
    set HEADERVARS(DIMSD1)    [list 70 "Suppression of first extension line:" [list  0 "Not suppressed" 1 Suppressed]]
    set HEADERVARS(DIMSD2)    [list 70 "Suppression of second extension line:" [list  0 "Not suppressed" 1 Suppressed]]
    set HEADERVARS(DIMSE1)    [list 70 "First extension line suppressed if nonzero"]
    set HEADERVARS(DIMSE2)    [list 70 "Second extension line suppressed if nonzero"]
    set HEADERVARS(DIMSHO)    [list 70 {} [list  1 "Recompute dimensions while dragging" 0 "Drag original image"]]
    set HEADERVARS(DIMSOXD)   [list 70 "Suppress outside-extensions dimension lines if nonzero"]
    set HEADERVARS(DIMSTYLE)  [list 2 "Dimension style name"]
    set HEADERVARS(DIMTAD)    [list 70 "Text above dimension line if nonzero"]
    set HEADERVARS(DIMTDEC)   [list 70 "Number of decimal places to display the tolerance values"]
    set HEADERVARS(DIMTFAC)   [list 40 "Dimension tolerance display scale factor"]
    set HEADERVARS(DIMTIH)    [list 70 "Text inside horizontal if nonzero"]
    set HEADERVARS(DIMTIX)    [list 70 "Force text inside extensions if nonzero"]
    set HEADERVARS(DIMTM)     [list 40 "Minus tolerance"]
    set HEADERVARS(DIMTMOVE)  [list 70 "Dimension text movement rules:" [list\
	    0 "Moves the dimension line with dimension text"\
	    1 "Adds a leader when dimension text is moved"\
	    2 "Allows text to be moved freely without a leader"]]
    set HEADERVARS(DIMTOFL)  [list 70 "If text is outside extensions, force line extensions between extensions if nonzero"]
    set HEADERVARS(DIMTOH)   [list 70 "Text outside horizontal if nonzero"]
    set HEADERVARS(DIMTOL)   [list 70 "Dimension tolerances generated if nonzero"]
    set HEADERVARS(DIMTOLJ)  [list 70 "Vertical justification for tolerance values:" [list  0 Top 1 Middle 2 Bottom]]
    set HEADERVARS(DIMTP)    [list 40 "Plus tolerance"]
    set HEADERVARS(DIMTSZ)   [list 40 "Dimensioning tick size, 0 = No ticks"]
    set HEADERVARS(DIMTVP)   [list 40 "Text vertical position"]
    set HEADERVARS(DIMTXSTY) [list  7 "Dimension text style"]
    set HEADERVARS(DIMTXT)   [list 40 "Dimensioning text height"]
    set HEADERVARS(DIMTZIN)  [list 70 "Controls suppression of zeros for tolerance values:" [list\
	    0 "Suppresses zero feet and precisely zero inches"\
	    1 "Includes zero feet and precisely zero inches"\
	    2 "Includes zero feet and suppresses zero inches"\
	    3 "Includes zero inches and suppresses zero feet"]]
    set HEADERVARS(DIMUPT) [list 70 "Cursor functionality for user positioned text:" [list\
	    0 "Controls only the dimension line location"\
	    1" Controls the text position as well as the dimension line location"]]
    set HEADERVARS(DIMZIN) [list 70 "Controls suppression of zeros for primary unit values:" [list\
	    0 "Suppresses zero feet and precisely zero inches"\
	    1 "Includes zero feet and precisely zero inches"\
	    2 "Includes zero feet and suppresses zero inches"\
	    3 "Includes zero inches and suppresses zero feet"]]
    set HEADERVARS(DISPSILH) [list 70  "Controls the display of silhouette curves of body objects in Wire-frame mode:" [list\
	    0 Off\
	    1 On]]
    set HEADERVARS(DWGCODEPAGE) [list 3 "Drawing code page; Set to the system code page when a new drawing is created, but not otherwise maintained by AutoCAD"]
    set HEADERVARS(ELEVATION)   [list 40 "Current elevation set by ELEV command"]
    set HEADERVARS(ENDCAPS)     [list 280 "Lineweight endcaps setting for new objects:" [list  0 none 1 round 2 angle 3 square]]
    set HEADERVARS(EXTMAX)      [list [list 10 20 30] "X, Y, and Z drawing extents upper-right corner (in WCS)"]


    set HEADERVARS(EXTMIN)      [list [list 10 20 30] "X, Y, and Z drawing extents lower-left corner (in WCS)"]


    set HEADERVARS(EXTNAMES)    [list 290 "Controls symbol table naming:" [list\
	    0 "Release 14 compatibility. Limits names to 31 characters in length. Names can include the letters A to Z, the numerals 0 to 9, and the special characters, dollar sign (   set HEADERVARS(), underscore (_), and hyphen (-)"\
	    1 "AutoCAD 2000. Names can be up to 255 characters in length, and can include the letters A to Z, the numerals 0 to 9, spaces, and any special characters not used by Microsoft Windows and AutoCAD for other purposes"]]
    set HEADERVARS(FILLETRAD)       [list 40 "Fillet radius"]
    set HEADERVARS(FILLMODE)        [list 70 "Fill mode on if nonzero"]
    set HEADERVARS(FINGERPRINTGUID) [list  2 "Set at creation time, uniquely identifies a particular drawing"]
    set HEADERVARS(HANDSEED)        [list 5 "Next available handle"]
    set HEADERVARS(HYPERLINKBASE)   [list 1 "Path for all relative hyperlinks in the drawing. If null, the drawing path is used"]
    set HEADERVARS(INSBASE)         [list [list 10 20 30] "Insertion base set by BASE command (in WCS)"] 
    set HEADERVARS(INSUNITS)        [list 70 "Default drawing units for AutoCAD DesignCenter blocks:" [list\
                          0 Unitless\
			  1 Inches\
			  2 Feet\
			  3 Miles\
			  4 Millimeters\
                          5 Centimeters\
			  6 Meters\
			  7 Kilometers\
			  8 Microinches\
			  9 Mils\
			  10 Yards\
			  11 Angstroms\
			  12 Nanometers\
			  13 Microns\
			  14 Decimeters\
			  15 Decameters\
			  16 Hectometers\
			  17 Gigameters\
			  18 "Astronomical units"\
			  19 "Light years"\
			  20 Parsecs]]
    set HEADERVARS(JOINSTYLE) [list 280 "Lineweight joint setting for new objects:" [list  0 none 1 round 2 angle 3 flat]]
    set HEADERVARS(LIMCHECK)  [list 70 "Nonzero if limits checking is on"]
    set HEADERVARS(LIMMAX)    [list [list 10 20] "XY drawing limits upper-right corner (in WCS)"]
    set HEADERVARS(LIMMIN)    [list [list 10 20] "XY drawing limits lower-left corner (in WCS)"]
    set HEADERVARS(LTSCALE)   [list 40 "Global linetype scale"]
    set HEADERVARS(LUNITS)    [list 70 "Units format for coordinates and distances"]
    set HEADERVARS(LUPREC)    [list 70 "Units precision for coordinates and distances"]
    set HEADERVARS(LWDISPLAY) [list 290 "Controls the display of lineweights on the Model or Layout tab:" [list\
	    0 "Lineweight is not displayed"\
	    1 "Lineweight is displayed"]]
    set HEADERVARS(MAXACTVP) [list 70 "Sets maximum number of viewports to be regenerated"]
    set HEADERVARS(MEASUREMENT) [list 70 "Sets drawing units:" [list  0 English 1 Metric]]
    set HEADERVARS(MENU)      [list  1 "Name of menu file"]
    set HEADERVARS(MIRRTEXT)  [list 70 "Mirror text if nonzero"]
    set HEADERVARS(ORTHOMODE) [list 70 "Ortho mode on if nonzero"]
    set HEADERVARS(PDMODE)    [list 70 "Point Display mode"]
    set HEADERVARS(PDSIZE)    [list 40 "Point display size"]
    set HEADERVARS(PELEVATION) [list 40 "Current paper space elevation"]
    set HEADERVARS(PEXTMAX)   [list [list 10 20 30] "Maximum X, Y, and Z extents for paper space"]
    set HEADERVARS(PEXTMIN)   [list [list 10 20 30] "Minimum X, Y, and Z extents for paper space"]
    set HEADERVARS(PINSBASE)  [list [list 10 20 30] "Paper space insertion base point"]
    set HEADERVARS(PLIMCHECK) [list 70 "Limits checking in paper space when nonzero"]
    set HEADERVARS(PLIMMAX)   [list [list 10 20] "Maximum X and Y limits in paper space"]
    set HEADERVARS(PLIMMIN)   [list [list 10 20] "Minimum X and Y limits in paper space"]
    set HEADERVARS(PLINEGEN)  [list 70 "Governs the generation of linetype patterns around the vertices of a 2D polyline:" [list\
	    1 "Linetype is generated in a continuous pattern around vertices of the polyline"\
	    0 "Each segment of the polyline starts and ends with a dash"]]
    set HEADERVARS(PLINEWID)       [list 40 "Default polyline width"]
    set HEADERVARS(PROXYGRAPHICS) [list 70 "Controls the saving of proxy object images"]
    set HEADERVARS(PSLTSCALE)     [list 70 "Controls paper space linetype scaling:" [list\
	    1 "No special linetype scaling"\
	    0 "Viewport scaling governs linetype scaling"]]
    set HEADERVARS(PSTYLEMODE) [list 290 "Indicates whether the current drawing is in a Color-Dependent or Named Plot Style mode:" [list\
	    0 "Uses color-dependent plot style tables in the current drawing"\
	    1 "Uses named plot style tables in the current drawing"]]
    set HEADERVARS(PSVPSCALE) [list 40 "View scale factor for new viewports: 0 Scaled to fit >0 Scale factor (a positive real value)"]
    set HEADERVARS(PUCSBASE) [list 2 "Name of the UCS that defines the origin and orientation of orthographic UCS settings (paper space only)"]
    set HEADERVARS(PUCSNAME) [list 2 "Current paper space UCS name"]
    set HEADERVARS(PUCSORG) [list [list 10 20 30] "Current paper space UCS origin"]
    set HEADERVARS(PUCSORGBACK) [list [list 10 20 30] "Point which becomes the new UCS origin after changing paper space UCS to 'BACK' when PUCSBASE is set to WORLD"]
    set HEADERVARS(PUCSORGBOTTOM) [list [list 10 20 30] "Point which becomes the new UCS origin after changing paper space UCS to 'BOTTOM' when PUCSBASE is set to WORLD"]
    set HEADERVARS(PUCSORGFRONT) [list [list 10 20 30] "Point which becomes the new UCS origin after changing paper space UCS to 'FRONT' when PUCSBASE is set to WORLD"]
    set HEADERVARS(PUCSORGLEFT) [list [list 10 20 30] "Point which becomes the new UCS origin after changing paper space UCS to 'LEFT' when PUCSBASE is set to WORLD"]
    set HEADERVARS(PUCSORGRIGHT) [list [list 10 20 30] "Point which becomes the new UCS origin after changing paper space UCS to 'RIGHT' when PUCSBASE is set to WORLD"]
    set HEADERVARS(PUCSORGTOP) [list [list 10 20 30] "Point which becomes the new UCS origin after changing paper space UCS to 'TOP' when PUCSBASE is set to WORLD"]
    set HEADERVARS(PUCSORTHOREF) [list 2 "If paper space UCS is orthographic (PUCSORTHOVIEW not equal to 0), this is the name of the UCS that the orthographic UCS is relative to. If blank, UCS is relative to WORLD"]
    set HEADERVARS(PUCSORTHOVIEW) [list 70 "Orthographic view type of paper space UCS:" [list\
	    0 "UCS is not orthographic"\
	    1 Top\
	    2 Bottom\
	    3 Front\
	    4 Back\
	    5 Left\
	    6 Right]]
    set HEADERVARS(PUCSXDIR)  [list [list 10 20 30] "Current paper space UCS X axis"]
    set HEADERVARS(PUCSYDIR)  [list [list 10 20 30] "Current paper space UCS Y axis"]
    set HEADERVARS(QTEXTMODE) [list 70 "Quick Text mode on if nonzero"]
    set HEADERVARS(REGENMODE) [list 70 "REGENAUTO mode on if nonzero"]
    set HEADERVARS(SHADEDGE)  [list 70 {} [list 0 "Faces shaded, edges not highlighted"\
	    1 "Faces shaded, edges highlighted in black"\
	    2 "Faces not filled, edges in entity color"\
	    3 "Faces in entity color, edges in black"]]
    set HEADERVARS(SHADEDIF)   [list 70 "Percent ambient/diffuse light, range 1-100, default 70"]
    set HEADERVARS(SKETCHINC)  [list 40 "Sketch record increment"]
    set HEADERVARS(SKPOLY)     [list 70 {} [list  0 "Sketch lines" 1 "Sketch polylines"]]
    set HEADERVARS(SPLFRAME)   [list 70 "Spline control polygon display:" [list  1 On 0 Off]]
    set HEADERVARS(SPLINESEGS) [list 70 "Number of line segments per spline patch"]
    set HEADERVARS(SPLINETYPE) [list 70 "Spline curve type for PEDIT Spline"]
    set HEADERVARS(SURFTAB1)   [list 70 "Number of mesh tabulations in first direction"]
    set HEADERVARS(SURFTAB2)   [list 70 "Number of mesh tabulations in second direction"]
    set HEADERVARS(SURFTYPE)   [list 70 "Surface type for PEDIT Smooth"]
    set HEADERVARS(SURFU)      [list 70 "Surface density (for PEDIT Smooth) in M direction"]
    set HEADERVARS(SURFV)      [list 70 "Surface density (for PEDIT Smooth) in N direction"]
    set HEADERVARS(TDCREATE)   [list 40 "Local date/time of drawing creation (see \"Special Handling of Date/Time Variables\")"]
    set HEADERVARS(TDINDWG)    [list 40 "Cumulative editing time for this drawing (see \"Special Handling of Date/Time Variables\")"]
    set HEADERVARS(TDUCREATE)  [list 40 "Universal date/time the drawing was created (see \"Special Handling of Date/Time Variables\")"]
    set HEADERVARS(TDUPDATE)   [list 40 "Local date/time of last drawing update (see \"Special Handling of Date/Time Variables\")"]
    set HEADERVARS(TDUSRTIMER) [list 40 "User-elapsed timer"]
    set HEADERVARS(TDUUPDATE)  [list 40 "Universal date/time of the last update/save (see \"Special Handling of Date/Time Variables\")"]
    set HEADERVARS(TEXTSIZE)   [list 40 "Default text height"]
    set HEADERVARS(TEXTSTYLE)  [list 7 "Current text style name"]
    set HEADERVARS(THICKNESS)  [list 40 "Current thickness set by ELEV command"]
    set HEADERVARS(TILEMODE)   [list 70 {} [list\
	    1 "for previous release compatibility mode"\
	    0 "otherwise"]]
    set HEADERVARS(TRACEWID) [list 40 "Default trace width"]
    set HEADERVARS(TREEDEPTH) [list 70 "Specifies the maximum depth of the spatial index"]
    set HEADERVARS(UCSBASE) [list 2 "Name of the UCS that defines the origin and orientation of orthographic UCS settings"]
    set HEADERVARS(UCSNAME) [list 2 "Name of current UCS"]
    set HEADERVARS(UCSORG) [list [list 10 20 30] "Origin of current UCS (in WCS)"]
    set HEADERVARS(UCSORGBACK) [list [list 10 20 30] "Point which becomes the new UCS origin after changing model space UCS to 'BACK' when UCSBASE is set to WORLD"]
    set HEADERVARS(UCSORGBOTTOM) [list [list 10 20 30] "Point which becomes the new UCS origin after changing model space UCS to 'BOTTOM' when UCSBASE is set to WORLD"]
    set HEADERVARS(UCSORGFRONT) [list [list 10 20 30] "Point which becomes the new UCS origin after changing model space UCS to 'FRONT' when UCSBASE is set to WORLD"]
    set HEADERVARS(UCSORGLEFT) [list [list 10 20 30] "Point which becomes the new UCS origin after changing model space UCS to 'LEFT' when UCSBASE is set to WORLD"]
    set HEADERVARS(UCSORGRIGHT) [list [list 10 20 30] "Point which becomes the new UCS origin after changing model space UCS to 'RIGHT' when UCSBASE is set to WORLD"]
    set HEADERVARS(UCSORGTOP) [list [list 10 20 30] "Point which becomes the new UCS origin after changing model space UCS to 'TOP' when UCSBASE is set to WORLD"]
    set HEADERVARS(UCSORTHOREF) [list 2 "If model space UCS is orthographic (UCSORTHOVIEW not equal to 0), this is the name of the UCS that the orthographic UCS is relative to. If blank, UCS is relative to WORLD"]
    set HEADERVARS(UCSORTHOVIEW) [list 70 "Orthographic view type of model space UCS:" [list\
	    0 "UCS is not orthographic"\
	    1 Top\
	    2 Bottom\
	    3 Front\
	    4 Back\
	    5 Left\
	    6 Right]]
    set HEADERVARS(UCSXDIR) [list [list 10 20 30] "Direction of the current UCS X axis (in WCS)"]
    set HEADERVARS(UCSYDIR) [list [list 10 20 30] "Direction of the current UCS Y axis (in WCS)"]
    set HEADERVARS(UNITMODE) [list 70 "Low bit set Display fractions, feet-and-inches, and surveyor's angles in input format"]
    set HEADERVARS(USERI1) [list 70 "Five integer variables intended for use by third-party developers"]
    set HEADERVARS(USERI2) [list 70 "Five integer variables intended for use by third-party developers"]
    set HEADERVARS(USERI3) [list 70 "Five integer variables intended for use by third-party developers"]
    set HEADERVARS(USERI4) [list 70 "Five integer variables intended for use by third-party developers"]
    set HEADERVARS(USERI5) [list 70 "Five integer variables intended for use by third-party developers"]
    set HEADERVARS(USERR1) [list 40 "Five real variables intended for use by third-party developers"]
    set HEADERVARS(USERR2) [list 40 "Five real variables intended for use by third-party developers"]
    set HEADERVARS(USERR3) [list 40 "Five real variables intended for use by third-party developers"]
    set HEADERVARS(USERR4) [list 40 "Five real variables intended for use by third-party developers"]
    set HEADERVARS(USERR5) [list 40 "Five real variables intended for use by third-party developers"]
    set HEADERVARS(USRTIMER) [list 70 {} [list 0 "Timer off" 1 "Timer on"]]
    set HEADERVARS(VERSIONGUID) [list 2 "Uniquely identifies a particular version of a drawing. Updated when the drawing is modified"]
    set HEADERVARS(VISRETAIN) [list 70 {} [list\
	    0 "Don't retain xref-dependent visibility settings"\
	    1 "Retain xref-dependent visibility settings"]]
    set HEADERVARS(WORLDVIEW) [list 70 {} [list\
	    1 "Set UCS to WCS during DVIEW/VPOINT"\
	    0 "Don't change UCS"]]
    set HEADERVARS(XEDIT) [list 290 "Controls whether the current drawing can be edited in-place when being referenced by another drawing" [list\
	    0 "Can't use in-place reference editing"\
	    1 "Can use in-place reference editing"]]
}

proc dxf::cleancv {code value} {
    if {($code >= 10 && $code <= 59) ||
    ($code >= 140 && $code <= 147) ||
    ($code >= 1010 && $code <= 1059)} {
	set value [expr {double($value)}]
    } elseif {($code >= 60 && $code <= 79) ||  ($code >= 90 && $code <= 99) || ($code >= 170 && $code <= 175) || ($code >= 280 && $code <= 289) || ($code >= 370 && $code <= 379) || ($code >= 380 && $code <= 389) || ($code >= 400 && $code <= 409) || ($code >= 1060 && $code <= 1070) || ($code == 1071)} {
	set value [expr {$value}]
    } elseif {($code >= 176 && $code <= 179) || ($code >= 270 && $code <= 279)} {
	# spécial DIMSTYLE ?
	set value [expr {$value}]
    }
    return $value
}

proc dxf::readCV {lignes iVar} {
    upvar $iVar i
    set code [expr {[lindex $lignes $i]}]
    incr i
    set value [dxf::cleancv $code [lindex $lignes $i]]
    incr i
    # puts  [list $code $value]
    return [list $code $value]
}

proc dxf::readError {iName shift message args} {
    upvar $iName i
    set message "ligne [expr {$i + 1+ ($shift)}]: $message"
    if {$args != "-warnOnly"} {
	error $message
    } else {
	puts stderr $message
    }
}

proc dxf::readFile {fichier HEADERNAME CLASSESNAME TABLESNAME BLOCKSNAME ENTITIESNAME} {
    upvar $HEADERNAME HEADER
    upvar $CLASSESNAME CLASSES
    upvar $TABLESNAME TABLES
    upvar $BLOCKSNAME BLOCKS
    upvar $ENTITIESNAME ENTITIES

    foreach x {HEADER CLASSES TABLES BLOCKS ENTITIES} {
        upvar [set ${x}NAME] $x
        if {[info exists $x]} {
            unset $x
        }
    }

    set f [open $fichier r]
    llength [set lignes [split [read -nonewline $f] \n]]
    close $f
    set thumnailimages [list]
    set sections [list header classes tables blocks entities objects thumnailimages]

    set section unknown

    set NKV [llength $lignes]
    if {[expr {$NKV % 2} != 0]} {
	error "Nombre impair de lignes"
    }
    set i 0
    dxf::readFileHeader HEADER $lignes i
puts stderr "CLASSES supposé absent"
#    dxf::readFileClasses CLASSES $lignes i
    dxf::readFileTables TABLES $lignes i
    dxf::readFileBlocks BLOCKS $lignes i
    dxf::readFileEntities ENTITIES $lignes i
}

proc dxf::readFileHeader {HEADERNAME lignes iName} {

    upvar $HEADERNAME HEADER
    upvar $iName i

    set NKV [llength $lignes]
    # lecture de HEADER SECTION

    set cv [dxf::readCV $lignes i]
    if {$cv != [list 0 SECTION]} {
	dxf::readError i -2 "0 SECTION attendu"
    }
    set cv [dxf::readCV $lignes i]
    if {$cv != [list 2 HEADER]} {
	dxf::readError i -2 "2 HEADER attendu"
    }
    while {$i < $NKV} {
	set cv [dxf::readCV $lignes i]
	set code [lindex $cv 0]
	set value [lindex $cv 1]
	if {$code == 0} {
	    if {$value != "ENDSEC"} {
		dxf::readError i -1 "mauvaise fin de HEADER SECTION"
	    }
	    break
	}
	if {$code == 9} {
	    if {[string index $value 0] != "\$"} {
		dxf::readError i -1 "mauvais nom de variable"
	    }
	    set name [string range $value 1 end]
	    if {[info exists HEADER($name)]} {
		dxf::readError i -1 "la variable \"HEADER($name)\" existe déjà"
	    }
	    set HEADER($name) [list]
	    continue
	}
	lappend HEADER($name) $value
    }
}

proc dxf::readFileClasses {CLASSESNAME lignes iName} {
    
    upvar $CLASSESNAME CLASSES
    upvar $iName i

    set NKV [llength $lignes]
    # lecture de CLASSES SECTION

    set cv [dxf::readCV $lignes i]
    if {$cv != [list 0 SECTION]} {
	dxf::readError i -2 "0 SECTION attendu"
    }
    set cv [dxf::readCV $lignes i]
    if {$cv != [list 2 CLASSES]} {
	return
    }
    while {$i < $NKV} {
	set cv [dxf::readCV $lignes i]
	set code [lindex $cv 0]
	set value [lindex $cv 1]
	if {$code != 0} {
	    dxf::readError i -2 "0 attendu"
	}
	if {$value == "ENDSEC"} {
	    break
	}
	if {$value != "CLASS"} {
	    dxf::readError i -1 "CLASS attendu"
	}
	foreach {code class} [dxf::readCV $lignes i] {}
	if {$code != 1} {
	    dxf::readError i -2 "1 attendu, $code reçu"
	}
	if {[info exists CLASSES($class)]} {
	    dxf::readError i -1 "CLASSES($class) existe"
	}
	set CLASSES($class) [list]
	foreach k [list 2 3 90 280 281] {
	    foreach {code value} [dxf::readCV $lignes i] {}
	    if {$code != $k} {
		dxf::readError i -2 "$k attendu"
	    }
	    lappend CLASSES($class) $value
	}
    }
}

proc dxf::readFileTables {TABLESNAME lignes iName} {
    
    upvar $TABLESNAME TABLES
    upvar $iName i
 
    set NKV [llength $lignes]
    # lecture de TABLES SECTION

    set cv [dxf::readCV $lignes i]
    if {$cv != [list 0 SECTION]} {
	dxf::readError i -2 "0 SECTION attendu"
    }
    set cv [dxf::readCV $lignes i]
    if {$cv != [list 2 TABLES]} {
	return
    }
    while {$i < $NKV} {

	# lecture de l'entête d'une liste de tables

	foreach {code value} [dxf::readCV $lignes i] {}
	if {$code != 0} {
	    "dxf::readError i -2 0 attendu (ENDSEC ou TABLE)"
	}
	if {$value == "ENDSEC"} {
	    break
	}
	if {$value != "TABLE"} {
	    dxf::readError i -1 "TABLE attendu"
	}
	foreach {code table} [dxf::readCV $lignes i] {}
	if {$code != 2} {
	    dxf::readError i -2 "2 attendu"
	}
	if {[info exists TABLES($table)]} {
	    dxf::readError i -1 "TABLES($table) existe déjà"
	}
        
	if {$table == "LAYER" && ![info exists TABLES(LTYPE)]} {
	    dxf::readError i -1 "LAYER rencontré avant LTYPE"
	}
	if {![regexp {^[A-Z_]+$} $table]} {
	    dxf::readError i -1 "la table \"$table\" n'est pas écrite en majuscules"
	}

	foreach {code handle} [dxf::readCV $lignes i] {}

        puts {codes 5 et 100 sautés} ; set maxTableEntries 1000000
set rien {
	if {$code != 5} {
	    dxf::readError i -2 "5 attendu, $code vu"
	}
	set cv [dxf::readCV $lignes i]
	if {$cv != [list 100 AcDbSymbolTable]} {
	    dxf::readError i -2 "[list 100 AcDbSymbolTable] attendu"
	}
	foreach {code maxTableEntries} [dxf::readCV $lignes i] {}
    }
	if {$code != 70} {
	    "dxf::readError i -2 70 attendu"
	}
	set TABLES($table) [list $handle]
	# le premier élément est un handle, les autres sont les tableEntries

	# lecture de la liste de tables

	set nTableEntries 0
	foreach {code value} [dxf::readCV $lignes i] {}
	set entry [list]
	catch {unset vus}
	while 1 {
	    if {$code != 0} {
		dxf::readError i -2 "0 attendu (ENDTAB ou $table)"
	    }
	    if {$value == "ENDTAB"} {
		break
	    }
	    if {$value != $table} {
		dxf::readError i -1 "\"$table\" attendu"
	    }
	    incr nTableEntries
	    if {$nTableEntries > $maxTableEntries} {
		puts stderr "Warning: débordement de tableEntries \"$table\": $nTableEntries > $maxTableEntries"
	    }
	    foreach {code handle} [dxf::readCV $lignes i] {}
	    if {!($code == 5 || ($code == 105 && $table == "DIMSTYLE"))} {
		expr "ligne [expr {$i - 1}] error 5 ou 105 attendu, $code vu"
	    }
	    lappend entry $code $handle
	    set vus($code) {}
	    set cv [dxf::readCV $lignes i]
	    if {$cv == [list 102 \{ACAD_REACTORS]} {
		set persistent [list]
		foreach {code value} [dxf::readCV $lignes i] {}
		while {$code != 102} {
		    if {$code != 330} {
			dxf::readError i -2 "330 attendu"
		    }
		    lappend persistent $value
		    foreach {code value} [dxf::readCV $lignes i] {}
		}
		if {$value != "\}"} {
		    dxf::readError i -1 "\"\}\" attendu"
		}
		lappend entry 102 $persistent
		unset persistent
		set vus(102) {}
	    } elseif {$cv != [list 100 AcDbSymbolTableRecord]} {
		dxf::readError i -2 "[list 100 AcDbSymbolTableRecord] attendu"
	    }
	    while 1 {
		foreach {code value} [dxf::readCV $lignes i] {}
		if {[info exists vus($code)]} {
		    # pas de test ici 49 peut être répété dans LTYPE, par exemple
		    # error "ligne [expr {$i - 1}] code $code déjà vu"
		}
		if {$code != 0} {
		    lappend entry $code $value
		    set vus($code) {}
		} else {
		    break
		}
	    }
	    lappend TABLES($table) $entry
	    set entry [list]
	    catch {unset vus}
	}
    }
}

proc dxf::readFileBlocks {BLOCKSNAME lignes iName} {
    
    upvar $BLOCKSNAME BLOCKS
    upvar $iName i
 
    set NKV [llength $lignes]
    # lecture de BLOCKS SECTION

    set cv [dxf::readCV $lignes i]
    if {$cv != [list 0 SECTION]} {
	dxf::readError i -2 "0 SECTION attendu"
    }
    set cv [dxf::readCV $lignes i]
    if {$cv != [list 2 BLOCKS]} {
	return
    }
    while {$i < $NKV} {

	# lecture de l'entête d'une liste de blocks

	foreach {code value} [dxf::readCV $lignes i] {}
	if {$code != 0} {
	    dxf::readError i -2 "0 attendu (ENDSEC ou BLOCK), $code reçu"
	}
	if {$value == "ENDSEC"} {
	    break
	}
	if {$value != "BLOCK"} {
	    dxf::readError i -1 "BLOCK attendu"
	}
	foreach {code handle} [dxf::readCV $lignes i] {}
	if {$code != 5} {
	    dxf::readError i -2 "5 attendu, $code vu"
	}
	upvar #0 HANDLE_$handle HANDLE
	if {[info exists HANDLE]} {
	    error "Le Handle $handle exists déjà"
	}
	lappend BLOCKS $handle
	set HANDLE(type) BLOC

	foreach {code value} [dxf::readCV $lignes i] {}
	while {$code != 0} {
	    set HANDLE($code) $value
	    foreach {code value} [dxf::readCV $lignes i] {}
	}

	set type $value
	while 1 {
	    if {$code != 0} {
		dxf::readError i -2 "0 attendu (ENDBLK ou entity_type)"
	    }
	    if {$type == "ENDBLK"} {
		break
	    }

	    foreach {handle nextType} [dxf::readEntity $type $lignes i] {}
	    lappend HANDLE($type) $handle
	    set type $nextType
	}

	foreach {code handle} [dxf::readCV $lignes i] {}
	while {$code != 5} {
	    dxf::readError i -2 "5 attendu, [list $code $handle] reçu"
	}
	set HANDLE(handleEnd) $handle
	set cv [dxf::readCV $lignes i]
	while {$cv != [list 100 AcDbBlockEnd ]} {
	    dxf::readError i -2 "[list 100 AcDbBLockEnd] attendu, $cv reçu" -warnOnly
	    set cv [dxf::readCV $lignes i]
	}
    }
}

proc dxf::readFileEntities {ENTITIESNAME lignes iName} {
    
    upvar $ENTITIESNAME ENTITIES
    upvar $iName i
 
    set NKV [llength $lignes]
    # lecture de ENTITIES SECTION

    set cv [dxf::readCV $lignes i]
    if {$cv != [list 0 SECTION]} {
	dxf::readError i -2 "0 SECTION attendu"
    }
    set cv [dxf::readCV $lignes i]
    if {$cv != [list 2 ENTITIES]} {
	return
    }
    
    foreach {code type} [dxf::readCV $lignes i] {}
    while 1 {
	if {$code != 0} {
	    dxf::readError i -2 "0 attendu (ENDSEC ou entity_type)"
	}
	if {$type == "ENDSEC"} {
	    break
	}
	foreach {handle nextType} [dxf::readEntity $type $lignes i] {}
	lappend ENTITIES($type) $handle
	set type $nextType
    }
}


proc dxf::readEntity {type lignes iName} {
    upvar $iName i

    foreach {code handle} [dxf::readCV $lignes i] {}
    if {$code != 5} {
	dxf::readError i -2 "5 attendu (handle)"
    }
    upvar #0 HANDLE_$handle HANDLE
    if {[info exists HANDLE]} {
	error "Le Handle $handle exists déjà"
    }
    set HANDLE(type) $type
    foreach {code value} [dxf::readCV $lignes i] {}
    while {$code != 0} {
	lappend HANDLE($code) $value
	foreach {code value} [dxf::readCV $lignes i] {}
    }
    return [list $handle $value]
}

proc dxf::kvfind {list key} {
    foreach {k v} $list {
	if {$k == $key} {
	    return $v
	}
    }
    return {}
}

proc dxf::printheader {HEADERNAME} {
    upvar $HEADERNAME HEADER
    variable HEADERVARS

    puts {}
    puts ******
    puts HEADER
    puts ******
    puts {}

    foreach name [lsort [array names HEADER]] {
	puts $name
	if {[info exists HEADERVARS($name)]} {
	    set hv $HEADERVARS($name)
	    if {[llength [lindex $hv 0]] != [llength $HEADER($name)]} {
		"error nelems mismatch"
	    }
	    puts [lindex $hv 1]
	} else {
	    set hv {}
	    puts "inconnu"
	} 
	foreach v $HEADER($name) {
	    puts -nonewline $v
	    if {[llength $hv] == 3} {
		puts " -> [dxf::kvfind [lindex $hv 2] $v]"
	    } else {
		puts {}
	    }
	}
	puts {}
    }
}

proc dxf::printclasses {CLASSESNAME} {
    upvar $CLASSESNAME CLASSES

    puts {}
    puts *******
    puts CLASSES
    puts *******
    puts {}
    foreach name [lsort [array names CLASSES]] {
	puts "$name $CLASSES($name)"
    }
}

proc dxf::printtables {TABLESNAME} {
    upvar $TABLESNAME TABLES

    puts {}
    puts ******
    puts TABLES
    puts ******
    foreach name [lsort [array names TABLES]] {
	puts {}
	set blabla "Table $name, handle [lindex $TABLES($name) 0]"
	set bloblo ""
	for {set j [string length $blabla]} {$j > 0} {incr j -1} {
	    append bloblo *
	}
	puts "    $bloblo"
	puts "    $blabla"
	puts "    $bloblo"
	set i 0
	foreach table [lrange $TABLES($name) 1 end] {
	    incr i
	    puts {}
	    puts "$name #$i"
	    foreach {code value} $table {
		puts [list $code $value]
	    }
	}
    }
}

proc dxf::printblocks {BLOCKSNAME} {
    upvar $BLOCKSNAME BLOCKS

    puts {}
    puts ******
    puts BLOCKS
    puts ******
    puts {}

    puts $BLOCKS

    foreach handle $BLOCKS {
	upvar #0 HANDLE_$handle HANDLE
	puts {}
	set bloblo ""
	set blabla "Block $HANDLE(2)"
	for {set j [string length $blabla]} {$j > 0} {incr j -1} {
	    append bloblo *
	}
	puts "    $bloblo"
	puts "    $blabla"
	puts "    $bloblo"
	puts {}

	
	dxf::printentity $handle

	foreach entityType [lsort [array names HANDLE {[A-Z]*}]] {
	    foreach entityHandle [lsort -command dxf::triHandle $HANDLE($entityType)] {
		dxf::printentity $entityHandle
	    }
	}
    }
}

proc dxf::mixCompare {a b} {
    set ta [catch {expr $a} ia]
    set tb [catch {expr $b} ib]

    if {$ta == 1} {
	if {$tb == 0} {
	    return 0
	} else {
	    return [string compare $a $b]
	}
    } else {
	if {$tb == 1} {
	    return 1
	} else {
	    return [expr $a >= $b]
	}
    }
}
	    

proc dxf::printentity {handle} {
    puts {}
    puts $handle
    upvar #0 HANDLE_$handle HANDLE
    foreach code [lsort -command dxf::mixCompare [array names HANDLE]] {
	puts "[format %5s $code] $HANDLE($code)"
    }
}

proc dxf::printentities {ENTITIESNAME} {
    upvar $ENTITIESNAME ENTITIES

    puts {}
    puts ********
    puts ENTITIES
    puts ********
    puts {}
    
    # ENTITIES est un tableau
    # chaque indice est un type (ARC ATTRIB CIRCLE DIMENSION HATCH, etc.)
    # la valeur associée est une liste de "handles"

    set types [lsort [array names ENTITIES]]

    puts $types
    puts {}

    foreach type $types {
	set bloblo ""
	set blabla $type
	for {set j [string length $blabla]} {$j > 0} {incr j -1} {
	    append bloblo *
	}
	puts {}
	puts "    $bloblo"
	puts "    $blabla"
	puts "    $bloblo"

	foreach handle [lsort -command dxf::triHandle $ENTITIES($type)] {
	    dxf::printentity $handle
	}
    }
}

proc dxf::triHandle {a1 a2} {
    if {![scan $a1 %x i1]} {
	error "Handle non hexa: $a1"
    }
    if {![scan $a2 %x i2]} {
	error "Handle non hexa: $a2"
    }
    return [expr {$i1-$i2}]
}

proc dxf::printobjects {OBJECTSNAME} {
    upvar $OBJECTSNAME OBJECTS

    puts {}
    puts *******
    puts OBJECTS
    puts *******
    puts {}
    puts "Pas Fait !!!"
    puts {}
}

proc execute {} {
    global FICHIER

    global HEADER CLASSES TABLES BLOCKS ENTITIES
    set kvs [dxf::readFile $FICHIER HEADER CLASSES TABLES BLOCKS ENTITIES]
    
}

button .b -command execute
pack .b

proc dxf::printAll {} {
    dxf::printheader HEADER
    dxf::printclasses CLASSES
    dxf::printtables TABLES
    dxf::printblocks BLOCKS
    dxf::printentities ENTITIES
#    dxf::printobjects OBJECTS
}

proc dxf::displayWinProc {canvas args} {

    foreach {xmin ymin xmax ymax} [::fidev::zinzout::getLimits $canvas] {}
    set echelle [::fidev::zinzout::getScale $canvas]

    $canvas create line 0 0 100 100
}

toplevel .essai
::fidev::zinzout::create .essai dxf::displayWinProc bobo

# vu ARC ATTDEF CIRCLE INSERT LINE LWPOLYLINE MTEXT POINT SOLID TEXT  

proc dxf::displayBlock {canvas handle} {
    upvar #0 HANDLE_$handle HANDLE

    set entities [array names HANDLE {[A-Z]*}]
    puts $entities

    dxf::displayThings $canvas HANDLE
}

proc dxf::displayEntities {canvas args} {
    global ENTITIES

    set entities [array names ENTITIES {[A-Z]*}]
    puts $entities

    dxf::displayThings $canvas ENTITIES
}


proc dxf::displayThings {canvas arrayName} {
    upvar $arrayName ARRAY
    global DISPLAYTEXT

    foreach {xmin ymin xmax ymax} [::fidev::zinzout::getLimits $canvas] {}
    set echelle [::fidev::zinzout::getScale $canvas]

    if {[info exists ARRAY(CIRCLE)]} {
	foreach handle $ARRAY(CIRCLE) {
	    upvar #0 HANDLE_$handle HANDLE
	    set layer $HANDLE(8)
	    set LAYERS($layer) {}
	    set x $HANDLE(10)
	    set y $HANDLE(20)
	    set radius $HANDLE(40)
	    $canvas create oval\
		    [expr {$echelle*($x - $radius)}] [expr {-$echelle*($y - $radius)}]\
		    [expr {$echelle*($x + $radius)}] [expr {-$echelle*($y + $radius)}]\
		    -width 0\
		    -tags [list handle_$handle layer_$layer CIRCLE]
	}
    }

    if {[info exists ARRAY(ARC)]} {
	foreach handle $ARRAY(ARC) {
	    upvar #0 HANDLE_$handle HANDLE
	    set layer $HANDLE(8)
	    set LAYERS($layer) {}
	    set x $HANDLE(10)
	    set y $HANDLE(20)
	    set radius $HANDLE(40)
	    set start $HANDLE(50)
	    set end $HANDLE(51)
	    $canvas create arc\
		    [expr {$echelle*($x - $radius)}] [expr {-$echelle*($y - $radius)}]\
		    [expr {$echelle*($x + $radius)}] [expr {-$echelle*($y + $radius)}]\
		    -start $start\
		    -extent [expr {$end - $start}]\
		    -style arc\
		    -width 0\
		    -tags [list handle_$handle layer_$layer ARC]
	}
    }

    if {[info exists ARRAY(LWPOLYLINE)]} {
	foreach handle $ARRAY(LWPOLYLINE) {
	    upvar #0 HANDLE_$handle HANDLE
	    set layer $HANDLE(8)
	    set LAYERS($layer) {}
	    set command [list $canvas create line]
	    foreach x $HANDLE(10) y $HANDLE(20) {
		lappend command [expr {$echelle*$x}] [expr {-$echelle*$y}]
	    }
	    lappend command -width 0 -tags [list handle_$handle layer_$layer LWPOLYLINE]
#	    puts $command
	    eval $command
	}
    }

    if {[info exists ARRAY(LINE)]} {
	foreach handle $ARRAY(LINE) {
	    upvar #0 HANDLE_$handle HANDLE
	    set layer $HANDLE(8)
	    set LAYERS($layer) {}
	    set x1 $HANDLE(10)
	    set y1 $HANDLE(20)
	    set x2 $HANDLE(11)
	    set y2 $HANDLE(21)
	    $canvas create line\
		    [expr {$echelle*$x1}] [expr {-$echelle*$y1}]\
		    [expr {$echelle*$x2}] [expr {-$echelle*$y2}]\
		    -width 0\
		    -tags [list handle_$handle layer_$layer LINE]
#	    puts [list\
#		    [expr {$echelle*$x1}] [expr {-$echelle*$y1}]\
#		    [expr {$echelle*$x2}] [expr {-$echelle*$y2}]]
	}
    }

    if {[info exists ARRAY(POINT)]} {
	foreach handle $ARRAY(POINT) {
	    upvar #0 HANDLE_$handle HANDLE
	    set layer $HANDLE(8)
	    set LAYERS($layer) {}
	    set x $HANDLE(10)
	    set y $HANDLE(20)
	    $canvas create line\
		    [expr {$echelle*$x - 2}] [expr {-$echelle*$y}]\
		    [expr {$echelle*$x + 2}] [expr {-$echelle*$y}]\
		    -width 0\
		    -tags [list handle_$handle layer_$layer POINT]
	    $canvas create line\
		    [expr {$echelle*$x}] [expr {-$echelle*$y - 2}]\
		    [expr {$echelle*$x}] [expr {-$echelle*$y + 2}]\
		    -tags [list handle_$handle layer_$layer POINT]
	}
    }
    if {[info exists ARRAY(SOLID)]} {
	foreach handle $ARRAY(SOLID) {
	    upvar #0 HANDLE_$handle HANDLE
	    set layer $HANDLE(8)
	    set LAYERS($layer) {}
	    set x1 $HANDLE(10)
	    set y1 $HANDLE(20)
	    set x2 $HANDLE(11)
	    set y2 $HANDLE(21)
	    set x3 $HANDLE(12)
	    set y3 $HANDLE(22)
	    set x4 $HANDLE(13)
	    set y4 $HANDLE(23)
	    $canvas create polygon\
		    [expr {$echelle*$x1}] [expr {-$echelle*$y1}]\
		    [expr {$echelle*$x2}] [expr {-$echelle*$y2}]\
		    [expr {$echelle*$x3}] [expr {-$echelle*$y3}]\
		    [expr {$echelle*$x4}] [expr {-$echelle*$y4}]\
		    -tags [list handle_$handle layer_$layer SOLID]
	}
    }
    if {[info exists ARRAY(TEXT)] && $DISPLAYTEXT} {
	foreach handle $ARRAY(TEXT) {
	    upvar #0 HANDLE_$handle HANDLE
	    set layer $HANDLE(8)
	    set LAYERS($layer) {}
	    set x $HANDLE(10)
	    set y $HANDLE(20)
	    set h $HANDLE(40)
	    set text $HANDLE(1)
	    $canvas create text\
		    [expr {$echelle*$x}] [expr {-$echelle*$y}]\
		    -text $text\
		    -tags [list handle_$handle layer_$layer TEXT]
	}
    }
    if {[info exists ARRAY(MTEXT)] && $DISPLAYTEXT} {
	foreach handle $ARRAY(MTEXT) {
	    upvar #0 HANDLE_$handle HANDLE
	    set layer $HANDLE(8)
	    set LAYERS($layer) {}
	    set x $HANDLE(10)
	    set y $HANDLE(20)
	    set h $HANDLE(40)
	    set text $HANDLE(1)
	    $canvas create text\
		    [expr {$echelle*$x}] [expr {-$echelle*$y}]\
		    -text $text\
		    -tags [list handle_$handle layer_$layer MTEXT]
	}
    }
    puts "LAYERS: [array names LAYERS ]"
}

set DISPLAYTEXT 0


foreach b $BLOCKS {
    set name [set HANDLE_${b}(2)]
    set win .w$name
    catch {destroy $win}
    toplevel $win
    ::fidev::zinzout::create $win dxf::displayBlock $b
}

toplevel .entities
::fidev::zinzout::create .entities dxf::displayEntities {}


.entities.c itemconfigure all -fill white
foreach l {0 P_PLAFOND_TECHNIQUE NOMS_PERSONNES N1_D1_MURS P_CLOISONS ORGANIGRAMME P_COTATIONS MOBILIER N0_D5_CLOISON N1_D1_CLOISONS SSERVITU P_PLANS N0_D5_COTATION P_PLAFOND_60X60 CADRE N__BUREAUX P_TRAME P_PLAFOND_OSSATURE SURFACE N0_D5_MUR P_SANIT__CHAUFF CALQUE_27 P_L_GENDE_PANNEAUX P_SOL N0_D5_TRAME SUTILE P_CARTOUCHE_CLOISONS P_MURS LC P_TYPES_CH_SSIS P_CARTOUCHE_MOBILIER
} {
    .entities.c itemconfigure all -fill white
    .entities.c itemconfigure layer_$l -fill red
    puts $l
    after 1000
    update
}