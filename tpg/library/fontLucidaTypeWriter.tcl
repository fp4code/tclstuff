package provide tpgFontLucidaTypeWriter 0.1

package require tpgPixFont 0.1

tpg::FixedFontCode LucidaTypeWriter_5x11 5 9 0 {
  0     0    000  00000    0  00000  000  00000  000   000 
 0 0   00   0   0     0    0  0     0   0     0 0   0 0   0
0   0 0 0   0   0    0    00  0     0        0  0   0 0   0
0   0   0       0   0    0 0  0 00  0        0  0   0 0   0   
0   0   0      0   000   0 0  00  0 0000    0    000   0000    
0   0   0     0       0 0  0      0 0   0   0   0   0     0
0   0   0    0        0 00000     0 0   0  0    0   0     0
 0 0    0   0     0   0    0  0   0 0   0  0    0   0 0   0
  0   00000 00000  000     0   000   000   0     000   000
} {ch_0 ch_1 ch_2 ch_3 ch_4 ch_5 ch_6 ch_7 ch_8 ch_9}

tpg::FixedFontCode LucidaTypeWriter_5x11 5 9 0 {
  0   0000   000  0000  00000 00000  000  0   0  000    000     
 0 0   0  0 0   0  0  0 0     0     0   0 0   0   0      0     
0   0  0  0 0      0  0 0     0     0     0   0   0      0      
0   0  0  0 0      0  0 0     0     0     0   0   0      0      
0   0  000  0      0  0 0000  0000  0     00000   0      0      
00000  0  0 0      0  0 0     0     0  0  0   0   0      0      
0   0  0  0 0      0  0 0     0     0   0 0   0   0      0         
0   0  0  0 0   0  0  0 0     0     0   0 0   0   0   0  0         
0   0 0000   000  0000  00000 0     0000  0   0  000   00 
} {a_maj b_maj c_maj d_maj e_maj f_maj g_maj h_maj i_maj j_maj}

proc tpg::createLucidaTypeWriterFont {sPrefix pixStep pixSize} {
    upvar LucidaTypeWriter_5x11 LucidaTypeWriter_5x11
    tpg::createPixFont LucidaTypeWriter_5x11 $sPrefix $pixStep $pixSize
}
