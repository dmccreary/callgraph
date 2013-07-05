xquery version "1.0";
import module namespace a = "http://danmccreary.com/a" at "../data/a.xqm";
import module namespace cgu = "http://danmccreary.com/callgraph-util" at "../modules/callgraph-util.xqm";

let $data-collection := $cgu:data-collection
let $module-path := concat($data-collection, '/a.xqm')
let $module-uri := xs:anyURI($module-path)

return
<results>
  {inspect:inspect-module($module-uri)}
</results>