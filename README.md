callgraph
=========

Creates XQuery call graphs for complexity analysis.  This is a very early pre-release.

The progam works by using the eXist inspect module and then transforms the result to a graph XML markup format.
It then converts this graph format to GraphViz "dot" format and then to SVG for rendering within a web browser.

The XQuery pipeline is the following:

let $inspect := inspect:inspect-module($file-name-as-uri)
let $graphml := callgraph:main($inspect)
let $dot := gv:dotml-to-dot($graphml)
let $svg := gv:dot-to-svg($dot)

The current version only works on a single module.

For more information, see the wikibook here:

http://en.wikibooks.org/wiki/XQuery/Call_Graphs
