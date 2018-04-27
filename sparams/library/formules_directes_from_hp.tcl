    #####################
    # formules directes #
    #####################

proc sparams::HfromSdirect {s11 s12 s21 s22} {
    variable un
    
    set s12s21 [complexes::mul $s12 $s21]
    set ums11 [complexes::sub 1.0 $s11]        
    set ums22 [complexes::sub 1.0 $s22]        
    set ups11 [complexes::add 1.0 $s11]        
    set ups22 [complexes::add 1.0 $s22]        
    
    set denom [complexes::add [complexes::mul $ums11 $ups22] $s12s21]
    set invdenom [complexes::inv $denom]
    
    set h11 [complexes::mul $invdenom [complexes::sub [complexes::mul $ups11 $ups22] $s12s21]]
    set h12 [complexes::mul $invdenom [complexes::realMul 2.0 $s12]]
    set h21 [complexes::mul $invdenom [complexes::realMul -2.0 $s21]]
    set h22 [complexes::mul $invdenom [complexes::sub [complexes::mul $ums11 $ums22] $s12s21]]
    
    return [list $h11 $h12 $h21 $h22]
}

proc sparams::SfromHdirect {h11 h12 h21 h22} {
#    variable un
    
    set h12h21 [complexes::mul $h12 $h21]
    set umh11 [complexes::sub 1.0 $h11]        
    set umh22 [complexes::sub 1.0 $h22]        
    set uph11 [complexes::add 1.0 $h11]        
    set uph22 [complexes::add 1.0 $h22]        
    
    set denom [complexes::sub [complexes::mul $uph11 $uph22] $h12h21]
    set invdenom [complexes::inv $denom]
    
    set s11 [complexes::mul $invdenom [complexes::sub [complexes::neg [complexes::mul $umh11 $uph22]] $h12h21]]
    set s12 [complexes::mul $invdenom [complexes::realMul 2.0 $h12]]
    set s21 [complexes::mul $invdenom [complexes::realMul -2.0 $h21]]
    set s22 [complexes::mul $invdenom [complexes::add [complexes::mul $uph11 $umh22] $h12h21]]
    
    return [list $s11 $s12 $s21 $s22]
}

proc sparams::ZfromSdirect {s11 s12 s21 s22} {
    variable un
    
    set s12s21 [complexes::mul $s12 $s21]
    set ums11 [complexes::sub 1.0 $s11]        
    set ums22 [complexes::sub 1.0 $s22]        
    set ups11 [complexes::add 1.0 $s11]        
    set ups22 [complexes::add 1.0 $s22]        
    
    set denom [complexes::sub [complexes::mul $ums11 $ums22] $s12s21]
    set invdenom [complexes::inv $denom]
    
    set z11 [complexes::mul $invdenom [complexes::add [complexes::mul $ups11 $ums22] $s12s21]]
    set z12 [complexes::mul $invdenom [complexes::realMul 2.0 $s12]]
    set z21 [complexes::mul $invdenom [complexes::realMul 2.0 $s21]]
    set z22 [complexes::mul $invdenom [complexes::add [complexes::mul $ums11 $ups22] $s12s21]]
    
    return [list $z11 $z12 $z21 $z22]
}

proc sparams::SfromZdirect {z11 z12 z21 z22} {
    variable un
    
    set z12z21 [complexes::mul $z12 $z21]
    set umz11 [complexes::sub 1.0 $z11]        
    set umz22 [complexes::sub 1.0 $z22]        
    set upz11 [complexes::add 1.0 $z11]        
    set upz22 [complexes::add 1.0 $z22]        
    
    set denom [complexes::sub [complexes::mul $upz11 $upz22] $z12z21]
    set invdenom [complexes::inv $denom]
    
    set s11 [complexes::mul $invdenom [complexes::sub [complexes::neg [complexes::mul $umz11 $upz22]] $z12z21]]
    set s12 [complexes::mul $invdenom [complexes::realMul 2.0 $z12]]
    set s21 [complexes::mul $invdenom [complexes::realMul 2.0 $z21]]
    set s22 [complexes::mul $invdenom [complexes::sub [complexes::neg [complexes::mul $upz11 $umz22]] $z12z21]]
    
    return [list $s11 $s12 $s21 $s22]
}

proc sparams::YfromSdirect {s11 s12 s21 s22} {
    variable un
    
    set s12s21 [complexes::mul $s12 $s21]
    set ums11 [complexes::sub 1.0 $s11]        
    set ums22 [complexes::sub 1.0 $s22]        
    set ups11 [complexes::add 1.0 $s11]        
    set ups22 [complexes::add 1.0 $s22]        
    
    set denom [complexes::sub [complexes::mul $ups11 $ups22] $s12s21]
    set invdenom [complexes::inv $denom]
    
    set y11 [complexes::mul $invdenom [complexes::add [complexes::mul $ums11 $ups22] $s12s21]]
    set y12 [complexes::mul $invdenom [complexes::realMul -2.0 $s12]]
    set y21 [complexes::mul $invdenom [complexes::realMul -2.0 $s21]]
    set y22 [complexes::mul $invdenom [complexes::add [complexes::mul $ups11 $ums22] $s12s21]]
    
    return [list $y11 $y12 $y21 $y22]
}

proc sparams::SfromYdirect {y11 y12 y21 y22} {
    variable un
    
    set y12y21 [complexes::mul $y12 $y21]
    set umy11 [complexes::sub 1.0 $y11]        
    set umy22 [complexes::sub 1.0 $y22]        
    set upy11 [complexes::add 1.0 $y11]        
    set upy22 [complexes::add 1.0 $y22]        
    
    set denom [complexes::sub [complexes::mul $upy11 $upy22] $y12y21]
    set invdenom [complexes::inv $denom]
    
    set s11 [complexes::mul $invdenom [complexes::add [complexes::mul $umy11 $upy22] $y12y21]]
    set s12 [complexes::mul $invdenom [complexes::realMul -2.0 $y12]]
    set s21 [complexes::mul $invdenom [complexes::realMul -2.0 $y21]]
    set s22 [complexes::mul $invdenom [complexes::add [complexes::mul $upy11 $umy22] $y12y21]]
    
    return [list $s11 $s12 $s21 $s22]
}
