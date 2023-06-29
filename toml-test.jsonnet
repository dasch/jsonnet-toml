local toml = import './toml.libsonnet';

local input = |||
  foo = 1
  bar = "hello"
  biz = [1, "hello", 2, [ 3 ]]

  [section]
  boo = 3
|||;


toml.parse(input)
