xquery version "3.1";

(: JSONiq Implementation of Algorithm 1 - Factoring :)

(: Nested → Reference-based :)

declare function local:canonicalize($schema as item()) as xs:string {
  serialize(
    if (exists($schema?*))
    then map:merge(
           for $k in sort(keys($schema))
           return map:entry($k, local:canonicalize($schema($k)))
         )
    else $schema,
    map { "method": "json", "indent": false }
  )
};

declare function local:hash($str as xs:string) as xs:string {
  let $h := fn:hash($str, "sha1")
  return fn:substring($h, 1, 8)  (: short, stable identifier :)
};

(: Phase 1 – Frequency Counting :)
declare function local:count-occurrences($schema as item(), $freq as map(*)) as map(*) {
  if (not($schema instance of map(*))) then $freq
  else
    let $canon := local:canonicalize($schema)
    let $id := local:hash($canon)
    let $new-freq := map:put($freq, $id, 1 + map:get($freq, $id, 0))
    return fold-left(
      for $k in keys($schema)
      return local:count-occurrences($schema($k), $new-freq),
      $new-freq,
      function($acc, $m) { map:merge(($acc, $m)) }
    )
};

(: Phase 2 – Factoring :)
declare function local:factor($schema as item(), $freq as map(*), $defs as map(*)) as map(*) {
  if (not($schema instance of map(*))) then
    map:entry("schema", $schema)
  else
    let $canon := local:canonicalize($schema)
    let $id := local:hash($canon)
    return
      if (map:get($freq, $id) > 1) then
        (: repeated substructure → factor :)
        if (map:contains($defs, $id)) then
          map:entry("schema", map { "$ref": "#/definitions/" || $id })
        else
          let $processed :=
            map:merge(
              for $k in keys($schema)
              return map:entry($k,
                (local:factor($schema($k), $freq, $defs))("schema"))
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
            for $k in keys($schema)
            return map:entry($k,
              (local:factor($schema($k), $freq, $defs))("schema"))
          )
        return map:entry("schema", $processed)
};

(: Driver code :)
declare variable $input := json-doc("input-schema.json");

let $freq := local:count-occurrences($input, map{})
let $res := local:factor($input, $freq, map{})
return map:merge((
  map:entry("$ref", "#/definitions/" || local:hash(local:canonicalize($input))),
  map:entry("definitions", $res("definitions"))
))

