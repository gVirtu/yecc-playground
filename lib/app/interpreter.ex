defmodule App.Interpreter do
  @moduledoc """
  Evaluates program statements and returns results
  """
  require Kernel

  @kernel_un_ops [:+, :-, :not]
  @kernel_bin_ops [:-, :*, :/, :and, :or, :<, :>, :<=, :>=, :==, :!=]

  def eval(ctx, nil), do:
    return(ctx, nil)

  def eval(ctx, {:integer, _line, number}), do:
    return(ctx, number)

  def eval(ctx, {:boolean, _line, boolean}), do:
    return(ctx, boolean)

  def eval(ctx, {:string, _line, charlist}), do:
    return(ctx, charlist |> List.to_string() |> Macro.unescape_string())

  def eval(ctx, {:array, items}), do:
    return(ctx, Enum.map(items, & return_of(ctx, &1)))

  def eval(ctx, {:map, items}), do:
    return(ctx, items |> Enum.map(& kv_pair(ctx, &1)) |> Map.new())

  def eval(ctx, {:var, {:name, _line, name}}) do
    value = binding_of(ctx, name)

    return(ctx, value)
  end

  def eval(ctx, {:access, var_expr, accessor_list}) do
    var_value = return_of(ctx, var_expr)
    accessor_values = Enum.map(accessor_list, & return_of(ctx, &1))

    return(ctx, access(var_value, accessor_values))
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
    function_name = List.to_atom(name)

    apply(App.Functions, function_name, [ctx | arg_values])
  end

  defp do_add(a, b) when is_number(a) and is_number(b) do
    a + b
  end

  defp do_add(a, b) when is_binary(a) and is_binary(b) do
    a <> b
  end

  defp kv_pair(ctx, {{type, _line, key}, expr}) when type in [:name, :string] do
    {List.to_string(key), return_of(ctx, expr)}
  end

  def return(ctx, value) do
    %{ctx | return: value}
  end

  def bind(ctx, key, value) do
    %{ctx | bindings: Map.put(ctx.bindings, key, value)}
  end

  defp return_of(ctx, rule), do: eval(ctx, rule).return

  defp binding_of(ctx, key), do: Map.get(ctx.bindings, key)

  defp access(nil, _accessor), do: nil

  defp access(array, [head | remainder]) when is_list(array) and is_integer(head) do
    array
    |> Enum.at(head)
    |> access(remainder)
  end

  defp access(map, [head | remainder]) when is_map(map) do
    map
    |> Map.get(head)
    |> access(remainder)
  end

  defp access(return, []), do: return

  defp access(_, _), do: nil
end
