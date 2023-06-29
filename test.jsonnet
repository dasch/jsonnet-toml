local input = |||
  foo = "bar"
  bar = "baz"

  [section]
  boo = "bah"
|||;

local splitLines(str) = std.split(str, '\n');

local trim(str) = std.stripChars(str, ' ');

local decodeValue(value) =
  if std.startsWith(value, '"') && std.endsWith(value, '"') then
    std.substr(value, 1, std.length(value) - 2)
  else
    error 'invalid value `%s`' % value;

local decodeLine(line) =
  local parts = std.split(line, '=');
  local key = trim(parts[0]);
  local value = trim(parts[1]);

  if std.length(parts) == 2 then
    { [key]: decodeValue(value) }
  else
    {};

local decode(input) =
  local lines = splitLines(input);
  std.foldl(function(state, line) state + decodeLine(line), lines, {});

decode(input)
