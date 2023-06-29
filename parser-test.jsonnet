local parser = import './parser.libsonnet';

local x = parser.char('x');

{
  char: {
    'it parses characters':
      parser.parse(parser.char('x'))('x') == 'x',
  },

  int: {
    'it parses integers':
      local decoder = parser.int;
      parser.parse(decoder)('42') == 42,
  },

  succeed: {
    'it evaluates to the provided value':
      parser.parse(parser.succeed(42))('') == 42,
  },

  map: {
    'it maps the value for a matching decoder':
      local decoder = parser.map(
        std.asciiUpper,
        parser.succeed('hello')
      );
      local value = parser.parse(decoder)('');

      value == 'HELLO',
  },

  zeroOrMore: {
    'it matches zero matches of the decoder':
      local decoder = parser.zeroOrMore(x);
      local value = parser.parse(decoder)('');
      value == [],

    'it matches one match of the decoder':
      local decoder = parser.zeroOrMore(x);
      local value = parser.parse(decoder)('x');
      value == ['x'],

    'it matches multiple matches of the decoder':
      local decoder = parser.zeroOrMore(x);
      local value = parser.parse(decoder)('xxx');
      value == ['x', 'x', 'x'],
  },

  oneOrMore: {
    'it does not match zone occurrences of the decoder':
      local decoder = parser.either(
        parser.oneOrMore(x),
        parser.succeed(42)
      );
      local value = parser.parse(decoder)('');
      value == 42,

    'it matches one occurrence of the decoder':
      local decoder = parser.oneOrMore(x);
      local value = parser.parse(decoder)('x');
      value == ['x'],

    'it matches multiple occurrences of the decoder':
      local decoder = parser.oneOrMore(x);
      local value = parser.parse(decoder)('xxx');
      value == ['x', 'x', 'x'],
  },
}
