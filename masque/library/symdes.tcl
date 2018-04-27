namespace eval masque {
    proc compareLiCo {symDes1 symDes2} {
        foreach {x1 y1} [::masque::symDesToPos $symDes1] {}
        foreach {x2 y2} [::masque::symDesToPos $symDes2] {}
        if {$y1 < $y2} {
            return 1
        } elseif {$y1 > $y2} {
            return -1
        } elseif {$x1 > $x2} {
            return 1
        } elseif {$x1 < $x2} {
            return -1
        } else {
            return 0
        }
    }
    proc compareCoLi {symDes1 symDes2} {
        foreach {x1 y1} [::masque::symDesToPos $symDes1] {}
        foreach {x2 y2} [::masque::symDesToPos $symDes2] {}
        if {$x1 > $x2} {
            return 1
        } elseif {$x1 < $x2} {
            return -1
        } elseif {$y1 < $y2} {
            return 1
        } elseif {$y1 > $y2} {
            return -1
        } else {
            return 0
        }
    }
}

