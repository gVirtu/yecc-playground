defmodule App.Interpreter do
  @moduledoc """
  Evaluates program statements and returns results
  """
  require Kernel

  @kernel_un_ops [:+, :-, :not]
  @kernel_bin_ops [:-, :*, :/, :and, :or, :<, :>, :<=, :>=, :==, :!=]

  def eval(ctx, {:integer, _line, number}), do:
    return(ctx, number)

  def eval(ctx, {:boolean, _line, boolean}), do:
    return(ctx, boolean)

  def eval(ctx, {:string, _line, charlist}), do:
    return(ctx, List.to_string(charlist))

  def eval(ctx, {:name, _line, name}) do
    value = binding_of(ctx, name)

    return(ctx, value)
  end

  Enum.each(@kernel_un_ops, fn op ->
    def eval(ctx, {:op_krn, unquote(op), rhs}), do:
      return(
        ctx,
        Kernel.unquote(op)(return_of(ctx, rhs))
      )
  end)

  Enum.each(@kernel_bin_ops, fn op ->
    def eval(ctx, {:op_krn, unquote(op), lhs, rhs}), do:
      return(
        ctx,
        Kernel.unquote(op)(return_of(ctx, lhs), return_of(ctx, rhs))
      )
  end)

  # Add is overloaded to allow concat
  def eval(ctx, {:op_krn, :+, lhs, rhs}), do:
    return(
      ctx,
      do_add(return_of(ctx, lhs), return_of(ctx, rhs))
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
