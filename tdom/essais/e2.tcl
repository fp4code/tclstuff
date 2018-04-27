package require tdom 0.7.7

# First create our top-level document
set doc [dom createDocument rss]
set root [$doc documentElement]
# Set RSS version number
$root setAttribute version "0.91"

# Create the commands to build up our XML document
dom createNodeCmd elementNode channel
dom createNodeCmd elementNode title
dom createNodeCmd elementNode description
dom createNodeCmd textNode t

# Build our XML document
$root appendFromScript {
    channel {
	title { t "Tcl'ers Wiki Recent Changes" }
	description { t "A daily dose of Tcl inspiration!" }
    }
}

# Add another channel to the document, with a made-up attribute
$root appendFromScript {
    channel {foo bar} {
	t "Testing..."
    }
}

# Finally, show the resulting doc:
puts [$root asXML]

