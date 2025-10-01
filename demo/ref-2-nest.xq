xquery version "3.1";

(: JSONiq Implementation of Algorithm 2 - Inlining :)

(: Reference-based → Nested :)

declare function local:inline($S as item()) as item() {
  local:_inline-node($S, $S)
};

(: DFS traversal :)
declare function local:_inline-node($n as item(), $root as map(*)) as item() {
  if ($n instance of map(*)) then
    if (map:contains($n, "$ref")) then
      let $target := local:_resolve($root, $n("$ref"))
      return local:_deepcopy($target)
    else
      map:merge(
        for $k in object:keys($n)
        return map:entry($k, local:_inline-node($n($k), $root))
      )
  else if ($n instance of array(*)) then
    array { for $i in 1 to array:size($n) return local:_inline-node($n($i), $root) }
  else
    $n
};

(: Resolve an internal JSON Pointer :)
declare function local:_resolve($root as map(*), $ref as xs:string) as item()? {
  if (starts-with($ref, "#/")) then
    let $pointer := substring($ref, 3)
    let $parts := tokenize($pointer, "/")
    return fold-left($parts, $root, function($ctx, $p) {
      if ($ctx instance of map(*)) then
        if (map:contains($ctx, $p)) then $ctx($p) else ()
      else if ($ctx instance of array(*)) then
        let $i := xs:integer($p) + 1 (: JSON Pointer uses 0-based indexing :)
        return if ($i ge 1 and $i le array:size($ctx)) then $ctx($i) else ()
      else ()
    })
  else $root (: external refs not expanded :)
};

(: Deep copy :)
declare function local:_deepcopy($n as item()) as item() {
  if ($n instance of map(*)) then
    map:merge(
      for $k in object:keys($n)
      return map:entry($k, local:_deepcopy($n($k)))
    )
  else if ($n instance of array(*)) then
    array { for $i in 1 to array:size($n) return local:_deepcopy($n($i)) }
  else $n
};

(: ---------------- Driver code ---------------- :)

declare variable $input := json-doc("input-refbased.json");

return local:inline($input)
