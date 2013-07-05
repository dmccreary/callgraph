xquery version "3.0";

module namespace cgu = "http://danmccreary.com/callgraph-util";
(:
import module namespace cgu = "http://danmccreary.com/callgraph-util" at "../modules/callgraph-util.xqm";
:)
declare namespace svg="http://www.w3.org/2000/svg";

(: no other place in our application should reference the actual path.  They should use this variable :)
declare variable $cgu:app-collection := '/db/apps/callgraph';
declare variable $cgu:data-collection := concat($cgu:app-collection, '/data');
declare variable $cgu:code-table-collection := concat($cgu:app-collection, '/code-tables');

declare variable $cgu:default-config-path := concat($cgu:app-collection, '/conf.xml');
declare variable $cgu:default-config := doc($cgu:default-config-path)/conf;
declare variable $cgu:xunit-test-verbose := xs:boolean($cgu:default-config//xunit-test-verbose);

declare variable $cgu:all-examples := collection($cgu:data-collection)/*;

declare function cgu:tree($id as xs:string) {
$cgu:all-trees[id=$id]
};

declare function cgu:test-status() as node() {
let $collection := concat($cgu:app-collection, '/unit-tests')
let $test-status-path := concat($collection, '/test-status.xml')
let $tests := doc($test-status-path)//test

(: don't show the index or non-xquery or html files :)
let $filtered-files :=
   for $file in xmldb:get-child-resources( $collection )
   return
     if (not($file='index.xq') and (ends-with($file, '.xq') or ends-with($file, '.xql') or ends-with($file, '.html')))
             then $file
             else ()
             
(: the default order is by last update :)
let $sort := request:get-parameter('sort', 'last-modified')

let $sorted-files :=
   if ($sort = 'last-modified')
   then
        for $file in $filtered-files
        order by xs:dateTime(xmldb:last-modified($collection, $file)) descending
        return
           $file
     else if ($sort = 'pass-fail')
        then
        for $file in $filtered-files
        let $test := $tests[file=$file]
        order by $test/status/text()
        return
           $file
           (: the fall through default is by file name :)
     else
       for $file in $filtered-files
        order by $file
        return
           $file
   
return
<div class="content">
      Unit Tests Sorted By 
      {if ($sort = 'last-modified') then 'Last Modified'
      else if ($sort = 'pass-fail') then 'Pass Fail'
      else 'File Name'
     }
      <table class="datatable span-24">
         <thead>
            <tr>
               <th class="span-5 row1">File <a href="{request:get-uri()}?sort=name">Sort</a> </th>
               <th class="span-10 row1">Description</th>
               <th class="span-1 row1">Status <a href="{request:get-uri()}?sort=pass-fail">Sort</a></th>
               <th class="span-2 row1">Modified <a href="{request:get-uri()}?sort=last-modified">Sort</a></th>
            </tr>
         </thead>
      {for $file at $count in $sorted-files
         let $test := $tests[file=$file]
         return
             <tr>
                {if ($count mod 2)
                    then attribute class {'odd'}
                    else attribute class {'even'}
                 }
                <td style="text-align:left;"><a href="{$file}">{$file}</a></td>
                <td style="text-align:left;">{$test/desc/text()}</td>
                <td style="text-align:center;">
                 {if ($test/status/text() = 'fail') 
                    then <span class="fail">fail</span>
                    else <span class="pass">pass</span>
                 }
                </td>
                <td style="text-align:left;">{xmldb:last-modified($collection, $file)}</td>
             </tr>
      }
      </table>
   Test Status at <a href="/rest{$test-status-path}">{$test-status-path}</a>
</div>
};
