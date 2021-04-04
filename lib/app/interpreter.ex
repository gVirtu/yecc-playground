defmodule App.Interpreter do
  @moduledoc """
  Evaluates program statements and returns results
  """

  def eval(ctx, {:integer, _line, number}), do:
    return(ctx, number)

  def eval(ctx, {:string, _line, charlist}), do:
    return(ctx, List.to_string(charlist))

  def eval(ctx, {:name, _line, name}) do
    value = binding_of(ctx, name)

    return(ctx, value)
  end

  def eval(ctx, {:op_add, lhs, rhs}), do:
    return(
      ctx,
      do_add(return_of(ctx, lhs), return_of(ctx, rhs))
    )

  def eval(ctx, {:op_sub, lhs, rhs}), do:
    return(
      ctx,
      return_of(ctx, lhs) - return_of(ctx, rhs)
    )

  def eval(ctx, {:op_mul, lhs, rhs}), do:
    return(
      ctx,
      return_of(ctx, lhs) * return_of(ctx, rhs)
    )

  def eval(ctx, {:op_div, lhs, rhs}), do:
    return(
      ctx,
      return_of(ctx, lhs) / return_of(ctx, rhs)
    )

  def eval(ctx, {:assign, {:name, _, name}, rhs}) do
    value = return_of(ctx, rhs)

    ctx
    |> bind(name, value)
    |> return(value)
  end

  defp do_add(a, b) when is_number(a) and is_number(b) do
    a + b
  end

  defp do_add(a, b) when is_binary(a) and is_binary(b) do
    a <> b
  end

  defp return(ctx, value) do
    %{ctx | return: value}
  end

  defp bind(ctx, key, value) do
    %{ctx | bindings: Map.put(ctx.bindings, key, value)}
  end

  defp return_of(ctx, rule), do: eval(ctx, rule).return

  defp binding_of(ctx, key), do: Map.get(ctx.bindings, key)
end
