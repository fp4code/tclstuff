# http://www.javanti.org/en

package require html
package require struct 1
package require cmdline 1.1
package require htmlparse 0.3

set original {
<!DOCTYPE HTML PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
  <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
  <meta http-equiv="imagetoolbar" content="no">
  <meta name="author" content="Javanti.org - Christian Kohls, Tobias Windbrake">
  <meta name="publisher" content="Internet-Service Wernecke - http://www.iswernecke.de">
  <meta name="copyright" content="Javanti.org - Christian Kohls, Tobias Windbrake">
  <meta name="Content-Language" content="en">
  <meta name="language" content="en,english">
  <meta name="keywords" content="elearning,e-learning,Javanti,jtap,elearning development environment,authoring tool,SCORM,CBT,Computer Based Traning,WBT,Web Based Training,authoringtools,selfauthoring tool,content creation,education,educational software,course,course authoring,course authoring tool,course builder,course creation,course development,computer managed instruction,distance learning,online distance learning,collaborative,tool,download,IDE,Traning,University,School,Open Source,Java,XML,Windows,Linux,Mac">
  <meta name="description" content="Javanti is an Integrated Development Environment (IDE) for eLearning applications. Several assessment types and a collaborative working mode are available. The java-based software is open source and runs on Windows, Linux and Mac.">
  <meta name="Robots" content="index,follow">
  <meta name="revisit-after" content="3 weeks">
  <title>Javanti - eLearning Authoring Tool</title>
  <link rel=stylesheet type="text/css" href="/style.css">
  </head>
<body leftmargin="0" marginwidth="0" topmargin="0" marginheight="0" rightmargin="0">
<table border=0 cellpadding=0 cellspacing=0 width="100%" height="100%">
  <tr height=150>
    <td colspan=5 valign=bottom>
      <table border=0 cellpadding=0 cellspacing=0 width="100%">
        <tr>
          <td class=mittel>
            <table border=0 cellpadding=0 cellspacing=0 width=780>
              <tr>
                <td valign=top>
                  <a href="http://www.javanti.org" name=top><img src="/grafik/logo.gif" width="238" height="75" border="0" alt="Javanti"></a><br>
                  <table border=0 cellpadding=0 cellspacing=0>
                    <tr>
                      <td valign=top><a href="http://www.javanti.org"><img src="/grafik/logo1.gif" width="54" height="14" border="0" alt="Javanti"></a></td>
                      <td><img src="/grafik/blind.gif" width="53" height="22" alt=""></td>
                      <td valign=bottom><a href="/de/index.php"><img src="/grafik/deutsch.gif" width="34" height="16" border="0" alt="Deutsch"></a></td>
                      <td><img src="/grafik/blind.gif" width="5" height="1" alt=""></td>
                      <td valign=bottom><img src="/grafik/englisch1.gif" width="32" height="16" border="0" alt="English"></td>
                      <td><img src="/grafik/blind.gif" width="5" height="1" alt=""></td>
                      <td valign=bottom><img src="/grafik/spanisch1.gif" width="33" height="16" border="0" alt="Spanish"></td>
                    </tr>
                  </table>
                </td>
                <td><img src="/grafik/blind.gif" width="152" height="1" border="0" alt=""></td>
                <td valign=bottom align=center><img src="/grafik/blind.gif" width="200" height="1" alt=""><br>
                  <table border=0 cellpadding=3 cellspacing=0>
                    <form action="http://search.atomz.com/search/" method=get>
                    <input type=hidden name="sp-a" value="sp10028403">
                    <input type=hidden name="sp-f" value="ISO-8859-1">
                    <tr>
                      <td><a href="/en/suche.php" class=navia>Search:</a></td>
                      <td><input type=text size=10 name=sp-q class=search></td>
                      <td><input type=submit value=Go class=searchbt></td>
                    </tr>
                    </form>
                  </table>
                </td>
                <td valign=bottom><a href="/en/sitemap.php" onMouseOver="window.document.images[10].src='/grafik/sitemap_hover.gif';" onMouseOut="window.document.images[10].src='/grafik/sitemap.gif';"><img src="/grafik/sitemap.gif" width="55" height="26" border="0" alt="Sitemap"></a></td>
                <td align=right><img src="/grafik/foto1.gif" width="135" height="108" border="0" alt=""></td>
              </tr>
            </table>
          </td>
        </tr>
        <tr>
          <td class=dunkel>
            <table border=0 cellpadding=0 cellspacing=0 width=780>
              <tr>
                <td width=590>&nbsp;&nbsp;&nbsp;&nbsp;
                  <a href="/en/download.php" class=navitop>Download</a>&nbsp;&nbsp;&nbsp;
                  <a href="/en/javanti/dokumentation.php" class=navitop>Documentation</a>&nbsp;&nbsp;&nbsp;
                  <a href="/en/support/faq.php" class=navitop>FAQ</a>&nbsp;&nbsp;&nbsp;
                  <a href="/forum" class=navitop>Forum</a>&nbsp;&nbsp;&nbsp;
                  <a href="mailto:info@javanti.org" class=navitop>Feedback</a>
                </td>
                <td width=55 align=center><a href="/en/sitemap.php" class=navitop onMouseOver="window.document.images[10].src='/grafik/sitemap_hover.gif';" onMouseOut="window.document.images[10].src='/grafik/sitemap.gif';">Sitemap</a></td>
                <td width=135 align=right><img src="/grafik/foto2.gif" width="135" height="20" border="0" alt=""></td>
              </tr>
            </table>
          </td>
        </tr>
        <tr><td class=mittel><table border=0 cellpadding=0 cellspacing=0 width=780><tr><td align=right><img src="/grafik/foto3.gif" width="135" height="20" border="0" alt=""></td></tr></table></td></tr>
        <tr><td class=dunkel><table border=0 cellpadding=0 cellspacing=0 width=780><tr><td align=right><img src="/grafik/foto4.gif" width="135" height="2" border="0" alt=""></td></tr></table></td></tr>
      </table>
    </td>
  </tr>
  <tr height="100%">
    <td class=dunkel width=150 valign=top>
      <table border=0 cellpadding=0 cellspacing=0 width="100%">
        <tr><td class=mittel><table border=0 cellpadding=0 cellspacing=0><tr><td class=mittel><img src="/grafik/navi_2.gif" width="14" height="19" border="0" alt=""></td><td class=mittel><a href="/en/index.php" class=navia>Home</a></td></tr></table></td></tr>
        <tr><td class=mittel><img src="/grafik/blind.gif" width=1 height=3 alt=""></td></tr>
        <tr><td class=mittel><table border=0 cellpadding=0 cellspacing=0><tr><td class=mittel valign=top><img src="/grafik/navi_3.gif" width="23" height="14" border="0" alt=""></td><td class=mittel><a href="/en/index/termine.php" class=navib>Current Events</a></td></tr></table></td></tr>
        <tr><td class=mittel><img src="/grafik/blind.gif" width=1 height=2 alt=""></td></tr>
        <tr><td class=mittel><table border=0 cellpadding=0 cellspacing=0><tr><td class=mittel valign=top><img src="/grafik/navi_3.gif" width="23" height="14" border="0" alt=""></td><td class=mittel><a href="/en/index/team.php" class=navib>Team</a></td></tr></table></td></tr>
        <tr><td class=mittel><img src="/grafik/blind.gif" width=1 height=2 alt=""></td></tr>
        <tr><td class=mittel><table border=0 cellpadding=0 cellspacing=0><tr><td class=mittel valign=top><img src="/grafik/navi_3.gif" width="23" height="14" border="0" alt=""></td><td class=mittel><a href="/en/index/opensource.php" class=navib>Open Source</a></td></tr></table></td></tr>
        <tr><td class=mittel><img src="/grafik/blind.gif" width=1 height=2 alt=""></td></tr>
        <tr><td class=mittel><table border=0 cellpadding=0 cellspacing=0><tr><td class=mittel valign=top><img src="/grafik/navi_3.gif" width="23" height="14" border="0" alt=""></td><td class=mittel><a href="/en/index/beitrag.php" class=navib>Contribute</a></td></tr></table></td></tr>
        <tr><td class=mittel><img src="/grafik/blind.gif" width=1 height=2 alt=""></td></tr>
        <tr><td class=mittel><table border=0 cellpadding=0 cellspacing=0><tr><td class=mittel valign=top><img src="/grafik/navi_3.gif" width="23" height="14" border="0" alt=""></td><td class=mittel><a href="/en/index/newsletter.php" class=navib>Newsletter</a></td></tr></table></td></tr>
        <tr><td class=mittel><img src="/grafik/blind.gif" width=1 height=2 alt=""></td></tr>
        <tr><td class=mittel><img src="/grafik/blind.gif" width=1 height=3 alt=""></td></tr>
        <tr><td class=hell><img src="/grafik/blind.gif" width=1 height=1 alt=""></td></tr>
        <tr><td class=dunkel><table border=0 cellpadding=0 cellspacing=0><tr><td class=dunkel><img src="/grafik/navi_1.gif" width="14" height="19" border="0" alt=""></td><td class=dunkel><a href="/en/javanti.php" class=navi>Javanti</a></td></tr></table></td></tr>
        <tr><td class=hell><img src="/grafik/blind.gif" width=1 height=1 alt=""></td></tr>
        <tr><td class=dunkel><table border=0 cellpadding=0 cellspacing=0><tr><td class=dunkel><img src="/grafik/navi_0.gif" width="14" height="19" border="0" alt=""></td><td class=dunkel><a href="/en/download.php" class=navi>Free Download!</a></td></tr></table></td></tr>
        <tr><td class=hell><img src="/grafik/blind.gif" width=1 height=1 alt=""></td></tr>
        <tr><td class=dunkel><table border=0 cellpadding=0 cellspacing=0><tr><td class=dunkel><img src="/grafik/navi_1.gif" width="14" height="19" border="0" alt=""></td><td class=dunkel><a href="/en/exchange.php" class=navi>eXchange</a></td></tr></table></td></tr>
        <tr><td class=hell><img src="/grafik/blind.gif" width=1 height=1 alt=""></td></tr>
        <tr><td class=dunkel><table border=0 cellpadding=0 cellspacing=0><tr><td class=dunkel><img src="/grafik/navi_1.gif" width="14" height="19" border="0" alt=""></td><td class=dunkel><a href="/en/support.php" class=navi>Support</a></td></tr></table></td></tr>
        <tr><td class=hell><img src="/grafik/blind.gif" width=1 height=1 alt=""></td></tr>
        <tr><td class=dunkel><table border=0 cellpadding=0 cellspacing=0><tr><td class=dunkel><img src="/grafik/navi_1.gif" width="14" height="19" border="0" alt=""></td><td class=dunkel><a href="/en/elearning.php" class=navi>eLearning</a></td></tr></table></td></tr>
        <tr><td class=hell><img src="/grafik/blind.gif" width=1 height=1 alt=""></td></tr>
        <tr><td class=dunkel><table border=0 cellpadding=0 cellspacing=0><tr><td class=dunkel><img src="/grafik/navi_1.gif" width="14" height="19" border="0" alt=""></td><td class=dunkel><a href="/en/development.php" class=navi>Development</a></td></tr></table></td></tr>
        <tr><td class=hell><img src="/grafik/blind.gif" width=1 height=1 alt=""></td></tr>
      </table>    <br><img src="/grafik/blind.gif" width="150" height="1" alt="">
    </td>
    <td class=dunkel><img src="/grafik/blind.gif" width="2" height="1" alt=""></td>
    <td class=weiss valign=top><img src="/grafik/blind.gif" width="626" height="1" alt=""><br>
          <table border=0 cellpadding=10 cellspacing=0 width=626><tr><td>
      <table border=0 cellpadding=0 cellspacing=0 width=606>
        <tr>
          <td valign=top>
          <p class=ueber>Welcome to Javanti</p>
          <span style="font-weight:bold; color:#A06A67;">Javanti</span> is an Integrated Development Environment (IDE) for
          interactive presentations and eLearning applications. It allows you to easily create virtual, interactive slides
          for your presentation, lecture or training session.<p>
          <span style="font-weight:bold; color:#A06A67;">Javanti</span> slides can contain static and dynamic elements,
          from simple text to complex simulations and experiments.<p>
          <span style="font-weight:bold; color:#A06A67;">Javanti</span> is Open Source and runs on all common
          operating systems, e.g. Windows, Linux and MacOS.<p><br>
          <table border=0 cellpadding=0 cellspacing=0 width="100%"><tr><td class=dunkel>
          <table border=0 cellpadding=3 cellspacing=1 width="100%">
            <tr><td class=dunkel><b>News</b></td></tr>
            <tr><td class=weiss>
          <table border=0 cellpadding=3 cellspacing=0>
            <tr>
              <td class=weiss valign=top nowrap><p class=startsmall>2003-03-28</p></td>
              <td class=weiss valign=top><p class=small>Visit us at trade fair <b>Bildungsmesse</b> in Nuremberg (Germany) in hall 8, booth 418. CU there! :) <span style="font-size:8pt;">[<a href="javanti/termine.php" class=small>more</a>]</span></p></td>
            </tr>
            <tr>
              <td class=weiss valign=top nowrap><p class=startsmall>2003-03-21</p></td>
              <td class=weiss valign=top><p class=small>Austrian Mac magazine <b>mac.time</b> publishes article about Javanti (issue 2/03). Read here... <span style="font-size:8pt;">[<a href="http://www.javanti.de/download/download.php?id=16" class=small>more</a>]</span></p></td>
            </tr>
            <tr>
              <td class=weiss valign=top nowrap><p class=startsmall>2003-03-19</p></td>
              <td class=weiss valign=top><p class=small><b>New release 1.9.1</b> can be downloaded now! <span style="font-size:8pt;">[<a href="download.php" class=small>more</a>]</span></p></td>
            </tr>
            <tr>
              <td class=weiss valign=top nowrap><p class=startsmall>2003-03-14</p></td>
              <td class=weiss valign=top><p class=small><b>CeBIT 2003</b> - Visit us in hall 11, booth B14 (e-Region SH) on Sunday or Monday. CU there! :)</p></td>
            </tr>
            <tr>
              <td class=weiss valign=top nowrap><p class=startsmall>2003-03-06</p></td>
              <td class=weiss valign=top><p class=small>Screenshots of Javanti - now online ... <span style="font-size:8pt;">[<a href="javanti/screenshots.php" class=small>more</a>]</span></p></td>
            </tr>
            <tr>
              <td class=weiss valign=top nowrap><p class=startsmall>2003-03-05</p></td>
              <td class=weiss valign=top><p class=small>Our eXchange/Tutorials section has been restructured and improved. Have a look ... <span style="font-size:8pt;">[<a href="exchange/tutorial.php" class=small>more</a>]</span></p></td>
            </tr>
            <tr>
              <td class=weiss valign=top nowrap><p class=startsmall>2003-02-27</p></td>
              <td class=weiss valign=top><p class=small>;login: The Magazine of USENIX & SAGE publishes article about Javanti. Read here ... <span style="font-size:8pt;">[<a href="javanti/presse.php" class=small>more</a>]</span></p></td>
            </tr>
<tr><td class=weiss align=right colspan=2><a href="archiv.php" class=small>Older News</a></td></tr>          </table>            </td></tr>
          </table>
          </td></tr></table>
          <br><br></td>
          <td><img src="/grafik/blind.gif" width="10" height="1" alt=""></td>
          <td valign=top align=center><img src="/grafik/blind.gif" width="190" height="1" alt=""><br>
            <table border=0 cellpadding=0 cellspacing=0 width=190><tr><td class=dunkel>
            <table border=0 cellpadding=3 cellspacing=1 width=190>
              <tr><td class=dunkel><p class=boxtopic>XML</p></td></tr>
              <tr><td class=hell><p class=small>Javanti´s file format is based on XML.</p></td></tr>
            </table>
            </td></tr></table><br>
            <table border=0 cellpadding=0 cellspacing=0 width=190><tr><td class=dunkel>
            <table border=0 cellpadding=3 cellspacing=1 width=190>
              <tr><td class=dunkel><p class=boxtopic>LaTeX</p></td></tr>
              <tr><td class=hell><p class=small>HotEqn, a software to display mathematical equations using LaTeX notation, was transformed into a Javanti Smart Element in a cooperation with the Ruhr-Universitaet Bochum.</p></td></tr>
            </table>
            </td></tr></table><br>
            <table border=0 cellpadding=0 cellspacing=0 width=190><tr><td class=dunkel>
            <table border=0 cellpadding=3 cellspacing=1 width=190>
              <tr><td class=dunkel><p class=boxtopic>Language</p></td></tr>
              <tr><td class=hell><p class=small>Javanti is available in English and German now.</p></td></tr>
            </table>
            </td></tr></table><br>
            <br><a href="index/termine.php" target="_blank"><img src="/grafik/logos/bildungsmesse.gif" width="120" height="44" border="0" alt="Bildungsmesse 2003"></a><br><br>

            <br><a href="http://www.elearningday.de" target="_blank"><img src="/grafik/logos/eld2003.jpg" width="140" height="55" border="0" alt="eLearning Day 2003"></a><br><br>

            <br><a href="http://www.e-region-sh.de/" target="_blank"><img src="/grafik/logos/e-region.gif" width="120" height="32" border="0" alt="e-Region SH"></a><br><br>

          </td>
        </tr>
      </table>
          <br><br></td></tr></table>
    </td>
    <td class=dunkel><img src="/grafik/blind.gif" width="2" height="1" alt=""></td>
    <td class=hell width="100%"><img src="/grafik/blind.gif" width="1" height="1" alt=""></td>
  </tr>
  <tr height=2><td class=dunkel colspan=5><img src="/grafik/blind.gif" width="1" height="2" alt=""></td></tr>
  <tr height=20>
    <td class=dunkel colspan=2><img src="/grafik/blind.gif" width="1" height="20" alt=""></td>
    <td class=mittel>
      <table border=0 cellpadding=0 cellspacing=0 width="100%">
        <tr>
          <td>&nbsp;&nbsp;<a href="/en/impressum.php" class=navibottom>Disclaimer</a></td>
          <td align=right><p class=bottom>
            <a href="http://www.javanti.org/en/?print=show" class=navibottom>Print version</a>&nbsp;&nbsp;|&nbsp;
            <a href="#top" class=navibottom>top</a>
          </p></td>
        </tr>
      </table>
    </td>
    <td class=mittel colspan=2><img src="/grafik/blind.gif" width="1" height="1" alt=""></td>
  </tr>
</table>
</body>
</html>
}

set new {
<!DOCTYPE HTML PUBLIC \"-//W3C//DTD HTML 4.01 Transitional//EN">
<html>
<head>
  <meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1">
  <meta http-equiv="imagetoolbar" content="no">
  <meta name="author" content="Javanti.org - Christian Kohls, Tobias Windbrake">
  <meta name="publisher" content="Internet-Service Wernecke - http://www.iswernecke.de">
  <meta name="copyright" content="Javanti.org - Christian Kohls, Tobias Windbrake">
  <meta name="Content-Language" content="en">
  <meta name="language" content="en,english">
  <meta name="keywords" content="elearning,e-learning,Javanti,jtap,elearning development environment,authoring tool,SCORM,CBT,Computer Based Traning,WBT,Web Based Training,authoringtools,selfauthoring tool,content creation,education,educational software,course,course authoring,course authoring tool,course builder,course creation,course development,computer managed instruction,distance learning,online distance learning,collaborative,tool,download,IDE,Traning,University,School,Open Source,Java,XML,Windows,Linux,Mac">
  <meta name="description" content="Javanti is an Integrated Development Environment (IDE) for eLearning applications. Several assessment types and a collaborative working mode are available. The java-based software is open source and runs on Windows, Linux and Mac.">
  <meta name="Robots" content="index,follow">
  <meta name="revisit-after" content="3 weeks">
  <title>Javanti - eLearning Authoring Tool</title>
  <link rel=stylesheet type="text/css" href="/style.css">
  </head>
<body leftmargin="0" marginwidth="0" topmargin="0" marginheight="0" rightmargin="0">
<table border=0 cellpadding=0 cellspacing=0 width="100%" height="100%">
  <tr height=150>
    <td colspan=5 valign=bottom>
      <table border=0 cellpadding=0 cellspacing=0 width="100%">
        <tr>
          <td class=mittel>
            <table border=0 cellpadding=0 cellspacing=0 width=780>
              <tr>
                <td valign=top>
                  <a href="http://www.javanti.org" name=top><img src="/grafik/logo.gif" width="238" height="75" border="0" alt="Javanti"></a><br>
                  <table border=0 cellpadding=0 cellspacing=0>
                    <tr>
                      <td valign=top><a href="http://www.javanti.org"><img src="/grafik/logo1.gif" width="54" height="14" border="0" alt="Javanti"></a></td>
                      <td><img src="/grafik/blind.gif" width="53" height="22" alt=""></td>
                      <td valign=bottom><a href="/de/index.php"><img src="/grafik/deutsch.gif" width="34" height="16" border="0" alt="Deutsch"></a></td>
                      <td><img src="/grafik/blind.gif" width="5" height="1" alt=""></td>
                      <td valign=bottom><img src="/grafik/englisch1.gif" width="32" height="16" border="0" alt="English"></td>
                      <td><img src="/grafik/blind.gif" width="5" height="1" alt=""></td>
                      <td valign=bottom><img src="/grafik/spanisch1.gif" width="33" height="16" border="0" alt="Spanish"></td>
                    </tr>
                  </table>
                </td>
                <td><img src="/grafik/blind.gif" width="152" height="1" border="0" alt=""></td>
                <td valign=bottom align=center><img src="/grafik/blind.gif" width="200" height="1" alt=""><br>
                  <table border=0 cellpadding=3 cellspacing=0>
                    <form action="http://search.atomz.com/search/" method=get>
                    <input type=hidden name="sp-a" value="sp10028403">
                    <input type=hidden name="sp-f" value="ISO-8859-1">
                    <tr>
                      <td><a href="/en/suche.php" class=navia>Search:</a></td>
                      <td><input type=text size=10 name=sp-q class=search></td>
                      <td><input type=submit value=Go class=searchbt></td>
                    </tr>
                    </form>
                  </table>
                </td>
                <td valign=bottom><a href="/en/sitemap.php" onMouseOver="window.document.images\[10\].src='/grafik/sitemap_hover.gif';" onMouseOut="window.document.images\[10\].src='/grafik/sitemap.gif';"><img src="/grafik/sitemap.gif" width="55" height="26" border="0" alt="Sitemap"></a></td>
                <td align=right><img src="/grafik/foto1.gif" width="135" height="108" border="0" alt=""></td>
              </tr>
            </table>
          </td>
        </tr>
        <tr>
          <td class=dunkel>
            <table border=0 cellpadding=0 cellspacing=0 width=780>
              <tr>
                <td width=590>&nbsp;&nbsp;&nbsp;&nbsp;
                  <a href="/en/download.php" class=navitop>Download</a>&nbsp;&nbsp;&nbsp;
                  <a href="/en/javanti/dokumentation.php" class=navitop>Documentation</a>&nbsp;&nbsp;&nbsp;
                  <a href="/en/support/faq.php" class=navitop>FAQ</a>&nbsp;&nbsp;&nbsp;
                  <a href="/forum" class=navitop>Forum</a>&nbsp;&nbsp;&nbsp;
                  <a href="mailto:info@javanti.org" class=navitop>Feedback</a>
                </td>
                <td width=55 align=center><a href="/en/sitemap.php" class=navitop onMouseOver="window.document.images\[10\].src='/grafik/sitemap_hover.gif';" onMouseOut="window.document.images\[10\].src='/grafik/sitemap.gif';">Sitemap</a></td>
                <td width=135 align=right><img src="/grafik/foto2.gif" width="135" height="20" border="0" alt=""></td>
              </tr>
            </table>
          </td>
        </tr>
        <tr><td class=mittel><table border=0 cellpadding=0 cellspacing=0 width=780><tr><td align=right><img src="/grafik/foto3.gif" width="135" height="20" border="0" alt=""></td></tr></table></td></tr>
        <tr><td class=dunkel><table border=0 cellpadding=0 cellspacing=0 width=780><tr><td align=right><img src="/grafik/foto4.gif" width="135" height="2" border="0" alt=""></td></tr></table></td></tr>
      </table>
    </td>
  </tr>
  <tr height="100%">
    <td class=dunkel width=150 valign=top>
      <table border=0 cellpadding=0 cellspacing=0 width="100%">
        <tr><td class=mittel><table border=0 cellpadding=0 cellspacing=0><tr><td class=mittel><img src="/grafik/navi_2.gif" width="14" height="19" border="0" alt=""></td><td class=mittel><a href="/en/index.php" class=navia>Home</a></td></tr></table></td></tr>
        <tr><td class=mittel><img src="/grafik/blind.gif" width=1 height=3 alt=""></td></tr>
        <tr><td class=mittel><table border=0 cellpadding=0 cellspacing=0><tr><td class=mittel valign=top><img src="/grafik/navi_3.gif" width="23" height="14" border="0" alt=""></td><td class=mittel><a href="/en/index/termine.php" class=navib>Current Events</a></td></tr></table></td></tr>
        <tr><td class=mittel><img src="/grafik/blind.gif" width=1 height=2 alt=""></td></tr>
        <tr><td class=mittel><table border=0 cellpadding=0 cellspacing=0><tr><td class=mittel valign=top><img src="/grafik/navi_3.gif" width="23" height="14" border="0" alt=""></td><td class=mittel><a href="/en/index/team.php" class=navib>Team</a></td></tr></table></td></tr>
        <tr><td class=mittel><img src="/grafik/blind.gif" width=1 height=2 alt=""></td></tr>
        <tr><td class=mittel><table border=0 cellpadding=0 cellspacing=0><tr><td class=mittel valign=top><img src="/grafik/navi_3.gif" width="23" height="14" border="0" alt=""></td><td class=mittel><a href="/en/index/opensource.php" class=navib>Open Source</a></td></tr></table></td></tr>
        <tr><td class=mittel><img src="/grafik/blind.gif" width=1 height=2 alt=""></td></tr>
        <tr><td class=mittel><table border=0 cellpadding=0 cellspacing=0><tr><td class=mittel valign=top><img src="/grafik/navi_3.gif" width="23" height="14" border="0" alt=""></td><td class=mittel><a href="/en/index/beitrag.php" class=navib>Contribute</a></td></tr></table></td></tr>
        <tr><td class=mittel><img src="/grafik/blind.gif" width=1 height=2 alt=""></td></tr>
        <tr><td class=mittel><table border=0 cellpadding=0 cellspacing=0><tr><td class=mittel valign=top><img src="/grafik/navi_3.gif" width="23" height="14" border="0" alt=""></td><td class=mittel><a href="/en/index/newsletter.php" class=navib>Newsletter</a></td></tr></table></td></tr>
        <tr><td class=mittel><img src="/grafik/blind.gif" width=1 height=2 alt=""></td></tr>
        <tr><td class=mittel><img src="/grafik/blind.gif" width=1 height=3 alt=""></td></tr>
        <tr><td class=hell><img src="/grafik/blind.gif" width=1 height=1 alt=""></td></tr>
        <tr><td class=dunkel><table border=0 cellpadding=0 cellspacing=0><tr><td class=dunkel><img src="/grafik/navi_1.gif" width="14" height="19" border="0" alt=""></td><td class=dunkel><a href="/en/javanti.php" class=navi>Javanti</a></td></tr></table></td></tr>
        <tr><td class=hell><img src="/grafik/blind.gif" width=1 height=1 alt=""></td></tr>
        <tr><td class=dunkel><table border=0 cellpadding=0 cellspacing=0><tr><td class=dunkel><img src="/grafik/navi_0.gif" width="14" height="19" border="0" alt=""></td><td class=dunkel><a href="/en/download.php" class=navi>Free Download!</a></td></tr></table></td></tr>
        <tr><td class=hell><img src="/grafik/blind.gif" width=1 height=1 alt=""></td></tr>
        <tr><td class=dunkel><table border=0 cellpadding=0 cellspacing=0><tr><td class=dunkel><img src="/grafik/navi_1.gif" width="14" height="19" border="0" alt=""></td><td class=dunkel><a href="/en/exchange.php" class=navi>eXchange</a></td></tr></table></td></tr>
        <tr><td class=hell><img src="/grafik/blind.gif" width=1 height=1 alt=""></td></tr>
        <tr><td class=dunkel><table border=0 cellpadding=0 cellspacing=0><tr><td class=dunkel><img src="/grafik/navi_1.gif" width="14" height="19" border="0" alt=""></td><td class=dunkel><a href="/en/support.php" class=navi>Support</a></td></tr></table></td></tr>
        <tr><td class=hell><img src="/grafik/blind.gif" width=1 height=1 alt=""></td></tr>
        <tr><td class=dunkel><table border=0 cellpadding=0 cellspacing=0><tr><td class=dunkel><img src="/grafik/navi_1.gif" width="14" height="19" border="0" alt=""></td><td class=dunkel><a href="/en/elearning.php" class=navi>eLearning</a></td></tr></table></td></tr>
        <tr><td class=hell><img src="/grafik/blind.gif" width=1 height=1 alt=""></td></tr>
        <tr><td class=dunkel><table border=0 cellpadding=0 cellspacing=0><tr><td class=dunkel><img src="/grafik/navi_1.gif" width="14" height="19" border="0" alt=""></td><td class=dunkel><a href="/en/development.php" class=navi>Development</a></td></tr></table></td></tr>
        <tr><td class=hell><img src="/grafik/blind.gif" width=1 height=1 alt=""></td></tr>
      </table>    <br><img src="/grafik/blind.gif" width="150" height="1" alt="">
    </td>
    <td class=dunkel><img src="/grafik/blind.gif" width="2" height="1" alt=""></td>
    <td class=weiss valign=top><img src="/grafik/blind.gif" width="626" height="1" alt=""><br>
          <table border=0 cellpadding=10 cellspacing=0 width=626><tr><td>
      <table border=0 cellpadding=0 cellspacing=0 width=606>
        <tr>
          <td valign=top>
          [pclass ueber {Welcome to Javanti}]
          <span style="font-weight:bold; color:#A06A67;">Javanti</span> is an Integrated Development Environment (IDE) for
          interactive presentations and eLearning applications. It allows you to easily create virtual, interactive slides
          for your presentation, lecture or training session.<p>
          <span style="font-weight:bold; color:#A06A67;">Javanti</span> slides can contain static and dynamic elements,
          from simple text to complex simulations and experiments.<p>
          <span style="font-weight:bold; color:#A06A67;">Javanti</span> is Open Source and runs on all common
          operating systems, e.g. Windows, Linux and MacOS.<p><br>
          <table border=0 cellpadding=0 cellspacing=0 width="100%"><tr><td class=dunkel>
          <table border=0 cellpadding=3 cellspacing=1 width="100%">
            <tr><td class=dunkel><b>News</b></td></tr>
            <tr><td class=weiss>
          <table border=0 cellpadding=3 cellspacing=0>
            [news 2003-03-28 {Visit us at trade fair <b>Bildungsmesse</b> in Nuremberg (Germany) in hall 8, booth 418. CU there! :) <span style="font-size:8pt;">[<a href="javanti/termine.php" class=small>more</a>]</span>}]
            [news 2003-03-21 {Austrian Mac magazine <b>mac.time</b> publishes article about Javanti (issue 2/03). Read here... <span style="font-size:8pt;">[<a href="http://www.javanti.de/download/download.php?id=16" class=small>more</a>]</span>}]
            [news 2003-03-19 {<b>New release 1.9.1</b> can be downloaded now! <span style="font-size:8pt;">[<a href="download.php" class=small>more</a>]</span>}]
            [news 2003-03-14 {<b>CeBIT 2003</b> - Visit us in hall 11, booth B14 (e-Region SH) on Sunday or Monday. CU there! :)}]
            [news 2003-03-06 {Screenshots of Javanti - now online ... <span style="font-size:8pt;">[<a href="javanti/screenshots.php" class=small>more</a>]</span>}]
            [news 2003-03-05 {Our eXchange/Tutorials section has been restructured and improved. Have a look ... <span style="font-size:8pt;">[<a href="exchange/tutorial.php" class=small>more</a>]</span>}]
            [news 2003-02-27 {;login: The Magazine of USENIX & SAGE publishes article about Javanti. Read here ... <span style="font-size:8pt;">[<a href="javanti/presse.php" class=small>more</a>]</span>}]
<tr><td class=weiss align=right colspan=2><a href="archiv.php" class=small>Older News</a></td></tr>          </table>            </td></tr>
          </table>
          </td></tr></table>
          <br><br></td>
          <td><img src="/grafik/blind.gif" width="10" height="1" alt=""></td>
          <td valign=top align=center><img src="/grafik/blind.gif" width="190" height="1" alt=""><br>
            <table border=0 cellpadding=0 cellspacing=0 width=190><tr><td class=dunkel>
            <table border=0 cellpadding=3 cellspacing=1 width=190>
              <tr><td class=dunkel><p class=boxtopic>XML</p></td></tr>
              <tr><td class=hell><p class=small>Javanti´s file format is based on XML.</p></td></tr>
            </table>
            </td></tr></table><br>
            <table border=0 cellpadding=0 cellspacing=0 width=190><tr><td class=dunkel>
            <table border=0 cellpadding=3 cellspacing=1 width=190>
              <tr><td class=dunkel><p class=boxtopic>LaTeX</p></td></tr>
              <tr><td class=hell><p class=small>HotEqn, a software to display mathematical equations using LaTeX notation, was transformed into a Javanti Smart Element in a cooperation with the Ruhr-Universitaet Bochum.</p></td></tr>
            </table>
            </td></tr></table><br>
            <table border=0 cellpadding=0 cellspacing=0 width=190><tr><td class=dunkel>
            <table border=0 cellpadding=3 cellspacing=1 width=190>
              <tr><td class=dunkel><p class=boxtopic>Language</p></td></tr>
              <tr><td class=hell><p class=small>Javanti is available in English and German now.</p></td></tr>
            </table>
            </td></tr></table><br>
            <br><a href="index/termine.php" target="_blank"><img src="/grafik/logos/bildungsmesse.gif" width="120" height="44" border="0" alt="Bildungsmesse 2003"></a><br><br>

            <br><a href="http://www.elearningday.de" target="_blank"><img src="/grafik/logos/eld2003.jpg" width="140" height="55" border="0" alt="eLearning Day 2003"></a><br><br>

            <br><a href="http://www.e-region-sh.de/" target="_blank"><img src="/grafik/logos/e-region.gif" width="120" height="32" border="0" alt="e-Region SH"></a><br><br>

          </td>
        </tr>
      </table>
          <br><br></td></tr></table>
    </td>
    <td class=dunkel><img src="/grafik/blind.gif" width="2" height="1" alt=""></td>
    <td class=hell width="100%"><img src="/grafik/blind.gif" width="1" height="1" alt=""></td>
  </tr>
  <tr height=2><td class=dunkel colspan=5><img src="/grafik/blind.gif" width="1" height="2" alt=""></td></tr>
  <tr height=20>
    <td class=dunkel colspan=2><img src="/grafik/blind.gif" width="1" height="20" alt=""></td>
    <td class=mittel>
      <table border=0 cellpadding=0 cellspacing=0 width="100%">
        <tr>
          <td>&nbsp;&nbsp;<a href="/en/impressum.php" class=navibottom>Disclaimer</a></td>
          <td align=right><p class=bottom>
            <a href="http://www.javanti.org/en/?print=show" class=navibottom>Print version</a>&nbsp;&nbsp;|&nbsp;
            <a href="#top" class=navibottom>top</a>
          </p></td>
        </tr>
      </table>
    </td>
    <td class=mittel colspan=2><img src="/grafik/blind.gif" width="1" height="1" alt=""></td>
  </tr>
</table>
</body>
</html>
}

catch {t destroy}
struct::tree t
htmlparse::2tree $original t
foreach b {hmstart} {
    set OPEN($b) 0; set PCDATA($b) 0; set CLOSE($b) 0; set BR($b) 0
}
foreach b {PCDATA} {
    set OPEN($b) 0; set PCDATA($b) 1; set CLOSE($b) 0; set BR($b) 0
}
foreach b {img} {
    set OPEN($b) 1; set PCDATA($b) 0; set CLOSE($b) 0; set BR($b) 0
}
foreach b {br input link meta} {
    set OPEN($b) 1; set PCDATA($b) 0; set CLOSE($b) 0; set BR($b) 1
}
foreach b {a b span} {
    set OPEN($b) 1; set PCDATA($b) 0; set CLOSE($b) 1; set BR($b) 0
}
foreach b {body form head html p table td title tr} {
    set OPEN($b) 1; set PCDATA($b) 0; set CLOSE($b) 1; set BR($b) 1
}

proc wawa {&prevBR &html indent node} {
    upvar ${&html} html
    upvar ${&prevBR} prevBR
    global TYPES OPEN PCDATA CLOSE BR
    if {[t keys $node] != "type data"} {
	return -code error "Special node : $node, keys = [t keys $node]"
    }
    set type [t get $node -key type]
    set data [t get $node -key data]
    set TYPES($type) {}
    puts "$indent[list $type $data]"
    if {$OPEN($type)} {
	if {$prevBR || $BR($type)} {
	    append html \n
	}
	set prevBR $BR($type)
	append html "<$type"
	if {$data != {}} {
	    append html " $data"
	}
	if {!$CLOSE($type)} {
	    append html " /"
	}
	append html ">"
    }
    if {$PCDATA($type)} {
	append html "$data"
	set prevBR $BR($type)
    }
    append indent " "
    foreach n [t children $node] {
	wawa prevBR html $indent $n
    }
    if {$CLOSE($type)} {
	append html "</$type>"
	set prevBR $BR($type)
    }
    return $html
}

set prevBR 0
set html ""
wawa prevBR html "" node1

set ff [open ~/Z/t.html w]
puts $ff $html
close $ff
puts stderr "tidy err = [catch {exec tidy /home/fab/Z/t.html > /home/fab/Z/t2.html} m]"
puts stderr $m
 


puts [lsort [array names TYPES]]





proc out {s file} {
    if {[string index $s 0] != "\n"} {
	return -code error "Manque \\n au début"
    }
    if {[string index $s end] != "\n"} {
	return -code error "Manque \\n au début"
    }
    set f [open ~/Z/$file w]
    puts $f [string range $s 1 end-1]
    close $f
}

proc pclass {class string} {
    return "<p class=$class>$string</p>"
}

proc td_weiss_nowrap {string} {
     return "<td class=weiss valign=top nowrap>[pclass startsmall $string]</td>"
}

proc indent {n} {
     return {}
}

proc news {date blabla} {
    set ret ""
    append ret {<tr>
              }
    append ret [td_weiss_nowrap $date][indent 0]
    append ret {
              <td class=weiss valign=top><p class=small>}
    append ret $blabla</p></td>
    append ret {
            </tr>}
    return $ret
}

set new2 [subst $new]
if {$new2 != $original} {
    out $original original.html
    out $new2 new.html
    exec tkdiff $env(HOME)/Z/original.html $env(HOME)/Z/new.html
}

