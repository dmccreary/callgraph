xquery version "1.0";
import module namespace cgu = "http://danmccreary.com/callgraph-util" at "../modules/callgraph-util.xqm";
import module namespace gv = "http://kitwallace.co.uk/ns/qraphviz" at "../modules/graphviz.xqm";
import module namespace callgraph="http://danmccreary.com/callgraph" at "../modules/callgraph.xqm";

declare option exist:serialize "method=xhtml media-type=application/xhtml+xml";

(: given any file name in out test collection, this will return the inspect document for that module :)

let $file-name := request:get-parameter("file-name",'a-graphml.xml')
let $data-collection := $cgu:data-collection
let $file-path := concat($data-collection, '/', $file-name)
let $file-name-as-uri := xs:anyURI($file-path)
return
  if (not(util:binary-doc-available($file-path)))
    then <error>Document {$file-path} is not available.</error>
    else

let $inspect := inspect:inspect-module($file-name-as-uri)
let $graphml := callgraph:main($inspect)
let $dot := gv:dotml-to-dot($graphml)
let $svg := gv:dot-to-svg($dot)
return
<html xmlns ="http://www.w3.org/1999/xhtml">
  {$svg}
</html>