local State(input) = {
  input: input,
  length: std.length(input),
  position: 0,
};

local concat(head, tail) = [head] + tail;

local didMatch(result) = result.matched;

local run(decoder, state) =
  decoder(state);

local match = { matched: true };

local noMatch = { matched: false, errorMessage: 'did not match' };

local parse(decoder) = function(input)
  local state = State(input);
  local result = run(decoder, state);

  if didMatch(result) then
    if result.newState.position < std.length(state.input) then
      std.trace('decoder is not exhaustive', result.value)
    else
      result.value
  else
    error 'parsing failed: %s' % result.errorMessage;

local peek(state, n=1) =
  local start = state.position;
  local end = state.position + n;

  state.input[start:end];

local advance(state, n=1) =
  local nextPos = state.position + n;
  assert nextPos <= state.length :
         'cannot advance to %d, input is only %d long' % [nextPos, state.length];
  state { position: nextPos };

local succeed(value) = function(state)
  match { newState: state, value: value };

local fail(state) =
  noMatch;

local eof(state) =
  if state.position == state.length then
    match { newState: state, value: null }
  else
    noMatch;

local char(c) = function(state)
  local nextChar = peek(state);
  if nextChar == c then
    match { newState: advance(state, 1), value: c }
  else
    noMatch { errorMessage: 'expected `%s` but found `%s`' % [c, nextChar] };

local notChar(c) = function(state)
  local nextChar = peek(state);
  if nextChar != c then
    match { newState: advance(state, 1), value: nextChar }
  else
    noMatch { errorMessage: 'expected anything but `%s`, but found it' % [c, nextChar] };

local either(decoder1, decoder2) = function(state)
  local result1 = run(decoder1, state);

  if didMatch(result1) then
    result1
  else
    run(decoder2, state);

local optional(decoder) =
  either(decoder, succeed(null));

local anyOf(decoders) =
  if std.length(decoders) == 0 then
    fail
  else
    either(decoders[0], anyOf(decoders[1:]));

// Runs the decoder and feeds the matched value to `nextF`, which needs
// to itself evaluate to a decoder.
local andThen(decoder, nextF) = function(state)
  local result = run(decoder, state);

  if didMatch(result) then
    local nextDecoder = nextF(result.value);
    run(nextDecoder, result.newState)
  else
    noMatch;

local map(f, decoder) = function(state)
  local result = run(decoder, state);

  if didMatch(result) then
    result { value: f(result.value) }
  else
    noMatch;

local map2(f, decoder1, decoder2) =
  andThen(
    decoder1,
    function(value1)
      andThen(
        decoder2,
        function(value2)
          succeed(f(value1, value2))
      )
  );

local map3(f, decoder1, decoder2, decoder3) =
  andThen(
    decoder1,
    function(value1)
      andThen(
        decoder2,
        function(value2)
          andThen(
            decoder3,
            function(value3)
              succeed(f(value1, value2, value3))
          )
      )
  );

local zeroOrMore(decoder) =
  either(map2(concat, decoder, zeroOrMore(decoder)), succeed([]));

local oneOrMore(decoder) =
  map2(concat, decoder, zeroOrMore(decoder));

local seq(decoders) =
  if decoders == [] then
    succeed([])
  else
    map2(concat, decoders[0], seq(decoders[1:]));

local followedBy(decoder1, ignoredDecoder) =
  andThen(
    decoder1,
    function(value)
      andThen(
        ignoredDecoder,
        function(_)
          succeed(value)
      )
  );

local surroundedBy(start, middle, end) =
  map3(
    function(_1, value, _2) value,
    start,
    middle,
    end
  );

local separatedBy(separatorDecoder, elementDecoder) =
  local restDecoder =
    andThen(
      separatorDecoder,
      function(_)
        separatedBy(separatorDecoder, elementDecoder)
    );

  anyOf([
    map2(concat, elementDecoder, restDecoder),
    map(function(element) [element], elementDecoder),
    succeed([]),
  ]);

local toString(decoder) =
  map(function(value) std.join('', value), decoder);

local whitespaceChar =
  anyOf(std.map(char, [' ', '\t']));

local whitespace =
  toString(oneOrMore(whitespaceChar));

local intChars =
  std.map(char, std.map(std.toString, std.range(0, 9)));

local numeral =
  anyOf(intChars);

local numerals = oneOrMore(numeral);

local int =
  map(std.parseInt, toString(numerals));

local letterChars =
  local chars = [
    'a',
    'b',
    'c',
    'd',
    'e',
    'f',
    'g',
    'h',
    'i',
    'j',
    'k',
    'l',
    'm',
    'n',
    'o',
    'p',
    'q',
    'r',
    's',
    't',
    'u',
    'v',
    'w',
    'x',
    'y',
    'z',
  ];

  std.map(char, chars + std.map(std.asciiUpper, chars));

local letter =
  anyOf(letterChars);

local underscore =
  char('_');

local newline =
  char('\n');

local doubleQuote =
  char('"');

local wordChars =
  intChars + letterChars + [underscore];

local wordChar =
  anyOf(wordChars);

local word =
  toString(map2(concat, either(letter, underscore), zeroOrMore(wordChar)));

local doubleQuotedString =
  map3(
    function(_1, str, _2) str,
    doubleQuote,
    toString(zeroOrMore(notChar('"'))),
    doubleQuote
  );

{
  parse: parse,
  succeed: succeed,
  fail: fail,
  either: either,
  eof: eof,
  anyOf: anyOf,
  andThen: andThen,
  seq: seq,
  map: map,
  map2: map2,
  map3: map3,
  followedBy: followedBy,
  separatedBy: separatedBy,
  surroundedBy: surroundedBy,
  zeroOrMore: zeroOrMore,
  oneOrMore: oneOrMore,
  optional: optional,
  char: char,
  word: word,
  letter: letter,
  underscore: underscore,
  newline: newline,
  whitespace: whitespace,
  whitespaceChar: whitespaceChar,
  doubleQuotedString: doubleQuotedString,
  numeral: numeral,
  int: int,
}
