import module namespace gv = "http://kitwallace.co.uk/ns/qraphviz" at "../modules/graphviz.xqm";
import module namespace cgu = "http://danmccreary.com/callgraph-util" at "../modules/callgraph-util.xqm";

let $file-name := request:get-parameter("file-name", 'conf.xml')

let $app-collection := $cgu:app-collection
let $file-path := concat($app-collection, '/', $file-name)

return
  if (not(doc-available($file-path)))
    then <error>Document {$file-path} is not available.</error>
    else
    
let $conf := doc($file-path)/*
let $xsl := concat($app-collection, '/', $conf/dotml2dot)
return
<results>
  <conf>{$conf}</conf>
  
  <xslt-available>{if (doc-available($xsl))
    then 'pass'
    else 'fail'
   }</xslt-available>
   <xsl>{$gv:dotml2dot-xsl}</xsl>
 </results>