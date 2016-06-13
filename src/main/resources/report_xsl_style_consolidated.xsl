<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:regexp="http://exslt.org/regular-expressions"
                xmlns:math="http://exslt.org/math"
                xmlns:testng="http://testng.org"
                xmlns:xs="http://www.w3.org/2001/XMLSchema"
                xmlns:f="Functions">

    <xsl:output method="html" indent="yes" omit-xml-declaration="yes"
                doctype-public="-//W3C//DTD XHTML 1.0 Transitional//EN"
                doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd"/>
    <xsl:output name="text" method="text"/>
    <xsl:output name="xml" method="xml" indent="yes"/>
    <xsl:output name="html" method="html" indent="yes" omit-xml-declaration="yes"/>
    <xsl:output name="xhtml" method="xhtml" indent="yes" omit-xml-declaration="yes"/>

    <xsl:param name="testNgXslt.outputDir"/>
    <xsl:param name="testNgXslt.cssFile"/>
    <xsl:param name="testNgXslt.showRuntimeTotals"/>
    <xsl:param name="testNgXslt.reportTitle"/>
    <xsl:param name="testNgXslt.sortTestCaseLinks"/>
    <xsl:param name="testNgXslt.chartScaleFactor"/>
    <xsl:param name="testNgXslt.testDetailsFilter"/>


    <!--<xsl:variable name="properties" select="unparsed-text('../config/Settings.ini')" as="xs:string"/>-->

    <!--    <xsl:function name="f:getProperty" as="xs:string?">
        <xsl:param name="key" as="xs:string"/>
        <xsl:variable name="lines" as="xs:string*" select="
          for $x in
            for $i in tokenize($properties, '\n')[matches(., '^[^!#]')] return
              tokenize($i, '=')
            return translate(normalize-space($x), '\', '')"/>
        <xsl:sequence select="$lines[index-of($lines, $key)+1]"/>
    </xsl:function>-->

    <xsl:variable name="testDetailsFilter"
                  select="if ($testNgXslt.testDetailsFilter) then $testNgXslt.testDetailsFilter else 'FAIL,PASS,SKIP'"/>

    <xsl:variable name="chartWidth" select="round(600 * testng:getVariableSafe($testNgXslt.chartScaleFactor, 1))"/>
    <xsl:variable name="chartHeight" select="round(200 * testng:getVariableSafe($testNgXslt.chartScaleFactor, 1))"/>

    <xsl:template name="writeCssFile">
        <xsl:result-document href="{testng:absolutePath('style.css')}" format="text">
            <xsl:choose>
                <xsl:when test="testng:isFilterSelected('CONF') = 'true'">
                    .testMethodStatusCONF { }
                </xsl:when>
                <xsl:otherwise>
                    .testMethodStatusCONF { display: none; }
                </xsl:otherwise>
            </xsl:choose>

            <xsl:choose>
                <xsl:when test="testng:isFilterSelected('FAIL') = 'true'">
                    .testMethodStatusFAIL { background-color: #FFBBBB; }
                </xsl:when>
                <xsl:otherwise>
                    .testMethodStatusFAIL { background-color: #FFBBBB; display: none; }
                </xsl:otherwise>
            </xsl:choose>

            <xsl:choose>
                <xsl:when test="testng:isFilterSelected('PASS') = 'true'">
                    .testMethodStatusPASS { background-color: lightgreen; }
                </xsl:when>
                <xsl:otherwise>
                    .testMethodStatusPASS { background-color: lightgreen; display: none; }
                </xsl:otherwise>
            </xsl:choose>

            <xsl:choose>
                <xsl:when test="testng:isFilterSelected('SKIP') = 'true'">
                    .testMethodStatusSKIP { background-color: #FFFFBB; }
                </xsl:when>
                <xsl:otherwise>
                    .testMethodStatusSKIP { background-color: #FFFFBB; display: none; }
                </xsl:otherwise>
            </xsl:choose>

            <![CDATA[
                    .testMethodStatusCONF { display: none; }

                    .testMethodStatusFAIL { background-color: #FFBBBB; }

                    .testMethodStatusPASS { background-color: lightgreen; }

                    .testMethodStatusSKIP { background-color: #FFFFBB; }


            body { font-family: Arial, sans-serif; font-size: 12px; padding: 10px; margin: 0px; background:white url('images/jenkins-icon.png') no-repeat scroll top right; }
            a, a:hover, a:active, a:visited { color: navy; }

            .suiteMenuHeader { margin-top: 10px; }
            .suiteMenuHeader td { padding: 5px; background-color: #e0e0e0; font-size: 12px; width: 100%; vertical-align: top; }

            .suiteStatusPass, .suiteStatusFail, .suiteStatus { padding-right: 20px; width: 20px; height: 20px; margin: 2px 4px 2px 2px; display: inline; }
            .suiteStatusPass { background-color: green; }
            .suiteStatusFail { background-color: red; }
            .suiteStatus { border:2px solid #f5f5f5; background-color: #f5f5f5; }

            .testCaseLink, .testCaseLinkSelected { margin-top: 2px; padding: 4px; cursor: pointer; }
            .testCaseLink { background-color: #f6f6f6; }
            .testCaseLinkSelected { background-color: lightblue; border: 1px solid gray;  padding: 3px; }
            .testCaseFail, .testCasePass, .testCaseSkip { padding-right: 15px; width: 15px; height: 15px; margin: 2px 4px 2px 2px; display: inline; }
            .testCaseFail { background-color: red; }
            .testCasePass { background-color: green; }
            .testCaseSkip { background-color: yellow; }

            tr.methodsTableHeader { background-color: #cedcec; font-weight: bold; }
            tr.methodsTableHeader td { padding: 3px; }

			tr.serviceRunTableHeader { background-color: #eaf0f7; font-weight: bold; }
            tr.serviceRunTableHeader td { padding: 3px; }

            .testMethodStatusFAIL a, .testMethodStatusPASS a, .testMethodStatusSKIP a { text-decoration: none; cursor: pointer; font-size: 11px; font-weight: bold }
			.testMethodStatusFAIL td, .testMethodStatusPASS td, .testMethodStatusSKIP td { padding: 3px; }

			.testMethodStatusPASS td { background-color: #2BCC71 }
			.testMethodStatusFAIL td { background-color: #F23838 }
			.testMethodStatusSKIP td { background-color: #f2cb27 }

			.testMethodStatusPASS td:hover  { background-color: #2CDB78; }
			.testMethodStatusFAIL td:hover  { background-color: #F05151; }
			.testMethodStatusSKIP td:hover  { background-color: #f4d44c; }

            .testMethodDetails, .testMethodDetailsVisible { padding: 5px; background-color: #EEEED0; margin: 1px; }
			.testMethodDetailsVisible td { font-size: 10px;}
            .testMethodDetails { display: none; }

            .testRunDetails { padding: 0; background-color: #f5f5f5; margin: 0; }
            .testRunDetails { display: none; }

			.testRunDetailsVisible div { padding-left: 10px; font-size: 10px;}
            .testRunDetailsVisible tr td { background-color: #EEEED0;}

			.reportDetails, .reportDetailsVisible { padding: 5px; background-color: #f5f5f5; margin: 1px; }
            .reportDetails { display: none; }

			.reportsDetails, .reportsDetailsVisible { padding: 0; background-color: #f5f5f5; margin: 0; }
            .reportsDetails { display: none; }

            .exceptionDetails, .exceptionDetailsVisible { padding: 5px; background-color: #f5f5f5; margin: 1px; }
            .exceptionDetails { display: none; }

             .logDetails, .logDetailsVisible { padding: 0; background-color: #f5f5f5; margin: 0; }
            .logDetails { display: none; }

            .testMethodsTable { margin-top: 10px; font-size: 12px; }
            .testMethodsTable td { border-width: 1px 0 0 1px; border-color: white; border-style:solid;  }
            .testMethodsTable .detailsBox { padding: 0; background-color: white; border-style: none; height: 0px; }
            .testMethodsTable .testMethodStatusCONF td.firstMethodCell { border-left: 5px solid gray; }

			.individualRunsPass td { background-color: #DBFFE2}
			.individualRuns a { font-weight: bold}

			.imgExpandClose { float: left; padding-top: 3px; padding-left: 3px; padding-right: 5px}
            ]]>
        </xsl:result-document>
    </xsl:template>


    <xsl:template name="writeDefaultCssFile">
        <xsl:result-document href="{testng:absolutePath('default.css')}" format="text">
            <![CDATA[
/*
 * ----------------------------------------------------
 * Some general stuff   -
 * ----------------------------------------------------
 */
*
{
    margin: 0px;
    padding: 0px;
}

body
{
    margin: 5px;
    padding: 0px;

    font-family: Trebuchet,"Bitstream Vera Sans",verdana,lucida,arial,helvetica,sans-serif;
    font-size: 70%;

    background-color: #e9e9e9;
}

/*
 * ----------------------------------------------------
 * Avoid scrolling problems for scroll-to by
 * using local scroll bars for wide content, applied
 * when needed.
 * ----------------------------------------------------
 */
pre
{
    overflow: auto;
}

/*
 * ----------------------------------------------------
 * Headlines
 * ----------------------------------------------------
 */
h1
{
    font-size: 20px;
    font-weight: bold;
}
h2
{
    font-size: 16px;
    font-weight: bold;
}
h3
{
    font-size: 14px;
    font-weight: bold;
}

/*
 * ----------------------------------------------------
 * The global anchor definitions
 * ----------------------------------------------------
 */
a
{
    color: #3d5376;
    text-decoration: none;
}
    a:hover
    {
        color: #3d5376;
        text-decoration: underline;
    }
    a:visited
    {
        color: #3d5376;
    }

/*
 * Global container for the page
 */
#container
{
    background-color: #e9e9e9;
}

/*
 * ----------------------------------------------------
 * The content section. Holds header, navigation, data, footer.
 * No direct need at the moment, maybe for future use.
 * ----------------------------------------------------
 */
#content
{
}

/*
 * ----------------------------------------------------
 * Headers
 * ----------------------------------------------------
 */
#header
{
    background-color: #dAA163;
    border: 1px solid #bbb;

    /*
        This is not 100% standard conform, but gives us
        rounded corners for CSS 3 and in some supporting browsers
        even before that. Will fall back to standard corners
        in all other browsers.
    */
    border-radius: 4px;
    -moz-border-radius: 4px;
    -webkit-border-radius: 4px;
    -khtml-border-radius: 4px;
    padding: 15px 10px 15px 15px;
}
    #header .logo
    {
        margin-right: 20px;
        float: left;
    }
    #header h1
    {
        font-size: 250%;
        font-weight: bold;

        color: #f9f9f9;
    }
	#header h2
    {
        font-size: 120%;
        font-weight: normal;
        text-align: left;
        color: #f9f9f9;
        padding-left:2px;
    }
    	#header h2 .productversion
    	{
    		padding-left: 0.5em;
    	}

        #header h2 a
        {
            color: #f9f9f9;
        }

/*
 * ----------------------------------------------------
 * The navigation that is places right upper corner.
 * ----------------------------------------------------
 */
#navigation
{
    position: fixed;
    top: 10px;
    right: 10px;
    width: 15em;

    border: 1px solid #aaa;
    font-size: 11px;
    padding: 5px;
    color: #333;
    background-color: White;

    border-radius: 4px;
    -moz-border-radius: 4px;
    -webkit-border-radius: 4px;
    -khtml-border-radius: 4px;
    z-index:100;
}
    #navigation h2
    {
        text-align: right;
        padding: 0px;
        color: #3D5376;
        font-size: 11px;
    }
    #navigation ul
    {
        margin: 5px;
        text-align: right;
    }
        #navigation ul li
        {
            list-style-type: none;
        }


/*
 * ----------------------------------------------------
 * Data Content section to hold all the reports and
 * data tables.
 * ----------------------------------------------------
 */
#data-content
{
    padding: 0px;
}

/*
 * ----------------------------------------------------
 * The footer.
 * ----------------------------------------------------
 */
#footer
{
    padding: 10px 5px;
    margin-top: 5px;
    margin-bottom: 5px;
    text-align:center;
    font-size: 11px;

    border: 1px solid #aaa;
    background-color: #EAA163;
    color: #f9f9f9;

    border-radius: 4px;
    -moz-border-radius: 4px;
    -webkit-border-radius: 4px;
    -khtml-border-radius: 4px;
}
    #footer a
    {
        color: #f9f9f9;
    }

/*
 * ----------------------------------------------------
 * The most important data container, the table
 * with all these beautful numbers.
 * ----------------------------------------------------
 */
table
{
    width: 100%;
    border-spacing: 1px;

    /* get wide tables displayed nicely */
    overflow: scroll;

    empty-cells: show;
}
    table thead td, th
    {
        background-color: #F0DCA9;
        padding: 4px;
		text-align: left;
    }
    table tfoot td
    {
        background-color: #F0DCA9;
        padding: 4px;
    }
    table th
    {
        background-color: #f0dCa9;
        white-space: nowrap;
        padding-left: 5px;
        padding-right: 6px;
    }
        table th.table-sortable
        {
            background: #f0dCa9 url(../images/01_unsorted.gif) right no-repeat;
        }
        table th.table-sorted-asc
        {
            background: #f0cCa9  url(../images/01_ascending.gif) right no-repeat;
        }
        table th.table-sorted-desc
        {
            background: #f0cCa9  url(../images/01_descending.gif) right no-repeat;
        }
    table td
    {
        /*background-color: #eeeed0; */

        padding: 2px 4px;
        vertical-align: top;
    }

    	/*
    		Hover effect for tables. Clean lines
    	 	It uses CSS 3 for the left and right border effect.
    	 */
        table tr td
        {
			border-top: 1px solid transparent;
			border-bottom: 1px solid transparent;
        }
	        table tr td:first-child
	        {
				border-left: 1px solid transparent;
	        }
	        table tr td:last-child
	        {
				border-right: 1px solid transparent;
	        }




        /* format total rows in bold */
        table tr.totals
        {
            font-weight: bold;
        }
        table tr.totals td.key
        {
            text-align: right;
        }

        table tr.odd td
        {
            background-color: #f5f5f0;
        }

        table td.key
        {
            text-align: left;
			white-space: nowrap;
        }
            table td.key div.cluetip-data
            {
                display: none;
            }
        table td.value
        {
            text-align: right;
        }
        table td.text
        {
            text-align: left;
        }
        table td.centeredtext
        {
            text-align: center;
        }
		table td.number
        {
            text-align: right;
        }
        table td.link
        {
            text-align: center;
        }
        table td.error
        {
            color: Red;
        }
        table td.event
        {
            color: #cc6600;
        }
        /* Style the directory entry in the error table */
        table td.directory
        {
            white-space: nowrap;
        }

/*
 * ----------------------------------------------------
 * The data within a specific reporting topic
 * ----------------------------------------------------
 */
.section
{
    margin-top: 8px;
    margin-bottom: 8px;
    background-color: White;
    -moz-border-radius: 4px;
    -webkit-border-radius: 4px;
    -khtml-border-radius: 4px;
    border-radius: 4px;
    border: 1px solid #bbb;

    padding: 5px;
}
    .section h2
    {
        background-color: White;
        border-bottom: 2px solid #2F4782;
        padding: 5px 10px 2px 5px;
        color: #2F4782;
    }

    .section h3
    {
		border-bottom: 1px dashed #2F4782;
        margin: 20px 0px 5px 0px;
        padding: 2px 5px;
        color: #3D5376;
    }
        .section .description h3
        {
            display: none;
        }

    .section p
    {
        margin: 5px 0px;
        padding: 2px 5px;

        text-align: justify;
    }

.subsection
{
    margin-top: 8px;
    margin-bottom: 8px;
}

/*
 * ----------------------------------------------------
 * The chart area, usually as tabs, but sometimes standalone.
 * You find the tab stuff below.
 * ----------------------------------------------------
 */
.charts
{
    text-align: center;
    margin: 10px 50px;
}
    .charts .chart
    {

        text-align: center;
    }
        .charts .chart img
        {
            border: 1px solid #bbb;
        }

/*
 * ----------------------------------------------------
 * The tool tips and their styling
 * ----------------------------------------------------
*/
#cluetip
{
    width: auto !important;
    font-size: 10px;
    max-width: 95%;
}
    #cluetip #cluetip-inner
    {
        padding: 2px;
        overflow: hidden;

        border: 1px solid #bbb;

        background-color: White;
    }
    #cluetip h4
    {
        font-size: 10px;
        background-color:#f0cca9;
        padding: 5px 5px;
    }
    #cluetip ul.urls
    {
        padding:0px;
        margin: 0px;
    }
        #cluetip li
        {
            padding: 2px 5px;
            list-style-type: none;
        }
        #cluetip li.even
        {
            background-color: #e9e9d2;
        }
        #cluetip li.odd
        {
        }


/*
 * ----------------------------------------------------
 * Tabs
 * ----------------------------------------------------
 */
.ui-tabs
{
    margin: 5px 0px;
    padding: 10px;
}
    .ui-tabs .ui-tabs-nav
    {
        text-align: left;
        list-style: none;
        padding: 0px;
        margin: 0px;
    }
        .ui-tabs .ui-tabs-nav ul
        {
            list-style: none;
            padding: 5px;
            margin: 0;
        }
        .ui-tabs .ui-tabs-nav li
        {
            display: inline;
            cursor: pointer;
            position: relative;
            z-index: 0;
            border: 1px solid #bbb;
            margin: 0 5px -1px 0;
            padding: 5px 0px 0px 0px;
            background-color: #e9e9e9;

            border-top-left-radius: 4px;
            border-top-right-radius: 4px;
            -moz-border-radius-topleft: 4px;
            -moz-border-radius-topright: 4px;
            -webkit-border-top-left-radius: 4px;
            -webkit-border-top-right-radius: 4px;
            -khtml-border-top-right-radius: 4px;
            -khtml-border-top-left-radius: 4px;
        }
            .ui-tabs .ui-tabs-nav li a
            {
                text-decoration: none;
                padding: 0px 20px;
            }
            .ui-tabs .ui-tabs-nav li.ui-tabs-selected
            {
                padding-bottom: 1px;
                border-bottom-width: 0;
                background-color: White;
            }
        .ui-tabs .ui-tabs-panel
        {
            border-radius: 4px;
            -moz-border-radius: 4px;
            -webkit-border-radius: 4px;
            -khtml-border-radius: 4px;

            border-top-left-radius: 0px;
            -moz-border-radius-topleft: 0px;
            -webkit-border-top-left-radius: 0px;
            -khtml-border-top-left-radius: 0px;

            padding: 5px;
            border: 1px solid #bbb;
            background-color: White;
        }

        .ui-tabs .ui-tabs-hide
        {
            display: none !important;
        }


/*
 * ----------------------------------------------------
 * Diff report color coding
 * ----------------------------------------------------
 */
.p0                                                        { background-color: rgb(245,245,245) !important; }
.p1, .p2, .p3, .p4, .p5, .p6, .p7, .p8, .p9                { background-color: rgb(248,250,248) !important; }
.p10, .p11, .p12, .p13, .p14, .p15, .p16, .p17, .p18, .p19 { background-color: rgb(241,246,241) !important; }
.p20, .p21, .p22, .p23, .p24, .p25, .p26, .p27, .p28, .p29 { background-color: rgb(226,236,226) !important; }
.p30, .p31, .p32, .p33, .p34, .p35, .p36, .p37, .p38, .p39 { background-color: rgb(212,227,212) !important; }
.p40, .p41, .p42, .p43, .p44, .p45, .p46, .p47, .p48, .p49 { background-color: rgb(197,217,197) !important; }
.p50, .p51, .p52, .p53, .p54, .p55, .p56, .p57, .p58, .p59 { background-color: rgb(183,208,183) !important; }
.p60, .p61, .p62, .p63, .p64, .p65, .p66, .p67, .p68, .p69 { background-color: rgb(168,198,168) !important; }
.p70, .p71, .p72, .p73, .p74, .p75, .p76, .p77, .p78, .p79 { background-color: rgb(154,189,154) !important; }
.p80, .p81, .p82, .p83, .p84, .p85, .p86, .p87, .p88, .p89 { background-color: rgb(139,179,139) !important; }
.p90, .p91, .p92, .p93, .p94, .p95, .p96, .p97, .p98, .p99 { background-color: rgb(125,170,125) !important; }
.p100                                                      { background-color: rgb(110,160,110) !important; }

.n0                                                        { background-color: rgb(245,245,245) !important; }
.n1, .n2, .n3, .n4, .n5, .n6, .n7, .n8, .n9                { background-color: rgb(253,248,248) !important; }
.n10, .n11, .n12, .n13, .n14, .n15, .n16, .n17, .n18, .n19 { background-color: rgb(250,242,242) !important; }
.n20, .n21, .n22, .n23, .n24, .n25, .n26, .n27, .n28, .n29 { background-color: rgb(244,228,228) !important; }
.n30, .n31, .n32, .n33, .n34, .n35, .n36, .n37, .n38, .n39 { background-color: rgb(239,215,215) !important; }
.n40, .n41, .n42, .n43, .n44, .n45, .n46, .n47, .n48, .n49 { background-color: rgb(233,201,201) !important; }
.n50, .n51, .n52, .n53, .n54, .n55, .n56, .n57, .n58, .n59 { background-color: rgb(228,188,188) !important; }
.n60, .n61, .n62, .n63, .n64, .n65, .n66, .n67, .n68, .n69 { background-color: rgb(222,174,174) !important; }
.n70, .n71, .n72, .n73, .n74, .n75, .n76, .n77, .n78, .n79 { background-color: rgb(217,161,161) !important; }
.n80, .n81, .n82, .n83, .n84, .n85, .n86, .n87, .n88, .n89 { background-color: rgb(211,147,147) !important; }
.n90, .n91, .n92, .n93, .n94, .n95, .n96, .n97, .n98, .n99 { background-color: rgb(206,134,134) !important; }
.n100                                                      { background-color: rgb(200,120,120) !important; }

.added    { color: #888 !important;}
.removed  { color: #888 !important;}
.infinity { background-color: rgb(200,120,120) !important;}

            ]]>
        </xsl:result-document>
    </xsl:template>

    <xsl:template name="writeJsFile">
        <xsl:result-document href="{testng:absolutePath('main.js')}" format="text">
            <![CDATA[
            var selectedTestCaseLink;

            function clearAllSelections() {
                if (selectedTestCaseLink != null) {
                    selectedTestCaseLink.className = "testCaseLink";
                }
            }

            function selectTestCaseLink(testCaseLinkElement) {
                clearAllSelections();
                testCaseLinkElement.className = "testCaseLinkSelected";
                selectedTestCaseLink = testCaseLinkElement;
            }

            function switchTestMethodsView(checkbox) {
                document.getElementById("testMethodsByStatus").style["display"] = checkbox.checked ? "none" : "block";
                document.getElementById("testMethodsByClass").style["display"] = checkbox.checked ? "block" : "none";
            }

            function toggleVisibility(elementId) {
                var displayElement = document.getElementById(elementId);
                if (getCurrentStyle(displayElement, "display") == "none") {
                    displayElement.style["display"] = "block";
                } else {
                    displayElement.style["display"] = "none";
                }
            }

            function toggleDetailsVisibility(elementId) {
                var displayElement = document.getElementById(elementId);
                if (displayElement.className == "testMethodDetails") {
                    displayElement.className = "testMethodDetailsVisible";
                    document.getElementById("imgExpand_"+elementId).src = "images/open.gif";
                } else {
                    displayElement.className = "testMethodDetails";
                    document.getElementById("imgExpand_"+elementId).src = "images/close.gif";
                }
            }

            function toggleTestRunDetailsVisibility(elementId) {
                var displayElement = document.getElementById(elementId).parentNode.parentNode;
                if (displayElement.className == "testRunDetails") {
                    displayElement.className = "testRunDetailsVisible";
                    document.getElementById("imgExpand_"+elementId).src = "images/open.gif";
                } else {
                    displayElement.className = "testRunDetails";
                    document.getElementById("imgExpand_"+elementId).src = "images/close.gif";
                }
            }
			
			function toggleReportVisibility(elementId) {
                var displayElement = document.getElementById(elementId);
                if (displayElement.className == "reportDetails") {
                    displayElement.className = "reportDetailsVisible";
                } else {
                    displayElement.className = "reportDetails";
                }
            }
			
			function toggleReportsVisibility(elementId) {
                var displayElement = document.getElementById(elementId);
                if (displayElement.className == "reportsDetails") {
                    displayElement.className = "reportsDetailsVisible section";
                } else {
                    displayElement.className = "reportsDetails";
                }
            }

            function toggleExceptionsVisibility(elementId) {
                var displayElement = document.getElementById(elementId);
                if (displayElement.className == "exceptionDetails") {
                    displayElement.className = "exceptionDetailsVisible";
                } else {
                    displayElement.className = "exceptionDetails";
                }
            }

             function toggleLogsVisibility(elementId) {
                /*var displayElement = document.getElementById(elementId);
                if (displayElement.className == "logDetails") {
                    displayElement.className = "logDetailsVisible";
                } else {
                    displayElement.className = "logDetails";
                } */
                newwindow = window.open("logOpener.html?id="+elementId,'Log Details','height=600,width=850');

				formatLog(elementId);
            }

            function getCurrentStyle(elem, prop) {
                if (elem.currentStyle) {
                    var ar = prop.match(/\w[^-]*/g);
                    var s = ar[0];
                    for(var i = 1; i < ar.length; ++i) {
                        s += ar[i].replace(/\w/, ar[i].charAt(0).toUpperCase());
                    }
                    return elem.currentStyle[s];
                } else if (document.defaultView.getComputedStyle) {
                    return document.defaultView.getComputedStyle(elem, null).getPropertyValue(prop);
                }
            }

            function testMethodsFilterChanged(filterCheckBox, status) {
                var filterAll = document.getElementById("methodsFilter_ALL");
                var filterFail = document.getElementById("methodsFilter_FAIL");
                var filterPass = document.getElementById("methodsFilter_PASS");
                var filterSkip = document.getElementById("methodsFilter_SKIP");
                var filterConf = document.getElementById("methodsFilter_CONF");
                if (filterCheckBox != filterAll) {
                    filterMethods(filterCheckBox, status);
                    checkMainFilter(filterAll, filterFail, filterPass, filterSkip, filterConf);
                } else {
                    filterFail.checked = filterPass.checked = filterSkip.checked = filterConf.checked = filterAll.checked;
                    filterMethods(filterAll, "FAIL");
                    filterMethods(filterAll, "PASS");
                    filterMethods(filterAll, "SKIP");
                    filterMethods(filterAll, "CONF");
                }
                closeAllExpandedDetails();
            }

            function checkMainFilter(filterAll, filterFail, filterPass, filterSkip, filterConf) {
                if ((filterFail.checked == filterPass.checked) && (filterPass.checked == filterSkip.checked) && (filterSkip.checked == filterConf.checked)) {
                    filterAll.checked = filterFail.checked;
                } else {
                    filterAll.checked = false;
                }
            }

            function filterMethods(filterCheckBox, status) {
                var visible = filterCheckBox.checked;
                alterCssElement("testMethodStatus" + status, "display", visible ? "" : "none");
            }            
			
			function formatLog(docEleid) {
                var str = document.getElementById(docEleid).innerHTML;
				var new_str = str.replace(/                                                         /gi, "");
				document.getElementById(docEleid).innerHTML = new_str;
            }

            function alterCssElement(cssClass, element, value) {
                var rules;
                if (document.all) {
                    rules = 'rules';
                }
                else if (document.getElementById) {
                    rules = 'cssRules';
                }
                for (var i = 0; i < document.styleSheets.length; i++) {
                    for (var j = 0; j < document.styleSheets[i][rules].length; j++) {
                        if (document.styleSheets[i][rules][j].selectorText.indexOf(cssClass) > -1) {
                            document.styleSheets[i][rules][j].style[element] = value;
                            break;
                        }
                    }
                }
            }

            function closeAllExpandedDetails() {
                var node = document.getElementsByTagName("body")[0];
                //var re = new RegExp("\\btestMethodDetailsVisible\\b");
                var els = document.getElementsByTagName("div");
                for (var i = 0,j = els.length; i < j; i++) {
                    if (els[i].className == "testMethodDetailsVisible") {
                        els[i].className = "testMethodDetails";
                    }
                }
            }

            function renderSvgEmbedTag(chartWidth, chartHeight) {
                var success = false;
                var userAgent = navigator.userAgent;

                if (userAgent.indexOf("Firefox") > -1 || userAgent.indexOf("Safari") > -1) {
                    success = true;
                } else if (navigator.mimeTypes != null && navigator.mimeTypes.length > 0) {
                    if (navigator.mimeTypes["image/svg+xml"] != null) {
                        success = true;
                    }
                } else if (window.ActiveXObject) {
                    try {
                        testObj = new ActiveXObject("Adobe.SVGCtl");
                        success = true;
                    } catch (e) {}
                }

                var chartContainer = document.getElementById('chart-container');
                
                if (success) {
                    var chart = document.createElement('embed');
                    
                    chart.src = 'overview-chart.svg';
                    chart.type = 'image/svg+xml';
                    chart.width = chartWidth;
                    chart.height = chartHeight;
                    
                    chartContainer.appendChild(chart);
                } else {
                    var message = document.createElement('h4');
                    var text = document.createTextNode('SVG Pie Charts are not available. Please install a SVG viewer for your browser.');
                    
                    message.style.color = 'navy';
                    message.appendChild(text);
                    
                    chartContainer.appendChild(message);
                }
            }


            function gup( name )
                        {
                          name = name.replace(/[\[]/,"\\\[").replace(/[\]]/,"\\\]");
                          var regexS = "[\\?&]"+name+"=([^&#]*)";
                          var regex = new RegExp( regexS );
                          var results = regex.exec( window.location.href );
                          if( results == null )
                            return "";
                          else
                            return results[1];
                        }
            ]]>
        </xsl:result-document>
    </xsl:template>

    <xsl:template name="htmlHead">
        <head>
            <title>
                <xsl:value-of select="testng:getVariableSafe($testNgXslt.reportTitle, 'TestNG Results')"/>
            </title>
            <meta http-equiv="content-type" content="text/html; charset=utf-8"/>
            <meta http-equiv="pragma" content="no-cache"/>
            <meta http-equiv="cache-control" content="max-age=0"/>
            <meta http-equiv="cache-control" content="no-cache"/>
            <meta http-equiv="cache-control" content="no-store"/>
            <LINK rel="stylesheet" href="style.css"/>
            <LINK rel="stylesheet" href="default.css"/>
            <xsl:if test="$testNgXslt.cssFile">
                <LINK rel="stylesheet" href="{$testNgXslt.cssFile}"/>
            </xsl:if>
            <script type="text/javascript" src="main.js"/>
        </head>
    </xsl:template>

    <xsl:function name="testng:getVariableSafe">
        <xsl:param name="testVar"/>
        <xsl:param name="defaultValue"/>
        <xsl:value-of select="if ($testVar) then $testVar else $defaultValue"/>
    </xsl:function>

    <xsl:function name="testng:trim">
        <xsl:param name="arg"/>
        <xsl:sequence select="replace(replace($arg,'\s+$',''),'^\s+','')"/>
    </xsl:function>

    <xsl:function name="testng:absolutePath">
        <xsl:param name="fileName"/>
        <xsl:value-of select="concat('file:////', $testNgXslt.outputDir, '/', $fileName)"/>
    </xsl:function>

    <xsl:function name="testng:safeFileName">
        <xsl:param name="fileName"/>
        <xsl:value-of select="translate($fileName, '[]{}`~!@#$%^*(){};?/\|' , '______________________')"/>
    </xsl:function>

    <xsl:function name="testng:suiteContentFileName">
        <xsl:param name="suiteElement"/>
        <xsl:value-of select="testng:safeFileName(concat($suiteElement/@name, '.html'))"/>
    </xsl:function>

    <xsl:function name="testng:suiteGroupsFileName">
        <xsl:param name="suiteElement"/>
        <xsl:value-of select="testng:safeFileName(concat($suiteElement/@name, '_groups.html'))"/>
    </xsl:function>

    <xsl:function name="testng:testCaseContentFileName">
        <xsl:param name="testCaseElement"/>
        <xsl:value-of
                select="testng:safeFileName(concat($testCaseElement/../@name, '_', $testCaseElement/@name, '.html'))"/>
    </xsl:function>

    <xsl:function name="testng:concatParams">
        <xsl:param name="params"/>
        <xsl:variable name="outputString">
            <xsl:value-of separator="," select="for $i in ($params) return $i"/>
        </xsl:variable>
        <xsl:value-of select="$outputString"/>
    </xsl:function>


    <xsl:function name="testng:testMethodStatus">
        <xsl:param name="testMethodElement"/>
        <xsl:variable name="status" select="$testMethodElement/@status"/>
        <xsl:variable name="statusClass" select="concat('testMethodStatus', $status)"/>
        <xsl:value-of
                select="if ($testMethodElement/@is-config) then concat($statusClass, ' testMethodStatusCONF') else $statusClass"/>
    </xsl:function>

    <xsl:function name="testng:suiteMethodsCount">
        <xsl:param name="testCasesElements"/>
        <xsl:param name="state"/>
        <xsl:value-of
                select="if ($state = '*') then count($testCasesElements/class/test-method[not(@is-config)]) else count($testCasesElements/class/test-method[(@status=$state) and (not(@is-config))])"/>
    </xsl:function>

    <xsl:function name="testng:testCaseMethodsCount">
        <xsl:param name="testCaseElement"/>
        <xsl:param name="state"/>
        <xsl:value-of
                select="if ($state = '*') then count($testCaseElement/class/test-method[not(@is-config)]) else count($testCaseElement/class/test-method[(@status=$state) and (not(@is-config))])"/>
    </xsl:function>

    <xsl:function name="testng:suiteStateClass">
        <xsl:param name="testCaseElements"/>
        <xsl:value-of
                select="if (count($testCaseElements/class/test-method[(@status='FAIL') and (not(@is-config))]) > 0) then 'suiteStatusFail' else 'suiteStatusPass'"/>
    </xsl:function>

    <xsl:function name="testng:formatDuration">
        <xsl:param name="durationMs"/>
        <!--Days-->
        <xsl:if test="$durationMs > 86400000">
            <xsl:value-of select="format-number($durationMs div 86400000, '#')"/>d
        </xsl:if>
        <!--Hours-->
        <xsl:if test="($durationMs > 3600000) and ($durationMs mod 86400000 > 1000)">
            <xsl:value-of select="format-number(($durationMs mod 86400000) div 3600000, '#')"/>h
        </xsl:if>
        <xsl:if test="$durationMs &lt; 86400000">
            <!--Minutes-->
            <xsl:if test="($durationMs > 60000) and ($durationMs mod 3600000 > 1000)">
                <xsl:value-of select="format-number(($durationMs mod 3600000) div 60000, '#')"/>m
            </xsl:if>
            <!--Seconds-->
            <xsl:if test="($durationMs > 1000) and ($durationMs mod 60000 > 1000)">
                <xsl:value-of select="format-number(($durationMs mod 60000) div 1000, '#')"/>s
            </xsl:if>
        </xsl:if>
        <!--Milliseconds - only when less than a second-->
        <xsl:if test="$durationMs &lt; 1000">
            <xsl:value-of select="$durationMs"/>&#160;ms
        </xsl:if>
    </xsl:function>

    <xsl:function name="testng:isFilterSelected">
        <xsl:param name="filterName"/>
        <xsl:value-of select="contains($testDetailsFilter, $filterName)"/>
    </xsl:function>

    <xsl:template name="formField">
        <xsl:param name="label"/>
        <xsl:param name="value"/>
        <xsl:if test="$value">
            <td width="12%">
                <b>
                    <xsl:value-of select="$label"/>
                </b>
            </td>
            <td width="1%">:</td>
            <td>
                <xsl:value-of select="$value"/>
            </td>
        </xsl:if>
    </xsl:template>

    <xsl:template name="formFieldList">
        <xsl:param name="label"/>
        <xsl:param name="value"/>
        <xsl:if test="count($value) > 0">
            <div>
                <b>
                    <xsl:value-of select="$label"/>:
                </b>
                <xsl:for-each select="$value">
                    <div>
                        &#160;&#160;&#160;&#160;-
                        <xsl:value-of select="."/>
                    </div>
                </xsl:for-each>
            </div>
        </xsl:if>
    </xsl:template>

    <xsl:template match="/testng-results">
        <xsl:call-template name="writeCssFile"/>
        <xsl:call-template name="writeDefaultCssFile"/>
        <xsl:call-template name="writeJsFile"/>
        <html>
            <xsl:call-template name="htmlHead"/>
            <frameset cols="250px, 100%" frameborder="1">
                <frame name="navigation" src="navigation.html"/>
                <frame name="content" src="overview.html"/>
            </frameset>
        </html>

        <xsl:variable name="suiteElements" select="if (suite/@url) then document(suite/@url)/suite else suite"/>

        <xsl:call-template name="navigationFile">
            <xsl:with-param name="suiteElements" select="$suiteElements"/>
            <xsl:with-param name="reporterOutputElement" select="reporter-output"/>
        </xsl:call-template>

        <!--TODO: Review this-->
        <xsl:result-document href="{testng:absolutePath('overview-chart.svg')}" format="xml">
            <svg xmlns="http://www.w3.org/2000/svg" preserveAspectRatio="xMidYMid meet" width="{$chartWidth}"
                 height="{$chartHeight}"
                 viewBox="0 0 900 300">
                <defs>
                    <style type="text/css">
                        <![CDATA[
				            .axistitle { font-weight:bold; font-size:24px; font-family:Arial; text-anchor:middle; }
				            .xgrid, .ygrid, .legendtext { font-weight:normal; font-size:24px; font-family:Arial; }
				            .xgrid {text-anchor:middle;}
				            .ygrid {text-anchor:end;}
				            .gridline { stroke:black; stroke-width:1; }
				            .values { fill:black; stroke:none; text-anchor:middle; font-size:12px; font-weight:bold; }
	   		            ]]>
                    </style>
                </defs>
                <svg id="graphzone" preserveAspectRatio="xMidYMid meet" x="0" y="0">
                    <xsl:variable name="testCaseElements" select="
                    if (suite/@url) then
                        if (document(suite/@url)/suite/test/@url)
                            then document(document(suite/@url)/suite/test/@url)/test 
                            else document(suite/@url)/suite/test
                        else suite/test"/>
                    <xsl:variable name="failedCount" select="testng:suiteMethodsCount($testCaseElements, 'FAIL')"/>
                    <xsl:variable name="passedCount" select="testng:suiteMethodsCount($testCaseElements, 'PASS')"/>
                    <xsl:variable name="skippedCount" select="testng:suiteMethodsCount($testCaseElements, 'SKIP')"/>
                    <xsl:variable name="totalCount" select="testng:suiteMethodsCount($testCaseElements, '*')"/>

                    <xsl:variable name="pi" select="3.141592"/>
                    <xsl:variable name="radius" select="130"/>

                    <xsl:variable name="failedPercent" select="format-number($failedCount div $totalCount, '###%')"/>
                    <xsl:variable name="failedAngle" select="($failedCount div $totalCount) * $pi * 2"/>
                    <xsl:variable name="failedX" select="$radius * math:cos($failedAngle)"/>
                    <xsl:variable name="failedY" select="-1 * $radius * math:sin($failedAngle)"/>
                    <xsl:variable name="failedArc" select="if ($failedAngle >= $pi) then 1 else 0"/>

                    <xsl:variable name="failedAngle_text" select="$failedAngle div 2"/>
                    <xsl:variable name="failedX_text" select="($radius div 2) * math:cos($failedAngle_text)"/>
                    <xsl:variable name="failedY_text" select="(-1 * ($radius div 2) * math:sin($failedAngle_text))"/>

                    <xsl:variable name="passPercent" select="format-number($passedCount div $totalCount, '###%')"/>
                    <xsl:variable name="passAngle" select="($passedCount div $totalCount) * $pi * 2"/>
                    <xsl:variable name="passX" select="$radius * math:cos($passAngle)"/>
                    <xsl:variable name="passY" select="-1 * $radius * math:sin($passAngle)"/>
                    <xsl:variable name="passArc" select="if ($passAngle >= $pi) then 1 else 0"/>

                    <xsl:variable name="skipPercent" select="format-number($skippedCount div $totalCount, '###%')"/>
                    <xsl:variable name="skipAngle" select="($skippedCount div $totalCount) * $pi * 2"/>
                    <xsl:variable name="skipX" select="$radius * math:cos($skipAngle)"/>
                    <xsl:variable name="skipY" select="-1 * $radius * math:sin($skipAngle)"/>
                    <xsl:variable name="skipArc" select="if ($skipAngle >= $pi) then 1 else 0"/>

                    <rect style="fill:#F23838;stroke-width:1;stroke:black;" x="10" y="86" width="20" height="20"/>
                    <text class="legendtext" x="40" y="105">Failed (<xsl:value-of select="$failedPercent"/>)
                    </text>
                    <rect style="fill:#2BCC71;stroke-width:1;stroke:black;" x="10" y="125" width="20" height="20"/>
                    <text class="legendtext" x="40" y="143">Passed (<xsl:value-of select="$passPercent"/>)
                    </text>
                    <rect style="fill:#f2cb27;stroke-width:1;stroke:black;" x="10" y="163" width="20" height="20"/>
                    <text class="legendtext" x="40" y="182">Skipped (<xsl:value-of select="$skipPercent"/>)
                    </text>
                    <g style="stroke:black;stroke-width:1" transform="translate(450,150)">
                        <xsl:variable name="failedRotation" select="(($skippedCount) div $totalCount) * 360"/>
                        <xsl:if test="($failedCount div $totalCount) > 0">
                            <g style="fill:#F23838"
                               transform="rotate(-{$failedRotation}) translate({round($failedX_text div 4)}, {round($failedY_text div 4)})">
                                <path d="M 0 0 h {$radius} A {$radius},{$radius} 0,{$failedArc},0 {$failedX},{$failedY} z"/>
                            </g>
                        </xsl:if>
                        <xsl:variable name="passRotation"
                                      select="(($failedCount + $skippedCount) div $totalCount) * 360"/>
                        <xsl:if test="($passedCount div $totalCount) > 0">
                            <g style="fill:#2BCC71" transform="rotate(-{$passRotation})">
                                <path d="M 0 0 h {$radius} A {$radius},{$radius} 0,{$passArc},0 {$passX},{$passY} z"/>
                            </g>
                        </xsl:if>
                        <xsl:if test="($skippedCount div $totalCount) > 0">
                            <g style="fill:#f2cb27" transform="rotate(360)">
                                <path d="M 0 0 h {$radius} A {$radius},{$radius} 0,{$skipArc},0 {$skipX},{$skipY} z"/>
                            </g>
                        </xsl:if>
                    </g>
                </svg>
            </svg>
        </xsl:result-document>


        <!-- Results overview file -->
        <xsl:result-document href="{testng:absolutePath('overview.html')}" format="xhtml">
            <html xmlns="http://www.w3.org/1999/xhtml">
                <xsl:call-template name="htmlHead"/>
                <body>
                    <h2>Test suites overview</h2>
                    <table width="100%">
                        <tr>
                            <td align="center" id="chart-container">
                                <script type="text/javascript">
                                    renderSvgEmbedTag(<xsl:value-of select="$chartWidth"/>, <xsl:value-of
                                        select="$chartHeight"/>);
                                </script>
                            </td>
                        </tr>
                    </table>
                    <h3>Test Suites Summary</h3>
                    <table width="100%" cellpadding="5" cellspacing="1">
                        <tr style="background-color: #cedcec;">
                            <td width="100%"><div class="suiteStatus" title="Individual Suite Status"/>Test Suite Name
                            </td>
                            <td style="font-size: 14; background-color: #FFBBBB; padding: 3px 3px 3px 0;"
                                align="center">
                                <div style="width: 50px;">Failed</div>
                            </td>
                            <td style="font-size: 14; background-color: lightgreen; padding: 3px 3px 3px 0;"
                                align="center">
                                <div style="width: 50px;">Passed</div>
                            </td>
                            <td style="font-size: 14; background-color: #FFFFBB; padding: 3px 3px 3px 0;"
                                align="center">
                                <div style="width: 50px;">Skipped</div>
                            </td>
                            <td align="center"
                                style="font-size: 14; background-color: #cedcec; padding: 3px 3px 3px 0;">
                                <div style="width: 50px;">Total</div>
                            </td>
                            <td align="center"
                                style="font-size: 13; background-color: #cedcec; padding: 3px 3px 3px 0;">
                                <div style="width: 50px;">Pass(%)</div>
                            </td>
                            <xsl:if test="compare($testNgXslt.showRuntimeTotals, 'true') = 0">
                                <td style="font-size: 14; background-color: #cedcec; padding: 3px 3px 3px 0;"
                                    align="center">
                                    <div style="width: 80px;">Duration</div>
                                </td>
                            </xsl:if>
                        </tr>
                        <tr style="background-color: #f5f5f5; font-size: 15px;">
                            <td>
                                All Automation Test Suites
                            </td>
                            <xsl:variable name="suiteElements"
                                          select="if (suite/@url) then document(suite/@url)/suite else suite"/>
                            <xsl:variable name="totalTime"
                                          select="testng:formatDuration(sum($suiteElements/@duration-ms))"/>
                            <xsl:variable name="testCaseElements" select="
											if (suite/@url) then
												if (document(suite/@url)/suite/test/@url)
													then document(document(suite/@url)/suite/test/@url)/test 
													else document(suite/@url)/suite/test
												else suite/test"/>
                            <xsl:variable name="failedCount"
                                          select="testng:suiteMethodsCount($testCaseElements, 'FAIL')"/>
                            <xsl:variable name="passedCount"
                                          select="testng:suiteMethodsCount($testCaseElements, 'PASS')"/>
                            <xsl:variable name="skippedCount"
                                          select="testng:suiteMethodsCount($testCaseElements, 'SKIP')"/>
                            <xsl:variable name="totalCount" select="testng:suiteMethodsCount($testCaseElements, '*')"/>
                            <xsl:variable name="passedPercent"
                                          select="format-number($passedCount div $totalCount, '###%')"/>
                            <td align="center">
                                <xsl:value-of select="$failedCount"/>
                            </td>
                            <td align="center">
                                <xsl:value-of select="$passedCount"/>
                            </td>
                            <td align="center">

                                <xsl:value-of select="$skippedCount"/>
                            </td>
                            <td align="center">
                                <xsl:value-of select="$totalCount"/>
                            </td>
                            <td align="center">
                                <xsl:value-of select="$passedPercent"/>
                            </td>
                            <td align="center">
                                <!--<xsl:value-of select="$totalTime"/>-->
                            </td>
                        </tr>
                    </table>
                    <br/>
                    <xsl:for-each select="$suiteElements">
                        <xsl:variable name="testCaseElements"
                                      select="if (test/@url) then document(test/@url)/test else test"/>
                        <table width="100%" cellpadding="5" cellspacing="1">
                            <tr style="background-color: #cedcec;">
                                <td width="100%">
                                    <div class="{testng:suiteStateClass($testCaseElements)}"/>
                                    <xsl:value-of select="@name"/>
                                </td>
                                <xsl:call-template name="percentageOverview">
                                    <xsl:with-param name="failedCount"
                                                    select="testng:suiteMethodsCount($testCaseElements, 'FAIL')"/>
                                    <xsl:with-param name="passedCount"
                                                    select="testng:suiteMethodsCount($testCaseElements, 'PASS')"/>
                                    <xsl:with-param name="skippedCount"
                                                    select="testng:suiteMethodsCount($testCaseElements, 'SKIP')"/>
                                    <xsl:with-param name="totalCount"
                                                    select="testng:suiteMethodsCount($testCaseElements, '*')"/>
                                    <xsl:with-param name="totalDuration"
                                                    select="''"/>
                                </xsl:call-template>
                            </tr>
                            <xsl:for-each select="$testCaseElements">
                                <tr style="background-color: #f5f5f5; font-size: 12px;">
                                    <td>
                                        <xsl:value-of select="@name"/>
                                    </td>
                                    <td align="center">
                                        <xsl:value-of select="testng:testCaseMethodsCount(., 'FAIL')"/>
                                    </td>
                                    <td align="center">
                                        <xsl:value-of select="testng:testCaseMethodsCount(., 'PASS')"/>
                                    </td>
                                    <td align="center">
                                        <xsl:value-of select="testng:testCaseMethodsCount(., 'SKIP')"/>
                                    </td>
                                    <td align="center">
                                        <xsl:value-of select="testng:testCaseMethodsCount(., '*')"/>
                                    </td>
                                    <td align="center" style="font-weight: bold;">
                                        <xsl:value-of
                                                select="if (testng:testCaseMethodsCount(., '*') > 0) then format-number(testng:testCaseMethodsCount(., 'PASS') div testng:testCaseMethodsCount(., '*'), '###%') else '100%'"/>
                                    </td>
                                    <xsl:if test="compare($testNgXslt.showRuntimeTotals, 'true') = 0">
                                        <td align="center" nowrap="true">
                                            <xsl:value-of select="testng:formatDuration(./@duration-ms)"/>
                                        </td>
                                    </xsl:if>
                                </tr>
                            </xsl:for-each>
                        </table>
                        <br/>
                    </xsl:for-each>


                    <h3>Test Execution Log</h3>
                    <table width="100%" cellpadding="5" cellspacing="1">
                        <tr style="background-color: #f5f5f5; font-size: 15px;">
                            <td>All Test Suites Execution Log</td>
                            <td style="font-size: 14; background-color: #cedcec; padding: 3px 3px 3px 0;"
                                align="center">
                                <!--<div style="width: 50px;">Log</div>-->
                                <!--<xsl:choose>
                                    <xsl:when test="not(@is-config)">
                                        <a onclick="toggleLogsVisibility('{$inLogDetailsId}')">
                                            <xsl:value-of select="'Logs'"/>
                                        </a>
                                    </xsl:when>
                                    <xsl:otherwise>
                                        &#160;
                                    </xsl:otherwise>
                                </xsl:choose>-->
                                <a onclick="toggleLogsVisibility('log_12')">
                                    <xsl:value-of select="'Logs'"/>
                                </a>
                            </td>
                        </tr>
                    </table>
                    <div id="log_12" class="logDetails">
                        <div>
                            <table width='75%'>
                                <tbody>
                                    <tr>
                                        <td width='100%'>
                                            <font size='2'>
                                                <b>Test Execution Log</b>
                                            </font>
                                        </td>
                                    </tr>

                                </tbody>
                            </table>
                        </div>

                        <div>
                            <table width='75%'>
                                <tbody>
                                    <tr nowrap="true">
                                        <td colspan="6">
                                            <!--<pre>
                                                <xsl:variable name="TElogMessage"
                                                              select="unparsed-text(concat('file:///', system-property('user.dir'), '/../', 'eselenium.log'))"/>
                                                <xsl:value-of select="$TElogMessage"/>
                                            </pre>-->
                                        </td>
                                    </tr>
                                </tbody>
                            </table>
                        </div>
                    </div>
                    <br/>
                    <xsl:call-template name="powered-by"/>
                </body>
            </html>
        </xsl:result-document>

        <!-- Reporter output file -->
        <!--<xsl:result-document href="{testng:absolutePath('reporterOutput.html')}" format="xhtml">
            <html xmlns="http://www.w3.org/1999/xhtml">
                <xsl:call-template name="htmlHead"/>
                <body>
                    <h2>Reporter output</h2>
                    <xsl:for-each select="reporter-output/line">
                        <div>
                            <code>
                                <xsl:value-of select="."/>
                            </code>
                        </div>
                    </xsl:for-each>
                    <xsl:call-template name="powered-by"/>
                </body>
            </html>
        </xsl:result-document>-->

        <!-- Pop-Up Window file -->
        <xsl:result-document href="{testng:absolutePath('logOpener.html')}" format="xhtml">
            <html xmlns="http://www.w3.org/1999/xhtml">
                <xsl:call-template name="htmlHead"/>
                <body>
                    <h2>Log Opener</h2>
                    <script>
                        id = gup("id");
                        document.write(window.opener.document.getElementById(id).innerHTML);
                    </script>
                </body>
            </html>
        </xsl:result-document>
    </xsl:template>

    <xsl:template name="navigationFile">
        <xsl:param name="suiteElements"/>
        <xsl:param name="reporterOutputElement"/>
        <xsl:result-document href="{testng:absolutePath('navigation.html')}" format="xhtml">
            <html xmlns="http://www.w3.org/1999/xhtml">
                <xsl:call-template name="htmlHead"/>
                <body>
                    <h2 style="margin-bottom: 5px;">
                        <xsl:value-of select="testng:getVariableSafe($testNgXslt.reportTitle, 'TestNG Results')"/>
                    </h2>
                    <div>
                        <a href="overview.html" target="content"
                           onclick="javscript:clearAllSelections();">Results overview
                        </a>
                    </div>
                    <div>
                        <!--<a href="reporterOutput.html" target="content"
                           onclick="javscript:clearAllSelections();">Reporter output
                        </a>-->
                    </div>
                    <div>
                        <xsl:for-each select="$suiteElements">
                            <xsl:variable name="testCaseElements"
                                          select="if (test/@url) then document(test/@url)/test else test"/>
                            <table class="suiteMenuHeader" width="100%" cellpadding="0" cellspacing="0">
                                <tr>
                                    <td nowrap="true">
                                        <b>
                                            <a href="{testng:suiteContentFileName(.)}" target="content"
                                               onclick="javscript:clearAllSelections();">
                                                <xsl:value-of select="@name"/>
                                            </a>
                                        </b>
                                        <div style="margin: 3px 0 3px 0;">
                                            <a href="{testng:suiteGroupsFileName(.)}" target="content"
                                               onclick="javscript:clearAllSelections();">
                                                <xsl:value-of select="count(./groups/group)"/>
                                                Groups
                                            </a>
                                        </div>
                                        <span style="color: red;">
                                            <xsl:value-of select="testng:suiteMethodsCount($testCaseElements, 'FAIL')"/>
                                        </span>
                                        /
                                        <span style="color: green;">
                                            <xsl:value-of select="testng:suiteMethodsCount($testCaseElements, 'PASS')"/>
                                        </span>
                                        /
                                        <span style="color: yellow;">
                                            <xsl:value-of select="testng:suiteMethodsCount($testCaseElements, 'SKIP')"/>
                                        </span>
                                        /
                                        <span>
                                            <xsl:value-of select="testng:suiteMethodsCount($testCaseElements, '*')"/>
                                        </span>
                                    </td>
                                    <td style="font-weight: bold;">
                                        <xsl:value-of
                                                select="format-number(testng:suiteMethodsCount($testCaseElements, 'PASS') div testng:suiteMethodsCount($testCaseElements, '*'), '###%')"/>
                                    </td>
                                </tr>
                            </table>
                            <xsl:call-template name="suiteContentFile">
                                <xsl:with-param name="suiteElement" select="."/>
                            </xsl:call-template>
                            <xsl:call-template name="suiteGroupsFile">
                                <xsl:with-param name="suiteElement" select="."/>
                            </xsl:call-template>
                            <xsl:call-template name="suiteTestCasesLinks">
                                <xsl:with-param name="testCases" select="$testCaseElements"/>
                            </xsl:call-template>
                            <xsl:call-template name="suiteTestCasesContentFiles">
                                <xsl:with-param name="testCases" select="$testCaseElements"/>
                            </xsl:call-template>
                        </xsl:for-each>
                    </div>
                </body>
            </html>
        </xsl:result-document>
    </xsl:template>


<!--    <xsl:template name="testStepsTemplate">
        <xsl:param name="in-name"/>
        <xsl:param name="in-started-at"/>
        <xsl:param name="in-finished-at"/>
        <xsl:param name="in-status"/>
        <xsl:param name="inClassName"/>
        <xsl:param name="xmlFile"/>
        <xsl:param name="inTestName"/>
        <xsl:param name="inSuiteName"/>

        <xsl:variable name="xmlData" select="document($xmlFile)"/>
        <xsl:variable name="xmlRaw" select="$xmlData/testng-results/suite[@name=$inSuiteName]/test[@name=$inTestName]/class[@name=$inClassName]/test-method[@started-at=$in-started-at and @finished-at=$in-finished-at and @name=$in-name and @status=$in-status]/logs/log"/>

        <xsl:for-each select="$xmlRaw">
            <xsl:variable name="rawNum" select="position()"/>
            <xsl:variable name="xmlStep" select="$xmlRaw[$rawNum]"/>
            <tr>
                <td>
                    <xsl:value-of select="$xmlStep/@name"/>
                </td>
                <td>
                    Status
                </td>
                <td>
                    Status
                </td>
                <td>
                    Status
                </td>
                <td>
                    Status
                </td>
            </tr>
        </xsl:for-each>
    </xsl:template>-->

    <xsl:template name="testStepsTemplate">
        <xsl:param name="stepsList"/>
        <xsl:for-each select="$stepsList">
            <tr><xsl:value-of select="." disable-output-escaping="yes"/>

            </tr>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="suiteContentFile">
        <xsl:param name="suiteElement"/>
        <xsl:variable name="testCaseElements" select="if (test/@url) then document(test/@url)/test else test"/>
        <xsl:result-document href="{testng:absolutePath(testng:suiteContentFileName($suiteElement))}" format="xhtml">
            <html>
                <xsl:call-template name="htmlHead"/>
                <body>
                    <table width="100%" style="font-size: 16px; margin-bottom: 10px;" cellspacing="1">
                        <tr>
                            <td width="100%">
                                All Services in Suite:
                                <b>
                                    <xsl:value-of select="./@name"/>
                                </b>
                            </td>
                            <xsl:call-template name="percentageOverview">
                                <xsl:with-param name="failedCount"
                                                select="testng:suiteMethodsCount($testCaseElements, 'FAIL')"/>
                                <xsl:with-param name="passedCount"
                                                select="testng:suiteMethodsCount($testCaseElements, 'PASS')"/>
                                <xsl:with-param name="skippedCount"
                                                select="testng:suiteMethodsCount($testCaseElements, 'SKIP')"/>
                                <xsl:with-param name="totalCount"
                                                select="testng:suiteMethodsCount($testCaseElements, '*')"/>
                                <xsl:with-param name="totalDuration"
                                                select="testng:formatDuration($suiteElement/@duration-ms)"/>
                            </xsl:call-template>
                        </tr>
                    </table>
                    <xsl:call-template name="testMethods">
                        <xsl:with-param name="classes" select="$testCaseElements/class"/>
                        <xsl:with-param name="failedMethods"
                                        select="$testCaseElements/class/test-method[@status='FAIL']"/>
                        <xsl:with-param name="passedMethods"
                                        select="$testCaseElements/class/test-method[@status='PASS']"/>
                        <xsl:with-param name="skipedMethods"
                                        select="$testCaseElements/class/test-method[@status='SKIP']"/>
                    </xsl:call-template>
                    <xsl:call-template name="powered-by"/>
                </body>
            </html>
        </xsl:result-document>
    </xsl:template>

    <xsl:template name="suiteGroupsFile">
        <xsl:param name="suiteElement"/>
        <xsl:result-document href="{testng:absolutePath(testng:suiteGroupsFileName($suiteElement))}" format="xhtml">
            <html xmlns="http://www.w3.org/1999/xhtml">
                <xsl:call-template name="htmlHead"/>
                <body>
                    <h2>
                        Groups for suite:
                        <b>
                            <xsl:value-of select="$suiteElement/@name"/>
                        </b>
                    </h2>
                    <xsl:for-each select="$suiteElement/groups/group">
                        <xsl:sort order="ascending" select="@name"/>
                        <table style="margin-bottom: 20px; font-size: 12px; width:100%;" cellpadding="3"
                               cellspacing="1">
                            <tr>
                                <td style="background-color: #f5f5f5;">
                                    <div style="font-size: 18px;">
                                        <xsl:value-of select="./@name"/>
                                    </div>
                                </td>
                            </tr>
                            <xsl:for-each select="method">
                                <tr>
                                    <td style="background-color: #cedcec;">
                                        <xsl:value-of select="@signature"/>
                                    </td>
                                </tr>
                            </xsl:for-each>
                        </table>
                    </xsl:for-each>
                    <xsl:call-template name="powered-by"/>
                </body>
            </html>
        </xsl:result-document>
    </xsl:template>

    <xsl:template name="testMethods">
        <xsl:param name="classes"/>
        <xsl:param name="failedMethods"/>
        <xsl:param name="passedMethods"/>
        <xsl:param name="skipedMethods"/>
        <xsl:param name="filePrefix"/>

        <div style="width: 200px;">
            <label for="groupMethodsCheckBox" style="font-weight: bold; margin: 0;">
                <input id="groupMethodsCheckBox" type="checkbox" onclick="switchTestMethodsView(this)">
                    <xsl:if test="testng:isFilterSelected('BY_CLASS') = 'true'">
                        <xsl:attribute name="checked" select="true"/>
                    </xsl:if>
                </input>
                Group by class
            </label>
            <br/>
            <label for="methodsFilter_ALL" style="font-weight: bold; margin: 0;">
                <input id="methodsFilter_ALL" type="checkbox" onclick="testMethodsFilterChanged(this, 'ALL')">
                    <xsl:if test="testng:isFilterSelected('FAIL') = 'true' and testng:isFilterSelected('PASS') = 'true' and testng:isFilterSelected('SKIP') = 'true' and testng:isFilterSelected('CONF') = 'true'">
                        <xsl:attribute name="checked" select="true"/>
                    </xsl:if>
                </input>
                All
            </label>
        </div>
        <label for="methodsFilter_FAIL" style="margin-left: 20px;">
            <input id="methodsFilter_FAIL" type="checkbox" onclick="testMethodsFilterChanged(this, 'FAIL')">
                <xsl:if test="testng:isFilterSelected('FAIL') = 'true'">
                    <xsl:attribute name="checked" select="true"/>
                </xsl:if>
            </input>
            Failed
        </label>
        <label for="methodsFilter_PASS">
            <input id="methodsFilter_PASS" type="checkbox" onclick="testMethodsFilterChanged(this, 'PASS')">
                <xsl:if test="testng:isFilterSelected('PASS') = 'true'">
                    <xsl:attribute name="checked" select="true"/>
                </xsl:if>
            </input>
            Passed
        </label>
        <label for="methodsFilter_SKIP">
            <input id="methodsFilter_SKIP" type="checkbox" onclick="testMethodsFilterChanged(this, 'SKIP')">
                <xsl:if test="testng:isFilterSelected('SKIP') = 'true'">
                    <xsl:attribute name="checked" select="true"/>
                </xsl:if>
            </input>
            Skipped
        </label>
        <label for="methodsFilter_CONF">
            <input id="methodsFilter_CONF" type="checkbox" onclick="testMethodsFilterChanged(this, 'CONF')">
                <xsl:if test="testng:isFilterSelected('CONF') = 'true'">
                    <xsl:attribute name="checked" select="true"/>
                </xsl:if>
            </input>
            Config
        </label>
        <br/>

        <!-- Display methods list grouped by status -->
        <div id="testMethodsByStatus">
            <xsl:if test="testng:isFilterSelected('BY_CLASS') = 'true'">
                <xsl:attribute name="style" select="'display: none;'"/>
            </xsl:if>
            <div class="section">
                <table class="testMethodsTable" cellpadding="0" cellspacing="0">
                    <tr class="methodsTableHeader">
                        <th width="100%">Name</th>
                        <th nowrap="true">Started</th>
                        <th nowrap="true">Duration</th>
                        <th>Exception</th>
                    </tr>
                    <xsl:call-template name="testMethodsList">
                        <xsl:with-param name="methodList" select="$failedMethods"/>
                        <xsl:with-param name="category" select="'byStatus_failed'"/>
                    </xsl:call-template>
                    <xsl:call-template name="testMethodsList">
                        <xsl:with-param name="methodList" select="$passedMethods"/>
                        <xsl:with-param name="category" select="'byStatus_passed'"/>
                    </xsl:call-template>
                    <xsl:call-template name="testMethodsList">
                        <xsl:with-param name="methodList" select="$skipedMethods"/>
                        <xsl:with-param name="category" select="'byStatus_skiped'"/>
                    </xsl:call-template>
                </table>
            </div>
        </div>

        <!-- Display methods list grouped by class -->
        <div id="testMethodsByClass">
            <xsl:if test="testng:isFilterSelected('BY_CLASS') != 'true'">
                <xsl:attribute name="style" select="'display: none;'"/>
            </xsl:if>
            <xsl:for-each select="$classes">
                <xsl:sort order="ascending" select="@name"/>
                <div class="section">
                    <h3 style="display: inline;">
                        <xsl:value-of select="./@name"/>
                    </h3>
                    <table class="testMethodsTable" cellpadding="0" cellspacing="0">
                        <tr class="methodsTableHeader">
                            <th width="100%">Name</th>
                            <th nowrap="true">Started</th>
                            <th nowrap="true">Duration</th>
                            <th>Exception</th>
                        </tr>
                        <xsl:call-template name="testMethodsList">
                            <xsl:with-param name="methodList" select="./test-method"/>
                            <xsl:with-param name="category" select="'byClass'"/>
                            <xsl:with-param name="sortByStartTime" select="'true'"/>
                            <xsl:with-param name="className" select="@name"/>
                        </xsl:call-template>
                    </table>
                </div>
                <br/>
            </xsl:for-each>
        </div>
    </xsl:template>

    <xsl:template name="testMethodsList">
        <xsl:param name="methodList"/>
        <xsl:param name="category"/>
        <xsl:param name="sortByStartTime"/>
        <xsl:param name="className"/>
        <xsl:for-each select="$methodList">
            <xsl:sort order="ascending" select="if (compare($sortByStartTime, 'true') = 0) then @started-at else ''"/>
            <xsl:variable name="methodId"
                          select="concat(../@name, '_', @name, '_', $category, '_', @status, position())"/>
            <xsl:variable name="detailsId" select="concat($methodId, '_details')"/>
            <xsl:variable name="exceptionDetailsId" select="concat($methodId, '_exception')"/>

            <tr id="{concat($methodId, '_row')}" class="{testng:testMethodStatus(.)}">
                <xsl:if test="testng:isFilterSelected(@status) != 'true'">
                    <!--<xsl:attribute name="style" select="'display: none;'"/>-->
                </xsl:if>
                <td width="100%" class="firstMethodCell" onclick="toggleDetailsVisibility('{$detailsId}')">
                    <img src="images/close.gif" id="imgExpand_{$detailsId}" class="imgExpandClose"/>
                    <a>
                        <xsl:value-of
                                select="concat(@name, '(', testng:trim(testng:concatParams(./params/param)), ')')"/>
                    </a>
                </td>
                <td nowrap="true">
                    <xsl:value-of select="substring(@started-at, 12, 8)"/>
                </td>
                <td nowrap="true" align="right">
                    <xsl:value-of select="testng:formatDuration(@duration-ms)"/>
                </td>

                <td nowrap="true">
                    <xsl:if test="./exception">
                        <a onclick="toggleExceptionsVisibility('{$exceptionDetailsId}')">
                            <xsl:choose>
                                <xsl:when
                                        test="contains(exception/@class, 'java.lang.AssertionError') and contains(tokenize(exception/message, '\t.+')[1], 'Test Plan could not be found')">
                                    No Test Plan
                                </xsl:when>
                                <xsl:when
                                        test="contains(exception/@class, 'java.lang.RuntimeException') and contains(tokenize(exception/message, '\t.+')[1], 'java.lang.ArrayIndexOutOfBoundsException')">
                                    <xsl:value-of
                                            select="concat('OutOfBounds', replace(replace(exception/message, '\t+', ''), 'java.lang.ArrayIndexOutOfBoundsException', ''))"/>
                                </xsl:when>
                                <xsl:when test="contains(exception/@class, 'org.testng.TestNGException')">
                                    TestNG Exception
                                </xsl:when>
                                <xsl:otherwise>
                                    <xsl:value-of select="exception/@class"/>
                                </xsl:otherwise>
                            </xsl:choose>
                        </a>
                    </xsl:if>
                    &#160;
                </td>
            </tr>
            <tr>
                <td colspan="6" class="detailsBox">
                    <div id="{$detailsId}" class="testMethodDetails">
                        <table>
                            <tr>
                                <xsl:call-template name="formField">
                                    <xsl:with-param name="label" select="'Start time'"/>
                                    <xsl:with-param name="value" select="testng:trim(substring(@started-at, 12, 8))"/>
                                </xsl:call-template>
                                <xsl:call-template name="formField">
                                    <xsl:with-param name="label" select="'End time'"/>
                                    <xsl:with-param name="value" select="testng:trim(substring(@finished-at, 12, 8))"/>
                                </xsl:call-template>
                                <xsl:call-template name="formField">
                                    <xsl:with-param name="label" select="'Duration'"/>
                                    <xsl:with-param name="value" select="testng:formatDuration(@duration-ms)"/>
                                </xsl:call-template>
                            </tr>
                        </table>
                        <table>
                            <tr>
                                <xsl:call-template name="formField">
                                    <xsl:with-param name="label" select="'In groups:'"/>
                                    <xsl:with-param name="value" select="@groups"/>
                                </xsl:call-template>
                            </tr>
                            <tr>
                                <xsl:call-template name="formField">
                                    <xsl:with-param name="label" select="'Description'"/>
                                    <xsl:with-param name="value" select="@description"/>
                                </xsl:call-template>
                            </tr>
                        </table>
                        <xsl:if test="@depends-on-methods">
                            <xsl:call-template name="formFieldList">
                                <xsl:with-param name="label" select="'Depends on methods'"/>
                                <xsl:with-param name="value" select="tokenize(@depends-on-methods, ',')"/>
                            </xsl:call-template>
                        </xsl:if>
                        <xsl:if test="@depends-on-groups">
                            <xsl:call-template name="formFieldList">
                                <xsl:with-param name="label" select="'Depends on groups'"/>
                                <xsl:with-param name="value" select="tokenize(@depends-on-groups, ',')"/>
                            </xsl:call-template>
                        </xsl:if>

                        <div id="testMethodsByClass">
                            <div class="section">
                                <table class="testMethodsTable individualRunsPass individualRuns" cellpadding="0"
                                       cellspacing="0">
                                    <tr class="serviceRunTableHeader">
                                        <th width="100%">Test Step</th>
                                        <th nowrap="true">Status</th>
                                        <th nowrap="true">Browser</th>
                                        <th nowrap="true">Desktop</th>
                                        <th nowrap="true">Html</th>
                                    </tr>

                                    <!--<xsl:variable name="rptGraphPath"
                                                  select="'F:/Work/P/code/Projects/TestNG-Reporting/eselenium-lsibat-tests/Test_Steps.xml'"/>
                                    <xsl:call-template name="testStepsTemplate">
                                        <xsl:with-param name="in-name"
                                                        select="@name"></xsl:with-param>
                                        <xsl:with-param name="in-started-at" select="@started-at"></xsl:with-param>
                                        <xsl:with-param name="in-finished-at"
                                                        select="@finished-at"></xsl:with-param>
                                        <xsl:with-param name="in-status"
                                                        select="@status"></xsl:with-param>
                                        <xsl:with-param name="inClassName" select="$className"/>
                                        <xsl:with-param name="xmlFile" select="$rptGraphPath"/>
                                        <xsl:with-param name="inTestName" select="../../@name"/>
                                        <xsl:with-param name="inSuiteName" select="../../../@name"/>
                                    </xsl:call-template>-->

                                    <xsl:call-template name="testStepsTemplate">
                                        <xsl:with-param name="stepsList" select="./reporter-output/line"/>
                                    </xsl:call-template>
                                </table>
                            </div>
                        </div>
                        <!--</xsl:if>-->
                        <xsl:if test="exception">
                            <div id="{$exceptionDetailsId}" class="exceptionDetails">
                                <div>
                                    <table width='75%'>
                                        <tbody>
                                            <tr>
                                                <td width='100%'>
                                                    <font size='2'>
                                                        <b>Exception</b>
                                                    </font>
                                                </td>
                                            </tr>

                                        </tbody>
                                    </table>
                                </div>
                                <div>
                                    <table width='75%'>
                                        <tbody>
                                            <tr nowrap="true">
                                                <td colspan="6">
                                                    <xsl:choose>
                                                        <xsl:when test="exception/full-stacktrace">
                                                            <pre style="padding: 0px; margin-left:-200; margin-bottom:-40;">
                                                                <xsl:value-of
                                                                        select="replace(exception/full-stacktrace, '\t+', ' ')"/>
                                                            </pre>
                                                        </xsl:when>
                                                        <xsl:when
                                                                test="exception/short-stacktrace and not (exception/full-stacktrace)">
                                                            <pre style="padding: 0px; margin-left:-200; margin-bottom:-40;">
                                                                <xsl:value-of
                                                                        select="replace(exception/short-stacktrace, '\t+', ' ')"/>
                                                            </pre>
                                                        </xsl:when>
                                                        <xsl:otherwise>
                                                            <pre style="padding: 0px; margin-left:-200; margin-bottom:-40;">
                                                                &lt;No
                                                                stacktrace
                                                                information&gt;</pre>
                                                        </xsl:otherwise>
                                                    </xsl:choose>
                                                </td>
                                            </tr>
                                        </tbody>
                                    </table>
                                </div>
                            </div>
                        </xsl:if>
                    </div>
                </td>
            </tr>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="suiteTestCasesLinks">
        <xsl:param name="testCases"/>
        <xsl:for-each select="$testCases">
            <xsl:sort order="ascending"
                      select="if (compare($testNgXslt.sortTestCaseLinks, 'true') = 0) then @name else ''"/>
            <div class="testCaseLink"
                 onclick="javscript:selectTestCaseLink(this); parent.content.location='{testng:testCaseContentFileName(.)}'">
                <div class="{if (count(./class/test-method[@status='FAIL']) > 0)
                                then 'testCaseFail'
                                else if ((count(./class/test-method[@status='FAIL']) = 0) and (count(./class/test-method[@status='PASS']) > 0))
                                    then 'testCasePass'
                                    else 'testCaseSkip'}">
                </div>
                <xsl:value-of select="@name"/>
            </div>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="suiteTestCasesContentFiles">
        <xsl:param name="testCases"/>
        <xsl:for-each select="$testCases">
            <xsl:result-document href="{testng:absolutePath(testng:testCaseContentFileName(.))}" format="xhtml">
                <html>
                    <xsl:call-template name="htmlHead"/>
                    <body>
                        <table width="100%" style="font-size: 16px; margin-bottom: 10px;" cellspacing="1">
                            <tr>
                                <td width="100%">
                                    Project/Module:
                                    <b>
                                        <xsl:value-of select="./@name"/>
                                    </b>
                                </td>
                                <xsl:call-template name="percentageOverview">
                                    <xsl:with-param name="failedCount" select="testng:testCaseMethodsCount(., 'FAIL')"/>
                                    <xsl:with-param name="passedCount" select="testng:testCaseMethodsCount(., 'PASS')"/>
                                    <xsl:with-param name="skippedCount"
                                                    select="testng:testCaseMethodsCount(., 'SKIP')"/>
                                    <xsl:with-param name="totalCount" select="testng:testCaseMethodsCount(., '*')"/>
                                    <xsl:with-param name="totalDuration"
                                                    select="testng:formatDuration(./@duration-ms)"/>
                                </xsl:call-template>
                            </tr>
                        </table>
                        <xsl:call-template name="testMethods">
                            <xsl:with-param name="classes" select="./class"/>
                            <xsl:with-param name="failedMethods" select="./class/test-method[@status='FAIL']"/>
                            <xsl:with-param name="passedMethods" select="./class/test-method[@status='PASS']"/>
                            <xsl:with-param name="skipedMethods" select="./class/test-method[@status='SKIP']"/>
                        </xsl:call-template>
                        <xsl:call-template name="powered-by"/>
                    </body>
                </html>
            </xsl:result-document>
        </xsl:for-each>
    </xsl:template>

    <xsl:template name="percentageOverview">
        <xsl:param name="failedCount"/>
        <xsl:param name="passedCount"/>
        <xsl:param name="skippedCount"/>
        <xsl:param name="totalCount"/>
        <xsl:param name="totalDuration"/>
        <td style="background-color: #FFBBBB; padding: 3px 3px 3px 0;" align="center">
            <div style="width: 50px;">
                <xsl:value-of select="$failedCount"/>
            </div>
        </td>
        <td style="background-color: lightgreen; padding: 3px 3px 3px 0;" align="center">
            <div style="width: 50px;">
                <xsl:value-of select="$passedCount"/>
            </div>
        </td>
        <td style="background-color: #FFFFBB; padding: 3px 3px 3px 0;" align="center">
            <div style="width: 50px;">
                <xsl:value-of select="$skippedCount"/>
            </div>
        </td>
        <td align="center" style="background-color: #cedcec; padding: 3px 3px 3px 0;">
            <div style="width: 50px;">
                <xsl:value-of select="$totalCount"/>
            </div>
        </td>
        <td align="center" style="font-weight: bold; background-color: #cedcec; padding: 3px 3px 3px 0;">
            <div style="width: 50px;">
                <xsl:value-of
                        select="if ($totalCount > 0) then format-number($passedCount div $totalCount, '###%') else '100%'"/>
            </div>
        </td>
        <xsl:if test="compare($testNgXslt.showRuntimeTotals, 'true') = 0">
            <td style="background-color: #cedcec; padding: 3px 3px 3px 0;" align="center">
                <div style="width: 80px;">
                    <xsl:value-of select="$totalDuration"/>
                </div>
            </td>
        </xsl:if>
    </xsl:template>

    <xsl:template name="powered-by">
        <div style="margin-top: 15px; color: gray; text-align: center; font-size: 9px;">
            Copyright ©
            <a href="" style="color: #8888aa;" target="_blank">
                TAF - Frame Work
            </a>
        </div>
    </xsl:template>

</xsl:stylesheet>
