local p = import './parser.libsonnet';

local merge(a, b) =
  a + b;

local mergeObjects(objects) =
  std.foldl(merge, objects, {});

local key =
  p.word;

local surroundedByWhitespace(decoder) =
  p.surroundedBy(
    p.optional(p.whitespace),
    decoder,
    p.optional(p.whitespace),
  );

local value =
  local array =
    p.surroundedBy(
      p.char('['),
      p.separatedBy(p.char(','), value),
      p.char(']')
    );

  local inlineTable =
    local keyValue = p.map3(
      function(key, _, value) { [key]: value },
      surroundedByWhitespace(key),
      surroundedByWhitespace(p.char('=')),
      value
    );
    p.map(
      mergeObjects,
      p.surroundedBy(
        p.char('{'),
        p.separatedBy(p.char(','), keyValue),
        p.char('}')
      )
    );

  surroundedByWhitespace(
    p.anyOf([
      p.int,
      p.doubleQuotedString,
      array,
      inlineTable,
    ])
  );

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
  p.map2(
    function(headerStr, assignments) { [headerStr]: mergeObjects(assignments) },
    header,
    p.oneOrMore(assignment),
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
