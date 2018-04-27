# 2009-09-09 (PB + FP)


:*RST
:TRAC:CLE                     â€˜clear buffer and set for 2000 readings
:TRAC:POIN 2000
:STAT:MEAS:ENAB 512    â€˜generate an SRQ upon buffer full (GPIB only!)
:*SRE 1
:TRIG:COUN 2000         â€˜trigger count fonctionne 5000s (25ms par cycle)
:SYST:AZER:STAT OFF    â€˜Auto Zero off
:SOUR:FUNC CURR               â€˜source current
:SENS:FUNC:CONC OFF    â€˜concurrent readings off
:SENS:FUNC VOLT             â€˜measure voltage

set NPLC 1

:SENS:VOLT:NPLC $NPLC
:SENS:VOLT:RANG 20
:SENS:VOLT:PROT:LEV 10 â€˜voltage compliance
:FORM:ELEM VOLT,CURR,TIME,STAT               â€˜read back voltage only
:SOUR:CURR 1               â€˜source current level 1A

100 ms on 900 ms off

0.9 - 0.000225

set tau_on 0.1
set tau_off 0.9

:TRIG:DEL [format %.6f [expr {$tau_off - 0.000225}]]
:SOUR:DEL [format %.6f [expr {$tau_on - 50e-6 - $NPLC/50.0 + 185e-6}]]

:TRAC:FEED:CONT NEXT # sinon pas de stockage des mesures
:SOUR:CLE:AUTO ON    # source-on automatique
:DISP:ENAB OFF       #  â€˜display set up
:INIT


â€˜On receiving SRQ.
:TRAC:DATA?
â€˜Enter 10K bytes of data from 2400 & process data
â€˜clean up registers
*RST;
*CLS;
*SRE 0;
:STAT:MEAS:ENAB 0
