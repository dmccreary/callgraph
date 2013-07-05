xquery version "1.0";
import module namespace a = "http://danmccreary.com/a" at "../data/a.xqm";
import module namespace cgu = "http://danmccreary.com/callgraph-util" at "../modules/callgraph-util.xqm";

let $start-time := util:system-time()

(: this is our test :)
let $a := a:a()

let $runtime := ((util:system-time() - $start-time) div xs:dayTimeDuration('PT1S'))

let $pass-fail :=
  if ($a//e)
    then 'success'
    else 'failure'

let $content :=
    if ($cgu:xunit-test-verbose)
       then
            <results>
               {$a}
            </results>
       else ()

return
<testcase name="01-template-xunit" classname="template-app" time="{$runtime}">
   <site-config-unit-test-verbose>{$cgu:xunit-test-verbose}</site-config-unit-test-verbose>
   {element {$pass-fail} {$content/*}}
</testcase>
     