local State(input) = {
  input: input,
  position: 0,
};

local concat(head, tail) = [head] + tail;

local didMatch(result) = result.matched;

local run(decoder, state) =
  decoder(state);

local match = { matched: true };

local noMatch = { matched: false };

local parse(decoder) = function(input)
  local state = State(input);
  local result = run(decoder, state);

  if didMatch(result) then
    if result.newState.position < std.length(state.input) then
      std.trace('decoder is not exhaustive', result.value)
    else
      result.value
  else
    error 'decoder did not match input';

local peek(state, n=1) =
  local start = state.position;
  local end = state.position + n;

  state.input[start:end];

local advance(state, n=1) =
  state { position: state.position + n };

local succeed(value) = function(state)
  match { newState: state, value: value };

local fail(state) =
  noMatch;

local char(c) = function(state)
  if peek(state) == c then
    match { newState: advance(state, 1), value: c }
  else
    noMatch;

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

local zeroOrMore(decoder) =
  either(map2(concat, decoder, zeroOrMore(decoder)), succeed([]));

local oneOrMore(decoder) =
  map2(concat, decoder, zeroOrMore(decoder));

local toString(decoder) =
  map(function(value) std.join('', value), decoder);

local whitespaceChar =
  anyOf(std.map(char, [' ', '\n', '\t', '\r']));

local whitespace =
  toString(oneOrMore(whitespaceChar));

local intChars =
  std.map(char, std.map(std.toString, std.range(0, 9)));

local numeral =
  anyOf(intChars);

local numerals = zeroOrMore(numeral);

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

local wordChars =
  intChars + letterChars + [underscore];

local wordChar =
  anyOf(wordChars);

local word =
  toString(map2(concat, either(letter, underscore), zeroOrMore(wordChar)));

{
  parse: parse,
  succeed: succeed,
  fail: fail,
  either: either,
  andThen: andThen,
  map: map,
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
  numeral: numeral,
  int: int,
}
