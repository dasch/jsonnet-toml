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

local anyOf(decoders) = function(state)
  local results = std.map(function(decoder) run(decoder, state), decoders);
  local matchingResults = std.filter(didMatch, results);

  if std.length(matchingResults) == 0 then
    fail
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
    noMatch;

local map(f, decoder) = function(state)
  local result = run(decoder, state);

  if didMatch(result) then
    result { value: f(result.value) }
  else
    noMatch;

local map2(f, decoder1, decoder2) = function(state)
  local result1 = run(decoder1, state);

  if didMatch(result1) then
    run(
      map(function(value2) f(result1.value, value2), decoder2),
      result1.newState
    )
  else
    noMatch;

local zeroOrMore(decoder) =
  either(map2(concat, decoder, zeroOrMore(decoder)), succeed([]));

local numeral(state) =
  local intChars =
    std.map(char, ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9']);
  anyOf(intChars);

local numerals = zeroOrMore(numeral);

local int =
  map(std.parseInt, map(function(value) std.join('', value), numerals));

{
  parse: parse,
  succeed: succeed,
  map: map,
  zeroOrMore: zeroOrMore,
  char: char,
  int: int,
}
