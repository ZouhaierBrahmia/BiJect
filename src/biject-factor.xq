(: biject-factor.xq :)

xquery version "3.1";

module namespace biject="http://example.org/biject/factor";

(:========================================================================
  BiJect — Factoring Library (Nested → Reference-based)

  Public API:
    biject:factor($schema as item()) as map(*)
    biject:factor($schema as item(), $options as map(*)) as map(*)

  Options (all optional; defaults shown):
    "ignore-annotations" : true()
    "annotation-keys"    : ["title","description","examples","$comment","default",
                            "deprecated","readOnly","writeOnly"]
    "protect-keys"       : ["$schema","$id","$anchor"]
    "root-may-be-ref"    : false()
    "defs-key"           : "auto"      (: "auto" | "$defs" | "definitions" :)
    "signature-mode"     : "hash"      (: "hash" | "text" :)
    "promote-names"      : true()      (: semantic name promotion :)
    "name-precedence"    : ["title"]   (: fields to try before property key :)
========================================================================:)

declare function biject:factor($schema as item()) as map(*)
{
  biject:factor(
    $schema,
    map {
      "ignore-annotations": true(),
      "annotation-keys":    ["title","description","examples","$comment","default",
                             "deprecated","readOnly","writeOnly"],
      "protect-keys":       ["$schema","$id","$anchor"],
      "root-may-be-ref":    false(),
      "defs-key":           "auto",
      "signature-mode":     "hash",
      "promote-names":      true(),
      "name-precedence":    ["title"]
    }
  )
};

declare function biject:factor($schema as item(), $options as map(*)) as map(*)
{
  let $opts := biject:_normalize-options($schema, $options)

  (: Phase 1 — Count signatures and gather name hints :)
  let $countState := map {
    "counts": map {},                  (: sig -> integer :)
    "name-hints": map {},              (: sig -> map(name->count) :)
    "opts": $opts
  }
  let $counted := biject:_count($schema, [], $countState)

  (: Phase 2 — Factor with semantic naming + safe defs merge :)
  let $state0 := map {
    "defs": biject:_existing-defs($schema, $opts?defs-key),  (: keep original defs :)
    "sig->name": map {},            (: chosen name per signature :)
    "used-names": map:keys( biject:_existing-defs($schema, $opts?defs-key) ) ! string#1,
    "counts": $counted?counts,
    "name-hints": $counted?name-hints,
    "opts": $opts
  }

  let $factored := biject:_factor-node($schema, true(), [], $state0)

  (: attach/merge defs only if non-empty and not already embedded :)
  let $defs := $factored?state?defs
  let $out  := $factored?node

  return
    if (map:size($defs) gt 0) then
      if (map:contains($out, $opts?defs-key)) then
        map:put($out, $opts?defs-key,
          map:merge( ($defs, $out($opts?defs-key)) )
        )
      else
        map:put($out, $opts?defs-key, $defs)
    else
      $out
};

(:==================== Helpers: Options, detection, defs key ====================:)

declare function biject:_normalize-options($schema as item(), $options as map(*)) as map(*)
{
  let $opt := function($k, $d) { if (map:contains($options,$k)) then $options($k) else $d }
  let $defs-key :=
    let $req := $opt("defs-key","auto")
    return
      if ($req eq "$defs" or $req eq "definitions") then $req
      else if ($schema instance of map(*) and map:contains($schema, "$defs")) then "$defs"
      else if ($schema instance of map(*) and map:contains($schema, "definitions")) then "definitions"
      else "$defs"
  return map {
    "ignore-annotations": $opt("ignore-annotations", true()),
    "annotation-keys":    ($opt("annotation-keys",
                           ["title","description","examples","$comment","default",
                            "deprecated","readOnly","writeOnly"])),
    "protect-keys":       ($opt("protect-keys", ["$schema","$id","$anchor"])),
    "root-may-be-ref":    $opt("root-may-be-ref", false()),
    "defs-key":           $defs-key,
    "signature-mode":     $opt("signature-mode","hash"),
    "promote-names":      $opt("promote-names", true()),
    "name-precedence":    ($opt("name-precedence", ["title"]))
  }
};

declare function biject:_existing-defs($schema as item(), $defs-key as xs:string) as map(*)
{
  if ($schema instance of map(*) and map:contains($schema, $defs-key)) then
    let $d := $schema($defs-key)
    return if ($d instance of map(*)) then $d else map {}
  else map {}
};

(:==================== Phase 1: counting & name hints ====================:)

declare function biject:_count(
  $n as item(),
  $path as array(*),
  $state as map(*)
) as map(*)
{
  let $opts := $state?opts
  return
    if (biject:_is-schema-object($n)) then
      let $sig := biject:_signature($n, $opts)
      let $counts1 := map:put($state?counts, $sig, ( ($state?counts($sig), 0)[1] + 1 ))
      let $name-hints1 :=
        let $hint-name := biject:_hint-from-node($n, $path, $opts)
        return
          if (empty($hint-name)) then $state?name-hints
          else
            let $cur := ($state?name-hints($sig), map {})[1]
            let $new := map:put($cur, $hint-name, ( ($cur($hint-name), 0)[1] + 1 ))
            return map:put($state?name-hints, $sig, $new)
      let $state1 := map:put(map:put($state, "counts", $counts1), "name-hints", $name-hints1)
      return biject:_map-fold($n, $state1,
               function($k, $v, $st) { biject:_count($v, array:append($path, $k), $st) })
    else if (biject:_is-array($n)) then
      fold-left(1 to array:size($n), $state,
        function($st, $i) { biject:_count($n($i), array:append($path, $i), $st) })
    else $state
};

(: derive a human name for this node (title > id/anchor > property key) :)
declare function biject:_hint-from-node(
  $n as map(*),
  $path as array(*),
  $opts as map(*)
) as xs:string?
{
  let $prec := $opts?name-precedence
  let $by-field :=
    for $k in $prec
    where map:contains($n, $k) and $n($k) instance of xs:string
    return string($n($k))
  return
    if (exists($by-field)) then $by-field[1]
    else if (array:size($path) gt 0 and $path(array:size($path)) instance of xs:string) then
      string($path(array:size($path)))   (: last property key :)
    else ()
};

(:==================== Phase 2: factoring ====================:)

declare function biject:_factor-node(
  $n as item(),
  $is-root as xs:boolean,
  $path as array(*),
  $state as map(*)
) as map(*)
{
  let $opts := $state?opts
  return
    if (biject:_is-schema-object($n)) then
      let $sig := biject:_signature($n, $opts)
      let $count := ($state?counts($sig), 0)[1]
      return
        if (($count gt 1) and (not($is-root) or $opts?root-may-be-ref)) then
          (: repeated → factor :)
          let $chosen :=
            if (map:contains($state?{"sig->name"}, $sig)) then $state?{"sig->name"}($sig) else ()
          return
            if ($chosen) then
              map { "node": map { "$ref": "#/" || $opts?defs-key || "/" || $chosen }, "state": $state }
            else
              let $name0 := if ($opts?promote-names) then biject:_best-name($sig, $state) else ()
              let $name1 := biject:_sanitize-name( ($name0, "Def")[1] )
              let $unique := biject:_unique-name($name1, $state?used-names)
              let $state1 := map:put($state, "used-names", array:append($state?used-names, $unique))
              (: build the definition by factoring children inside it :)
              let $defRec := biject:_factor-children($n, array:append($path, $unique), $state1)
              let $defs2 := map:put($defRec?state?defs, $unique, $defRec?node)
              let $sig2name := map:put($defRec?state?{"sig->name"}, $sig, $unique)
              let $state2 := map:put(map:put($defRec?state, "defs", $defs2), "sig->name", $sig2name)
              return map {
                "node": map { "$ref": "#/" || $opts?defs-key || "/" || $unique },
                "state": $state2
              }
        else
          (: single-use or forced-inline root → recurse into children :)
          let $rec := biject:_factor-children($n, $path, $state)
          return map { "node": $rec?node, "state": $rec?state }

    else if (biject:_is-array($n)) then
      let $acc := fold-left(1 to array:size($n), map { "items": array {}, "state": $state },
        function($st, $i) {
          let $res := biject:_factor-node($n($i), false(), array:append($path, $i), $st?state)
          return map { "items": array:append($st?items, $res?node), "state": $res?state }
        })
      return map { "node": $acc?items, "state": $acc?state }

    else
      map { "node": $n, "state": $state }
};

declare function biject:_factor-children(
  $m as map(*),
  $path as array(*),
  $state as map(*)
) as map(*)
{
  let $opts := $state?opts
  return biject:_map-rewrite($m, function($k, $v) {
    if (some $p in $opts?protect-keys satisfies $p eq $k) then
      map { "node": $v, "state": $state }
    else
      biject:_factor-node($v, false(), array:append($path, $k), $state)
  })
};

(:================ Signatures, canonicalization, sanitization ================:)

declare function biject:_signature($n as map(*), $opts as map(*)) as xs:string
{
  let $norm := if ($opts?ignore-annotations) then biject:_strip-annotations($n, $opts?annotation-keys) else $n
  let $canon := biject:_canonical-string($norm)
  return
    if ($opts?signature-mode eq "hash") then substring(fn:hash($canon, "sha1"), 1, 8)
    else $canon
};

declare function biject:_strip-annotations($m as map(*), $ann as array(*)) as map(*)
{
  let $keys := object:keys($m)
  let $kept := for $k in $keys where not(some $a in $ann satisfies $a eq $k) return $k
  return map:merge(
    for $k in sort($kept)
    return map:entry($k,
      let $v := $m($k)
      return
        if (biject:_is-schema-object($v)) then biject:_strip-annotations($v, $ann)
        else if (biject:_is-array($v)) then
          array { for $i in 1 to array:size($v)
                  let $vi := $v($i)
                  return if (biject:_is-schema-object($vi)) then biject:_strip-annotations($vi, $ann) else $vi }
        else $v
    )
  )
};

declare function biject:_canonical-string($n as item()) as xs:string
{
  if (biject:_is-schema-object($n)) then
    let $keys := sort(object:keys($n))
    return concat("{",
      string-join(
        for $k in $keys
        return concat(escape-html-uri($k), ":", biject:_canonical-string($n($k))),
        ","
      ),
      "}"
    )
  else if (biject:_is-array($n)) then
    concat("[",
      string-join(
        for $i in 1 to array:size($n)
        return biject:_canonical-string($n($i)),
        ","
      ),
      "]"
    )
  else
    if ($n instance of xs:string) then concat('"', replace($n, '"','\"'), '"')
    else if ($n instance of xs:boolean) then (if ($n) then "true" else "false")
    else if ($n instance of xs:double or $n instance of xs:decimal or $n instance of xs:integer) then string($n)
    else if ($n instance of xs:untypedAtomic) then concat('"', replace(string($n), '"','\"'), '"')
    else "null"
};

declare function biject:_best-name($sig as xs:string, $state as map(*)) as xs:string?
{
  let $hint-map := ($state?{"name-hints"}($sig), map {})[1]
  let $cands := map:keys($hint-map)
  return
    if (empty($cands)) then ()
    else
      let $best :=
        for $n in $cands
        let $w := $hint-map($n)
        order by $w descending, string-length($n) ascending, lower-case($n) ascending
        return $n
      return $best[1]
};

declare function biject:_sanitize-name($s as xs:string) as xs:string
{
  let $alnum := replace($s, "[^A-Za-z0-9]+", " ")
  let $caps  := string-join( for $t in tokenize(normalize-space($alnum), " ")
                             return concat(upper-case(substring($t,1,1)), lower-case(substring($t,2))), "" )
  return if ($caps = "") then "Def" else $caps
};

declare function biject:_unique-name($base as xs:string, $used as array(*)) as xs:string
{
  let $exists := some $u in 1 to array:size($used) satisfies $used($u) eq $base
  return
    if (not($exists)) then $base
    else
      let $i := 2
      return
        let $gen := function($k as xs:integer) as xs:string { concat($base, $k) }
        return
          head( for $k in $i to 100000
                let $n := $gen($k)
                where not(some $u in 1 to array:size($used) satisfies $used($u) eq $n)
                return $n )
};

(:==================== Generic utilities ====================:)

declare function biject:_map-rewrite(
  $m as map(*),
  $f as function(item(), item()) as map(*)
) as map(*)
{
  let $keys := object:keys($m)
  let $acc := fold-left($keys, map { "node": map {}, "state": () }, function($st, $k) {
    let $res := $f($k, $m($k))
    let $node := if (empty($st?node)) then map {} else $st?node
    map { "node": map:put($node, $k, $res?node), "state": ($res?state, $st?state)[1] }
  })
  return $acc
};

declare function biject:_map-fold(
  $m as map(*),
  $seed as map(*),
  $f as function(item(), item(), map(*)) as map(*)
) as map(*)
{
  fold-left(object:keys($m), $seed, function($st, $k) { $f($k, $m($k), $st) })
};

declare function biject:_is-array($n as item()) as xs:boolean
{ exists(function-lookup(QName("http://www.w3.org/2005/xpath-functions/array", "size"), 1)) and $n instance of array(*) }

declare function biject:_is-schema-object($n as item()) as xs:boolean
{
  $n instance of map(*) and not(map:contains($n, "$ref"))
};
