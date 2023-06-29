local p = import './parser.libsonnet';

local key =
  p.word;

local value =
  p.int;

local optionalNewline =
  p.optional(p.newline);

local assignment =
  p.followedBy(
    p.andThen(
      key,
      function(keyStr)
        p.andThen(
          p.seq([p.whitespace, p.char('='), p.whitespace]),
          function(_)
            p.andThen(
              value,
              function(valueStr)
                p.succeed({ key: keyStr, value: valueStr })
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
          p.succeed({ [headerStr]: assignments })
      )
  );

local expression =
  assignment;

local toml =
  p.oneOrMore(expression);

local parse =
  p.parse(toml);

{
  parse: parse,
}
