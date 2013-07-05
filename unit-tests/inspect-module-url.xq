xquery version "1.0";
declare namespace docbook="http://docbook.org/ns/docbook";

let $module-uri := xs:anyURI("/db/apps/doc/modules/docbook.xql")
(:
does now include a <calls> section for each described function, which lists all the functions called:

<function name="templates:each"  module="http://exist-db.org/xquery/templates">
    <argument type="node()"  cardinality="exactly one"  var="node"/>
    <argument type="map"  cardinality="exactly one"  var="model"/>
    <argument type="xs:string"  cardinality="exactly one"  var="from"/>
    <argument type="xs:string"  cardinality="exactly one"  var="to"/>
    <returns type="item()"  cardinality="zero or more"/>
    <annotation name="templates:wrap"  namespace="http://exist-db.org/xquery/templates"/>
    <calls>
        <function name="templates:process"  module="http://exist-db.org/xquery/templates"  arity="2"/>
    </calls>
</function>

:)

return
<results>
  {inspect:inspect-module($module-uri)}
</results>