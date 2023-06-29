local toml = import './toml.libsonnet';

local input = |||
  foo = 1
  bar = 2
  [section]
  boo = 3
|||;


toml.parse(input)
