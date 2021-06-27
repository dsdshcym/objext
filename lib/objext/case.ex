defmodule Objext.Case do
  defmacro __using__(opts) do
    for = Keyword.fetch!(opts, :for)
    case_opts = Keyword.delete(opts, :for)

    quote do
      use unquote(for).Case, unquote(case_opts)
    end
  end

  defmacro defterms(vars, do: block) do
    block = {:quote, [], [[do: block]]}
    subjects_used_by_terms = Keyword.fetch!(vars, :subjects)

    quote do
      # TODO: raise if defterms is not called inside an interface module

      defmodule Case do
        defmacro __using__(opts) do
          subjects_passed_from_test_module = Keyword.get(opts, :subjects, [])

          def_subjects_used_by_terms =
            for name <- unquote(subjects_used_by_terms) do
              quote do
                defp unquote(name)() do
                  raise "Please define #{unquote(name)}/0 by either:\n" <>
                          "1. pass `subjects: [#{unquote(name)}: ...]` option when calling `use Objext.Case`\n" <>
                          "2. define private function `#{unquote(name)}/0` in #{inspect(__MODULE__)}"
                end

                defoverridable([{unquote(name), 0}])
              end
            end

          def_subjects_passed_from_test_module =
            for {name, body} <- subjects_passed_from_test_module do
              quote do
                defp unquote(name)() do
                  unquote(body)
                end
              end
            end

          {:__block__, [],
           [unquote(block) | def_subjects_used_by_terms ++ def_subjects_passed_from_test_module]}
        end
      end
    end
  end
end
