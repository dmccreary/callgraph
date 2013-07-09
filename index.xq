import module namespace style = "http://danmccreary.com/style" at "modules/style.xqm";
let $title := 'XQuery Callgraph System'

let $content :=
<div class="content">
     <p>This application creates and call graphs for module complexity analysis.
     It is a very early beta version.</p>
     
     <h3>List Examples</h3>
     <a href="views/list-items.xq">List Example</a> List call graph examples.<br/>

     <h3>Unit Tests</h3>
     <a href="unit-tests/index.xq">List Unit tests</a> listing of unit tests.<br/>
     
     <h3>References</h3>
     <a href="http://en.wikibooks.org/wiki/XQuery/Call_Graphs">XQuery Wikibook Article on this app</a><br/>
     <a href="https://github.com/dmccreary/callgraph">GitHub</a> Source code repository for this app<br/>
     <a href="http://en.wikipedia.org/wiki/Call_graph">Wikipedia Call Graphs</a> Good overview of what a call graph is and what it is used for.<br/>


     <p>Please contact Dan McCreary (dan@danmccreary.com) if you have any feedback on this app.</p>
</div>

return style:assemble-page($title, $content)