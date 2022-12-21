# Used by "mix format"
[
  inputs: [
    "{mix,.formatter}.exs",
    "{config,lib,test,priv}/**/*.{ex,exs}",
    "{priv}/**/**/*.{ex,exs}"
  ],
  # By default the formatter will turn any definition with out () like below
  locals_without_parens: [
    # Formatter tests
    assert_format: 2,
    assert_format: 3,
    assert_same: 1,
    assert_same: 2,
    line_length: 110,

    # Errors tests
    assert_eval_raise: 3,

    # Mix tests
    in_fixture: 2,
    in_tmp: 2
  ],

  # importing configs from other libraries it is depending
  # import_deps: [:dependency1, :dependency2],

  line_length: 110
]
