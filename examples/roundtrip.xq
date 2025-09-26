xquery version "3.1";

(:======================================================
  BiJect — Roundtrip Sanity Check
  ------------------------------------------------------
  Loads a sample input JSON Schema, applies factoring
  and then inlining, and prints all three versions.
======================================================:)

import module namespace biject = "http://example.org/biject"
  at "../src/biject.xq";

(: Load the test input schema :)
declare variable $input := json-doc("input-schema.json");

(: Run factoring and inlining :)
declare variable $factored := biject:factor($input);
declare variable $inlined  := biject:inline($factored);

(: Pretty-print JSON :)
declare function local:pp($m as item()) as xs:string {
  serialize($m, map { "method": "json", "indent": true() })
};

(: Build result object :)
map {
  "original" : $input,
  "factored" : $factored,
  "inlined"  : $inlined
}
! local:pp(.)