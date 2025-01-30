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
        {Credo.Check.Design.AliasUsage, false},
        # {Credo.Check.Design.DuplicatedCode, excluded_macros: [], mass_threshold: 120},
        {Credo.Check.Design.TagTODO, false},
        {Credo.Check.Design.TagFIXME, false},
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
        {Credo.Check.Refactor.CyclomaticComplexity, false},
        {Credo.Check.Refactor.DoubleBooleanNegation},
        {Credo.Check.Refactor.FunctionArity},
        # {Credo.Check.Refactor.LongQuoteBlocks, files: %{excluded: ["apps/swagger_doc"]}},
        {Credo.Check.Refactor.LongQuoteBlocks, false},
        {Credo.Check.Refactor.MatchInCondition},
        {Credo.Check.Refactor.NegatedConditionsInUnless},
        {Credo.Check.Refactor.NegatedConditionsWithElse},
        {Credo.Check.Refactor.Nesting, false},
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
        {Credo.Check.Warning.LazyLogging, false},
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
        # TODO: need to be enable in code improvement part
        {Credo.Check.Warning.SpecWithStruct, false},
        {Credo.Check.Warning.MissedMetadataKeyInLoggerConfig},
        # Controversial and experimental checks (opt-in, just remove `, false`)
        {Credo.Check.Refactor.ABCSize, false},
        {Credo.Check.Refactor.AppendSingleItem, false},
        {Credo.Check.Refactor.VariableRebinding, false},
        {Credo.Check.Warning.MapGetUnsafePass},
        {Credo.Check.Consistency.MultiAliasImportRequireUse, false},
        # Deprecated checks (these will be deleted after a grace period)
        {Credo.Check.Readability.Specs},
        {Credo.Check.Readability.ModuleDoc, false}
      ]
    }
  ]
}
