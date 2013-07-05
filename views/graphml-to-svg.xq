import module namespace gv = "http://kitwallace.co.uk/ns/qraphviz" at "../modules/graphviz.xqm";
import module namespace cgu = "http://danmccreary.com/callgraph-util" at "../modules/callgraph-util.xqm";

declare option exist:serialize "method=xhtml media-type=application/xhtml+xml";

let $file-name := request:get-parameter("file-name",'a-graphml.xml')
let $format := request:get-parameter("format","svg")
let $data-collection := $cgu:data-collection
let $file-path := concat($data-collection, '/', $file-name)

return
  if (not(doc-available($file-path)))
    then <error>Document {$file-path} is not available.</error>
    else if (not(doc-available($gv:dotml2dot-path)))
             then <error>Document {$gv:dotml2dot-path} is not available.</error>
             else


let $doc := doc($file-path)/*
let $graph := gv:dotml-to-dot($doc)
let $svg := gv:dot-to-svg($graph) 
return 
<html xmlns="http://www.w3.org/1999/xhtml">
  <head>
     <title>{$file-name}</title>
  </head>
   <body>
      <h1>{$file-name}</h1>
      path: {$file-path}<br/>
      xslt: {$gv:dotml2dot-path}<br/>
      <in>{$doc}</in>
      <dot>{$graph}</dot>
      {$svg}
   </body>       
</html>