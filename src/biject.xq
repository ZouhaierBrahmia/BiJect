xquery version "3.1";

(:======================================================
  BiJect — Unified Wrapper Module
  -----------------------------------------------------
  This module re-exports the factoring and inlining
  submodules under a single namespace URI.
======================================================:)

module namespace biject = "http://example.org/biject";

import module namespace factor = "http://example.org/biject/factor"
  at "biject-factor.xq";

import module namespace inline = "http://example.org/biject/inline"
  at "biject-inline.xq";

(:------------------------------------------------------
  Public API
  - biject:factor($schema as map(*)) as map(*)
  - biject:inline($schema as map(*)) as map(*)
Why here there are not????:
biject:inline($schema as map(*), $options as map(*)) as map(*) see below
biject:factor($schema as map(*), $options as map(*)) as map(*) see below
-------------------------------------------------------:)

declare function biject:factor($schema as map(*)) as map(*)
{
  factor:factor($schema)
};

declare function biject:inline($schema as map(*)) as map(*)
{
  inline:inline($schema)
};

(: Overload to allow options when factoring :)
declare function biject:factor($schema as map(*), $options as map(*)) as map(*)
{
  factor:factor($schema, $options)
};

(: Overload to allow options when inlining :)
declare function biject:inline($schema as map(*), $options as map(*)) as map(*)
{
  inline:inline($schema, $options)
};
