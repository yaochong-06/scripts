/* 
 * Copyright (c) 2020, Oracle and/or its affiliates.
 * 
 * FileName: flashver.js
 * 
 * NOTES: 
 *  1. This is an updated version for flashver.js which renders 
 *	11.X versions of active reports in JET.
 *  2. The original/backup version of this file is renamed to flashver_flash.js
 *	and can be found at the same location
 *  3. This file is kept in this repo for reference. 
 *      
 * MODIFIED  (MM/DD/YY)
 * 
 * sshastry - 11/11/20 - Creation
 * 
 */

/*
 * Register event to listen on messages
 */ 
if (typeof window.addEventListener !== 'undefined')
{
    window.addEventListener("message", emxActiveReportMessageReceived, false);
    //window.addEventListener("load", sendXML);
} else if (typeof window.attachEvent !== 'undefined')
{
    window.attachEvent("onmessage", emxActiveReportMessageReceived);
}

/*
 * Global variable that contains active report xml data
 */
var g_activeReportXmlData = "";

/*
 * Global variable to indicate EM Mode
 * Possible values: 
 *  a. em_express           => Indicates connected mode. This is the default value.
 *  b. emx_active_report    => Indicates active report mode. 
 */
var g_emMode = "em_express";

var DOC_ROOT = "/otn_software/omx/emsaasui/emcdbms-dbcsperf/";
var componentURL = "";
var rootPkg = "PERF";

function isBrowserIE()
{
  var ua = window.navigator.userAgent;
  // IE 10 or older
  var msie = ua.indexOf("MSIE ");
  // IE 11
  var trident = ua.indexOf('Trident/');
  // IE 12+ (Edge)
  var edge = ua.indexOf('Edge/');
  // if not IE
  if (!(msie >= 0 || trident >= 0 || edge >= 0)) {
    return false;
  }
                  
  return true;
}

// function to get url parameter of the parent window by name 
function getURLParam(pname)
{
    pname = pname.replace(/[\[]/, "\\\[").replace(/[\]]/, "\\\]");
    var regex = new RegExp("[\\?&]" + pname + "=([^&#]*)");
    var results = regex.exec(window.location.href);
    var ret = (results === null) ? "" : results[1];
    return ret;
}

var emModeParamValue = getURLParam('emMode');
if (emModeParamValue !== null && emModeParamValue !== "")
    g_emMode = emModeParamValue;

function constructComponentRootURL(cdata) {
  var compURL = "";
  if (cdata && typeof cdata !== "undefined") {
    if (cdata.indexOf('/orarep/sqlmonitor/list') !== -1) {
      compURL = "sql-monitor/html/sql-monitor-list-actreport.html";
    } else if (cdata.indexOf('/orarep/sqlmonitor/main') !== -1) {
      compURL = "sql-monitor/html/sql-monitor-detail-actreport.html";
    } else if (cdata.indexOf('/orarep/cpaddm/main') !== -1) {
      compURL = "compare-period/html/compare-period-actreport.html";
    } else if (cdata.indexOf('/orarep/perf/main') !== -1) {
      compURL = "performance-hub/html/performance-hub-actreport.html";
    } else if ((cdata.indexOf('/orarep/sql_detail') !== -1) || (cdata.indexOf('/orarep/perf/sql_detail') !== -1)) {
      if (cdata.indexOf('/orarep/sql_detail') > -1) {
        rootPkg = "TUNE";
      }
      compURL = "sql-detail/html/sql-detail-actreport.html";
    } else if ( (cdata.indexOf('/orarep/session/details') !== -1) || (cdata.indexOf('/orarep/perf/session') !== -1) ) {
      compURL = "session-details/html/session-details-actreport.html";
    } else if ( (cdata.indexOf('/orarep/sqlpa/compare_summary') !== -1) || (cdata.indexOf('orarep/sqlpa/all') !== -1) ) {
      compURL = "sql-perf-analyzer/html/spa-report-actreport.html";
    }
  }
  componentURL = DOC_ROOT + compURL;
}

function getComponentRootURL(xmlTag)
{
    xmlTag = xmlTag.innerHTML;
    var parser;
    var xmlDoc = null;

    xmlTag = xmlTag.replace(/<!--FXTMODEL-->/g, "");
    //console.log(xmlTag);
    parser = new DOMParser();
    xmlDoc = parser.parseFromString(xmlTag, "text/xml");
    
    /*
     * NOTE: 
     *  1. Every <report> element will have a <report_id> element.
     *  2. Simple/Single active report
     *      - There will be one <report> element and one <report_id>
     *      - Get this <report_id> and extract the contents of CDATA within it
     *  3. In case of composite active report there can be multiple <report_id> elements each for a corresponding <report> element.
     *      - Get the first <report_id> and extract the contents of CDATA within it
     */
    if ((typeof xmlDoc !== "undefined") && (xmlDoc.getElementsByTagName("report_id").length !== 0)) {
        var cdata = xmlDoc.getElementsByTagName("report_id")[0].textContent;
        //console.log(cdata);
        constructComponentRootURL(cdata);
    }
}

function buildContextString(contextObj) {
    var ret = "";
    for (var key in contextObj) {
        if (contextObj.hasOwnProperty(key)) {
            ret += "&" + key + "=" + encodeURI(contextObj[key]);
        }
    }
    return ret;
}

function getBrowserLocale() {
    var locale = 'en';
    if(navigator.language != undefined){
        locale = navigator.language;
    }
    return "&lang="+locale;
}

/*  This function is for dynamically constructing the path of the iframe tag
 *  based on the version of the database release
 */
function writeIframe() {
    // write base path if not there
    if (document.getElementsByTagName('base').length === 0 && typeof swf_base_path !== "undefined" && swf_base_path) {
      var basePathElement = document.createElement("base");
      basePathElement.href = swf_base_path;
      document.getElementsByTagName('head')[0].appendChild(basePathElement);
    }
    // get the XML
    var xmlTag = document.getElementById("fxtmodel");

    //In 11.2.0.4 sqlmonitor reports, we do not have script tag with id fxtmodel.
    //Get the tag which has the report xml data
    if (!xmlTag) {
        xmlTag = document.getElementsByTagName('script')[1];
    }

    if (xmlTag) {
        getComponentRootURL(xmlTag);
        console.log("+++++ WRITING iframe TO THE DOCUMENT +++++", componentURL);
        var iFrameElement = document.createElement("iframe");
        iFrameElement.id = "iframe";
        var contextString = buildContextString(window.DBCSPERF_ACTIVE_REPORT_CONTEXT);
        contextString += getBrowserLocale();
        contextString += "&rootPkg=" +rootPkg;
        iFrameElement.src = componentURL + '?emMode=emx_active_report&dbcsperf-debug=true' + contextString;
        iFrameElement.width = "100%";
        iFrameElement.height = "99%";
        document.getElementsByTagName('body')[0].appendChild(iFrameElement);
    }
}

document.onreadystatechange = function(e)
{
  switch (document.readyState) {
    case "interactive":
    	// The document has finished loading. We can now access the DOM elements.
	writeIframe(); 
	break;
    //case "loaded":
    //	sendXML();
    //	break;
    case "complete":
        sendXML();
        break;
  }    
};

/*  This function is called when the html is loaded to pass the
 *  xml to the em express active report html on OTN/OMC/CDN
 */
function sendXML()
{
    // get the XML
    var xmlTag = document.getElementById("fxtmodel");

    //In 11.2.0.4 sqlmonitor reports, we do not have script tag with id fxtmodel.
    //Get the tag which has the report xml data
    if (!xmlTag) {
	xmlTag = document.getElementsByTagName('script')[1];
    }

    // get the iframe
    var frame = document.getElementById("iframe");
    var frameWindow = document.getElementById("iframe").contentWindow;

    // if xml is found, pass it to em express active report on ONT
    if (xmlTag != null)
    {
        var xml = xmlTag.innerHTML + '';

        if (isBrowserIE()) {
          setTimeout(function(){ frameWindow.postMessage(xml, "*"); }, 200);
        }
        else {
          frameWindow.postMessage(xml, "*");
        }
    }
}


function emxActiveReportMessageReceived(event)
{
    if (g_emMode === "emx_active_report") {
        //  NOTE: 
        //  Framework (either JET or omc) is posting other messages with event.data set to an object {id: 1, message: "oj-setImmeidate"}. 
        //  This will override the value of g_activeReportXmlData with the active report xml. Hence put additional checks
        //  window.DBCSPERF_APP_MODE = "ACTIVE_REPORT" always in active report mode and hence will not suffice
        // if (event.data && (event.data.indexOf("<report") !== -1)) {  //DOES'NT work, since event.data may not be a string always.
        if (event.data && (typeof event.data === "string") && (event.data.indexOf("<report") !== -1)) {
            g_activeReportXmlData = event.data;
        }
    }
}
