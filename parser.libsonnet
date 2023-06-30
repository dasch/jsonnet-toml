local State(input) = {
  input: input,
  length: std.length(input),
  position: 0,
};

local concat(head, tail) = [head] + tail;

local didMatch(result) = result.matched;

local run(decoder, state) =
  decoder(state);

local match = { matched: true, value: error 'no value specified', newState: 'no new state specified' };

local noMatch = { matched: false, errorMessage: 'did not match', position: 0 };

local pickError(a, b) =
  if a.position >= b.position then a else b;

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
  noMatch { position: state.position };

local eof(state) =
  if state.position == state.length then
    match { newState: state, value: null }
  else
    noMatch { errorMessage: 'did not match end of input', position: state.position };

local char(c) = function(state)
  local nextChar = peek(state);
  if nextChar == c then
    match { newState: advance(state, 1), value: c }
  else
    noMatch { errorMessage: 'expected `%s` but found `%s`' % [c, nextChar], position: state.position };

local notChar(c) = function(state)
  local nextChar = peek(state);
  if nextChar != c then
    match { newState: advance(state, 1), value: nextChar }
  else
    noMatch { errorMessage: 'expected anything but `%s`, but found it' % [c, nextChar], position: state.position };

local either(decoder1, decoder2) = function(state)
  local result1 = run(decoder1, state);

  if didMatch(result1) then
    result1
  else
    local result2 = run(decoder2, state);

    if didMatch(result2) then
      result2
    else
      pickError(result1, result2);

local optional(decoder) =
  either(decoder, succeed(null));

local anyOf(decoders) = function(state)
  if std.length(decoders) == 0 then
    noMatch
  else
    // Doing this instead of recursion to avoid blowing the stack.
    local results = std.map(function(decoder) run(decoder, state), decoders);
    local matchingResults = std.filter(didMatch, results);

    if matchingResults == [] then
      noMatch { errorMessage: 'none of the decoders matched' }
    else
      matchingResults[0];

// Runs the decoder and feeds the matched value to `nextF`, which needs
// to itself evaluate to a decoder.
local andThen(decoder, nextF) = function(state)
  local result = run(decoder, state);

  if didMatch(result) then
    local nextDecoder = nextF(result.value);
    run(nextDecoder, result.newState)
  else
    result;

local map(f, decoder) = function(state)
  local result = run(decoder, state);

  if didMatch(result) then
    result { value: f(result.value) }
  else
    result;

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

local map4(f, decoder1, decoder2, decoder3, decoder4) =
  andThen(
    decoder1,
    function(value1)
      andThen(
        decoder2,
        function(value2)
          andThen(
            decoder3,
            function(value3)
              andThen(
                decoder4,
                function(value4)
                  succeed(f(value1, value2, value3, value4))
              )
          )
      )
  );

local zeroOrMore(decoder) = function(state)
  local step(newState, agg) =
    local result = run(decoder, newState);
    if didMatch(result) then
      step(result.newState, agg + [result.value])
    else
      match { value: agg, newState: newState };

  step(state, []);

local oneOrMore(decoder) =
  map2(concat, decoder, zeroOrMore(decoder));

local seq(decoders) =
  if decoders == [] then
    succeed([])
  else
    map2(concat, decoders[0], seq(decoders[1:]));

local followedBy(decoder1, ignoredDecoder) =
  map2(function(value, ignoredValue) value, decoder1, ignoredDecoder);

local surroundedBy(start, middle, end) =
  map3(
    function(_1, value, _2) value,
    start,
    middle,
    end
  );

local separatedBy(separatorDecoder, elementDecoder) = function(state)
  local helper(newState, elements) =
    local result1 = run(elementDecoder, newState);

    if didMatch(result1) then
      local result2 = run(separatorDecoder, result1.newState);
      local newElements = elements + [result1.value];

      if didMatch(result2) then
        helper(result2.newState, newElements)
      else
        match { value: newElements, newState: result1.newState }
    else
      match { value: elements, newState: newState };

  helper(state, []);

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
  map4: map4,
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
  toString: toString,
  whitespace: whitespace,
  whitespaceChar: whitespaceChar,
  doubleQuotedString: doubleQuotedString,
  numeral: numeral,
  int: int,
}
