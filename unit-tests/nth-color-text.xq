import module namespace callgraph="http://danmccreary.com/callgraph" at "../modules/callgraph.xqm";


<testcase name="nth-color-test" classname="callgraph">
  {for $index in (1 to 10)
  return
     <item>
        <index>{$index}</index>
        <color>{callgraph:nth-color($index)}</color>
     </item>
  }
</testcase>