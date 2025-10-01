xquery version "3.1";

(:======================================================
  BiJect: JSONiq Implementation of Factoring & Inlining
  -----------------------------------------------------
  biject:factor(S)  — Nested → RefBased
  biject:inline(S)  — RefBased → Nested
======================================================:)

module namespace biject = "http://example.org/biject-unified";

(:------------------------------------------------------
  Shared helpers
-------------------------------------------------------:)

declare function biject:_canonicalize($schema as item()) as xs:string {
  serialize(
    if ($schema instance of map(*)) then
      map:merge(
        for $k in sort(object:keys($schema))
        return map:entry($k, biject:_canonicalize($schema($k)))
      )
    else $schema,
    map { "method": "json", "indent": false }
  )
};

declare function biject:_hash($str as xs:string) as xs:string {
  substring(hash($str, "sha1"), 1, 8)
};

(:======================================================
  Algorithm 1 – Factoring
  Nested → RefBased
======================================================:)

declare function biject:factor($schema as item()) as item() {
  (: Phase 1 – Frequency Counting :)
  let $freq := biject:_count-occurrences($schema, map{})
  (: Phase 2 – Factoring :)
  let $res := biject:_factor($schema, $freq, map{})
  return map:merge((
    map:entry("$ref", "#/definitions/" || biject:_hash(biject:_canonicalize($schema))),
    map:entry("definitions", $res("definitions"))
  ))
};

(: ---------------- Phase 1 – Frequency Counting ---------------- :)
declare function biject:_count-occurrences($schema as item(), $freq as map(*)) as map(*) {
  if (not($schema instance of map(*))) then $freq
  else
    let $canon := biject:_canonicalize($schema)
    let $id := biject:_hash($canon)
    let $new-freq := map:put($freq, $id, 1 + map:get($freq, $id, 0))
    return fold-left(
      for $k in object:keys($schema)
      return biject:_count-occurrences($schema($k), $new-freq),
      $new-freq,
      function($acc, $m) { map:merge(($acc, $m)) }
    )
};

(: ---------------- Phase 2 – Factoring ---------------- :)
declare function biject:_factor($schema as item(), $freq as map(*), $defs as map(*)) as map(*) {
  if (not($schema instance of map(*))) then
    map:entry("schema", $schema)
  else
    let $canon := biject:_canonicalize($schema)
    let $id := biject:_hash($canon)
    return
      if (map:get($freq, $id) > 1) then
        (: repeated substructure → factor :)
        if (map:contains($defs, $id)) then
          map:entry("schema", map { "$ref": "#/definitions/" || $id })
        else
          let $processed :=
            map:merge(
              for $k in object:keys($schema)
              return map:entry($k, (biject:_factor($schema($k), $freq, $defs))("schema"))
            )
          let $new-defs := map:put($defs, $id, $processed)
          return (
            map:put($new-defs, $id, $processed),
            map:entry("schema", map { "$ref": "#/definitions/" || $id })
          )
      else
        (: single-use → inline :)
        let $processed :=
          map:merge(
            for $k in object:keys($schema)
            return map:entry($k, (biject:_factor($schema($k), $freq, $defs))("schema"))
          )
        return map:entry("schema", $processed)
};

(:======================================================
  Algorithm 2 – Inlining
  RefBased → Nested
======================================================:)

declare function biject:inline($S as item()) as item() {
  biject:_inline-node($S, $S)
};

declare function biject:_inline-node($n as item(), $root as map(*)) as item() {
  if ($n instance of map(*)) then
    if (map:contains($n, "$ref")) then
      let $target := biject:_resolve($root, $n("$ref"))
      return biject:_deepcopy($target)
    else
      map:merge(
        for $k in object:keys($n)
        return map:entry($k, biject:_inline-node($n($k), $root))
      )
  else if ($n instance of array(*)) then
    array { for $i in 1 to array:size($n) return biject:_inline-node($n($i), $root) }
  else
    $n
};

declare function biject:_resolve($root as map(*), $ref as xs:string) as item()? {
  if (starts-with($ref, "#/")) then
    let $pointer := substring($ref, 3)
    let $parts := tokenize($pointer, "/")
    return fold-left($parts, $root, function($ctx, $p) {
      if ($ctx instance of map(*)) then
        if (map:contains($ctx, $p)) then $ctx($p) else ()
      else if ($ctx instance of array(*)) then
        let $i := xs:integer($p) + 1
        return if ($i ge 1 and $i le array:size($ctx)) then $ctx($i) else ()
      else ()
    })
  else $root
};

declare function biject:_deepcopy($n as item()) as item() {
  if ($n instance of map(*)) then
    map:merge(
      for $k in object:keys($n)
      return map:entry($k, biject:_deepcopy($n($k)))
    )
  else if ($n instance of array(*)) then
    array { for $i in 1 to array:size($n) return biject:_deepcopy($n($i)) }
  else $n
};

(:======================================================
  Ready-to-run Example (commented out)
======================================================:)
(:
(: Uncomment to test round-trip :)

declare variable $input := json-doc("input-schema.json");

(: Nested → RefBased → Nested :)
let $factored := biject:factor($input)
let $inlined  := biject:inline($factored)
return map {
  "original": $input,
  "factored": $factored,
  "inlined":  $inlined
}

:)
