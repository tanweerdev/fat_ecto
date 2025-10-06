%{
  configs: [
    %{
      name: "default",
      files: %{
        included: ["lib/", "src/", "test/", "apps/", "priv/", "config/"],
        excluded: [
          ~r"/_build/",
          ~r"/deps/",
          ~r"/priv/repo/migrations/",
          ~r"/test/support/",
          ~r"/assets/"
        ]
      },
      requires: [".credo/*.ex"],
      strict: true,
      color: true,
      checks: [
        ## Consistency Checks
        {Credo.Check.Consistency.ExceptionNames},
        {Credo.Check.Consistency.LineEndings},
        {Credo.Check.Consistency.ParameterPatternMatching},
        {Credo.Check.Consistency.SpaceAroundOperators},
        {Credo.Check.Consistency.SpaceInParentheses},
        {Credo.Check.Consistency.TabsOrSpaces},
        ## Design Checks
        {Credo.Check.Design.AliasUsage, [priority: :low, if_nested_deeper_than: 2, if_called_more_often_than: 0]},
        {Credo.Check.Design.DuplicatedCode, excluded_macros: [], mass_threshold: 120},
        {Credo.Check.Design.TagTODO, [priority: :low]},
        {Credo.Check.Design.TagFIXME, [priority: :normal]},
        ## Readability Checks
        {Credo.Check.Readability.AliasOrder},
        {Credo.Check.Readability.FunctionNames},
        {Credo.Check.Readability.LargeNumbers, only_greater_than: 99999},
        {Credo.Check.Readability.MaxLineLength, max_length: 120},
        {Credo.Check.Readability.ModuleAttributeNames},
        {Credo.Check.Readability.ModuleDoc},
        {Credo.Check.Readability.ModuleNames},
        {Credo.Check.Readability.ParenthesesOnZeroArityDefs},
        {Credo.Check.Readability.ParenthesesInCondition},
        {Credo.Check.Readability.PredicateFunctionNames},
        {Credo.Check.Readability.PreferImplicitTry},
        {Credo.Check.Readability.RedundantBlankLines},
        {Credo.Check.Readability.Semicolons},
        {Credo.Check.Readability.SpaceAfterCommas},
        {Credo.Check.Readability.StringSigils},
        {Credo.Check.Readability.TrailingBlankLine},
        {Credo.Check.Readability.TrailingWhiteSpace},
        {Credo.Check.Readability.VariableNames},
        {Credo.Check.Readability.WithSingleClause},
        {Credo.Check.Readability.SinglePipe},
        {Credo.Check.Readability.StrictModuleLayout},
        {Credo.Check.Readability.PipeIntoAnonymousFunctions},
        ## Refactoring Opportunities
        {Credo.Check.Refactor.CondStatements},
        {Credo.Check.Refactor.CyclomaticComplexity, [priority: :normal, max_complexity: 12]},
        {Credo.Check.Refactor.DoubleBooleanNegation},
        {Credo.Check.Refactor.FunctionArity},
        {Credo.Check.Refactor.LongQuoteBlocks, [priority: :low, max_line_count: 350]},
        {Credo.Check.Refactor.MatchInCondition},
        {Credo.Check.Refactor.NegatedConditionsInUnless},
        {Credo.Check.Refactor.NegatedConditionsWithElse},
        {Credo.Check.Refactor.Nesting, [priority: :normal, max_nesting: 3]},
        {Credo.Check.Refactor.PipeChainStart},
        {Credo.Check.Refactor.UnlessWithElse},
        {Credo.Check.Refactor.WithClauses},
        {Credo.Check.Refactor.RedundantWithClauseResult},
        {Credo.Check.Refactor.FilterFilter},
        {Credo.Check.Refactor.FilterCount},
        {Credo.Check.Refactor.MapJoin},
        ## Warnings
        {Credo.Check.Warning.BoolOperationOnSameValues},
        {Credo.Check.Warning.ExpensiveEmptyEnumCheck},
        {Credo.Check.Warning.IExPry},
        {Credo.Check.Warning.IoInspect},
        {Credo.Check.Warning.LazyLogging, false},  # Not compatible with Elixir >= 1.7
        {Credo.Check.Warning.OperationOnSameValues},
        {Credo.Check.Warning.OperationWithConstantResult},
        {Credo.Check.Warning.UnusedEnumOperation},
        {Credo.Check.Warning.UnusedFileOperation},
        {Credo.Check.Warning.UnusedKeywordOperation},
        {Credo.Check.Warning.UnusedListOperation},
        {Credo.Check.Warning.UnusedPathOperation},
        {Credo.Check.Warning.UnusedRegexOperation},
        {Credo.Check.Warning.UnusedStringOperation},
        {Credo.Check.Warning.UnusedTupleOperation},
        {Credo.Check.Warning.RaiseInsideRescue},
        {Credo.Check.Warning.SpecWithStruct, [priority: :normal]},
        {Credo.Check.Warning.MissedMetadataKeyInLoggerConfig},
        # Controversial and experimental checks (only those that make sense for open source)
        {Credo.Check.Refactor.ABCSize, false},  # Too controversial for many codebases
        {Credo.Check.Refactor.AppendSingleItem, [priority: :low]},  # Good practice
        {Credo.Check.Refactor.VariableRebinding, false},  # Too strict for Elixir patterns
        {Credo.Check.Warning.MapGetUnsafePass},
        {Credo.Check.Consistency.MultiAliasImportRequireUse, [priority: :low]},
        # Deprecated checks (these will be deleted after a grace period)
        {Credo.Check.Readability.Specs},
        {Credo.Check.Readability.ModuleDoc, false}
      ]
    }
  ]
}
