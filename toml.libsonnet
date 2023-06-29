local p = import './parser.libsonnet';

local key =
  p.word;

local value =
  p.int;

local assignment =
  p.andThen(
    key,
    function(keyStr)
      p.andThen(
        p.whitespace,
        function(_)
          p.andThen(
            p.char('='),
            function(_)
              p.andThen(
                p.whitespace,
                function(_)
                  p.andThen(
                    value,
                    function(valueStr)
                      p.succeed({ key: keyStr, value: valueStr })
                  )
              )
          )
      )
  );

local expression =
  p.andThen(
    assignment,
    function(assignmentValue)
      p.andThen(
        p.optional(p.newline),
        function(_)
          p.succeed(assignmentValue)
      )
  );

local toml =
  p.oneOrMore(expression);

local parse =
  p.parse(toml);

{
  parse: parse,
}
