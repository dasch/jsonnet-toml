local toml = import './toml.libsonnet';

local input = |||
  foo = 1
  bar = "hello"
  biz = [1, "hello", 2, [ 3 ]]
  addr.street = "Main St"
  addr."city" = "Hometown"

  [section]
  boo = 3
  name = { first = "Joe", last = "Sixpack" }
  name . middle = "Floe"

  [anothersection]
  "one two three" = "fizzle"
  boo = 3
|||;


toml.parse(input)
