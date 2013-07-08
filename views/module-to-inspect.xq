xquery version "1.0";
import module namespace cgu = "http://danmccreary.com/callgraph-util" at "../modules/callgraph-util.xqm";

(: given any file name in out test collection, this will return the inspect document for that module :)

let $file-name := request:get-parameter("file-name",'a-graphml.xml')
let $data-collection := $cgu:data-collection
let $file-path := concat($data-collection, '/', $file-name)
let $file-name-as-uri := xs:anyURI($file-path)
return
  if (not(util:binary-doc-available($file-path)))
    then <error>Document {$file-path} is not available.</error>
    else

inspect:inspect-module($file-name-as-uri)