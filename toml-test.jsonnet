local toml = import './toml.libsonnet';

local input = |||
  foo = 1
  bar = "hello"

  [section]
  boo = 3
|||;


toml.parse(input)
