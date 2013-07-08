import module namespace gv = "http://kitwallace.co.uk/ns/qraphviz" at "../modules/graphviz.xqm";
import module namespace cgu = "http://danmccreary.com/callgraph-util" at "../modules/callgraph-util.xqm";
import module namespace callgraph="http://danmccreary.com/callgraph" at "../modules/callgraph.xqm";

declare option exist:serialize "method=xhtml media-type=application/xhtml+xml";

let $input-1 :=
<graph xmlns="http://www.martin-loetzsch.de/DOTML">
    <cluster id="m1" bgcolor="pink" label="http://danmccreary.com/module-a">
        <node id="a"/>
        <node id="b"/>
        <node id="c"/>
        <edge from="a" to="b"/>
        <edge from="a" to="c"/>
    </cluster>
</graph>

let $input-2 := 
<graph xmlns="http://www.martin-loetzsch.de/DOTML">
    <cluster id="mod-1" bgcolor="pink" label="http://danmccreary.com/a">
        <node id="a:a"></node>
        <node id="a:b"></node>
        <node id="a:c"></node>
        <node id="a:d"></node>
        <edge from="a:a" to="a:c"></edge>
        <edge from="a:a" to="a:b"></edge>
        <edge from="a:c" to="a:d"></edge>
    </cluster>
</graph>

let $inspect1 :=
<module xmlns="" uri="http://danmccreary.com/a" prefix="a" location="/db/apps/callgraph/data/a.xqm">
        <function name="a:a" module="http://danmccreary.com/a">
            <returns type="item()" cardinality="zero or more"></returns>
            <calls>
                <function name="a:c" module="http://danmccreary.com/a" arity="0"></function>
                <function name="a:b" module="http://danmccreary.com/a" arity="0"></function>
            </calls>
        </function>
        <function name="a:b" module="http://danmccreary.com/a">
            <returns type="item()" cardinality="zero or more"></returns>
        </function>
        <function name="a:c" module="http://danmccreary.com/a">
            <returns type="item()" cardinality="zero or more"></returns>
            <calls>
                <function name="a:d" module="http://danmccreary.com/a" arity="0"></function>
            </calls>
        </function>
        <function name="a:d" module="http://danmccreary.com/a">
            <returns type="item()" cardinality="zero or more"></returns>
        </function>
    </module>
    
let $inspect := inspect:inspect-module(xs:anyURI('/db/apps/callgraph/data/a.xqm'))
let $graphml := callgraph:main($inspect)
let $dot := gv:dotml-to-dot($graphml)
let $svg := gv:dot-to-svg($dot/*)
return
<html xmlns ="http://www.w3.org/1999/xhtml">
  {$input-1}
  {$graphml}
  {$dot}
  {$svg}
</html>