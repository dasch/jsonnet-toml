local parser = import './parser.libsonnet';

local pipeline(items) =
  std.foldl(function(last, this) this(last), items[1:], items[0]);

{
  char: {
    'it parses characters':
      parser.parse(parser.char('x'))('x') == 'x',
  },

  int: {
    //'it parses integers': parser.parse(parser.int('42'))('42') == '42',
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
      local decoder = parser.zeroOrMore(parser.char('x'));
      local value = parser.parse(decoder)('');
      value == [],

    'it matches one match of the decoder':
      local decoder = parser.zeroOrMore(parser.char('x'));
      local value = parser.parse(decoder)('x');
      value == ['x'],

    'it matches multiple matches of the decoder':
      local decoder = parser.zeroOrMore(parser.char('x'));
      local value = parser.parse(decoder)('xxx');
      value == ['x', 'x', 'x'],
  },
}
