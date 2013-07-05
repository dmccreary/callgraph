xquery version "1.0";

(: module test b :)

module namespace b = "http://danmccreary.com/b";

declare function b:d() {
<d>
  {b:e()}
  {b:f()}
</d>
};

declare function b:e() {
<e/>
};

declare function b:f() {
<f/>
};