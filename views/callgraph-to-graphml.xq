xquery version "1.0";

import module namespace callgraph="http://danmccreary.com/callgraph" at "../modules/callgraph.xqm";

let $file-name := request:get-parameter('file-name', 'docbook-module.xml')
let $data-collection := '/db/apps/callgraph/data'
let $file-path := concat($data-collection, '/', $file-name)

return
if (not(doc-available($file-path)))
  then <error>Document {$file-path} is not available</error>
  else 

let $input := doc($file-path)/*

let $output := callgraph:main($input)
return
<results>
    <input>
      {$input}
    </input>
    <output>
      {$output}
    </output>
</results>