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
      p.char('='),
      surroundedByWhitespace(value)
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
    p.newline
  );

local header =
  p.followedBy(
    p.map3(
      function(_1, keyStr, _2) keyStr,
      p.char('['),
      key,
      p.char(']'),
    ),
    p.newline
  );

local table =
  p.map2(
    function(headerStr, data)
      { [headerStr]: mergeObjects(data) },
    header,
    p.zeroOrMore(assignment),
  );

local emptyline =
  p.map(function(_) {}, p.followedBy(p.optional(p.whitespace), p.newline));

local expression =
  p.anyOf([table, assignment, emptyline]);

local expressions =
  p.map(mergeObjects, p.oneOrMore(expression));

local toml =
  p.followedBy(expressions, p.eof);

local parse =
  p.parse(toml);

{
  parse: parse,
}
