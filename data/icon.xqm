xquery version "1.0";

(: module test a :)

module namespace a = "callgraph-module";

declare function a:a() {
<a>
  {a:b()}
  {a:c()}
</a>
};

declare function a:b() {
<b/>
};

declare function a:c() {
<c>
</c>
};
