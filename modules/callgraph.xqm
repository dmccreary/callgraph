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
<graph xmlns="http://www.martin-loetzsch.de/DOTML" rankdir="LR">
  <graph id="G" edgedefault="undirected">
    <node id="n0"/>
    <node id="n1"/>
    <edge id="e1" from="n0" to="n1"/>
  </graph>
</graph>
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
<graph xmlns="http://www.martin-loetzsch.de/DOTML"  
    xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
    xsi:schemaLocation="http://graphml.graphdrawing.org/xmlns
     http://graphml.graphdrawing.org/xmlns/1.0/graphml.xsd">
   {callgraph:main($node/*)}
</graph>
};

declare function callgraph:function($node as node()) {
<node id="{$node/@name/string()}"/>
};

declare function callgraph:calls($node as node()) {
<edge id="e1" from="{$node/@name/string()}" to="{$node/function/@name/string()}"/>
};

declare function callgraph:module($module as node()) as node(){
let $module-count := count($module/preceding-sibling::module) + 1
let $color-for-nth-module := callgraph:nth-color($module-count)
return
    if (name($module/..) = 'modules')
        then
            <cluster id="mod{$module-count}" bgcolor="{$color-for-nth-module}"  xmlns="http://www.martin-loetzsch.de/DOTML">
               {callgraph:functions-for-module($module/function)}
               {callgraph:calls-for-module($module//calls)}
            </cluster>
         else (: Note: we are now in the graphml namespace so we need to use *: to get the the null namespace :)
         <graph xmlns="http://www.martin-loetzsch.de/DOTML" rankdir="LR">
                <cluster id="mod_{$module-count}" bgcolor="white" label="{$module/@uri}">
                    {callgraph:functions-for-module($module/*:function)}
                    {callgraph:calls-for-module($module//*:calls)}
                 </cluster>
          </graph>
};

(: for each function in a module, add a node :)
declare function callgraph:functions-for-module($functions as node()*) as node()* {
   for $function at $count in $functions
   let $clean-name := replace($function/@name/string(), '-', '_')
   let $color-for-nth-node := callgraph:nth-color($count)
   return
      <node  xmlns="http://www.martin-loetzsch.de/DOTML"  id="{replace($clean-name, ':', '_')}" label="{$function/@name/string()}"
      style="filled" fillcolor="{$color-for-nth-node}"/>
};

declare function callgraph:calls-for-module($calls as node()*) as node()* {
   for $function in $calls/function
   let $clean-from-name1 := replace($function/../../@name/string(), '-', '_')
   let $clean-from-name2 := replace($clean-from-name1, ':', '_')
   let $clean-to-name1 := replace($function/@name/string(), '-', '_')
   let $clean-to-name2 := replace($clean-to-name1, ':', '_')
   return
      <edge xmlns="http://www.martin-loetzsch.de/DOTML" 
         from="{$clean-from-name2}"
         to="{$clean-to-name2}"/>
};

declare function callgraph:nth-color($n as xs:integer) as xs:string? {
let $color-codes-file-name := '10-color-codes.xml'
let $path := concat('/db/apps/callgraph/code-tables/', $color-codes-file-name)
let $doc := doc($path)/*
return
  $doc//item[$n]/value
};