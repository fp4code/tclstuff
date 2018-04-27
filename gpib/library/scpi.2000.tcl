set commonCommands {
*CLS         {Clear status}                    {Clears all event registers and Error Queue}
{*ESE <NRf>} {Event enable command}            {Program the Standard Event Enable Register}
*ESE?        {Event enable query}              {Read the Standard Event Enable Register}
*ESR?        {Event status register query}     {Read the Standard Event Enable Register and clear it}
*IDN?        {Identification query}            {}
*OPC         {Operation complete command}      {}
*OPC?        {Operation complete query}        {}
*OPT?        {Option identification query}     {}
{*RCL <NRf>} {Recall Command}                  {}
*RST         {Reset command}                   {}
{*SAV <NRf>} {Save Command}                    {}
{*SRE <NRf>} {Service request enable command}  {}
*SRE?        {Service request enable query}    {}
*STB?        {Read status byte query}          {}
*TRG         {Trigger command}                 {}
*TST?        {Self-test query}                 {}
*WAI         {Wait-to-continue command}        {Wait until all previous commands are executed}
}

set SignalOrientedMeasComm {
:CONFigure:VOLTage[:DC]
:CONFigure:VOLTage:AC
:CONFigure:CURRent[:DC]
:CONFigure:CURRent:AC
:CONFigure:RESistance
:CONFigure:FRESistance
:CONFigure:PERiod
:CONFigure:FREQuency
:CONFigure:TEMPerature
:CONFigure:DIODe
:CONFigure:CONTinuity
:CONFigure?
:FETCH?
...
}

set Units {
:UNIT:TEMPerature C
:UNIT:TEMPerature F
:UNIT:TEMPerature K
:UNIT:VOLTage:AC V
:UNIT:VOLTage:AC DB
:UNIT:VOLTage:AC DBM
:UNIT:VOLTage:AC?
:UNIT:VOLTage:AC:DB:REFerence <n=1..1000>
:UNIT:VOLTage:AC:DBM:IMPedance <n=1..9999>
:UNIT:VOLTage:DC V
:UNIT:VOLTage:DC DB
:UNIT:VOLTage:DC DBM
:UNIT:VOLTage:DC?
:UNIT:VOLTage:DC:DB:REFerence <n=1..1000>
:UNIT:VOLTage:DC:DBM:IMPedance <n=1..9999>



}


{:FORMat[:DATA] ASCii} {select ASCII format}
{:FORMat[:DATA] SREal} {select single precision format}
{:FORMat[:DATA] DREal} {select double precision format}
 :FORMat[:DATA]?       {query data format}
{:FORMat:ELEMents READing[,CHANnel][,UNITs]} {}
{:FORMat:ELEMents READing[,CHANnel][,UNITs]} {}
{:FORMat:BORDer NORMal}  {normal byte order for binary format}
{:FORMat:BORDer SWAPped} {revers byte order for binary format}
 :FORMat:BORDer?       {query byte order}

<b> : 0, 1, OFF, ON

set TriggerCommands {
:INITiate[:IMMediate]    {} {}
:INITiate:CONTinuous <b> {} {}
:INITiate:CONTinuous?    {} {}

:ABORt                   {} {}

:TRIGger[:SEQuence[1]]:COUNt <n>
:TRIGger[:SEQuence[1]]:COUNt?
:TRIGger[:SEQuence[1]]:DELay <n>
...
:SAMPle:COUNt <NRf>
:SAMPle:COUNt?


}

k2000 write ":INITiate:CONTinuous OFF"
k2000 write ":ABORt"
k2000 write ":INIT"
k2000 write "*OPC"

k2000 write "*ESR?"
set toto [k2000 read]
puts "toto = $toto"


Autozero :

proc 



k2000 write ":INITiate:CONTinuous OFF; :ABORt"
k2000 write ":SYSTem:AZERo:STATe OFF; STATe?"
set toto [k2000 read]
k2000 write ":INITiate:CONTinuous ON"

k2000 write ":INITiate:CONTinuous OFF; :ABORt"
k2000 write ":SYSTem:AZERo:STATe ON; STATe?"
set toto [k2000 read]
k2000 write ":INITiate:CONTinuous ON"


k2000 write ":SYSTem:AZERo:STATe OFF; :SYSTem:AZERo:STATe?"
set toto [k2000 read]
