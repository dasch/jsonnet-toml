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

  whitespace: {
    'it parses whitespace':
      local decoder = parser.whitespace;
      parser.parse(decoder)(' \t \n') == ' \t \n',
  },

  word: {
    'it matches word characters':
      local decoder = parser.word;
      parser.parse(decoder)('hello') == 'hello',

    'it does not match a starting numeral':
      local decoder = parser.either(parser.word, parser.succeed(42));
      parser.parse(decoder)('7hello') == 42,

    'it matches trailing numerals':
      local decoder = parser.word;
      parser.parse(decoder)('hello7') == 'hello7',
  },

  succeed: {
    'it evaluates to the provided value':
      parser.parse(parser.succeed(42))('') == 42,
  },

  optional: {
    'it uses the value if the decoder matches':
      parser.parse(parser.optional(parser.succeed(42)))('') == 42,

    'it evaluates to null if it does not match':
      parser.parse(parser.optional(parser.fail))('') == null,
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
