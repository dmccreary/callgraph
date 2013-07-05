import module namespace callgraph="http://danmccreary.com/callgraph" at "../modules/callgraph.xqm";
import module namespace cgu = "http://danmccreary.com/callgraph-util" at "../modules/callgraph-util.xqm";



let $data-collection := $cgu:data-collection
let $module-path := concat($data-collection, '/a.xqm')
let $module-uri := xs:anyURI($module-path)
let $simple-test-in := inspect:inspect-module($module-uri)

let $start-time := current-dateTime()
let $transform := callgraph:main($simple-test-in)

return
<testcase name="transform-a" classname="callgraph">
  <input>{$simple-test-in}</input>
  <output>{$transform}</output>
</testcase>