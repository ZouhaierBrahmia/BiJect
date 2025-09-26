(: biject-inline.xq :)

xquery version "3.1";

module namespace biject="http://example.org/biject/inline";

(:~
 : BiJect — Inlining library
 : Transform a reference-based JSON Schema into a semantically equivalent nested schema
 : by replacing internal $ref pointers with deep copies of their $defs targets.
 :
 : Public API:
 :   biject:inline($schema as map(*)) as map(*)
 :   biject:inline($schema as map(*), $options as map(*)) as map(*)
 :
 : Options (all optional; defaults shown):
 :   "defs-key"                : "$defs"    (: or "definitions" :)
 :   "inline-external-refs"    : false()    (: leave external refs untouched :)
 :   "drop-empty-defs"         : true()     (: remove $defs if fully consumed :)
 :   "max-deref-depth"         : 256        (: cycle safety / guard :)
:)

declare function biject:inline($schema as map(*)) as map(*)
{
  biject:inline($schema, map {
    "defs-key": "$defs",
    "inline-external-refs": false(),
    "drop-empty-defs": true(),
    "max-deref-depth": 256
  })
};

declare function biject:inline($schema as map(*), $options as map(*)) as map(*)
{
  (: Resolve options :)
  let $defs-key := ($options?defs-key, "$defs")[1]
  let $inline-ext := ($options?inline-external-refs, false())[1]
  let $drop-empty := ($options?drop-empty-defs, true())[1]
  let $max-depth := ($options?max-deref-depth, 256)[1]

  (: locate defs object if present :)
  let $defs := if ($schema instance of map(*) and map:contains($schema, $defs-key)) then $schema($defs-key) else map {}

  (: perform inlining on the root schema (preserve original root if it's a wrapper) :)
  let $inlined := biject:_inline-node($schema, $schema, $defs, $inline-ext, map {}, 0, $max-depth, $defs-key)

  return
    if ($drop-empty) then biject:_prune-empty-defs($inlined, $defs-key) else $inlined
};

(: ---------- Helpers ---------- :)

declare function biject:_inline-node(
  $node as item(),
  $root as map(*),
  $defs as map(*),
  $inline-ext as xs:boolean,
  $seen as map(*),             (: map from pointer-string -> true for cycle guard :)
  $depth as xs:integer,
  $max-depth as xs:integer,
  $defs-key as xs:string
) as item()
{
  if ($depth gt $max-depth) then
    (: reached configured depth limit — stop expanding :)
    $node

  else if ($node instance of map(*)) then
    (: if this node contains $ref, handle it :)
    if (map:contains($node, "$ref")) then
      let $refstr := string($node("$ref"))
      return
        if (biject:_is-internal-ref($refstr)) then
          let $pointer := substring($refstr, 3)        (: drop leading "#/" :)
          let $resolved := biject:_resolve-pointer($root, $pointer)
          return
            if (empty($resolved)) then
              (: unresolved pointer — keep as-is :)
              $node
            else
              (: cycle guard: if we've seen this exact ref already on the stack, do not re-expand :)
              if (map:contains($seen, $refstr)) then
                $node
              else
                let $copy := biject:_deepcopy($resolved)
                return biject:_inline-node($copy, $root, $defs, $inline-ext, map:put($seen, $refstr, true()), $depth + 1, $max-depth, $defs-key)
        else
          (: external ref :)
          if ($inline-ext) then
            (: external inlining not implemented in this offline library — keep as-is.
               In future: fetch and inline, or raise an error/optionally fail. :)
            $node
          else
            $node
    else
      (: no $ref on this map — recurse over children (preserve key ordering via object:keys) :)
      map:merge(
        for $k in object:keys($node)
        return map:entry($k, biject:_inline-node($node($k), $root, $defs, $inline-ext, $seen, $depth, $max-depth, $defs-key))
      )

  else if (exists(function-lookup(QName("http://www.w3.org/2005/xpath-functions/array","size"),1)) and $node instance of array(*)) then
    array { for $i in 1 to array:size($node) return biject:_inline-node($node($i), $root, $defs, $inline-ext, $seen, $depth, $max-depth, $defs-key) }

  else
    (: primitive (string/number/bool/null) — return as-is :)
    $node
};

(: JSON Pointer resolver supporting ~0 and ~1 unescaping; pointer is a string WITHOUT leading "#/" :)
declare function biject:_resolve-pointer($root as map(*), $pointer as xs:string) as item()?
{
  if (string-length(normalize-space($pointer)) eq 0) then $root
  else
    let $parts := tokenize($pointer, "/")
    return fold-left($parts, $root, function($ctx, $p) {
      let $step := biject:_unescape-ptr($p)
      if ($ctx instance of map(*)) then
        if (map:contains($ctx, $step)) then $ctx($step) else ()
      else if (exists(function-lookup(QName("http://www.w3.org/2005/xpath-functions/array","size"),1)) and $ctx instance of array(*)) then
        (: JSON Pointer uses 0-based indexing; convert to 1-based for JSONiq arrays :)
        let $idx := try { xs:integer($step) + 1 } catch * { -1 }
        return if ($idx ge 1 and $idx le array:size($ctx)) then $ctx($idx) else ()
      else ()
    })
};

declare function biject:_unescape-ptr($s as xs:string) as xs:string {
  (: JSON Pointer unescaping: "~1" -> "/", "~0" -> "~" :)
  let $t1 := replace($s, "~1", "/")
  return replace($t1, "~0", "~")
};

declare function biject:_is-internal-ref($s as xs:string) as xs:boolean {
  starts-with($s, "#/")
};

declare function biject:_deepcopy($n as item()) as item()
{
  if ($n instance of map(*)) then
    map:merge(
      for $k in object:keys($n)
      return map:entry($k, biject:_deepcopy($n($k)))
    )
  else if (exists(function-lookup(QName("http://www.w3.org/2005/xpath-functions/array","size"),1)) and $n instance of array(*)) then
    array { for $i in 1 to array:size($n) return biject:_deepcopy($n($i)) }
  else $n
};

(: Remove defs-key if no internal $ref remain :)
declare function biject:_prune-empty-defs($schema as map(*), $defs-key as xs:string) as map(*)
{
  let $has := biject:_has-internal-ref($schema)
  if (not($has) and map:contains($schema, $defs-key)) then
    map:merge(
      for $k in object:keys($schema)
      where $k ne $defs-key
      return map:entry($k, $schema($k))
    )
  else $schema
};

declare function biject:_has-internal-ref($n as item()) as xs:boolean
{
  if ($n instance of map(*)) then
    (map:contains($n, "$ref") and biject:_is-internal-ref(string($n("$ref"))))
    or some $k in object:keys($n) satisfies biject:_has-internal-ref($n($k))
  else if (exists(function-lookup(QName("http://www.w3.org/2005/xpath-functions/array","size"),1)) and $n instance of array(*)) then
    some $i in 1 to array:size($n) satisfies biject:_has-internal-ref($n($i))
  else false()
};

(: ------------------ End of module ------------------ :)

(: Example / Round-trip test (commented)
let $nested := json-doc("nested-example.json")
(: To produce ref-based: use biject:factor($nested) from factoring library :)
let $ref := biject:factor($nested) (: assuming factor available in same module or imported :)
let $back := biject:inline($ref)
(: verify round-trip equivalence in practice via semantic tests / instance validation :)
 :)
