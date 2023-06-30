local p = import './parser.libsonnet';

local mergeObjects(objects) =
  std.foldl(std.mergePatch, objects, {});

local surroundedByWhitespace(decoder) =
  p.surroundedBy(
    p.optional(p.whitespace),
    decoder,
    p.optional(p.whitespace),
  );

local keyPart =
  p.anyOf([
    p.word,
    p.doubleQuotedString,
  ]);

local key =
  p.andThen(
    p.separatedBy(p.char('.'), surroundedByWhitespace(keyPart)),
    function(keys)
      if keys == [] then
        p.fail
      else
        p.succeed(keys)
  );

local dottedKeyToNestedObject(keys, value) =
  if keys == [] then
    value
  else
    local key = keys[0];
    local rest = keys[1:];
    { [key]: dottedKeyToNestedObject(rest, value) };

local value =
  local array =
    p.surroundedBy(
      p.char('['),
      p.separatedBy(p.char(','), value),
      p.char(']')
    );

  local inlineTable =
    local keyValue = p.map3(
      function(keys, _, value) dottedKeyToNestedObject(keys, value),
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
                p.succeed(
                  if std.isArray(keyStr) then
                    dottedKeyToNestedObject(keyStr, valueStr)
                  else
                    { [keyStr]: valueStr }
                )
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
    function(keys, data)
      dottedKeyToNestedObject(keys, mergeObjects(data)),
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
