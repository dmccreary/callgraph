import module namespace style = "http://danmccreary.com/style" at "../modules/style.xqm";
import module namespace cgu = "http://danmccreary.com/callgraph-util" at "../modules/callgraph-util.xqm";

let $title := 'List Call Graph Examples'

let $all-examples := $cgu:all-examples

let $content :=
<div class="content">
   <table class="table table-striped table-bordered">
      <thead>
         <tr>
            <th>File Name</th>
            <th>Last Modified</th>
            <th>View</th>
            <th>SVG</th>
            <th>Edit</th>
         </tr>
      </thead>
      <tbody>
        {for $tree in $all-examples
         let $document-name := util:document-name($tree)
         let $id := $document-name
         let $last-modified := xmldb:last-modified($style:db-path-to-app-data, $document-name)
         return
            <tr>
               <th>
                   <a href="../data/{$id}">{$id}</a>
                 </th>
               <td>{$last-modified}</td>
               <th><a href="view-tree.xq?id={$id}">View</a></th>
               <th><a href="view-tree-svg.xq?id={$id}">SVG</a></th>
               <th><a href="../edit/edit.xq?id={$id}">Edit</a></th>
            </tr>
         }
       </tbody>
    </table>
</div>

return style:assemble-page($title, $content)