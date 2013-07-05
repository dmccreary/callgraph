import module namespace gv = "http://kitwallace.co.uk/ns/qraphviz" at "../modules/graphviz.xqm";
import module namespace cgu = "http://danmccreary.com/callgraph-util" at "../modules/callgraph-util.xqm";

declare option exist:serialize "method=xhtml media-type=application/xhtml+xml";

let $input :=
<graph xmlns="http://www.martin-loetzsch.de/DOTML">
    <cluster id="m1" bgcolor="pink" label="http://danmccreary.com/module-a">
        <node id="a"/>
        <node id="b"/>
        <node id="c"/>
        <edge from="a" to="b"/>
        <edge from="a" to="c"/>
    </cluster>
    <cluster id="m2" bgcolor="tan" label="http://danmccreary.com/module-b">
        <node id="d"/>
        <node id="e"/>
        <node id="f"/>
        <edge from="d" to="e"/>
        <edge from="d" to="f"/>
    </cluster>
    <edge from="c" to="d"/>
</graph>

let $output := gv:dotml-to-dot($input)
let $svg := gv:dot-to-svg($output)
return
<html xmlns ="http://www.w3.org/1999/xhtml">
  {$svg}
</html>