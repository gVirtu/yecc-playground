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

  def eval(ctx, {:call, {:name, _, name}, args}) do
    arg_values = Enum.map(args, & return_of(ctx, &1))

    apply(App.Functions, name, [ctx | arg_values])
  end

  defp do_add(a, b) when is_number(a) and is_number(b) do
    a + b
  end

  defp do_add(a, b) when is_binary(a) and is_binary(b) do
    a <> b
  end

  def return(ctx, value) do
    %{ctx | return: value}
  end

  def bind(ctx, key, value) do
    %{ctx | bindings: Map.put(ctx.bindings, key, value)}
  end

  defp return_of(ctx, rule), do: eval(ctx, rule).return

  defp binding_of(ctx, key), do: Map.get(ctx.bindings, key)
end
