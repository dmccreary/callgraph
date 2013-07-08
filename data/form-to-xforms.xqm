xquery version "1.0";

(: Data collection form (dc:from) to Orbeon XForms tranform module  
   Saxon compatable modules that transforms the dc:form XML file into XForms file that are compatble with the Orbeon XForms implementat
   No non-portable functions allowed in this module
:)
module namespace f2x = "http://grantsolutions.gov/form-to-xforms";
(:
import module namespace f2x = "http://grantsolutions.gov/form-to-xforms" at "../modules/form-to-xforms.xqm";
:)

(: put these back in when we refactor
import module namespace form-utils = "http://grantsolutions.gov/form-utils" at "form-utils.xqm";
import module namespace form-css = "http://grantsolutions.gov/form-css" at "form-css.xqm";

:)

declare namespace h="http://www.w3.org/1999/xhtml";
declare namespace xf="http://www.w3.org/2002/xforms";
declare namespace ev="http://www.w3.org/2001/xml-events";
declare namespace dc="http://gov/grantsolutions/dc";
declare namespace xsi="http://www.w3.org/2001/XMLSchema-instance";
(: Warning!  Orbeon Proprietary Extesions - not portable to other XForms engines :)
declare namespace fr="http://orbeon.org/oxf/xml/form-runner";
declare namespace xxforms="http://orbeon.org/oxf/xml/xforms";

(: static variables :)
declare variable $f2x:nl := '&#10;';

declare function f2x:test($in as node(), $config as node()) as node() {
<test>hello world</test>
};

(: read local lookup-table for masks to dates :)
declare variable $f2x:masks-to-formats :=
 (: doc('masks-to-formats.xml')/* :)
 <mask-value-lookups>
    <item>
        <description>Date MDY - 06/01/2013</description>
        <mask-type>date</mask-type>
        <mask-value>mm/dd/yyyy</mask-value>
        <xml-format>[M01]/[D01]/[Y]</xml-format>
    </item>
    <item>
        <description>Date YMD - 2013/01/01</description>
        <mask-type>date</mask-type>
        <mask-value>yyyy/mm/dd</mask-value>
        <xml-format>[Y]/[M01]/[D01]</xml-format>
    </item>
    <item>
        <description>Date DMY - 01/06/2013</description>
        <mask-type>date</mask-type>
        <mask-value>dd/mm/yyyy</mask-value>
        <xml-format>[D01]/[M01]/[Y]</xml-format>
    </item>
    <item>
        <description>Date MDY - June, 01, 2013</description>
        <mask-type>date</mask-type>
        <mask-value>Month DD, YYYY</mask-value>
        <xml-format>[MNn] [D01], [Y]</xml-format>
    </item>
    <item>
        <description>Date MDY - June 1, 2013</description>
        <mask-type>date</mask-type>
        <mask-value>FMMonth DD, YYYY</mask-value>
        <xml-format>[MNn] [D], [Y]</xml-format>
    </item>
    <item>
        <description>Date MDY - June 6th, 2013</description>
        <mask-type>date</mask-type>
        <mask-value>FMMonth ddth, YYYY</mask-value>
        <xml-format>[MNn] [D], [Y]</xml-format>
    </item>
    <item>
        <description>Date MDY - June 22nd, 2013</description>
        <mask-type>date</mask-type>
        <mask-value>FMMon ddth, YYYY</mask-value>
        <xml-format>[mNn] [D], [Y]</xml-format>
    </item>
    <item>
        <description>Date MDY with dashes - 01-01-2013</description>
        <mask-type>date</mask-type>
        <mask-value>mm-dd-yyyy</mask-value>
        <xml-format>[M01]-[D01]-[Y]</xml-format>
    </item>
    <item>
        <description>Time - hours:minutes:seconds AM/PM - 01:15:22 AM</description>
        <mask-type>time</mask-type>
        <mask-value>HH:MI:SS AM</mask-value>
        <xml-format>[h]:[m]:[s] [P,2-2]</xml-format>
    </item>
    <item>
        <description>Time - hours, minutes, seconds - 01:15:22</description>
        <mask-type>time</mask-type>
        <mask-value>HH:MI:SS</mask-value>
        <xml-format>[h]:[m]:[s]</xml-format>
    </item>
    <item>
        <description>Time - hours 24, minutes, seconds - 13:15:22</description>
        <mask-type>time</mask-type>
        <mask-value>HH24:MI:SS</mask-value>
        <xml-format>[H]:[m]:[s]</xml-format>
    </item>
    <item>
        <description>Time - hours and minutes - 01:22</description>
        <mask-type>time</mask-type>
        <mask-value>HH:MI</mask-value>
        <xml-format>[h]:[m]</xml-format>
    </item>
    <item>
        <description>Time - hours 24, minutes 13:22</description>
        <mask-type>time</mask-type>
        <mask-value>HH24:MM</mask-value>
        <xml-format>[H24]:[m]</xml-format>
    </item>
    <item>
        <description>Time - hours 24 - 13</description>
        <mask-type>time</mask-type>
        <mask-value>HH24</mask-value>
        <xml-format>[H24]</xml-format>
    </item>
    <item>
        <description>Time - minutes 22</description>
        <mask-type>time</mask-type>
        <mask-value>MM</mask-value>
        <xml-format>[m]</xml-format>
    </item>
    <item>
        <description>Date and time - 06/01/2013 13:22:15</description>
        <mask-type>dateTime</mask-type>
        <mask-value>mm/dd/yyyy hh24:mm:ss</mask-value>
        <xml-format>[M01]/[D01]/[Y] [H24]:[m]:[s]</xml-format>
    </item>
    <item>
        <description>Date and time - 06/01/2013 01:22:15 AM</description>
        <mask-type>dateTime</mask-type>
        <mask-value>mm/dd/yyyy hh:mm:ss AM</mask-value>
        <xml-format>[M01]/[D01]/[Y] [h]:[m]:[s] [PN, 2-2]</xml-format>
    </item>
    <item>
        <description>Percentage with 2 decimal  22.05%</description>
        <mask-type>number</mask-type>
        <mask-value>0.00%</mask-value>
        <xml-format>0.00%</xml-format>
    </item>
    <item>
        <description>Zipcode with 9 digits 55426-9425</description>
        <mask-type>string</mask-type>
        <mask-value>#####-####</mask-value>
        <xml-format>zip-code-9</xml-format>
    </item>
    <item>
        <description>Telephone number - (123) 555-1212</description>
        <mask-type>string</mask-type>
        <mask-value>\(###\) ###-####</mask-value>
        <xml-format>phone-number</xml-format>
    </item>
    <item>
        <description>Social Security Number 123-45-6789</description>
        <mask-type>string</mask-type>
        <mask-value>###-##-####</mask-value>
        <xml-format>ssn-number</xml-format>
    </item>
    <item>
        <description>Duns Number - 123456789-1234</description>
        <mask-type>string</mask-type>
        <mask-value>#########-####</mask-value>
        <xml-format>duns-number</xml-format>
    </item>
    <item>
        <description>Unsigned number no decimal, no commas</description>
        <mask-type>number</mask-type>
        <mask-value>#########</mask-value>
        <xml-format>#########</xml-format>
    </item>
    <item>
        <description>Signed number, no decimal, no 0</description>
        <mask-type>number</mask-type>
        <mask-value>-###,###,###</mask-value>
        <xml-format>###,###,###</xml-format>
    </item>
    <item>
        <description>Signed number, no decimal with 0</description>
        <mask-type>number</mask-type>
        <mask-value>-###,###,##0</mask-value>
        <xml-format>###,###,##0</xml-format>
    </item>
    <item>
        <description>Unsigned number no decimal and no 0</description>
        <mask-type>number</mask-type>
        <mask-value>###,###,###</mask-value>
        <xml-format>###,###,###</xml-format>
    </item>
    <item>
        <description>Unsigned number no decimal and with 0</description>
        <mask-type>number</mask-type>
        <mask-value>###,###,##0</mask-value>
        <xml-format>###,###,##0</xml-format>
    </item>
    <item>
        <description>Unsigned number with 2 decimal no 0</description>
        <mask-type>number</mask-type>
        <mask-value>###,###,###.##</mask-value>
        <xml-format>###,###,###.##</xml-format>
    </item>
    <item>
        <description>Unsigned number with 2 decimal and 0.00</description>
        <mask-type>number</mask-type>
        <mask-value>###,###,##0.00</mask-value>
        <xml-format>###,###,##0.00</xml-format>
    </item>
    <item>
        <description>Unsigned number with 6 decimal positions</description>
        <mask-type>number</mask-type>
        <mask-value>"###,###,###.######"</mask-value>
        <xml-format>###,###,###.######</xml-format>
    </item>
    <item>
        <description>Unsigned currency no decimal</description>
        <mask-type>number</mask-type>
        <mask-value>$###,###,###</mask-value>
        <xml-format>$###,###,###</xml-format>
    </item>
    <item>
        <description>Signed currency no decimal</description>
        <mask-type>number</mask-type>
        <mask-value>-$###,###,###</mask-value>
        <xml-format>$###,###,###</xml-format>
    </item>
    <item>
        <description>Unsigned currency no decimal with 0</description>
        <mask-type>number</mask-type>
        <mask-value>$###,###,##0</mask-value>
        <xml-format>$###,###,##0</xml-format>
    </item>
    <item>
        <description>Signed currency no decimal with 0</description>
        <mask-type>number</mask-type>
        <mask-value>-$###,###,##0</mask-value>
        <xml-format>$###,###,##0</xml-format>
    </item>
    <item>
        <description>Unsigned currency with 2 decimal positions</description>
        <mask-type>number</mask-type>
        <mask-value>$###,###,###.##</mask-value>
        <xml-format>$###,###,###.##</xml-format>
    </item>
    <item>
        <description>Signed currency with 2 decimal positions</description>
        <mask-type>number</mask-type>
        <mask-value>-$###,###,###.##</mask-value>
        <xml-format>$###,###,###.##</xml-format>
    </item>
    <item>
        <description>Unsigned currency with 2 decimal positions and 0.00 display</description>
        <mask-type>number</mask-type>
        <mask-value>$###,###,##0.00</mask-value>
        <xml-format>$###,###,##0.00</xml-format>
    </item>
    <item>
        <description>Signed currency with 2 decimal positions and 0.00 display</description>
        <mask-type>number</mask-type>
        <mask-value>-$###,###,##0.00</mask-value>
        <xml-format>$###,###,##0.00</xml-format>
    </item>
</mask-value-lookups>
;

(: Convert old proprietary mask format to standardized XML format strings 
 inputs are a sequence of these
 <item>
        <mask-type>date</mask-type>
        <mask-value>mm/dd/yyyy</mask-value>
        <xml-format>[M01]/[D01]/[Y]</xml-format>
</item>
:)
declare function f2x:mask-to-format($mask as xs:string) as xs:string {
$f2x:masks-to-formats/item[./mask-value = $mask]/xml-format/text()
};

(: this is a three function, no recursive main where the third argument is non-normalized form data used in all update :)
declare function f2x:main($form as node()*, $config as node(), $formdata as node()) as item()* {

(: All forms have two "modes" of operation, "new" and "update".
One mode is for new forms that we do the transform to normalized formdata instances.
The other is "update" mode for all updates to existing form data.  For this data we do not transform data.

Here is the structure that MUST be in the config to enable UPDATE mode.
   
    <entry>
        <string>form_type</string>
        <string>UPDATE</string>
    </entry>
    
If this is not found we by default revert to new mode.
:)
let $form-mode :=
   if ($config/entry[string[1] = 'form_type']/string[2] = 'UPDATE')
     then 'update'
     else 'new'
     
(: if we have a new form then we transform the incomming data into a normalized form :)
let $normalized-form-data :=
  if ($form-mode = 'new')
    then f2x:transform-form-data($form, $config) (: note twe are not using incommin formdata for new since we can derive from form specification :)
    else $formdata

(: next we build a new config file with form data as the last element :)
let $new-config :=
<config>
   {for $element in $config/*
     return $element
   }
   {$normalized-form-data}
</config>

(: lastly we call the two function main :)
return f2x:main($form, $new-config)
};

(: The MAIN sequence dispatcher.  This is the recursive two function main.  The three function is not recursive. :)
declare function f2x:main($input as node()*, $config as node()) as item()* {
for $node in $input
   return 
      typeswitch($node)
        case text() return $node
        case element(dc:dataCollectionControl) return f2x:dataCollectionControl($node, $config)
        
        case element(dc:form) return f2x:form($node, $config)
        case element(dc:section) return f2x:section($node, $config)
        case element(dc:layout) return f2x:layout($node, $config)
        case element(dc:label) return f2x:label($node, $config)
        
        case element(dc:formTitle) return ()
        case element(dc:description) return ()
        case element(dc:effectiveDate) return ()
        case element(dc:expirationDate) return ()
        case element(dc:obsoleteIndicator) return ()
        case element(dc:layoutStrategy) return ()
        case element(dc:extraProperties) return ()
        case element(dc:default-instance) return ()
        case element(dc:insert-template) return ()
        case element(dc:test-instance) return ()
        
        (: these elements are discarded since they are parsed in the table layout control :)
        case element(dc:headerRows) return ()
        case element(dc:regularRows) return ()
        case element(dc:regularColumns) return ()
        case element(dc:tableHeaders) return ()
        case element(dc:headers) return ()
        case element(dc:row) return ()
        case element(dc:repeating) return ()
        case element(dc:column) return ()
        case element(dc:columnTitle) return ()
        case element(dc:cells) return ()
        case element(dc:cell) return ()
        case element(dc:tableCell) return ()
        case element(dc:uniqueIdentifierForCell) return ()
        case element(dc:renameAllowed) return ()
        case element(dc:maximumOccurrence) return ()
        case element(dc:minimumOccurrence) return ()
        (: just for testing :)
        case element(dc:control) return f2x:dataCollectionControl($node, $config)
        
        (: not yet implemented :)
        case element(dc:layoutVisibility) return ()
        case element(dc:versionNumber) return ()
        case element(dc:displayName) return ()
        (: these are many XML Schema types (string, boolean, integer, decimal plus "currency" but are being ignored for now
           TODO - Find out if this is for validation or presentation? :)
        case element(dc:dataType) return () 
        case element(dc:sectionVisibility) return () (: if a section is not visible then we remove it :)
        (: versionNumber :)
        
        (: if we get the document node then just go to the root element :)
        case  document-node() return f2x:main($input/*, $config)
        (: remove all comments :)
        case  comment() return ()
        
        (: otherwise pass it through.  Used for comments, and PIs :)
        default return <span class="warn">f2x:main dispatcher did not understand element {name($node)} {$node}</span>
};

(: the root element of the input specification should be dc:form 
let $log := util:log-system-out('f2x:form')
return
:)
declare function f2x:form($input as node()?, $config as node()) as node() {
(: simple config xs:boolean($config/*:debug) :)
let $debug :=
   if ($config/*:entry[*:string[1] = 'debug']/*:string[2] = 'true')
      then true()
      else false()

(:
let $log := util:log-system-out($input)
let $log := util:log-system-out(concat('Running f2x:form with debug = ', $debug))
let $log2 := util:log-system-out(concat('Name of config root element = ', name($config)))
let $log2 := util:log-system-out(concat('Images URL = ', $config/*:images-url/text()))
:)
let $form-id := $input/@code/string()
let $section-id :=
  if ($input/dc:section/@code)
    then $input/dc:section/@code
    else '1'
return
  (: check for a string-length of at least one character in the ids.  Empty IDs are not allowed. :)
  if ( not($input) or (string-length($form-id) lt 1) or (string-length($section-id) lt 1) )
     then
        <error>
           <message>Missing required inputs.  Check form code ({$form-id}) and section code ($section-id) attributes.</message>
        </error>
      else

(: Build the service URLs depending on the URL passing standard.  
   The url-parameters flat use the ?para=value&para=value format
   If the config option is missing or non-true then the /form-id/section-id syntax is used :)
   
   (:
let $get-data-url :=
  if ($config/*:url-parameters = 'true')
     then concat($config/*:get-save-data-url/text(), '?form-id=', $form-id, '&amp;section-id=', $section-id)
     else concat($config/*:get-save-data-url/text(), '/', $form-id, '/', $section-id)
     :)
     
     (: $config/entry[1]/string[2]/text() :)
     
let $get-data-url :=
  if ($config/*:url-parameters = 'true')
     then concat($config/entry[string[1] = 'get_save_data_url']/string[2]/text(), '?form-id=', $form-id, '&amp;section-id=', $section-id)
     else $config/entry[string[1] = 'get_save_data_url']/string[2]/text()
     
let $code-table-url :=
  if ($config/*:url-parameters = 'true')
     then concat($config/*:code-table-url/text(), '?form-id=', $form-id, '&amp;section-id=', $section-id)
     else $config/entry[string[1] = 'code_table_url']/string[2]/text()
     
let $save-data-url :=
  if ($config/*:url-parameters = 'true')
     then concat($config/entry[string[1] = 'save_url']/string[2]/text(), '?form-id=', $form-id, '&amp;section-id=', $section-id)
     else $config/entry[string[1] = 'save_url']/string[2]/text()
     
let $formId := 
    if ($config/entry[string[1] = 'formId'])
     then $config/entry[string[1] = 'formId']/string[2]/text()
     else '#'

let $xforms-disable-alert-as-tooltip :=
    if ($config/entry[string[1] = 'xforms-disable-alert-as-tooltip']/string[2]/text() = 'true')
     then true()
     else false()
return
<html 
    xmlns="http://www.w3.org/1999/xhtml"
    xmlns:xhtml="http://www.w3.org/1999/xhtml"
    xmlns:xf="http://www.w3.org/2002/xforms" 
    xmlns:ev="http://www.w3.org/2001/xml-events"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:fr="http://orbeon.org/oxf/xml/form-runner"
    xmlns:xxforms="http://orbeon.org/oxf/xml/xforms"
    >
    <head>
        <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
        <meta name="version" content="0.02" />
        {
          if ($config/*:entry[*:string[1]='environment']/*:string[2] = 'local_exist')
          then
            (
               <link rel="shortcut icon" href="http://localhost:8088/exist/apps/grants/resources/images/favicon.ico"/>,
               <link rel="stylesheet" type="text/css" media="all"  href="http://localhost:8088/exist/apps/grants/resources/css/xforms-css.xq"/>
            )
            else
            (
               <link rel="shortcut icon" href="/images/favicon.png"/>,
               <link rel="stylesheet" type="text/css" media="all"  href="/styles/orbeon-bootstrap.css"/>,
               <link rel="stylesheet" type="text/css" media="all"  href="/styles/form-runner-bootstrap-override.css"/>,
               <link rel="stylesheet" type="text/css" media="all"  href="/styles/xforms-orbeon.css"/>,
               <link rel="stylesheet" type="text/css" media="all"  href="/styles/bootstrap.css"></link>,
               <link rel="stylesheet" type="text/css" media="all"  href="/styles/messages.css"></link>,
               <script type="text/javascript" src="/javascript/bootstrap.js"></script>,
               <script type="text/javascript" src="/dojo_v17/dojo/dojo.js"></script>,
               <script type="text/javascript">
                    dojo.registerModulePath("gswidgets", "/dc/javascript/gswidgets");
                    dojo.require("dojo.parser");
                    dojo.require("gswidgets.GUIMessage");
               </script>,
               <script type="text/javascript" src="/javascript/dc.js"></script> 
            )
        }
        <title>{f2x:form-title($input, $config)}</title>
        {f2x:css-refs($config)}
        <xf:model>
             <xf:instance id="save-data" xmlns="">
                {$config/*:formdata}
             </xf:instance>
           
           { (: for each layout that is of type table we add one instance for inserting new rows :)
              f2x:table-row-insert-templates($input, $config)
           }
           
           <!-- An instance that we can store our save result XML into.  Useful for debugging -->
           <xf:instance id="save-result" xmlns="">
              <data/>
           </xf:instance>
           
           {f2x:code-table-instances($input, $config)}
           { '' (: removed for now since calculations are held in save-data for now f2x:calculate-instance($input, $config) :)}
           
           {f2x:binds-required-fields($input, $config)}
           {f2x:binds-checkbox-fields($input, $config)}
           {f2x:binds-date-fields($input, $config)}
           {f2x:binds-date-time-fields($input, $config)}
           {f2x:binds-numeric-fields($input, $config)}
           {'' (: remove for now due to old test cases failing f2x:binds-totals($input, $config) :)}
           {f2x:binds-totals($input, $config)}
           
           <!-- this is the submission event that happens when the user presses the save button -->
           <xf:submission id="save-submission" ref="instance('save-data')" method="post" 
              resource="{concat($save-data-url,'/VALIDATE')}" replace="none">
                    <xf:action ev:event="xforms-submit-done" >
                        <xf:load resource="javascript:actionMessage.showSuccess('Saved Successfully')"/>
                    </xf:action>
                    <xf:action ev:event="xforms-submit-error">
                        <xf:load resource="javascript:actionMessage.showError('Unable to save, please correct errors in data')"/>
                    </xf:action>
           </xf:submission>
           
            <!-- note this one has a validate="false" attribute and is nice for save and continue working -->
            <xf:submission id="save-submission-no-validate" ref="instance('save-data')" method="post" 
              resource="{concat($save-data-url,'/SAVE')}" replace="none" instance="save-result" validate="false">
                 <xf:action ev:event="xforms-submit-done" >
                        <xf:load resource="javascript:actionMessage.showSuccess('Saved Successfully')"/>
                    </xf:action>
                    <xf:action ev:event="xforms-submit-error">
                        <xf:load resource="javascript:actionMessage.showError('Unable to save, please correct errors in data')"/>
                    </xf:action>
            </xf:submission>
        </xf:model>

        {f2x:css-inline($input, $config)}
        
    </head>
    <body class="orbeon {if ($xforms-disable-alert-as-tooltip) then 'xforms-disable-alert-as-tooltip' else ()}">
        <ul class="nav nav-tabs">
            <img src="/images/GS_logo_rings_transparent_small.png" alt="GrantSolutions Logo" />
        </ul>
      <div class="container1">

                <ul class="breadcrumb">
                     <li><a href="../xhtml/admin/formList.xhtml">Performance Reporting</a> <span class="divider">&gt;</span></li>
                     <li><a href="../xhtml/admin/formStatus.xhtml?formId={$formId}">{f2x:form-title($input, $config)}</a> <span class="divider">&gt;</span></li>
                     <li class="active">{f2x:section-name($input, $config)}</li>
                </ul>

               <div id="reportDetails">

                    <div class="section-header">{f2x:form-title($input, $config)} - {f2x:section-name($input, $config)}</div>

                    <dl class="dl-horizontal">

                        <dt>Awardee</dt>
                        <dd>Oregon Health Authority - Public Health Division</dd>

                        <dt>Reporting Period</dt>
                        <dd>07/01/2012 - 06/30/2013</dd>

                        <dt>Due Date</dt>
                        <dd>09/30/2013</dd>
                        
                        <dt>Section Status</dt>
                        <dd>In Progress</dd>
                    </dl>
                </div>
      
      <p> {$input/dc:description/text()}</p>
      
      { (: this is where we put debug information at the top of the form and on top of the main bootstrap and orbeon container div :)
      if ($debug)
      then
        <h:div class="debug">
            <a href="{$config/*:dynamic-config-url/text()}?debug=true">View Config</a><br/>
            namepsace URI of root node = {namespace-uri($input)}<h:br/>
            Max label chars={f2x:max-label-length($input)}<br/>
        </h:div>
      else ()
      }
      
      {f2x:main($input/*, $config)}
       
       <h:div style="text-align:center; width:100%">
        <xf:submit submission="save-submission-no-validate" class="btn btn-primary button-margin-top">
              <xf:label>Save</xf:label>
        </xf:submit>
        <xf:submit submission="save-submission" appearance="xxforms:primary" class="btn btn-primary button-margin-top">
              <xf:label>Save and Validate</xf:label>
        </xf:submit>
      </h:div>
      <div id="messageContainer" align="center"></div>
              
       { (: enable the Orbeon debug widget to view instance data :)
         if ($debug)
         then <fr:xforms-inspector/>
         else ()
       }
       
       { (: we enable the selected item for just the first repeat for debugging.  Only on table layouts
            Disable for now.  good for debugging repeating rows.  :)
          if (f2x:form-has-repeating-layout-indicator($input) and false())
          then
            <h:div class="debug">
              table row selected = <xf:output value="index('repeat-11')"/><h:br/>
            </h:div>
          else ()
      }
      </div>
      
      <!-- footer area; needs to move this out of static page eventually -->
        <footer class="footer">
            <div class="container">
                <!-- contact info -->
                <strong>GrantSolutions User Support</strong> | (202) 401-5282 or (866) 577-0771  | <a href="mailto:gsdev@grantsolutionstest.com?subject=GrantSolutions%20Help">gsdev@grantsolutionstest.com</a><br/>

                <a class="notesBottomNav" target="_blank" href="https://home.grantsolutions.gov/home/contacts/">Contact Us</a>|
                <a class="notesBottomNav" target="_blank" href="http://www.hhs.gov/Accessibility.html">Web Accessibility</a>|
                <a class="notesBottomNav" target="_blank" href="http://www.hhs.gov/Privacy.html">Privacy and Security Notice</a>|
                <a class="notesBottomNav" target="_blank" href="http://www.hhs.gov/foia/">Freedom of Information Act</a>|
                <a class="notesBottomNav" target="_blank" href="http://www.hhs.gov/Disclaimer.html">Disclaimers</a>
            </div>
        </footer>
        <!-- end of footer area -->
   
   </body>
</html>
};

(: functions that add content to the model :)


(: for each required field, we put in the model that is is required 
let $log := util:log-system-out('f2x:binds-required-fields')
return
:)
declare function f2x:binds-required-fields($form as node()*, $config as node()) as node()* {
for $layout at $layout-count in $form/dc:section/dc:layout
  (: all layouts must have a code but if one does not have one we put in a placeholder :)
  let $layout-xpath :=
     if ($layout/@code)
       then $layout/@code/string()
       else concat('layout-', $layout-count)
  return
    for $required-field in $layout//dc:dataCollectionControl[dc:required='true']
       return
          <xf:bind ref="{$layout-xpath}//{$required-field/@name/string()}" required="true()"/>
};


(: for each input in the layout that is a checkbox we add a bind to the model to indicate that it is a boolean :)
declare function f2x:binds-checkbox-fields($form as node()*, $config as node()) as node()* {
for $layout at $layout-count in $form/dc:section/dc:layout
  (: all layouts must have a code but if one does not have one we put in a placeholder :)
  let $layout-xpath :=
     if ($layout/@code)
       then $layout/@code/string()
       else concat('layout-', $layout-count)
  return
     for $checkbox-field in $layout/dc:dataCollectionControl[dc:controlType='checkbox']
       return
         <xf:bind ref="{$layout-xpath}/{$checkbox-field/@name/string()}" type="xs:boolean"/>
};

(: for each input in the layout that is a checkbox we add a bind to the model to indicate that it is a boolean 
let $log := util:log-system-out('in f2x:binds-date-fields')
return
:)
declare function f2x:binds-date-fields($form as node()*, $config as node()) as node()* {
for $layout at $layout-count in $form/dc:section/dc:layout
  (: all layouts must have a code but if one does not have one we put in a placeholder :)
  let $layout-xpath :=
     if ($layout/@code)
       then $layout/@code/string()
       else concat('layout-', $layout-count)
  return
     for $date-field in $layout/dc:dataCollectionControl[@xsi:type='dateControl']
        return
          <xf:bind ref="{$layout-xpath}/{$date-field/@name/string()}" type="xs:date"/>
};

(: For documentation on how Orbeon uses date and time fields see:
   http://wiki.orbeon.com/forms/projects/xforms-date-and-time-widgets
   TODO - add functions for "Masks" aka picture formats
   :)
declare function f2x:binds-date-time-fields($form as node()*, $config as node()) as node()* {
(<!-- dateTimeConrol binds -->,
  for $layout at $layout-count in $form/dc:section/dc:layout
  (: all layouts must have a code but if one does not have one we put in a placeholder :)
  let $layout-xpath :=
     if ($layout/@code)
       then $layout/@code/string()
       else concat('layout-', $layout-count)
       return
        for $date-field in $layout/dc:dataCollectionControl[@xsi:type="dateTimeControl"]
        return
            <xf:bind ref="{$layout-xpath}/{$date-field/@name/string()}" type="xs:dateTime"/>
  )
};

(: We will always us a decimal number of no controlDataType is specificed  :)
declare function f2x:binds-numeric-fields($form as node()*, $config as node()) as node()* {
  for $layout at $layout-count in $form/dc:section/dc:layout
  (: all layouts must have a code but if one does not have one we put in a placeholder :)
  let $layout-xpath :=
     if ($layout/@code)
       then $layout/@code/string()
       else concat('layout-', $layout-count)
       return
         for $control in $layout//dc:dataCollectionControl[@xsi:type='number' or @xsi:type='numberControl' or @xsi:type='numberInputControl']
        
            let $input-controlDataType := normalize-space($control/dc:controlDataType)
            (: get rid of any common XML Schema prefixes.  Although these are required in XForms we remove them and then add them back later :)
            let $controlDataType-noprefix1 := replace($input-controlDataType, 'xs:', '')
            let $normalized-datatype := replace($controlDataType-noprefix1, 'xsd:', '')
            
            (: we check to make sure there are no errors before we do any binds :)
            let $error-message := 'Error: unknown data type'
            
            (: here is the lookup between the dc:data types and XML Schema types
               Note that currency is a digit and we need to do some UI changes for this type also :)
            let $xmlschema-type :=
               if (not($normalized-datatype))
                  then 'xs:decimal'
                  else if ($normalized-datatype = 'decimal') then 'xs:decimal'
                  else if ($normalized-datatype = 'integer') then 'xs:integer'
                  else if ($normalized-datatype = 'currency') then 'xs:decimal'
                  else $error-message
            
            return
              if ($xmlschema-type ne $error-message)
                (: the double slash here will work even if the control is nested within a row :)
                then <xf:bind ref="{$layout-xpath}//{$control/@name/string()}" type="{$xmlschema-type}"/>
                else <h:span class="warning">Error - unknown data type for type {$normalized-datatype}</h:span> 
};

declare function f2x:calculate-instance($form as node(), $config as node()) as node()* {
<xf:instance id="calc" xmlns="">
<calc>
{
for $control in $form//dc:dataCollectionControl[dc:rowTotalIndicator='true']
      let $control-name := $control/@name/string()
      return
         element {$control-name} {''}
}
{
for $control in $form//dc:dataCollectionControl[dc:colTotalIndicator='true']
      let $control-name := $control/@name/string()
      return
         element {$control-name} {''}
}
</calc>
</xf:instance>
};

declare function f2x:binds-totals($form as node(), $config as node()) {

(: We must create seperate binds for each layout since names are only unique to
   a given layout.  We will do this for all layouts. :)
for $layout in $form/dc:section/dc:layout
let $layout-count := count($layout/preceding::dc:layout) + 1
(: this value should NEVER be null - but it is in some test cases :)
let $layout-name := 
   if ($layout/@code)
       then $layout/@code/string()
       else concat('layout-', $layout-count)
return
    (<!-- binding rules for calculated totals -->,
    
    for $control in $form//dc:dataCollectionControl[dc:rowTotalIndicator='true']
      let $control-name := $control/@name/string()
      return
         <xf:bind ref="instance('save-data')/{$layout-name}/{$control-name}"
                  calculate="sum(
                                 ({f2x:names-for-this-row($layout-name, $control)})
                                )"/>,
    for $control in $form//dc:dataCollectionControl[dc:colTotalIndicator='true']
      let $control-name := $control/@name/string()
      return
         <xf:bind ref="instance('save-data')/{$layout-name}/{$control-name}"
                  calculate="sum(
                                 ({f2x:names-for-this-col($layout-name, $control)})
                                )"/>              
    )
};

(: This returns a comma delimited string of all control names that in the same rows as the current control 
   Layouts should always have a name.  Not sure why I had to add the optional string yet.  
   Note that we are casting all the values to decimal to get around the bug with Java
   string to double conversion and rounding.  :)
declare function f2x:names-for-this-row($layout-name as xs:string?, $control as node()) as xs:string {
string-join(
     for $name in $control/../../..//dc:dataCollectionControl[not(dc:rowTotalIndicator)]/@name/string()
     return
       concat("xs:decimal(instance('save-data')/", $layout-name, '/', $name, ')')
     , ',')
};

(: this returns a comma delimited string of all control names that are in the samle column of the current control :)
declare function f2x:names-for-this-col($layout-name as xs:string?, $control as node()) as xs:string {
let $column-number := count($control/../../preceding-sibling::*) + 1
return
(: We navigate up to the top of the table and then get all rows but only the columns
   that match the current column.  The first * is rows and the second is columns.
   ../../../../*/*[$column-number]
   Once we have all the columns we can get the name of the controls
     :)
 string-join(
   for $name in $control/../../../../*/*[$column-number]//dc:dataCollectionControl/@name/string()
   return
       concat("instance('save-data')/", $layout-name, '/', $name)
 , ',')
};

(: this returns a comma delimited string of all control names that are sibling column cells of the current control :)
declare function f2x:control-parent-node($control as node()) as node()* {
  $control/../../..//dc:dataCollectionControl[not(dc:rowTotalIndicator)]
};

(: functions that add body content :)

(: I am told we will only get one section, so we will consider this the form title 
use this code if there are multiple sections per form.  For example in a multi-tab form.  For our use we are ignoring the section wrapper
<xf:group class="section">
   <xf:label>{$input/@name/string()}</xf:label>
   {f2x:main($input/*, $config)}
</xf:group>
:)
declare function f2x:section($section as node()*, $config as node()) as node()* {
  if ($section/dc:sectionVisibility='false')
     then ()
     else f2x:main($section/*, $config)
};


(: A section may have multiple layout areas.  Each layout must have consistent vertical or horizontal placement
   of controls :)
declare function f2x:layout($layout as node(), $config as node()) as node()* {
if ($layout/dc:layoutVisibility='false')
   then ()
   else
let $layout-count := count($layout/preceding::dc:layout) + 1

(: all layouts must have a code but if one does not have one we put in a placeholder :)
let $layout-xpath :=
  if ($layout/@code)
     then $layout/@code/string()
     else concat('layout-', $layout-count)

return
   if ($layout/@xsi:type = 'xhtml')
      then $layout/*
      else

(: Note, this is where we put in the context.  All path names are relative to the current layout container :)
<xf:group ref="{$layout-xpath}">
   
   { (: adding a class attribute that shows our orientation and count :)
   if ($layout/dc:layoutStrategy = 'vertical')
      then attribute {'class'} {concat('layout-vertical layout-', $layout-count)}
      else attribute {'class'} {concat('layout-horizontal layout-', $layout-count)}
   }
   
   {  (: if @name is present in the layout, then add a label element from the layout name if it exists 
         Unless we see the displayName to be false :)
      if ($layout/@name and ($layout/dc:displayName ne 'false'))
      then
        <div class="subsection-header">{$layout/@name/string()}</div>
      else ()
   }
   
   { (: note that this might be in the dc namespace :)
     if ($layout/@xsi:type='table' or $layout/@xsi:type='dc:table')
      then
        (f2x:table-specific-css($layout, $config),
        <h:table>
          { (: we put in the table headers for both repeating and freeform layouts :)
             f2x:table-headers($layout, $config)
          }
          <h:tbody>
            { (: here is how we decide if we have a freeform layout. :)
            if (f2x:layout-freeform-indicator($layout))
                then f2x:table-body-static($layout, $config)
                else f2x:table-body-repeat($layout, $config)
            }
          </h:tbody>
        </h:table>)
      else
       f2x:main($layout/*, $config)
    }

</xf:group>
};

declare function f2x:table-specific-css($layout as node(), $config as node()) as node() {
<h:style type="text/css"><![CDATA[
    /* the table headers are gray with white centered text */
    table thead tr th {
      background-color:gray; text-align:center!important; 
      color:white; font-weight:bold!important; 
      border: solid black 1px!important;
      padding: 2px;}
    
    /* by default, all table cells are inputs and have this width of 16 exs */
    .xforms-input-input {width: 16ex!important;}
    
    /* We are over-riding the Orbeon CSS and changing numbers to be changed to display inline and not jump to a new line when
       used within tables etc.  */
    .xbl-fr-number {display: inline-block}
    
    /* this right aligns the numbers */
    .xbl-fr-number-visible-input {text-align: right;}
    
    /* we add this class to all numeric output table data cells */
    .number * {text-align: right!important;}
    
    /* here is how we adjust the width of an individual input columns.  For each input put in the custom width.  
       TODO - make this dynamic for all input in a table header */
    .FederalAuditNumberAndComments .xforms-input-input {width: 32ex!important;}
]]></h:style>
};

(: this is triggered only when there are repeating rows in a table :)
declare function f2x:table-body-repeat($layout as node(), $config as node()) as node()* {
let $layout-count := count($layout/preceding::dc:layout) + 1
let $layout-name := $layout/@code/string()
return
(<!-- table-body-repeat() -->,
    
    <xf:repeat id="repeat-{$layout-count}" ref="instance('save-data')/{$layout-name}/row">
        <h:tr class="repeat-row">
            {for $th in $layout/dc:repeatableRows/dc:headerColumns[not(./dc:columnVisibility) or (./dc:columnVisibility ne 'false')]/dc:tableCell
               return
                 <h:th>
                    {f2x:cell-attributes($th, $config)}
                    {f2x:label($th//dc:label, $config)}
                 </h:th>
            }
            
            {for $td in $layout/dc:repeatableRows/dc:regularColumns[not(./dc:columnVisibility) or (./dc:columnVisibility ne 'false')]/dc:tableCell
              return
                 <h:td>
                    {f2x:cell-attributes($td, $config)}
                    {f2x:main($td/*, $config)}
                 </h:td>
            
            }
            
            {'' (: Note that the trigger should not be shown on the first row 
                   We only enable the trigger if the second row exists.
            :)}
            <h:td>
               <xf:trigger  ref="instance('save-data')/{$layout-name}/row[2]">
                  <xf:label>X</xf:label>
                  <xf:delete ref="." ev:event="DOMActivate"/>
               </xf:trigger>
            </h:td>
            {'' (: TODO: Need to decide when to add delete and add triggers to each row or just at the end of a table. 
            need to consider adding an element called 'RepeatingTableOrderedIndicator'.
            If it is set to RepeatingTableOrderedIndicator='true' then we would insert at the current row at="index('repeat-{$layout-count}')"
            else if RepeatingTableOrderedIndicator='false' append to the end of the table with at="last()"
            ref="instance('save-data')/rows"
            
            Note that for this to work an insert template for this layout
            must be added to the model so we can reference the correct row with
            origin="instance('insert-template-{$layout-count}')".
            :) }
             <h:td>
                   <xf:trigger>
                      <xf:label>+</xf:label>
                      <xf:insert ref="."
                         origin="instance('insert-template-{$layout-count}')" 
                         ev:event="DOMActivate"/>
                   </xf:trigger>
             </h:td>
         </h:tr>
    </xf:repeat>,
    f2x:table-regular-rows($layout, $config)
)
};

declare function f2x:table-body-static($layout as node(), $config as node()) as node()* {
(: Here we are looking for the following struture...
 <regularRows>
     <regularColumns>
         <tableCell>
             <dataCollectionControl xsi:type="stringInputControl" name="FirstName"/>
         </tableCell>
     </regularColumns>
     <regularColumns>
         <orderBy>2</orderBy>
         <tableCell>
             <dataCollectionControl xsi:type="stringInputControl" name="LastName"/>
         </tableCell>
     </regularColumns> 
 </regularRows>
:)
  <!-- table-body-static() -->,
  f2x:table-regular-rows($layout, $config)
};

(: return a sequence of <tr> elements if regular rows are present :)
declare function f2x:table-regular-rows($layout as node(), $config as node()) as node()* {
if ($layout/dc:regularRows)
  then
        for $row in $layout/dc:regularRows[./dc:rowVisibility != 'false']
           order by number($row/dc:orderBy)
           return
            <h:tr>
               { '' (: we have to be aware of duplicates
                     <rowTitle>2.3.1.24  Allopathic Physicians (M.D.)</rowTitle>
                     <headerColumns>
                        <columnTitle>2.3.1.24  Allopathic Physicians (M.D.)</columnTitle>
                  :)
               
                (: '' all logic to display rowTitle or colTile  has been removed for now...we should ONLY display
                      data in a cell if it is in the labelValue
                if ($row/dc:rowTitle and $row/dc:headerColumns/dc:columnTitle)
                then (: Note: the titles can contain escaped XHTML.  
                If there are escape codes we need to use the sax:parse() or util:parse() functions :)
                     <h:td class="left">{$row/dc:labelValue/text()}</h:td>
                else ()
                :)
                } 
                { (: first we put the header columns in <th> elements where visibility is not specified or not false 
                     by default, all header columns are left aligned.  :)
                 for $column in $row/dc:headerColumns[not(./dc:columnVisibility) or ./dc:columnVisibility ne 'false']
                    order by number($column/dc:orderBy)
                    return
                    <h:th class="left">
                       {f2x:cell-attributes($column, $config)}
                       {f2x:main($column/dc:tableCell/*, $config)}
                    </h:th>
                }
                {(: next we put the non-header columns (regular Columns) in 
                    Remove for now.  It is not working and is trying to
                     convert a boolean to a node() [(not(./dc:columnVisibility)) or (./dc:columnVisibility ne 'false')]:)
                 for $column in $row/dc:regularColumns[(not(exists(./dc:columnVisibility))) or (./dc:columnVisibility ne 'false')]
                    order by number($column/orderBy)
                    return
                    <h:td>
                       {f2x:cell-attributes($column, $config)}
                       {f2x:main($column/dc:tableCell/*, $config)}
                    </h:td>
                }
            </h:tr>
            
    else <!-- no regular rows found -->
};

(: this adds attributes to the containing element.  Usually called right after a td or a th :)
declare function f2x:cell-attributes($column as node(), $config as node()) {
   (
    if ($column/dc:rowSpan > 1)
       then attribute {'rowspan'} {$column/dc:rowSpan/text()}
       else (),
      
    if ($column/dc:colSpan > 1)
       then attribute {'colspan'} {$column/dc:colSpan/text()}
       else (),
      
    if ($column/dc:nowrap) (: this must also work if there is already a class attribute on a cell :)
       then
          if ($column/@class)
             then attribute {'class'} {concat($column/@class, ' nowrap')}
             else attribute {'class'} {'nowrap'}
       else ()
    )
};

declare function f2x:form-title($input as node(), $config) as xs:string {
(: TODO put in the path expression for the form title in the browser title bar :)
(: If we are running under eXist we can use the file name util:document-name($input)
   substring-before is a bit dangerious if the file names don't end in .xml :)
  if ($input/dc:formTitle/text())
     then $input/dc:formTitle/text()
     else if ($input/dc:section/dc:name/text()) then $input/dc:section/dc:name/text()
     else if ($input/dc:section/dc:layout/dc:name/text()) then $input/dc:section/dc:layout/dc:name/text()
     else 'No title found'
};


declare function f2x:section-name($input as node(),$config) as xs:string {
    if ($input/dc:section/@name)
     then $input/dc:section/@name
     else 'No title found'
};

(: we should always be at the dc:lable input element here :)
declare function f2x:label($label as node()?, $config as node()) as node()? {
(: if the parent layout is a table then do not display labels 
 if ($label/ancestor::dc:layout[@xsi:type='table' or @xsi:type='dc:table'])
      then ()
:)
<xf:label>
{if ($label/dc:labelValue/*:div and $label/dc:labelRequired = 'true')
      then $label/dc:labelValue/*
      else $label/dc:labelValue/text()
}</xf:label>
};

(: the row at the top of a table if as we get passed a $layout 
We are now expecting a structure like this
<layout>
    <headerRows>
        <headerColumns>
            <tableCell>
                <dataCollectionControl xsi:type="staticDisplayControl">
                    <label labelFor="header_col_2">
                        <labelValue>First Name</labelValue>
                    </label>
                </dataCollectionControl>
            </tableCell>
        </headerColumns>
     </headerRows>               
</layout>
:)
declare function f2x:table-headers($layout as node(), $config as node()) as node()? {
let $number-of-rows := count($layout/dc:headerRows)
return
  if (true()) (: we may want to disable headers in some places :)
    then
    <h:thead>
    
      {for $row at $row-count in $layout/dc:headerRows
        order by number($row/dc:orderBy)
        return
        <h:tr>
               {for $column in $row/dc:headerColumns[./dc:columnVisibility ne 'false']
               (: For now we are just putting in the label from the control.  In the future we can put controls in the header
                  where we put in a recursive call to main($layout/*, $config) in the table cell.  :)
                return 
                   <h:th class="col-{$column/dc:dataCollectionControl/dc:label/@labelFor/string()}">
                     { (: For historical reasons the OLDC stored data as colSpan="0" and colSpan="1".
                          Because this was difficult to fix in the import we are putting in the logic here 
                          :)
                      if ($column/dc:colSpan and number($column/dc:colSpan) gt 1)
                        then attribute {'colspan'} {$column/dc:colSpan}
                        else ()
                     }
                     {if ($column/dc:rowSpan and number($column/dc:rowSpan) gt 1)
                        then attribute {'rowspan'} {$column/dc:rowspan}
                        else ()
                     }
                     {if ($column/dc:tableCell/dc:dataCollectionControl/dc:label/dc:labelValue)
                        then $column/dc:tableCell/dc:dataCollectionControl/dc:label/dc:labelValue/text()
                        else $column/dc:columnTitle/text()
                      }
                   </h:th>
               }
              
              { (: if we are on the last column and we are using an insert mode into a repeating table then add the Delete and Insert column headers :)
                if ($row-count = $number-of-rows)
                  then
                    if (f2x:layout-repeating-table-indicator($layout))
                        then (<h:th>Del</h:th>,
                          <h:th>Ins</h:th>)
                        else ()
                 else ()
              }
        </h:tr>
      }

    </h:thead>
     else ()
};


(: TODO - different versions of the XML Schema use different types for control codes.  This should be standardized
   in a single enumerated list that we would use to validate
   the control.  The data is also duplicated in controlType element which is
   ignored by this version. :)
declare function f2x:dataCollectionControl($input, $config) as node()* {
let $name := normalize-space($input/@name/string())
let $type := $input/@xsi:type/string()
(:  for debug use (<h:span class="hidden">{$input/@xsi:type/string()}</h:span>,  ...) :)
return
(<h:span style="display:none;">{$input/@xsi:type/string()}</h:span>,
if ($type='string' or $type='stringInput' or $type='stringInputControl')
   then
     <xf:input ref="{$name}" class="{$name} nowrap">
        {f2x:standardControlAttributes($input, $config)}
        {f2x:label($input/dc:label, $config)}
        {f2x:standardControlElements($input, $config)}
     </xf:input>
    else
    if ($type='secret' or $type='secretControl' or $type='secretInputControl')
    then
      <xf:secret ref="{$name}" class="{$name}">
        {f2x:label($input/dc:label, $config)}
     </xf:secret>
     else
     if ($type='checkbox' or $type='checkboxControl')
     then
        <xf:input ref="{$name}">
           {f2x:label($input/dc:label, $config)}
        </xf:input>
     else
     if ($type='date' or $type='dateControl')
     then
        <xf:input ref="{$name}">
           {f2x:label($input/dc:label, $config)}
        </xf:input>
     else
     if ($type='dateTime' or $type='dateTimeControl')
     then
        <xf:input ref="{$name}">
           {f2x:label($input/dc:label, $config)}
        </xf:input>
     else
     if ($type='textArea' or $type='textarea' or $type='textareaControl')
     then
        <xf:textarea ref="{$name}" class="{$input/@name/string()}">
           {f2x:standardControlAttributes($input, $config)}
           {f2x:label($input/dc:label, $config)}
        </xf:textarea>
     else
     if ($type='radio' or $type='radioControl' or $type='radioControlGroup' or $type='radioGroupControl')
     then
        <xf:select1 ref="{$name}" appearance="full">
           {f2x:label($input/dc:label, $config)}
           
           (: In the long term, for high performance with one code tree call with with many code
           tables, each with their own name 
             <xf:itemset ref="instance('code-tables')/code-table[name='{$input/@name/string()}']/items/item">
                   <xf:label ref="label"/>
                   <xf:value ref="value"/>
             </xf:itemset>
           :)
           
           (: Until we have a code table service that pulls together all the codes
           <xf:itemset ref="instance('code-{$name}')/code-table/items/item">
                 <xf:label ref="label"/>
                 <xf:value ref="value"/>
           </xf:itemset>
        </xf:select1>
     else
     
     (: Static controls are read only and map to the xf:output element.
        Note that the protectIndicator still needs to skip over output and go to numeric for read-only-commas.
        Not sure this is a good idea.  
        TODO - look for a mask and put in an xxforms:format attribute after a lookup :)
     if (
             $type='static'
             or $type='output'
             or $type='staticDisplayControl' 
             or ($input/dc:protectIndicator = '1' and $type ne 'numberInputControl')
             or ($input/dc:protectIndicator = '2' and $type ne 'numberInputControl')
         )
     then
        if ($input/dc:labelRequired='true' or true())
           then
                <xf:output ref="{$name}">
                   {f2x:label($input/dc:label, $config)}
                </xf:output>
           else ()
     else
     
     if ($type='dropdown' or $type='dropdownControl' or $type='simpleDropDownControl' 
         or $type='dropDownControl' or $type='simpledropDownControl')
     then
        if (string-length($input/dc:internalSource) gt 1)
             then
               <xf:select1 ref="{$name}">
                 {f2x:pipe-delimited-string-to-itemset($input/dc:internalSource)}
               </xf:select1>
             else 
                <xf:select1 ref="{$name}">
                   {f2x:label($input/dc:label, $config)}
                   <!-- FIXME: This format assumes a seperate HTTP GET per code-table.  Update when code-trees contain multiple code tables for each form. -->
                   <xf:itemset ref="instance('code-{$name}')/code-table/items/item">
                         <xf:label ref="label"/>
                         <xf:value ref="value"/>
                   </xf:itemset>
                </xf:select1>
     else
     
     (: all types with the words "checkbox" and "group" will trigger this rule which is a select with full appearance :)
     if (contains(lower-case($type), 'checkbox') and contains(lower-case($type), 'group'))
     then
        <xf:select ref="{$name}" appearance="full">
           {f2x:label($input/dc:label, $config)}
           <!-- FIXME: This format assumes a seperate HTTP GET per code-table.  Update when code-trees contain multiple code tables for each form. -->
           <xf:itemset ref="instance('code-{$name}')/code-table/items/item">
                 <xf:label ref="label"/>
                 <xf:value ref="value"/>
           </xf:itemset>
        </xf:select>
     else
     
     (: all types with the words "dropdown" and "group" will trigger this rule which is a select without full appearance :)
     if (contains(lower-case($type), 'dropdown') and contains(lower-case($type), 'group'))
     then
        <xf:select ref="{$name}">
           {f2x:label($input/dc:label, $config)}
           <!-- FIXME: This format assumes a seperate HTTP GET per code-table.  Update when code-trees contain multiple code tables for each form. -->
           <xf:itemset ref="instance('code-{$name}')/code-table/items/item">
                 <xf:label ref="label"/>
                 <xf:value ref="value"/>
           </xf:itemset>
        </xf:select>
     else
     
     if ($type='number' or $type='numberControl' or $type='numberInputControl')
     then
        f2x:numberControl($input, $config)
     else
        <error>Unknown control {$input}</error>
)
};

declare function f2x:numberControl($control, $config) as node() {
let $name := $control/@name/string()
(: version 3.X.X or before will use a xf:input for all controls. number controls are for 4.X.X releases :)
let $orbeon-major-release-number :=
   if ($config/orbeon_version)
      then number(substring-before($config/orbeon_version, '.'))
      else 3
return
  if ($orbeon-major-release-number ge 4)
    then
        <fr:number ref="{$name}" class="right {$name}">
            {f2x:standardControlAttributes($control, $config)}
            {f2x:numberExtraPropertiesToAttributes($control, $config)}
            {f2x:label($control/dc:label, $config)}
            {f2x:standardControlElements($control, $config)} 
        </fr:number>
    else
     <xf:input ref="{$name}" class="number {$name}">
        {f2x:standardControlAttributes($control, $config)}
        {f2x:label($control/dc:label, $config)}
        {f2x:standardControlElements($control, $config)} 
      </xf:input> 
};

(: Put in the CSS URL that we get from the
   Config file with options for overrides.
   refactor idea: move all css functions to a seperate module :)
declare function f2x:css-refs($config as node()) as node()* {
let $css-url :=
if ($config/system = 'exist')
   then
     if ($config/output = 'xsltforms')
       then concat($config/*:css-url/text(), '?output=xsltforms')
       else
            concat($config/*:css-url/text(), '?output=orbeon')
     else (: the default is a simple pass through of the full URL :)
        ($config/*:css-url/text())
   return
      <h:link rel="stylesheet" type="text/css" href="{$css-url}"/>
}; 

(: This is the main CSS file that is generated inline within the form.  It should never be cached.  CSS
that does not vary from form to form should be in a cached CSS in site.css 
Note that without a layout number all layouts will have the same max label width :)
declare function f2x:css-inline($input as node(), $config as node()) as node()* {
<h:style type="text/css">
    /* all controls that are not specific to an instance of a form should be in the site.css file */
    .orbeon .xforms-label, .xforms-group legend {{ font-weight: bold }}
    
    /* Orbeon specific numeric controls should be right justified by default - move to static file ? 
    the parent div have attributes of xforms-type-decimal xbl-fr-number */
    .orbeon .xbl-fr-number-visible-input {{text-align: right}};
    
    /* If we are running on Orbeon 3.X.X we will be using the standard xf:input controls to input numbers */
    .orbeon .number .xforms-input-input {{text-align: right!important;}};
    
    /* rules for required fields, other colors are khaki, yellow or Moccasin */
    .orbeon .xforms-required .xforms-input-input {{ background-color: Moccasin; }}
    .orbeon .xforms-required .xforms-label:after {{
        content: "*";
        color: red;
     }}
    .orbeon .layout-vertical .xforms-control .xforms-label {{min-width: {concat(f2x:max-label-length($input) + 2, 'ex;')}}}
    
    /* indent all labels on radio controls.  Note the star after items is the selected/deselected wrapper */
    .orbeon .xforms-control .xforms-items * label  {{margin-left: {concat(f2x:max-label-length($input) + 2, 'ex;')}}}
    
    /* for testing table layouts */
    .orbeon table tbody tr td {{border: solid black 1px;}}
    .orbeon table tbody tr th {{border: solid black 1px;}}
    {$f2x:nl}
    {f2x:css-input-input-widths($input, $config)}
    {f2x:css-table-column-widths($input, $config)}
</h:style>
};

(: generate the input-input widths in CSS :)
declare function f2x:css-input-input-widths($input as node(), $config as node()) as xs:string {
(: 15 is the default field width, so we don't have to add any custom CSS to this layout block :)
  string-join (
        for $size in $input//dc:size[. ne '15']
        let $control-name := $size/../@name/string()
        return
          (: if we have an integer then we assume it is a number of ex letters 
             Note that .xforms-value is .xforms-input-input in Orbeon forms :)
          if ($size castable as xs:integer)
              then concat('.orbeon .', $control-name, ' .xforms-input-input {width:', $size/text() + 3, 'ex}', $f2x:nl)
              else concat('.orbeon .', $control-name, ' .xforms-input-input {', $size/text(), '}', $f2x:nl)
      , ' ')
};

(: generate the input-input widths in CSS :)
declare function f2x:css-rows-cols($form as node(), $config as node()) as xs:string {
  string-join (
        for $textarea in $form/dc:section/dc:layout//dc:dataCollectionControl[@xsi:type='textArea']
            let $size := $textarea/dc:size/text()
            return
              if ($textarea/dc:rows castable as xs:integer)
                  then concat('.orbeon .', $textarea/@name/string(), ' textarea {width:', $size + 3, 'ex}', $f2x:nl)
                  else concat('.orbeon .', $textarea/@name/string(), ' textarea {', $size, '}', $f2x:nl)
      , ' ')
};

(: At the top of each repeat table we have a table header for all the columns.  This generates the CSS to have
   the headers exactly match the input-input control widths :)
declare function f2x:css-table-column-widths($form as node(), $config as node()) as xs:string {
if ($form/dc:section/dc:layout/dc:headers)
   then
      let $column-ids := $form/dc:section/dc:layout/dc:headers/dc:header/dc:headerId/text()
      return
        string-join (
           for $control in $form/dc:section/dc:layout//dc:dataCollectionControl
            let $name := $control/@name/string()
            let $size := $control/dc:size/text()
            return
              (: if we have an integer then we assume it is a number of ex letters 
                 Note that .xforms-value is .xforms-input-input in Orbeon forms :)
              if ($size castable as xs:integer)
                  then concat('.orbeon table thead tr th.col-', $name, ' {width:', $size + 3, 'ex;}', $f2x:nl)
                  else concat('.orbeon table thead tr th.col-', $name, ' {width:', $size, '}', $f2x:nl)
         , $f2x:nl)
   else '/* no table headers width information */'
};

(: returns the max length of a label or 5 :)
declare function f2x:max-label-length($form as node()) as xs:integer {
   let $all-labels := $form//dc:labelValue/text()
   let $all-label-lengths :=
      for $label in $all-labels
         return string-length($label)
   let $max-length := max($all-label-lengths)
   return
      if ($max-length gt 5)
         then $max-length
         else 5
};

(: This can be used to generate the content of the save-data instance if the service is not used. 
   In many cases the service is not needed and only adds additional I/O overhead
   Note that "value" is the default value of the form when an "new" form is generated.
   :)
declare function f2x:save-data-instance-content($form as node(), $config as node()) as node() {
if ($form//dc:test-instance)
    then (: get it :)
       $form//dc:test-instance/*
    else (: make one :)
  <formdata form-id="{$form/@code/string()}">
      {f2x:layouts-formdata($form, $config)}
  </formdata>
};

(:
   Assume in input like this:
   
   Assume an output for like this:
   <formdata code="form-id">
      <section code="section-id">
         <layout name="layout-qname1">
            <control name="control-name">
            <control name="control-name">
         </layout>
         <layout name="layout-qname2">
            <control name="control-name">
            <control name="control-name">
         </layout>
      </section>
   </formdata>
:)
declare function f2x:dc-form-to-formdata($form as node(), $config as node()) as node() {
  <formdata code="{$form/@code/string()}" section-id="{$form/dc:section/@code/string()}" versionNumber="1.0">
      {
        for $layout at $layout-count in $form/dc:section/dc:layout
        return
           <layout code="{$layout/@code/string()}" name="{$layout/@name/string()}"> {
           for $control at $count in $layout/dc:dataCollectionControl
                  return
                     element {'control'} {
                       attribute {'identity'} {$count},
                       attribute {'name'} {$control/@name/string()},
                       $control/dc:value/text()
                       }
                 }
           </layout>
          }
  </formdata>
};

(: this function is used to determine if code-tables are required in the model
   right now we are only looking for radioControl but others will be added :)
declare function f2x:has-codes($input as node()) as xs:boolean {
if ($input/dc:section/dc:layout//dc:dataCollectionControl/@xsi:type = 'radioControl' 
 or $input/dc:section/dc:layout//dc:dataCollectionControl/@xsi:type = 'simpleDropDownControl')
  then true()
  else false()
};

(: this function puts in the formdata for all the layouts  :)
declare function f2x:layouts-formdata($form as node()*, $config as node()) as node()* {
for $layout at $layout-counter in $form/dc:section/dc:layout
   return
      f2x:layout-formdata($layout)
};

(: For each layout that uses repeating tables we add data
   to the formdata.  The data will use the layout name
   and the tables will wrap the instance controls in a row.
   :)
declare function f2x:layout-formdata($layout as node()*) as node() {

(: we count then number of prior layouts and we add one :)
let $counter := count($layout/preceding::dc:layout) + 1

(: In a layout, all element names are stored in the "code".  Missing names should be an error but we are just creating one to prevent failure :)
let $element-name :=
   if ($layout/@code)
      then $layout/@code/string()
      else concat('layout-', $counter)

return
(: if we have a freeform table the paths do not need to be nested in a row :)
element {$element-name} {
   if (f2x:layout-repeating-table-indicator($layout))
       then
        ( <row xmlns="">
           {f2x:layout-formdata-controls-repeating($layout)}
         </row>,
         <!-- non-repeating data -->
         ,
         f2x:layout-formdata-controls-non-repeating($layout)
       )
       else f2x:layout-formdata-controls-non-repeating($layout)
       
   }
};

(: For a given layout, this adds all the controls to the formdata.  This might be within a group or within a repeat
   in a group.  :)
declare function f2x:layout-formdata-controls-repeating($layout as node()*) as node()* {
  for $control at $control-count in ($layout/dc:repeatableRows//dc:dataCollectionControl)
    (: missing names should be an error but we are just creating one to prevent failure :)
    let $element-name :=
       if ($control/@name)
          then $control/@name/string()
          else concat('control-', $control-count)
    let $identifier :=
       if ($control/@id)
          then $control/@id/string()
          else concat('id-', $control-count)
    return
       element {$element-name} {
          attribute {'id'} {$identifier},
          $control/dc:value/text()
        }
};

(: For a given layout, this adds all the controls to the formdata.  This might be within a group or within a repeat
   in a group.  :)
declare function f2x:layout-formdata-controls-non-repeating($layout as node()*) as node()* {
  for $control at $control-count in ($layout/dc:dataCollectionControl, $layout/dc:regularRows//dc:dataCollectionControl)
    (: missing names should be an error but we are just creating one to prevent failure :)
    let $element-name :=
       if ($control/@name)
          then $control/@name/string()
          else concat('control-', $control-count)
    let $identifier :=
       if ($control/@id)
          then $control/@id/string()
          else concat('id-', $control-count)
    return
       element {$element-name} {
          attribute {'id'} {$identifier},
          $control/dc:value/text()
        }

};

(: this converts custom extra properties into Orbeon attributes :)
declare function f2x:numberExtraPropertiesToAttributes($control as node(), $config as node()) {
if ($control/dc:extraProperties/dc:property/@key = 'prefix')
  then attribute {'prefix'} {$control/dc:extraProperties/dc:property[@key = 'prefix']/dc:value/text()}
  else (),
  if ($control/dc:extraProperties/dc:property/@key = 'suffix')
  then attribute {'suffix'} {$control/dc:extraProperties/dc:property[@key = 'suffix']/dc:value/text()}
  else (),
  if ($control/dc:extraProperties/dc:property/@key = 'digits-after-decimal')
  then attribute {'digits-after-decimal'} {$control/dc:extraProperties/dc:property[@key = 'digits-after-decimal']/dc:value/text()}
  else (),
  if ($control/dc:extraProperties/dc:property/@key = 'grouping-separator')
  then attribute {'grouping-separator'} {$control/dc:extraProperties/dc:property[@key = 'grouping-separator']/dc:value/text()}
  else ()
};

declare function f2x:standardControlAttributes($control as node(), $config as node()) {
(: Note, attributes must be added directly after the control. :)

  (: This is like the old HTML size attribute and should be done with CSS! For a short-term
     work around we can use the Orbeon proprietory extension :)
  if ($control/dc:size and (number($control/dc:size) gt 0))
    then attribute {'xxforms:size'} {$control/dc:size/text()}
    else (),
    
  (: Warning! This uses the Orbeon proprietory extension form formatting numbers 
  xxforms:format= "format-number(number(.), '###,##0')" :)
  if (string-length($control/dc:maskType) ge 1)
    then
       let $format-number := f2x:mask-to-format($control/dc:maskType)
       return
       attribute {'xxforms:format'} {concat("format-number(number(.), '", $format-number, "')")}
    else (),
    
  (: this is for the textarea but might happen for other controls :)
  (: Note - this now conflicts with the Bootstrap CSS it is being ignored in Orbeon 4.0
     To get this to work again we MUST have a custom CSS for each control in each layout! 
     See the Orbeon Basecamp web site for the support calls in this issue :)
  if ($control/dc:rows and (number($control/dc:rows) gt 0))
    then attribute {'xxforms:rows'} {$control/dc:rows/text()}
    else (),
    
  (: Note - this now conflicts with the Bootstrap CSS it is being ignored in Orbeon 4.0
     To get this to work again we MUST have a custom CSS for each control in each layout! 
     See the Orbeon Basecamp web site for the support calls in this issue :)
  if ($control/dc:cols and (number($control/dc:cols) gt 0))
    then attribute {'xxforms:cols'} {$control/dc:cols/text()}
    else (),
    
  (: Note that the data collection element name is CamelCase but the Orbeon control is all lowercase 
     Note that maxLength of 0 does not make any sense :)
  (: The initial import process for legacy forms all had a maxLength of 0 :) 
  if ($control/dc:maxLength and (number($control/dc:maxLength) gt 1))
    then attribute {'xxforms:maxlength'} {$control/dc:maxLength/text()}
    else (),
  
  (: TODO - not sure what this does :)
  if ($control/dc:autocomplete)
    then attribute {'xxforms:autocomplete'} {$control/dc:autocomplete/text()}
    else (),
  (: I can not find any place in the specification that allows textarea to use Rich Text
     other than OLDC 1797 - Rich Text Area. 
     I note that the demos we saw during traning did have some examples :)
  if ($control/dc:enableRichTextIndicator='true')
    then attribute {'mediatype'} {'text/html'}
    else ()
};

(: Standard control elements like Hint, Help and Alert.
   These must be done AFTER all the attributes have been added to the control.
   The original Legacy forms systems use title but I can't find any things in the XML Schema
   about how hints, help and alerts are processed.
   :)
declare function f2x:standardControlElements($control as node(), $config as node()) {
(: hints and help have been disabled until mappings between input and XForms hints, help, alerts can be
     addressed. Question for the team, do we want to add controls differently based on if we are using a table layout?
if ($control/ancestor::dc:layout[@xsi:type='dc:table'])
then ()
else ()

    if (string-length($control/dc:title) gt 0)
           then <xf:hint>Hint: {$control/dc:title/text()}</xf:hint>
           else 
            if (string-length($control/dc:title) gt 0)
                   then <xf:help>Help: {$control/dc:title/text()}</xf:help>
                   else ()
                   <xf:alert>Invalid value</xf:alert>
:)
<xf:alert>Error</xf:alert>
 };
 
 declare function f2x:transform-form-data($form as node(), $config as node()) as node() {
<formdata code="{$form/@code/string()}" section-id="{$form/dc:section/@code/string()}">
     {f2x:layouts-formdata($form, $config)}
</formdata>
};

(: This function must be called in the model after the save-data instance 
   It will put one insert template in for each repeating table. :)
declare function f2x:table-row-insert-templates($input, $config) {
for $layout at $layout-count in $input/dc:section/dc:layout[@xsi:type='table' or @xsi:type='dc:table']
return
if (f2x:layout-freeform-indicator($layout))
   then () else
<xf:instance  xmlns="" id="insert-template-{$layout-count}">
   <row>
      {f2x:layout-formdata-controls-repeating($layout)}
   </row>
</xf:instance>
};

(: Add instanced to the model to support select and select1 itemsets.

   Note: This function currently adds one instance in the model PER CODE SELECTION LIST due to the limiation
   of the code table services.  This makes forms that have many code tables slower to render and should
   be changed in a future version to have one HTTP must be called in the model after the save-data instance. 
   :)
declare function f2x:code-table-instances($form, $config) {
(<!-- code table instances for -->,
let $code-table-url-prefix := 'http://localhost:8080/maintenance/maintenance/ws/mm/codeTable/get/DC/'
let $code-table-url-suffix := '/xml'
(:
  we need to make sure we do NOT put in an instance for single checkbox controls of type 'checkboxControl'
:)
for $control at $control-count in $form/dc:section/dc:layout/dc:dataCollectionControl
  [ contains(lower-case(@xsi:type),  'group') or 
    (contains(lower-case(./@xsi:type),  'checkbox') and contains(lower-case(./@xsi:type),  'group')) or 
    contains(lower-case(@xsi:type),  'dropdown') or 
    contains(lower-case(./@xsi:type),  'radio')]
  let $control-name := $control/@name/string()
  let $code-table-url := concat($code-table-url-prefix, $control-name, $code-table-url-suffix)
   return
     if (string-length($control/dc:externalSource) gt 1) (: note we need to check empty elements :)
       then
          (: here is where we should be able to ping the remote service to see if it is up and put
          this in some try/catch function :)
          <xf:instance  xmlns="" id="code-{$control-name}" src="{$control/dc:externalSource/text()}"/>
       else
          <xf:instance  xmlns="" id="code-{$control-name}">
             <code-tree>
                <code-table>
                   <name>ErrorCode</name>
                   <items>
                      <item>
                         <label>Error: No External Source URL Present for this code table</label>
                         <value>ERROR-no-external-source-present</value>
                      </item>
                   </items>
                </code-table>
             </code-tree>
          </xf:instance>
)
};

declare function f2x:layout-freeform-indicator($layout as node()) as xs:boolean {
if ($layout/@xsi:type = 'table' and not($layout/dc:repeatableRows))
   then true()
   else false()
};

declare function f2x:layout-repeating-table-indicator($layout as node()) as xs:boolean {
if ($layout/@xsi:type = 'table' and
        ( $layout/dc:repeatableRows/dc:repeating = 'true'
         or
          $layout/dc:repeatableRows/dc:repeating = 'repeatable'
         or
          $layout/dc:repeatableRows/dc:repeating = 'repeated'
         )
     )
   then true()
   else false()
};


(: if any of the layouts in this form have a repeating layout then this will be true :)
declare function f2x:form-has-repeating-layout-indicator($form as node()) as xs:boolean {
let $layouts := $form/dc:section/dc:layout

let $layout-repeating-booleans :=
  for $layout in $layouts
    return
      f2x:layout-repeating-table-indicator($layout)
return
  some $boolean in $layout-repeating-booleans satisfies ($boolean)
};

(: Convert a pipe-delimited string of selection options into an itemset node for use in internal code tables.
   Sample input: 'Male|Female|Unknown'
   Sample output:
    <xf:itemset>
        <xf:item>
            <xf:label>Male</xf:label>
            <xf:value>Male</xf:value>
        </xf:item>
        <xf:item>
            <xf:label>Female</xf:label>
            <xf:value>Female</xf:value>
        </xf:item>
        <xf:item>
            <xf:label>Unknown</xf:label>
            <xf:value>Unknown</xf:value>
        </xf:item>
    </xf:itemset>
   
   Note: that both on-the-screen (label) and the in-the-model-on-the-wire (value) string will be set to the
   same item string.  This makes REST-style parameter calling a challenge if the strings 
   contain spaces!
   :)
   declare function f2x:pipe-delimited-string-to-itemset($input as xs:string) as node()* {
   let $input-tokens := tokenize($input, '\|')
   let $input-count := count($input-tokens)
   return
      if ($input-count lt 1)
         then
            <xf:item>
               <xf:label>Error - no pipe characters in internal source of input: {$input}</xf:label>
               <xf:value>error-no-pipe-characters-in-input</xf:value>
            </xf:item>
          else
            (<xf:item>
                    <xf:label>Select...</xf:label>
                    <xf:value></xf:value>
               </xf:item>
               ,
                for $item in $input-tokens
                  return
                    <xf:item>
                        <xf:label>{$item}</xf:label>
                        <xf:value>{$item}</xf:value>
                   </xf:item>
               )
         
  };
  
declare function f2x:calculations-instance-for-layouts($form as node()) as node() {
let $layouts := $form/dc:section/dc:layout
return
<xf:instance xmlns="" id="calculations">
    <calculations>
       {for $layout in $layouts
          order by $layout/orderBy
          return
             element {$layout/@name} {
                for $cal-name in (
                    $layout/dc:dataCollectionControl[dc:rowTotalIndicator]/@name
                    (: $layout/dc:dataCollectionControl[dc:colTotalIndicator]@name :)
                   )
                   return
                      element {$cal-name} {'0'}
             }  
        }
    </calculations>
</xf:instance>
};