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
            case element(modules) return callgraph:modules($node)
            case text() return $node
            default return ()
};

declare function callgraph:modules($node as node()) {
<graphml xmlns="http://www.martin-loetzsch.de/DOTML"  
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xsi:schemaLocation="http://graphml.graphdrawing.org/xmlns
     http://graphml.graphdrawing.org/xmlns/1.0/graphml.xsd">
   {callgraph:main($node/*)}
</graphml>
};

declare function callgraph:function($node as node()) {
<node id="{$node/@name/string()}">
   {callgraph:main($node/*)}
</node>
};

declare function callgraph:calls($node as node()) {
<edge id="e1" source="{$node/@name/string()}" target="{$node/function/@name/string()}"/>
};

declare function callgraph:module($module as node()) as node(){
let $module-count := count($module/preceding-sibling::module) + 1
let $color-for-nth-module := callgraph:nth-color($module-count)
return
    if (name($module/..) = 'modules')
        then
            <cluster id="mod-{$module-count}" bgcolor="{$color-for-nth-module}"  xmlns="http://www.martin-loetzsch.de/DOTML">
               {callgraph:functions-for-module($module/function)}
               {callgraph:calls-for-module($module//calls)}
            </cluster>
         else (: Note: we are now in the graphml namespace so we need to use *: to get the the null namespace :)
         <graphml xmlns="http://www.martin-loetzsch.de/DOTML">
                <cluster id="mod-{$module-count}" bgcolor="{$color-for-nth-module}" label="{$module/@uri}">
                    {callgraph:functions-for-module($module/*:function)}
                    {callgraph:calls-for-module($module//*:calls)}
                 </cluster>
          </graphml>
};

(: for each function in a module, add a node :)
declare function callgraph:functions-for-module($functions as node()*) as node()* {
   for $function in $functions
   return
      <node  xmlns="http://www.martin-loetzsch.de/DOTML"  id="{$function/@name/string()}"/>
};

declare function callgraph:calls-for-module($calls as node()*) as node()* {
   for $function in $calls/function
   return
      <edge xmlns="http://www.martin-loetzsch.de/DOTML" 
         source="{$function/../../@name/string()}"
         target="{$function/@name/string()}"/>
};

declare function callgraph:nth-color($n as xs:integer) as xs:string? {
let $color-codes-file-name := '10-color-codes.xml'
let $path := concat('/db/apps/callgraph/code-tables/', $color-codes-file-name)
let $doc := doc($path)/*
return
  $doc//item[$n]/value
};