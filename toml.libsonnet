local p = import './parser.libsonnet';

local merge(a, b) =
  a + b;

local mergeObjects(objects) =
  std.foldl(merge, objects, {});

local key =
  p.word;

local surroundedByWhitespace(decoder) =
  p.map3(
    function(_1, value, _2) value,
    p.optional(p.whitespace),
    decoder,
    p.optional(p.whitespace),
  );

local value =
  local array =
    p.map3(
      function(_1, elements, _2) elements,
      p.char('['),
      p.separatedBy(surroundedByWhitespace(p.char(',')), value),
      p.char(']')
    );
  p.anyOf([
    p.int,
    p.doubleQuotedString,
    array,
  ]);

local optionalNewline =
  p.optional(p.newline);

local assignment =
  p.followedBy(
    p.andThen(
      key,
      function(keyStr)
        p.andThen(
          surroundedByWhitespace(p.char('=')),
          function(_)
            p.andThen(
              value,
              function(valueStr)
                p.succeed({ [keyStr]: valueStr })
            )
        )
    ),
    optionalNewline
  );

local header =
  p.followedBy(
    p.map3(
      function(_1, keyStr, _2) keyStr,
      p.char('['),
      key,
      p.char(']'),
    ),
    optionalNewline
  );

local table =
  p.andThen(
    header,
    function(headerStr)
      p.andThen(
        p.oneOrMore(assignment),
        function(assignments)
          p.succeed({ [headerStr]: mergeObjects(assignments) })
      )
  );

local emptyline =
  p.map(function(_) {}, p.newline);

local expression =
  p.anyOf([assignment, table, emptyline]);

local expressions =
  p.map(mergeObjects, p.oneOrMore(expression));

local toml =
  expressions;

local parse =
  p.parse(toml);

{
  parse: parse,
}
