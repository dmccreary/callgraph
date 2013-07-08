import module namespace style = "http://danmccreary.com/style" at "../modules/style.xqm";
import module namespace cgu = "http://danmccreary.com/callgraph-util" at "../modules/callgraph-util.xqm";

let $title := 'List Call Graph Examples'

let $all-examples := $cgu:all-file-names

let $content :=
<div class="content">
   <table class="table table-striped table-bordered">
      <thead>
         <tr>
            <th>File Name</th>
            <th>Last Modified</th>
            <th>Inspect</th>
            <th>GraphML</th>
            <th>Dot</th>
            <th>SVG</th>
         </tr>
      </thead>
      <tbody>
        {for $file-name in $all-examples
         let $id := $file-name
         let $suffix := substring-after($file-name, '.')
         let $last-modified := xmldb:last-modified($style:db-path-to-app-data, $file-name)
         return
            <tr>
               <th>
                   <a href="../data/{$id}">{$id}</a>
                 </th>
               <td>{format-dateTime($last-modified, '[M]/[D]/[Y] [H24]:[m]:[s]')}</td>
               <th><a href="module-to-inspect.xq?file-name={$id}">Inspect</a></th>
               <th><a href="module-to-graphml.xq?file-name={$id}">GraphML</a></th>
               <th><a href="module-to-dot.xq?file-name={$id}">Dot</a></th>
               <th><a href="module-to-svg.xq?file-name={$id}">SVG</a></th>
            </tr>
         }
       </tbody>
    </table>
</div>

return style:assemble-page($title, $content)