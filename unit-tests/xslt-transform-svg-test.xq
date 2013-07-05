import module namespace gv = "http://kitwallace.co.uk/ns/qraphviz" at "../modules/graphviz.xqm";
import module namespace cgu = "http://danmccreary.com/callgraph-util" at "../modules/callgraph-util.xqm";

let $input :=
<graph xmlns="http://www.martin-loetzsch.de/DOTML" file-name="graphs/bgcolor" rankdir="LR" bgcolor="#80FF80">
    <node id="a"/>
    <cluster id="c1" bgcolor="#FF8080">
        <node id="b"/>
        <node id="c"/>
        <edge from="b" to="c"/>
    </cluster>
    <edge from="a" to="b"/>
</graph>

let $output := gv:dotml-to-dot($input)
let $svg := gv:dot-to-svg($output)
return
<results>
  <input>{$input}</input>
  <output>{$output}</output>
  <svg>{$svg}</svg>
</results>