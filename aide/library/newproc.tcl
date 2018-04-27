if {[info commands procOriginal] == {}} {
    rename proc procOriginal
}

procOriginal proc {name arglist body} {
    global FILEOFPROC

    set fifi [info script]
    if {$fifi == {}} {
        set fifi "définition interactive"
    } elseif {[file pathtype $fifi] == "relative"} {
        set fifi [pwd]/$fifi 
    }  
    set nana [uplevel namespace current]
    puts "nana=$nana, name=$name, fifi=$fifi"    
    if {$nana == "::"} {
        set name ::$name
    } else {
        set name ${nana}::$name
    }
    puts "$nana -> $name"
    set FILEOFPROC($name) $fifi
    procOriginal $name $arglist $body
}
