import module namespace gv = "http://kitwallace.co.uk/ns/qraphviz" at "../modules/graphviz.xqm";
import module namespace cgu = "http://danmccreary.com/callgraph-util" at "../modules/callgraph-util.xqm";

declare option exist:serialize "method=xhtml media-type=application/xhtml+xml";

let $input :=
<graph xmlns="http://www.martin-loetzsch.de/DOTML">
    <cluster id="m1" bgcolor="pink" label="http://danmccreary.com/module-a">
        <node id="a" label="a:a"/>
        <node id="b"  label="a:b"/>
        <node id="c"  label="a:c"/>
        <edge from="a" to="b"/>
        <edge from="a" to="c"/>
    </cluster>
</graph>

let $input2 :=
<graph xmlns="http://www.martin-loetzsch.de/DOTML">
    <cluster id="mod1" bgcolor="pink" label="http://danmccreary.com/a">
        <node id="a"/>
        <node id="b"/>
        <node id="c"/>
        <node id="d"/>
        <edge from="a" to="c"/>
        <edge from="a" to="b"/>
        <edge from="c" to="d"/>
    </cluster>
</graph>

let $output := gv:dotml-to-dot($input)
let $svg := gv:dot-to-svg($output)

let $output2 := gv:dotml-to-dot($input2)
let $svg2 := gv:dot-to-svg($output2)
return
<html xmlns ="http://www.w3.org/1999/xhtml">
  {$svg}
  {$svg2}
</html>