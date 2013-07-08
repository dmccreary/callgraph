xquery version "1.0";

(: module test a :)

module namespace a = "http://danmccreary.com/sample-module";

declare function a:main() {
<a>
  {a:branch()}
  {a:c()}
  {a:util()}
</a>
};

declare function a:branch() {
<branch>
  {a:branch2()}
</branch>
};

declare function a:branch2() {
<branch2>
   {a:util()}
</branch2>
};

declare function a:c() {
<c>
  {a:d()}
  {a:util()}
</c>
};

declare function a:d() {
<d>
  {a:recursive('abc')}
  {a:leaf()}
   {a:util()}
</d>
};

declare function a:leaf() {
<leaf/>
};

declare function a:orphan() {
<u/>
};

declare function a:util() {
<util/>
};

declare function a:recursive($in as xs:string) as xs:string {
if (string-length($in) > 1)
    then
        <r>
           {a:recursive(substring($in, 2))}
           {a:leaf()}
        </r>
    else $in
};

declare function a:never-called() {
<e>
  {a:leaf()}
</e>
};