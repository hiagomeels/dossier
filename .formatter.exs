# Used by "mix format" and to export configuration.
locals_without_parens = [
  field: 1,
  field: 2,
  field: 3
]

[
  inputs: ["{mix,.formatter,.credo}.exs", "{config,lib,test}/**/*.{ex,exs}"],
  locals_without_parens: locals_without_parens,
  export: [
    locals_without_parens: locals_without_parens
  ]
]