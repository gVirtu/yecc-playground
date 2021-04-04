defmodule App do
  @moduledoc """
  Documentation for `App`.
  """

  alias App.{Context, Interpreter}

  @doc """
  Evaluates a binary expression and returns the result.
  """
  def evaluate(expr) do
    expr
    |> tokenize()
    |> parse()
    |> interpret()
  end

  defp tokenize(expr) do
    :lexer.string(expr |> String.to_charlist())
  end

  defp parse({:ok, tokens, _end_line_number}) do
    :parser.parse(tokens)
  end

  defp parse(error) do
    error
  end

  defp interpret({:ok, statements}) do
    ctx = Enum.reduce(statements, new_context(), fn statement, ctx ->
      Interpreter.eval(ctx, statement)
    end)

    {:ok, ctx.return}
  end

  defp interpret(error) do
    error
  end

  defp new_context do
    struct(Context)
  end
end
