defmodule App.Functions do
  @moduledoc """
  Implements functions that are callable by evaluated programs.
  """
  import App.Interpreter, only: [return: 2]

  def to_string(ctx, value) do
    return(ctx, to_string(value))
  end

  def substring(ctx, value, start, len \\ :infinity) do
    return(ctx, String.slice(value, start, len))
  end
end
