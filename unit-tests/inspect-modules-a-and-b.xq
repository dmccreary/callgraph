xquery version "1.0";
import module namespace a = "http://danmccreary.com/a" at "../data/a.xqm";
import module namespace cgu = "http://danmccreary.com/callgraph-util" at "../modules/callgraph-util.xqm";

let $data-collection := $cgu:data-collection
let $module-path-a := concat($data-collection, '/a.xqm')
let $module-uri-a := xs:anyURI($module-path-a)
let $module-path-b := concat($data-collection, '/b.xqm')
let $module-uri-b := xs:anyURI($module-path-b)

return
<modules>
  {inspect:inspect-module($module-uri-a)}
  {inspect:inspect-module($module-uri-b)}
</modules>