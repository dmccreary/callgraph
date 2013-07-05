import module namespace style = "http://danmccreary.com/style" at "../modules/style.xqm";
import module namespace cgu = "http://danmccreary.com/callgraph-util" at "../modules/callgraph-util.xqm";

let $title := 'Unit tests'

let $content :=
<div class="content">
  {cgu:test-status()}
</div>

return style:assemble-page($title, $content)