xquery version "3.0";

module namespace callgraph="http://danmccreary.com/callgraph";
(:
import module namespace callgraph="http://danmccreary.com/callgraph" at "../modules/callgraph.xqm";
:)
(: XQuery typeswitch transform module that converts function/call struture into graph markup structure of nodes and edges

Input is the result of inspect:inspect-module() or inspect:inspect-module-uri()
and the output is GraphML
http://en.wikipedia.org/wiki/GraphML

input format
<module uri="http://docbook.org/ns/docbook" prefix="docbook" location="/db/apps/doc/modules/docbook.xql">
    <function name="docbook:load" module="http://docbook.org/ns/docbook">
    ...
      <calls>
         <function name="dq:do-query" module="http://exist-db.org/xquery/documentation/search" arity="3"/>
       </calls>
    </function>
...

into
<graphml xmlns="http://graphml.graphdrawing.org/xmlns"  
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xsi:schemaLocation="http://graphml.graphdrawing.org/xmlns
     http://graphml.graphdrawing.org/xmlns/1.0/graphml.xsd">
  <graph id="G" edgedefault="undirected">
    <node id="n0"/>
    <node id="n1"/>
    <edge id="e1" source="n0" target="n1"/>
  </graph>
</graphml>
:)

declare namespace gml="http://graphml.graphdrawing.org/xmlns";

declare function callgraph:main($nodes as node()*) {
    for $node in $nodes
    return
        typeswitch ($node)
            case document-node() return callgraph:main($node/*)
            case element(function) return callgraph:function($node)
            case element(calls) return callgraph:calls($node)
            case element(module) return callgraph:module($node)
            case text() return $node
            default return ()
};

declare function callgraph:function($node as node()) {
<node id="{$node/@name/string()}">
   {callgraph:main($node/*)}
</node>
};

declare function callgraph:calls($node as node()) {
<edge id="e1" source="{../function/@name/string()}" target="{$node/function/@name/string()}"/>
};

declare function callgraph:module($node as node()) {
<graphml xmlns="http://graphml.graphdrawing.org/xmlns"  
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xsi:schemaLocation="http://graphml.graphdrawing.org/xmlns
     http://graphml.graphdrawing.org/xmlns/1.0/graphml.xsd">
  <graph id="G" edgedefault="undirected">
    <node id="n0"/>
    <node id="n1"/>
    <edge id="e1" source="n0" target="n1"/>
  </graph>
</graphml>
};