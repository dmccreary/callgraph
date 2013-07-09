xquery version "3.0";

module namespace style = "http://danmccreary.com/style";
(:
import module namespace style = "http://danmccreary.com/style" at "../modules/style.xqm";
:)

declare namespace request="http://exist-db.org/xquery/request";
declare namespace xf="http://www.w3.org/2002/xforms";
declare namespace xrx="http://code.google.com/p/xrx";
declare namespace repo="http://exist-db.org/xquery/repo";

declare variable $style:app-name := 'Call Graph';
declare variable $style:app-id := 'callgraph';
declare variable $style:app-home := concat('/db/apps/', $style:app-id);
declare variable $style:repo-file-path := concat($style:app-home, '/repo.xml');
declare variable $style:repo-doc := doc($style:repo-file-path)/repo:meta;

(: named application database collections starting with '/db' with no exist prefix or rest in paths :)
declare variable $style:app-collection := $style:app-home;
declare variable $style:data-collection := concat($style:app-home, '/data');
declare variable $style:resources-collection := concat($style:app-home, '/resources');
declare variable $style:images-collection := concat($style:resources-collection, '/images');
declare variable $style:css-collection := concat($style:resources-collection, '/css');
declare variable $style:config-collection := concat($style:app-home, '/config');

declare variable $style:default-config-file-path := concat($style:config-collection, 'default.xml');
declare variable $style:config := doc($style:default-config-file-path);

declare variable $style:context := request:get-context-path();

declare variable $style:rest-path-to-app := concat($style:context, '/rest', $style:app-home);

(: these all start with xmldb:exist:// and should be used with the collection and doc functions :)
declare variable $style:db-path-to-site  := concat('xmldb:exist://',  $style:rest-path-to-app);
declare variable $style:db-path-to-app  := concat('xmldb:exist://', $style:rest-path-to-app) ;
declare variable $style:db-path-to-app-data := concat($style:app-home, '/data');

declare variable $style:web-path-to-site := $style:app-home;
declare variable $style:site-dashboard := concat($style:context, '/apps/dashboard/index.html');
declare variable $style:web-path-to-app := concat($style:context, 'apps/', $style:app-id);
declare variable $style:app-home-page := concat($style:web-path-to-app, '/index.xq');


(: full rest path for CSS and image :)
declare variable $style:site-resources := concat($style:rest-path-to-app, '/resources');
declare variable $style:rest-path-to-style-resources := concat($style:rest-path-to-app, '/resources');
declare variable $style:site-images := concat($style:site-resources, '/images');
declare variable $style:site-scripts := concat($style:site-resources, '/js');
declare variable $style:site-css := concat($style:site-resources, '/css');
declare variable $style:rest-path-to-images := concat($style:rest-path-to-app, '/images');

 (: home = 1, apps = 2 :)
 declare function style:web-depth-in-site() as xs:integer {
(: if the context adds '/exist' then the offset is six levels.  If the context is '/' then we only need to subtract 5 :)
let $offset := 
   if ($style:context)
then 4 else 3
    return count(tokenize(request:get-uri(), '/')) - $offset
};

declare function style:header()  as node()*  {
    <div id="header">
        <div id="banner-login"> {
            let $current-user := xmldb:get-current-user()
            return
               if ($current-user eq 'guest')
                  then ()
                  else
                     <a href="{$style:web-path-to-app}/admin/user-prefs.xq">{concat("Logged in as user: ", $current-user)}</a>
        } </div>
       
        <div id="banner">
            <span id="logo">
               <a href="{$style:site-dashboard}/index.xq">
                 <img src="{$style:site-images}/icon.png" height="50px" width="50px" alt="Call Graph App"/>
              </a>
           </span>   
            
            <span id="banner-header-text">Kelly-McCreary &amp; Associates</span>
            
            <!--
            <div id="banner-search">
                <form method="GET" action="{$style:site-dashboard}/apps/search/search.xq">
                    <strong>Search:</strong>
                    <input name="q" type="text"/>
                    <input type="submit" value="Search"/>
                </form>
            </div>
            -->
        </div>
        <div class="banner-seperator-bar"/>
    </div>   
};

declare function style:footer()  as node()*  {
<div id="footer">
   <div class="banner-seperator-bar"/>
   
   <div id="footer-text">Copyright 2013 Kelly-McCreary &amp; Associates. All rights reserved.
      <a href="mailto:dan@danmccreary.com">Feedback</a>
   </div>
</div>
};

declare function style:breadcrumbs($suffix as node()*) as node() {
   <div class="breadcrumbs">
      <a href="{$style:site-dashboard}">eXist Dashboard</a>
      
      &gt; <a href="{$style:app-home-page}">App Home</a>
      
      {if (style:web-depth-in-site() > 2) then
      (' &gt; ',
      <a href="{$style:context}/apps/{$style:app-id}/views/list-items.xq">List Examples</a>
      )
      else ()}
      
      {if ($suffix) then (' &gt; ', $suffix) else ()}
   </div>
};

declare function style:css($page-type as xs:string) 
as node()+ {
    if ($page-type eq 'xhtml') then 
        (
            <link rel="stylesheet" href="{$style:site-css}/bootstrap.min.css" type="text/css" media="screen, projection" />,
            <link rel="stylesheet" href="{$style:site-css}/site.css" type="text/css" media="screen, projection" />
        )
    else if ($page-type eq 'xforms') then 
        <link rel="stylesheet" href="{$style:rest-path-to-style-resources}/css/xforms-css.xq" type="text/css" />
    else ()
};

declare function style:assemble-page($title as xs:string*, $breadcrumbs as node()*, 
                                     $style as element()*, $content as node()+) as element() {
    (
    util:declare-option('exist:serialize', 'method=xhtml media-type=text/html indent=yes')
    ,
    <html 
        xmlns="http://www.w3.org/1999/xhtml"
        xmlns:xf="http://www.w3.org/2002/xforms" 
        xmlns:ev="http://www.w3.org/2001/xml-events" 
        xmlns:bf="http://betterform.sourceforge.net/xforms" 
        xmlns:bfc="http://betterform.sourceforge.net/xforms/controls"
    >
        <head>
            <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
            <link rel="shortcut icon" href="{$style:site-images}/favicon.ico"/>
            <title>{ $title }</title>
        </head>
        <body>
            { style:css('xhtml') }
            { $style }
            <div class="container">
                { style:header() } 
                { style:breadcrumbs($breadcrumbs) }
                <div class="inner" style="line-height: 1.5em;">
                    <div class="pageTitle">
                        <table class="pageTitle">
                            <thead>
                                <tr>
                                    <th class="pageTitle"><h4>{$title}</h4></th>
                                </tr>
                            </thead>
                        </table>
                    </div>
                    { $content }
                </div>
                { style:footer() }
            </div>
        </body>
     </html>
     )
};

(: Just pass title and content.  Put in the default breadcrumb and null for style :)
declare function style:assemble-page($title as xs:string, $content as node()+) as element() {
    style:assemble-page($title, (), (), $content)
};

declare function style:substring-before-last-slash($arg as xs:string?)  as xs:string {
       
   if (matches($arg, '/'))
   then replace($arg,
            concat('^(.*)', '/','.*'),
            '$1')
   else ''
 } ;
 
declare function style:edit-controls($id as xs:string) as node() {
<div class="edit-controls">
    { (: only put the edit controls in if the user has edit rights auth:has-edit-rights(auth:get-current-user()) :)
    if ( true() )
       then (
           <a href="../edit/edit.xq?id={$id}">Edit</a>,
           <a href="../edit/delete-confirm.xq?id={$id}">Delete</a>,
           style:publish-controls($id)
       ) else ()
    }
    <a href="../edit/get-instance.xq?id={$id}">View XML</a>
</div>
};

(: This is the edit-controls with params.  It has a second parameter which controls which of the five buttons to display.
The params string is of the form "vedpx" where:

v: to enable the View button
e: to enable the Edit button
d: to enable the Delete button
p: to enable the Publish button
x: to enable the "View XML" button.

To enable all five controls call it like this:

   style:edit-controls($id, 'vedpx')
   
:)
declare function style:edit-controls($id as xs:string, $params as xs:string) as node() {
<div class="edit-controls">
    {if (contains($params, 'v')) then <a href="../views/view-tree.xq?id={$id}">View</a> else () }
    { (: only put the edit controls in if the user has edit rights auth:has-edit-rights(auth:get-current-user()):)
    if ( true() )
       then (
           if (contains($params, 'e')) then <a href="../edit/edit.xq?id={$id}">Edit</a> else (),
           if (contains($params, 'd')) then <a href="../edit/delete-confirm.xq?id={$id}">Delete</a> else (),
           if (contains($params, 'p')) then style:publish-controls($id) else ()
       ) else ()
    }
    {if (contains($params, 'x')) then <a href="../edit/get-instance.xq?id={$id}">View XML</a> else () }
</div>
};

(: This line will only appear if the user has a role of publisher :)
(: note that the style module uses the html namespace so we need to use *: as a prefix to select the null namespace :)
declare function style:publish-controls($id as xs:string) as node()? {

(: this line assumes that each item in the application collection has a unigue id :)
let $doc := collection($style:db-path-to-app-data)/*[*:id/text() = $id]
return
    (: auth:has-publish-rights(auth:get-current-user()) :)
    if ( true() )
       then
          if ($doc//*:publication-status-code/text() = 'published')
             then <a href="../scripts/publisher/un-publish-to-web.xq?id={$id}">Un-Publish</a>
             else <a href="../scripts/publisher/publish-to-web.xq?id={$id}">Publish</a>
       else ()
};
 
 declare function style:assemble-form($model as node(), $content as node()+) 
as node()+ {
    style:assemble-form((), (), $model, $content, true())
};

(:~
    An alternate version of style:assemble-form(), allowing debug mode.

    @param $model an XForms model node
    @param $content nodes for the body of the page
    @param $debug boolean to activate XSLTForms debug mode
    @return properly serialized XHTML+XForms page
:)
declare function style:assemble-form($model as node(), $content as node()+, $debug as xs:boolean) 
as node()+ {
    style:assemble-form((), (), $model, $content, $debug)
};

(:~
    A helper function for style:assemble-form(), with all optional parameters.

    @param $dummy-attributes an optional sequence of attributes to add to the HTML element
    @param $style an optional style node containing CDATA-encased CSS definitions
    @param $model an XForms model node
    @param $content nodes for the body of the page
    @return properly serialized XHTML+XForms page
:)
declare function style:assemble-form($title as xs:string, $dummy-attributes as attribute()*, $style as element(style)*, 
                                     $model as element(xf:model), $content as node()+)
as node()+ {
    style:assemble-form($dummy-attributes, $style, $model, $content, $style:form-debug-default)
};

(:~
    A helper function for style:assemble-form(), with all optional parameters.

    @param $title the text node containing the title of the page
    @param $breadcrumbs the element node containing the breadcrumbs
    @param $style an optional style node containing CDATA-encased CSS definitions
    @param $model an XForms model node
    @param $content nodes for the body of the page
    @param $dummy-attributes an optional sequence of attributes to add to the HTML element
    @param $debug boolean to activate XSLTForms debug mode
    @return properly serialized XHTML+XForms page
:)
declare function style:assemble-form(
        $title as xs:string,
        $dummy-attributes as attribute()*,
        $style as node()*, 
        $model as node(),
        $content as node()+, 
        $debug as xs:boolean) 
as node()+ {
    util:declare-option('exist:serialize', 'method=xhtml media-type=text/xml indent=yes process-xsl-pi=no')
    ,
    processing-instruction xml-stylesheet {concat('type="text/xsl" href="', request:get-context-path(), '/rest', '/db/apps/xsltforms/xsltforms.xsl"')}
    ,
    if ($debug) then 
        processing-instruction xsltforms-options {'debug="no"'}
    else ()
    ,
    <html  
    xmlns:xf="http://www.w3.org/2002/xforms" 
    xmlns:ev="http://www.w3.org/2001/xml-events"
    xmlns:kert="http://kuberam.ro/ns/kert"
    kert:dummy="dummy"
    eXSLTFormsDataInstancesViewer="true"
    >{ $dummy-attributes }
        <head>
            
            <title>{ $title }</title>
            <link rel="stylesheet" type="text/css" href="edit.css"/>
            { style:css('xforms') }
            { $style }
            { $model }
        </head>
        <body>
            <div class="container">
                { style:header() } 
                <div class="inner">
                { style:breadcrumbs(()) }
                    <h2>{$title}</h2>
                    { $content }
                </div>
                { style:footer() }
            </div>
        </body>
    </html>
};