import module namespace style = "http://danmccreary.com/style" at "modules/style.xqm";
let $title := 'XQuery Callgraph System'

let $content :=
<div class="content">
     <p>This application creates and call graphs for module complexity analysis.</p>
     <a href="views/callgraph-to-graphml.xq">Call graph to graph markup</a><br/><br/>
     
     <h3>Item Listers</h3>
     <a href="views/list-items.xq">List Example</a> List call graph examples<br/>
     <!-- 
     <a href="edit/edit.xq?new=true">New Callgraph</a>
     -->
     <h3>Unit Tests</h3>
     <a href="unit-tests/index.xq">List Unit tests</a> listing of unit tests<br/>
     
     <h3>References</h3>
     <a href="http://example.com/link">Link Name</a> Link description<br/>

     
     <p>Please contact Dan McCreary (dan@danmccreary.com) if you have any feedback on this app.</p>
</div>

return style:assemble-page($title, $content)