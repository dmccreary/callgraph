xquery version "1.0";

(: module test a :)

module namespace a = "http://danmccreary.com/a";
import module namespace b = "http://danmccreary.com/b" at "b.xqm";
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
  {b:d()}
</c>
};