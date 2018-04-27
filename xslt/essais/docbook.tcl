# load tDOM

package require tdom

 # parse xml

set xmldoc [dom parse \
		-baseurl $baseurl \
		-keepEmpties \ 
	    -externalentitycommand ::fxslt::extRefHandler\ 
	    $xmldata]




 # and same for xsl ... # access the root node of the xml document set xmlroot [$xmldoc documentElement] # call the method   xslt   on the root node, # giving the xslt dom parsed before $xmlroot xslt $xsldoc resultDoc # access root node of the resulting document set root [$resultDoc documentElement] # and show it as HTML set res [$root asHTML] # there might be more data: set nextRoot [$root nextSibling] while {$nextRoot != ""} { append res [$nextRoot asHTML] set nextRoot [$nextRoot nextSibling] } work, especially Corsin Decurtins and Ronnie Brunner.