import module namespace a = "http://danmccreary.com/a" at "../data/a.xqm";
import module namespace cgu = "http://danmccreary.com/callgraph-util" at "../modules/callgraph-util.xqm";
let $start-time := current-dateTime()
return
<testcase name="call a:a()" classname="a">
  {a:a()}
</testcase>