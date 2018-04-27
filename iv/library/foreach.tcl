
proc valeurs.par.defaut.xeq {} {}

proc iv:initoutiv {{win {}}} {
    global GPIBAPP    
    foreach app $GPIBAPP(init) {
        $app ini
    }
    valeurs.par.defaut.xeq
}

proc iv:testpoll {{win {}}} {
    global GPIBAPP    
    foreach app $GPIBAPP(poll) {
        puts [list $app [$app poll]]
    }
}

proc iv:sourcesAuRepos {{win {}}} {
    global GPIBAPP    
    foreach app $GPIBAPP(sources) {
        $app repos
    }
}
